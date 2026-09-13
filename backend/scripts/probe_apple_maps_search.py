#!/usr/bin/env python3
"""Apple Maps Server API の層別クエリ近傍検索をローカルから検証する probe。

#235 目的地ランドマーク検索 (本番は LandmarkSearchService → AppleMapsGateway)。
Directions / Street View / Roads / 中間地点検索は Google のまま。

## 事前準備 (Maps Server API キー)

1. [Apple Developer](https://developer.apple.com/account) にログイン
2. Identifiers → Maps IDs で Maps ID を作成
3. Keys → MapKit JS を有効化し Maps ID を紐づけて `.p8` を Download
4. `backend/.env.example` を参考に設定

環境変数:
  APPLE_TEAM_ID
  APPLE_MAPS_KEY_ID
  APPLE_MAPS_PRIVATE_KEY       (PEM 文字列。Cloud Run / Secret Manager 向け。優先)
  APPLE_MAPS_PRIVATE_KEY_PATH  (ローカル .p8。PEM が無いときのフォールバック)
  APPLE_MAPS_ID                (任意。鍵作成時の Maps ID 追跡用)

## 使い方

```bash
cd backend
uv run python scripts/probe_apple_maps_search.py
uv run python scripts/probe_apple_maps_search.py --lat 35.232 --lng 139.107 --radius-m 2000
uv run python scripts/probe_apple_maps_search.py --fixture all --json
```

認証情報が無い場合は非ゼロ終了し、単体テストには影響しない。

## 成功の目安

箱根 (~35.232, 139.107) や栗橋/久喜 (~36.122, 139.700) で、目標距離 ±15% 帯に
複数の POI が返り、`source` が `query` / `fanout` のどちらで拾えたか確認できること。
"""

from __future__ import annotations

import argparse
import json
import os
import sys
from pathlib import Path

from dotenv import load_dotenv

# backend/ を import パスへ
_BACKEND_DIR = Path(__file__).resolve().parent.parent
if str(_BACKEND_DIR) not in sys.path:
    sys.path.insert(0, str(_BACKEND_DIR))

# app.config が GOOGLE_API_KEY を要求するため、未設定時はダミーを入れる (本スクリプトでは未使用)
if "GOOGLE_API_KEY" not in os.environ:
    os.environ["GOOGLE_API_KEY"] = "dummy-key-for-apple-maps-search-probe"

from app.config import (  # noqa: E402
    APPLE_MAPS_KEY_ID,
    APPLE_MAPS_PRIVATE_KEY,
    APPLE_MAPS_PRIVATE_KEY_PATH,
    APPLE_TEAM_ID,
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


def _load_env() -> None:
    load_dotenv(_BACKEND_DIR / ".env")


def _build_gateway() -> AppleMapsGatewayImpl:
    provider = AppleMapsTokenProvider.from_env(
        team_id=APPLE_TEAM_ID or os.environ.get("APPLE_TEAM_ID"),
        key_id=APPLE_MAPS_KEY_ID or os.environ.get("APPLE_MAPS_KEY_ID"),
        private_key_pem=APPLE_MAPS_PRIVATE_KEY or os.environ.get("APPLE_MAPS_PRIVATE_KEY"),
        private_key_path=APPLE_MAPS_PRIVATE_KEY_PATH
        or os.environ.get("APPLE_MAPS_PRIVATE_KEY_PATH"),
        backend_dir=_BACKEND_DIR,
    )
    return AppleMapsGatewayImpl(provider)


def _print_table(hits: list, *, center_label: str) -> None:
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
) -> dict:
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

    _load_env()

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

    results: list[dict] = []

    if args.fixture == "all" or (args.fixture is None and args.lat is None):
        for name, (lat, lng, radius_m, description) in DEFAULT_FIXTURES.items():
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
    elif args.fixture:
        lat, lng, radius_m, description = DEFAULT_FIXTURES[args.fixture]
        results.append(
            _run_one(
                gateway,
                lat=lat,
                lng=lng,
                radius_m=args.radius_m if args.radius_m is not None else radius_m,
                label=f"{args.fixture}: {description}",
                as_json=args.json,
            )
        )
    elif args.lat is not None and args.lng is not None:
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
        parser.error("--lat/--lng か --fixture を指定してください")

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
