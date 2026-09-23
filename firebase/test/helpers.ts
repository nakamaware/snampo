import { readFileSync } from "node:fs";
import { resolve } from "node:path";

import {
  initializeTestEnvironment,
  type RulesTestEnvironment,
} from "@firebase/rules-unit-testing";
import { doc, setDoc, Timestamp } from "firebase/firestore";

export const PROJECT_ID = "demo-snampo";

export const HOST = "host-uid";
export const MEMBER = "member-uid";
export const STRANGER = "stranger-uid";

export const ROOM = "ABCD23";
export const SPOT_PLACE = "ChIJC3Cf2PuLGGAROO00ukl8JwA";
export const SPOT_GEO = "geo:35.681236,139.767125";

const HOUR_MS = 60 * 60 * 1000;
const DAY_MS = 24 * HOUR_MS;

export async function setupEnvironment(): Promise<RulesTestEnvironment> {
  const rulesDir = resolve(import.meta.dirname, "..");
  return initializeTestEnvironment({
    projectId: PROJECT_ID,
    firestore: {
      rules: readFileSync(resolve(rulesDir, "firestore.rules"), "utf8"),
      host: "127.0.0.1",
      port: 8080,
    },
    storage: {
      rules: readFileSync(resolve(rulesDir, "storage.rules"), "utf8"),
      host: "127.0.0.1",
      port: 9199,
    },
  });
}

/** 作成時刻から遊べる期限と保持期限を計算したルームの時刻フィールド */
export function roomTimes(createdAtMs: number) {
  return {
    createdAt: Timestamp.fromMillis(createdAtMs),
    expiresAt: Timestamp.fromMillis(createdAtMs + 12 * HOUR_MS),
    deleteAt: Timestamp.fromMillis(createdAtMs + 7 * DAY_MS),
  };
}

type Status = "waiting" | "generating" | "playing" | "finished";

export interface SeedOptions {
  status?: Status;
  /** true なら遊べる期限を過ぎたルームにする (保持期限内) */
  expired?: boolean;
  members?: string[];
}

/** Rules を無効にしてルームとメンバーを作成する */
export async function seedRoom(
  env: RulesTestEnvironment,
  { status = "playing", expired = false, members = [HOST, MEMBER] }: SeedOptions = {},
): Promise<ReturnType<typeof roomTimes>> {
  const createdAtMs = expired ? Date.now() - 13 * HOUR_MS : Date.now();
  const times = roomTimes(createdAtMs);
  await env.withSecurityRulesDisabled(async (context) => {
    const db = context.firestore();
    await setDoc(doc(db, "rooms", ROOM), {
      hostId: HOST,
      status,
      settings: { mode: "random", radius: 1000 },
      ...times,
      ...(status === "playing" || status === "finished"
        ? {
            missionRef: `rooms/${ROOM}/mission/bundle.json`,
            spotIds: [SPOT_PLACE, SPOT_GEO],
            startedAt: times.createdAt,
          }
        : {}),
    });
    for (const uid of members) {
      await setDoc(doc(db, "rooms", ROOM, "members", uid), {
        nickname: uid,
        joinedAt: times.createdAt,
        deleteAt: times.deleteAt,
      });
    }
  });
  return times;
}
