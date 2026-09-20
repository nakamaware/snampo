#!/usr/bin/env python3
"""Apple Maps 目的地検索のローカル probe。キーは @kawayama から取得。

```bash
cd backend
uv run python scripts/probe_apple_maps_search.py --fixture hakone --json
```
"""

from __future__ import annotations

import argparse
import json
import os
import sys
from pathlib import Path
from typing import Any

from dotenv import load_dotenv

_BACKEND_DIR = Path(__file__).resolve().parent.parent
if str(_BACKEND_DIR) not in sys.path:
    sys.path.insert(0, str(_BACKEND_DIR))


def _load_env() -> None:
    load_dotenv(_BACKEND_DIR / ".env")


_load_env()
if "GOOGLE_API_KEY" not in os.environ:
    os.environ["GOOGLE_API_KEY"] = "dummy-key-for-apple-maps-search-probe"

from app.application.gateway_interfaces.apple_maps_gateway import (  # noqa: E402
    AppleSearchHit,
)
from app.config import (  # noqa: E402
    LANDMARK_DISTANCE_TOLERANCE_PERCENT,
    LANDMARK_SEARCH_MAX_CALLS,
    LANDMARK_SEARCH_TARGET_COUNT,
)
from app.domain.value_objects import Coordinate  # noqa: E402
from app.infrastructure.gateways.apple_maps_auth import (  # noqa: E402
    AppleMapsCredentialsError,
    AppleMapsTokenProvider,
)
from app.infrastructure.gateways.apple_maps_gateway_impl import (  # noqa: E402
    AppleMapsGatewayImpl,
    build_stratified_query_bag,
    stable_search_seed,
)

DEFAULT_FIXTURES: dict[str, tuple[float, float, int, str]] = {
    # name -> (lat, lng, radius_m, description)
    "hakone": (35.232, 139.107, 2000, "箱根 (観光密集)"),
    "kurihashi": (36.122, 139.700, 2500, "栗橋/久喜付近"),
    "rural": (36.650, 138.190, 3000, "疎な山間寄り (長野寄り)"),
}


def _build_gateway() -> AppleMapsGatewayImpl:
    provider = AppleMapsTokenProvider.from_env(
        team_id=os.environ.get("APPLE_TEAM_ID"),
        key_id=os.environ.get("APPLE_MAPS_KEY_ID"),
        private_key_pem=os.environ.get("APPLE_MAPS_PRIVATE_KEY"),
        private_key_path=os.environ.get("APPLE_MAPS_PRIVATE_KEY_PATH"),
        backend_dir=_BACKEND_DIR,
    )
    return AppleMapsGatewayImpl(provider)


def _print_table(hits: list[AppleSearchHit], *, center_label: str) -> None:
    print(f"\n=== {center_label} ===")
    print(f"{'source':<10} {'distance_m':>10} {'category':<16} {'name':<28} coordinate")
    print("-" * 100)
    if not hits:
        print("(no in-band hits)")
        return
    for hit in hits:
        category = hit.poi_category or "-"
        coord = f"{hit.coordinate.latitude:.5f},{hit.coordinate.longitude:.5f}"
        print(
            f"{hit.source:<10} {hit.distance_m:10.1f} {category:<16} "
            f"{hit.display_name[:28]:<28} {coord}"
        )


def _run_one(
    gateway: AppleMapsGatewayImpl,
    *,
    lat: float,
    lng: float,
    radius_m: int,
    label: str,
    as_json: bool,
) -> dict[str, Any]:
    center = Coordinate(latitude=lat, longitude=lng)
    seed = stable_search_seed(center, radius_m)
    queries = build_stratified_query_bag(seed)
    hits = gateway.search_landmarks_nearby(
        center,
        radius_m,
        target_count=LANDMARK_SEARCH_TARGET_COUNT,
        distance_tolerance_percent=LANDMARK_DISTANCE_TOLERANCE_PERCENT,
        max_calls=LANDMARK_SEARCH_MAX_CALLS,
    )
    payload = {
        "label": label,
        "center": {"latitude": lat, "longitude": lng},
        "radius_m": radius_m,
        "tolerance_percent": LANDMARK_DISTANCE_TOLERANCE_PERCENT,
        "target_count": LANDMARK_SEARCH_TARGET_COUNT,
        "max_calls": LANDMARK_SEARCH_MAX_CALLS,
        "query_bag_preview": queries[:8],
        "hit_count": len(hits),
        "hits": [
            {
                "source": hit.source,
                "name": hit.display_name,
                "category": hit.poi_category,
                "distance_m": round(hit.distance_m, 1),
                "place_id": hit.place_id,
                "coordinate": {
                    "latitude": hit.coordinate.latitude,
                    "longitude": hit.coordinate.longitude,
                },
            }
            for hit in hits
        ],
    }
    if as_json:
        print(json.dumps(payload, ensure_ascii=False, indent=2))
    else:
        _print_table(hits, center_label=label)
        print(
            f"in-band hits={len(hits)} "
            f"(target>={LANDMARK_SEARCH_TARGET_COUNT}, "
            f"band=±{LANDMARK_DISTANCE_TOLERANCE_PERCENT}%, "
            f"max_calls={LANDMARK_SEARCH_MAX_CALLS})"
        )
        print(f"query bag head: {queries[:5]}")
    return payload


def main(argv: list[str] | None = None) -> int:
    """probe を実行する。"""
    parser = argparse.ArgumentParser(
        description="Probe Apple Maps stratified query landmark search (#235)"
    )
    parser.add_argument("--lat", type=float, help="中心緯度")
    parser.add_argument("--lng", type=float, help="中心経度")
    parser.add_argument(
        "--radius-m",
        type=int,
        default=None,
        help="目標距離 (m)。未指定時は fixture 既定値、または custom なら 2000",
    )
    parser.add_argument(
        "--fixture",
        choices=[*DEFAULT_FIXTURES.keys(), "all"],
        help="組み込み地点 (hakone / kurihashi / rural / all)",
    )
    parser.add_argument("--json", action="store_true", help="JSON で出力")
    parser.add_argument(
        "--save",
        action="store_true",
        help="backend/apple_maps_search_probe_result.json に保存",
    )
    args = parser.parse_args(argv)

    try:
        gateway = _build_gateway()
    except AppleMapsCredentialsError as error:
        print(f"エラー: {error}", file=sys.stderr)
        print(
            "Apple Maps 認証情報が無いため probe を中止します。"
            "単体テスト (mocked HTTP) は認証なしで実行できます。",
            file=sys.stderr,
        )
        return 1

    results: list[dict[str, Any]] = []

    if args.lat is not None and args.lng is not None and not args.fixture:
        results.append(
            _run_one(
                gateway,
                lat=args.lat,
                lng=args.lng,
                radius_m=args.radius_m if args.radius_m is not None else 2000,
                label=f"custom ({args.lat},{args.lng})",
                as_json=args.json,
            )
        )
    else:
        if args.fixture and args.fixture != "all":
            targets = {args.fixture: DEFAULT_FIXTURES[args.fixture]}
        else:
            targets = DEFAULT_FIXTURES
        for name, (lat, lng, radius_m, description) in targets.items():
            results.append(
                _run_one(
                    gateway,
                    lat=lat,
                    lng=lng,
                    radius_m=args.radius_m if args.radius_m is not None else radius_m,
                    label=f"{name}: {description}",
                    as_json=args.json,
                )
            )

    if args.save:
        output_path = _BACKEND_DIR / "apple_maps_search_probe_result.json"
        output_path.write_text(
            json.dumps(results, ensure_ascii=False, indent=2) + "\n",
            encoding="utf-8",
        )
        print(f"\nSaved: {output_path}")

    return 0


if __name__ == "__main__":
    try:
        raise SystemExit(main())
    except KeyboardInterrupt:
        raise SystemExit(130) from None
