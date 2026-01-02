"""ルート関連のドメイン例外

ルート生成で発生する例外を定義します。
"""


class RouteGenerationError(Exception):
    """ルート生成エラー

    ルート生成処理が失敗した場合に発生します。
    """

    def __init__(self, message: str, retry_count: int | None = None) -> None:
        """初期化

        Args:
            message: エラーメッセージ
            retry_count: 試行回数 (オプション)
        """
        self.message = message
        self.retry_count = retry_count
        super().__init__(self.message)
