"""ランドマーク値オブジェクト定義

ランドマーク情報を表す値オブジェクトです。
"""

from pydantic import BaseModel, ConfigDict, Field

from app.domain.value_objects.coordinate import Coordinate


class Landmark(BaseModel):
    """ランドマークを表す値オブジェクト"""

    model_config = ConfigDict(frozen=True)

    place_id: str = Field(min_length=1, description="Places APIのPlace ID")
    display_name: str = Field(min_length=1, description="表示名")
    coordinate: Coordinate = Field(description="座標")
    primary_type: str | None = Field(default=None, description="主要タイプ")
    types: list[str] | None = Field(default=None, description="すべてのタイプ")
    rating: float | None = Field(default=None, ge=0.0, le=5.0, description="評価 (0.0-5.0)")
