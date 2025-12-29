"""画像サイズ値オブジェクト定義"""

from pydantic import BaseModel, ConfigDict, Field


class ImageSize(BaseModel):
    """画像サイズを表す値オブジェクト"""

    model_config = ConfigDict(frozen=True)

    width: int = Field(
        gt=0,
        le=640,
        description="画像幅の値 (1から640の範囲)",
    )

    height: int = Field(
        gt=0,
        le=640,
        description="画像高さの値 (1から640の範囲)",
    )

    def __hash__(self) -> int:
        """ハッシュ値を計算

        Returns:
            int: ハッシュ値
        """
        return hash((self.width, self.height))

    def to_string(self) -> str:
        """Google API用の文字列形式に変換

        Returns:
            str: "WIDTHxHEIGHT"形式の文字列
        """
        return f"{self.width}x{self.height}"
