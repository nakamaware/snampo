"""画像サイズ値オブジェクト定義"""

from dataclasses import dataclass

from app.domain.value_objects.image_height import ImageHeight
from app.domain.value_objects.image_width import ImageWidth


@dataclass(frozen=True)
class ImageSize:
    """画像サイズを表す値オブジェクト"""

    width: ImageWidth
    height: ImageHeight

    def to_string(self) -> str:
        """Google API用の文字列形式に変換

        Returns:
            str: "WIDTHxHEIGHT"形式の文字列
        """
        return f"{self.width.to_int()}x{self.height.to_int()}"

    def __hash__(self) -> int:
        """ハッシュ値を計算 (lru_cacheで使用するため)

        Returns:
            int: ハッシュ値
        """
        return hash((self.width, self.height))
