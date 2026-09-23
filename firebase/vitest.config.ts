import { defineConfig } from "vitest/config";

export default defineConfig({
  test: {
    include: ["test/**/*.test.ts"],
    // 1 つのエミュレータを共有するため、テストファイルを直列に実行する
    fileParallelism: false,
    testTimeout: 20000,
    hookTimeout: 20000,
  },
});
