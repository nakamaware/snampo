"""pytestの共通設定ファイル"""

import os

# app.config は import 時に GOOGLE_API_KEY を要求する。単体テストでは実キー不要。
os.environ.setdefault("GOOGLE_API_KEY", "dummy-key-for-tests")
