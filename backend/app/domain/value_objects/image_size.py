"""画像サイズ値オブジェクト定義"""

from dataclasses import dataclass


@dataclass(frozen=True)
class ImageHeight:
    """画像高さを表す値オブジェクト"""

    value: int

    def __post_init__(self) -> None:
        """画像高さの範囲を検証

        Raises:
            ValueError: 画像高さが1から640の範囲外の場合
        """
        if not (0 < self.value <= 640):
            raise ValueError(f"ImageHeight must be between 1 and 640, got {self.value}")

    def to_int(self) -> int:
        """int型に変換

        Returns:
            int: 画像高さの値
        """
        return self.value

    def __hash__(self) -> int:
        """ハッシュ値を計算 (lru_cacheで使用するため)

        Returns:
            int: ハッシュ値
        """
        return hash(self.value)


@dataclass(frozen=True)
class ImageWidth:
    """画像幅を表す値オブジェクト"""

    value: int

    def __post_init__(self) -> None:
        """画像幅の範囲を検証

        Raises:
            ValueError: 画像幅が1から640の範囲外の場合
        """
        if not (0 < self.value <= 640):
            raise ValueError(f"ImageWidth must be between 1 and 640, got {self.value}")

    def to_int(self) -> int:
        """int型に変換

        Returns:
            int: 画像幅の値
        """
        return self.value

    def __hash__(self) -> int:
        """ハッシュ値を計算 (lru_cacheで使用するため)

        Returns:
            int: ハッシュ値
        """
        return hash(self.value)


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
