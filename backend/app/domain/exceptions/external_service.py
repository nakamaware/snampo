"""外部サービス関連のドメイン例外

外部サービス (Google Maps APIなど) との通信で発生する例外を定義します。
"""


class ExternalServiceError(Exception):
    """外部サービスで発生した一般的なエラー

    外部サービスとの通信で発生したエラーを表します。
    """

    def __init__(self, message: str, service_name: str | None = None) -> None:
        """初期化

        Args:
            message: エラーメッセージ
            service_name: サービス名 (オプション)
        """
        self.message = message
        self.service_name = service_name
        super().__init__(self.message)


class ExternalServiceTimeoutError(ExternalServiceError):
    """外部サービスのタイムアウトエラー

    外部サービスへのリクエストがタイムアウトした場合に発生します。
    """

    def __init__(self, message: str, service_name: str | None = None) -> None:
        """初期化

        Args:
            message: エラーメッセージ
            service_name: サービス名 (オプション)
        """
        super().__init__(message, service_name)


class ExternalServiceValidationError(ExternalServiceError):
    """外部サービスのバリデーションエラー

    外部サービスからのレスポンスが無効または不完全な場合に発生します。
    """

    def __init__(self, message: str, service_name: str | None = None) -> None:
        """初期化

        Args:
            message: エラーメッセージ
            service_name: サービス名 (オプション)
        """
        super().__init__(message, service_name)
