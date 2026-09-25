import {
  assertFails,
  assertSucceeds,
  type RulesTestEnvironment,
} from "@firebase/rules-unit-testing";
import {
  collection,
  doc,
  getDoc,
  getDocs,
  serverTimestamp,
  setDoc,
  Timestamp,
  updateDoc,
} from "firebase/firestore";
import { afterAll, beforeAll, beforeEach, describe, expect, test } from "vitest";

import {
  HOST,
  MEMBER,
  ROOM,
  roomTimes,
  seedRoom,
  SPOT_GEO,
  SPOT_PLACE,
  STRANGER,
  setupEnvironment,
} from "./helpers";

let env: RulesTestEnvironment;

beforeAll(async () => {
  env = await setupEnvironment();
});

afterAll(async () => {
  await env.cleanup();
});

beforeEach(async () => {
  await env.clearFirestore();
});

function db(uid: string | null) {
  return uid === null
    ? env.unauthenticatedContext().firestore()
    : env.authenticatedContext(uid).firestore();
}

function roomRef(uid: string | null, code = ROOM) {
  return doc(db(uid), "rooms", code);
}

function clearRef(uid: string | null, spotId = SPOT_PLACE) {
  return doc(db(uid), "rooms", ROOM, "clears", spotId);
}

function newRoom(hostId: string, createdAtMs = Date.now()) {
  return {
    hostId,
    status: "waiting",
    settings: { mode: "random", radius: 1000 },
    ...roomTimes(createdAtMs),
  };
}

/** アプリがサムネを上げる Storage のパス (geo: の `:` と `,` は `~` にする。SpotId.pathSegment) */
function thumbPath(spotId: string, uid: string, code = ROOM) {
  return `rooms/${code}/thumbs/${spotId.replace(":", "~").replace(",", "~")}/${uid}.jpg`;
}

function newClear(
  uid: string,
  deleteAt: Timestamp,
  extra: object = {},
  spotId = SPOT_PLACE,
) {
  return {
    clearedBy: uid,
    nickname: uid,
    clearedAt: serverTimestamp(),
    thumbPath: thumbPath(spotId, uid),
    deleteAt,
    ...extra,
  };
}

describe("未認証", () => {
  test("ルームの読み書きはすべて拒否する", async () => {
    await seedRoom(env);
    await assertFails(getDoc(roomRef(null)));
    await assertFails(setDoc(roomRef(null, "ZZZZ22"), newRoom(HOST)));
    await assertFails(getDocs(collection(db(null), "rooms", ROOM, "clears")));
    await assertFails(getDoc(doc(db(null), "rooms", ROOM, "members", MEMBER)));
  });
});

describe("rooms の作成", () => {
  test("自分をホストにして作成できる", async () => {
    await assertSucceeds(setDoc(roomRef(HOST), newRoom(HOST)));
  });

  test("他人をホストにして作成できない", async () => {
    await assertFails(setDoc(roomRef(HOST), newRoom(MEMBER)));
  });

  test("期限が作成時刻から計算した値と一致しないと作成できない", async () => {
    const room = newRoom(HOST);
    await assertFails(
      setDoc(roomRef(HOST), {
        ...room,
        expiresAt: Timestamp.fromMillis(room.expiresAt.toMillis() + 1000),
      }),
    );
    await assertFails(
      setDoc(roomRef(HOST), {
        ...room,
        deleteAt: Timestamp.fromMillis(room.deleteAt.toMillis() + 1000),
      }),
    );
  });

  test("作成時刻がサーバ時刻から大きくずれていると作成できない", async () => {
    await assertFails(setDoc(roomRef(HOST), newRoom(HOST, Date.now() - 60 * 60 * 1000)));
  });

  test("紛らわしい文字を含むルームコードでは作成できない", async () => {
    await assertFails(setDoc(roomRef(HOST, "ABCDO2"), newRoom(HOST)));
    await assertFails(setDoc(roomRef(HOST, "abcd23"), newRoom(HOST)));
  });

  test("既存のルームを上書きできない (create-only)", async () => {
    await seedRoom(env);
    await assertFails(setDoc(roomRef(STRANGER), newRoom(STRANGER)));
  });
});

describe("rooms の読み取り", () => {
  test("入室前の存在確認 (get) は認証済みなら可", async () => {
    await seedRoom(env);
    await assertSucceeds(getDoc(roomRef(STRANGER)));
  });

  test("ルームの一覧は取得できない", async () => {
    await seedRoom(env);
    await assertFails(getDocs(collection(db(STRANGER), "rooms")));
  });
});

describe("メンバーでない人", () => {
  test("クリアとメンバーを読めない", async () => {
    await seedRoom(env);
    await assertFails(getDocs(collection(db(STRANGER), "rooms", ROOM, "clears")));
    await assertFails(getDoc(clearRef(STRANGER)));
    await assertFails(getDocs(collection(db(STRANGER), "rooms", ROOM, "members")));
  });

  test("クリアを作成できない", async () => {
    const { deleteAt } = await seedRoom(env);
    await assertFails(setDoc(clearRef(STRANGER), newClear(STRANGER, deleteAt)));
  });
});

describe("members", () => {
  test("本人のメンバーを作成できる", async () => {
    const { deleteAt } = await seedRoom(env, { members: [HOST] });
    await assertSucceeds(
      setDoc(doc(db(MEMBER), "rooms", ROOM, "members", MEMBER), {
        nickname: "たろう",
        joinedAt: serverTimestamp(),
        deleteAt,
      }),
    );
  });

  test("他人のメンバーは作成できない", async () => {
    const { deleteAt } = await seedRoom(env, { members: [HOST] });
    await assertFails(
      setDoc(doc(db(STRANGER), "rooms", ROOM, "members", MEMBER), {
        nickname: "たろう",
        joinedAt: serverTimestamp(),
        deleteAt,
      }),
    );
  });

  test("finished のルームには入室できない", async () => {
    const { deleteAt } = await seedRoom(env, { status: "finished", members: [HOST] });
    await assertFails(
      setDoc(doc(db(MEMBER), "rooms", ROOM, "members", MEMBER), {
        nickname: "たろう",
        joinedAt: serverTimestamp(),
        deleteAt,
      }),
    );
  });

  test("本人は nickname と leftAt だけ変更できる", async () => {
    await seedRoom(env);
    const ref = doc(db(MEMBER), "rooms", ROOM, "members", MEMBER);
    await assertSucceeds(updateDoc(ref, { nickname: "じろう" }));
    await assertSucceeds(updateDoc(ref, { leftAt: serverTimestamp() }));
    await assertFails(updateDoc(ref, { joinedAt: serverTimestamp() }));
    await assertFails(
      updateDoc(doc(db(HOST), "rooms", ROOM, "members", MEMBER), { nickname: "x" }),
    );
  });

  test("抜けた人は入室時刻を更新して入り直せる (人数の上限を入室順で数えるため)", async () => {
    await seedRoom(env);
    const ref = doc(db(MEMBER), "rooms", ROOM, "members", MEMBER);
    await assertSucceeds(updateDoc(ref, { leftAt: serverTimestamp() }));

    // 入室時刻を更新せずに入り直すことはできない
    await assertFails(updateDoc(ref, { leftAt: null }));
    await assertSucceeds(
      updateDoc(ref, { leftAt: null, nickname: "じろう", joinedAt: serverTimestamp() }),
    );
  });

  test("入り直しのときも、nickname / leftAt / joinedAt 以外は変えられない", async () => {
    await seedRoom(env);
    const ref = doc(db(MEMBER), "rooms", ROOM, "members", MEMBER);
    await assertSucceeds(updateDoc(ref, { leftAt: serverTimestamp() }));

    await assertFails(
      updateDoc(ref, {
        leftAt: null,
        joinedAt: serverTimestamp(),
        deleteAt: Timestamp.fromMillis(Date.now() + 30 * 24 * 60 * 60 * 1000),
      }),
    );
  });

  test("抜けていない人は入室時刻を変えられない", async () => {
    await seedRoom(env);
    const ref = doc(db(MEMBER), "rooms", ROOM, "members", MEMBER);
    await assertFails(updateDoc(ref, { leftAt: null, joinedAt: serverTimestamp() }));
  });

  test("finished のルームには入り直せない", async () => {
    await seedRoom(env);
    const ref = doc(db(MEMBER), "rooms", ROOM, "members", MEMBER);
    await assertSucceeds(updateDoc(ref, { leftAt: serverTimestamp() }));
    await env.withSecurityRulesDisabled(async (context) => {
      await updateDoc(doc(context.firestore(), "rooms", ROOM), { status: "finished" });
    });

    await assertFails(
      updateDoc(ref, { leftAt: null, joinedAt: serverTimestamp() }),
    );
  });
});

describe("clears", () => {
  test("メンバーは自分を発見者にしてクリアを作成できる", async () => {
    const { deleteAt } = await seedRoom(env);
    await assertSucceeds(setDoc(clearRef(MEMBER), newClear(MEMBER, deleteAt)));
    await assertSucceeds(getDoc(clearRef(HOST)));
  });

  test("geo: のスポット ID でもクリアを作成できる", async () => {
    const { deleteAt } = await seedRoom(env);
    await assertSucceeds(
      setDoc(clearRef(MEMBER, SPOT_GEO), newClear(MEMBER, deleteAt, {}, SPOT_GEO)),
    );
    expect(thumbPath(SPOT_GEO, MEMBER)).toBe(
      `rooms/${ROOM}/thumbs/geo~35.681236~139.767125/${MEMBER}.jpg`,
    );
  });

  test("2 回目の作成 (上書き) はできない (先着勝ち)", async () => {
    const { deleteAt } = await seedRoom(env);
    await assertSucceeds(setDoc(clearRef(HOST), newClear(HOST, deleteAt)));
    await assertFails(setDoc(clearRef(MEMBER), newClear(MEMBER, deleteAt)));
    await assertFails(setDoc(clearRef(HOST), newClear(HOST, deleteAt)));
  });

  test("他人の uid を clearedBy にして書けない", async () => {
    const { deleteAt } = await seedRoom(env);
    await assertFails(setDoc(clearRef(MEMBER), newClear(HOST, deleteAt)));
  });

  test("spotIds に含まれないスポットはクリアできない", async () => {
    const { deleteAt } = await seedRoom(env);
    await assertFails(setDoc(clearRef(MEMBER, "unknown-spot"), newClear(MEMBER, deleteAt)));
  });

  test("抜けたメンバーはクリアを作成できない", async () => {
    const { deleteAt } = await seedRoom(env);
    await assertSucceeds(
      updateDoc(doc(db(MEMBER), "rooms", ROOM, "members", MEMBER), { leftAt: serverTimestamp() }),
    );
    await assertFails(setDoc(clearRef(MEMBER), newClear(MEMBER, deleteAt)));
  });

  test("playing でなければクリアできない", async () => {
    const { deleteAt } = await seedRoom(env, { status: "finished" });
    await assertFails(setDoc(clearRef(MEMBER), newClear(MEMBER, deleteAt)));
  });

  test("thumbPath のないクリアは作成できない (サムネを上げてから作成する)", async () => {
    const { deleteAt } = await seedRoom(env);
    await assertFails(setDoc(clearRef(MEMBER), newClear(MEMBER, deleteAt, { thumbPath: null })));
    const { thumbPath: _, ...withoutThumb } = newClear(MEMBER, deleteAt);
    await assertFails(setDoc(clearRef(MEMBER), withoutThumb));
  });

  test("thumbPath は、そのスポットの自分のサムネのパスでなければ作成できない", async () => {
    const { deleteAt } = await seedRoom(env);
    const invalid = [
      thumbPath(SPOT_PLACE, HOST),
      thumbPath(SPOT_GEO, MEMBER),
      thumbPath(SPOT_PLACE, MEMBER, "WXYZ89"),
      `rooms/${ROOM}/mission/bundle.json`,
      `https://example.com/${MEMBER}.jpg`,
      "",
      1,
    ];
    for (const path of invalid) {
      await assertFails(setDoc(clearRef(MEMBER), newClear(MEMBER, deleteAt, { thumbPath: path })));
    }
    // geo: のスポットは、`:` と `,` を `~` にしたパス (エンコードしていないパスは不可)
    await assertFails(
      setDoc(
        clearRef(MEMBER, SPOT_GEO),
        newClear(MEMBER, deleteAt, {
          thumbPath: `rooms/${ROOM}/thumbs/${SPOT_GEO}/${MEMBER}.jpg`,
        }),
      ),
    );
  });

  test("発見者の採点 (judgement) を一緒に書ける", async () => {
    const { deleteAt } = await seedRoom(env);
    await assertSucceeds(
      setDoc(
        clearRef(MEMBER),
        newClear(MEMBER, deleteAt, {
          judgement: {
            rank: "good",
            distanceErrorMeters: 12.5,
            headingErrorDegrees: -30,
            guessLatitude: 35.68,
            guessLongitude: 139.76,
            capturedHeading: 270,
            zoomLevel: 2,
          },
        }),
      ),
    );
  });

  test("採点は判定と位置誤差だけでも書ける (向きを取れない端末)", async () => {
    const { deleteAt } = await seedRoom(env);
    await assertSucceeds(
      setDoc(
        clearRef(MEMBER),
        newClear(MEMBER, deleteAt, { judgement: { rank: "miss", distanceErrorMeters: 120 } }),
      ),
    );
  });

  test("壊れた採点は書けない", async () => {
    const { deleteAt } = await seedRoom(env);
    const invalid = [
      { rank: "perfect", distanceErrorMeters: 1 },
      { rank: "good" },
      { rank: "good", distanceErrorMeters: -1 },
      { rank: "good", distanceErrorMeters: "1" },
      { rank: "good", distanceErrorMeters: 1, headingErrorDegrees: 200 },
      { rank: "good", distanceErrorMeters: 1, guessLatitude: 35 },
      { rank: "good", distanceErrorMeters: 1, guessLatitude: 91, guessLongitude: 139 },
      { rank: "good", distanceErrorMeters: 1, capturedHeading: 400 },
      { rank: "good", distanceErrorMeters: 1, zoomLevel: 0 },
      { rank: "good", distanceErrorMeters: 1, zoomLevel: 101 },
      { rank: "good", distanceErrorMeters: 1, zoomLevel: "2" },
      { rank: "good", distanceErrorMeters: 1, photoUrl: "https://example.com" },
      "good",
    ];
    for (const judgement of invalid) {
      await assertFails(setDoc(clearRef(MEMBER), newClear(MEMBER, deleteAt, { judgement })));
    }
  });

  test("作成したクリアは発見者本人も変更できない", async () => {
    const { deleteAt } = await seedRoom(env);
    await assertSucceeds(setDoc(clearRef(MEMBER), newClear(MEMBER, deleteAt)));
    await assertFails(updateDoc(clearRef(MEMBER), { thumbPath: "other.jpg" }));
  });
});

describe("遊べる期限", () => {
  test("期限を過ぎたルームには書けない", async () => {
    const { deleteAt } = await seedRoom(env, { expired: true });
    await assertFails(setDoc(clearRef(MEMBER), newClear(MEMBER, deleteAt)));
    await assertFails(updateDoc(roomRef(HOST), { status: "finished", finishReason: "hostEnded" }));
    await assertFails(
      updateDoc(doc(db(MEMBER), "rooms", ROOM, "members", MEMBER), {
        leftAt: serverTimestamp(),
      }),
    );
    await assertFails(
      setDoc(doc(db(STRANGER), "rooms", ROOM, "members", STRANGER), {
        nickname: "おそい",
        joinedAt: serverTimestamp(),
        deleteAt,
      }),
    );
  });

  test("期限を過ぎても保持期限内なら読める", async () => {
    await seedRoom(env, { expired: true });
    await env.withSecurityRulesDisabled(async (context) => {
      await setDoc(doc(context.firestore(), "rooms", ROOM, "clears", SPOT_PLACE), {
        clearedBy: MEMBER,
        nickname: MEMBER,
        clearedAt: Timestamp.now(),
        thumbPath: thumbPath(SPOT_PLACE, MEMBER),
        deleteAt: Timestamp.now(),
      });
    });
    await assertSucceeds(getDoc(roomRef(MEMBER)));
    await assertSucceeds(getDocs(collection(db(MEMBER), "rooms", ROOM, "clears")));
  });
});

describe("status と settings の変更", () => {
  test("ホストは設定を変更して開始できる", async () => {
    await seedRoom(env, { status: "waiting" });
    await assertSucceeds(
      updateDoc(roomRef(HOST), { settings: { mode: "destination", destination: { lat: 35, lng: 139 } } }),
    );
    await assertSucceeds(updateDoc(roomRef(HOST), { status: "generating" }));
    await assertSucceeds(
      updateDoc(roomRef(HOST), {
        status: "playing",
        missionRef: `rooms/${ROOM}/mission/bundle.json`,
        spotIds: [SPOT_PLACE],
        startedAt: serverTimestamp(),
      }),
    );
  });

  test("メンバーは status と settings を変更できない", async () => {
    await seedRoom(env, { status: "waiting" });
    await assertFails(updateDoc(roomRef(MEMBER), { settings: { mode: "random", radius: 5000 } }));
    await assertFails(updateDoc(roomRef(MEMBER), { status: "generating" }));
  });

  test("waiting 以外では設定を変更できない", async () => {
    await seedRoom(env, { status: "playing" });
    await assertFails(updateDoc(roomRef(HOST), { settings: { mode: "random", radius: 5000 } }));
  });

  test("ホストは途中終了できる", async () => {
    await seedRoom(env);
    await assertSucceeds(
      updateDoc(roomRef(HOST), {
        status: "finished",
        finishReason: "hostEnded",
        finishedAt: serverTimestamp(),
      }),
    );
  });

  test("メンバーは全スポットのクリアでだけ finished にできる", async () => {
    await seedRoom(env);
    await assertFails(
      updateDoc(roomRef(MEMBER), {
        status: "finished",
        finishReason: "hostEnded",
        finishedAt: serverTimestamp(),
      }),
    );
    await assertSucceeds(
      updateDoc(roomRef(MEMBER), {
        status: "finished",
        finishReason: "allCleared",
        finishedAt: serverTimestamp(),
      }),
    );
  });

  test("抜けたメンバーは finished にできない", async () => {
    await seedRoom(env);
    await assertSucceeds(
      updateDoc(doc(db(MEMBER), "rooms", ROOM, "members", MEMBER), { leftAt: serverTimestamp() }),
    );
    await assertFails(
      updateDoc(roomRef(MEMBER), {
        status: "finished",
        finishReason: "allCleared",
        finishedAt: serverTimestamp(),
      }),
    );
  });

  test("メンバーでない人は finished にできない", async () => {
    await seedRoom(env);
    await assertFails(
      updateDoc(roomRef(STRANGER), {
        status: "finished",
        finishReason: "allCleared",
        finishedAt: serverTimestamp(),
      }),
    );
  });

  test("playing の間はミッション (missionRef / spotIds) を変えられない", async () => {
    await seedRoom(env);
    await assertFails(updateDoc(roomRef(HOST), { spotIds: [SPOT_GEO, SPOT_PLACE] }));
    await assertFails(
      updateDoc(roomRef(HOST), { missionRef: `rooms/${ROOM}/mission/other.json` }),
    );
    await assertFails(updateDoc(roomRef(HOST), { startedAt: serverTimestamp() }));
  });

  test("ミッションは generating から playing にするときだけ設定できる", async () => {
    await seedRoom(env, { status: "waiting" });
    await assertFails(updateDoc(roomRef(HOST), { spotIds: [SPOT_PLACE] }));
  });

  test("状態を変えずに終了や生成失敗の情報を書き換えられない", async () => {
    await seedRoom(env);
    await assertFails(updateDoc(roomRef(HOST), { finishReason: "hostEnded" }));
    await assertFails(updateDoc(roomRef(HOST), { finishedAt: serverTimestamp() }));
    await assertFails(updateDoc(roomRef(HOST), { generationError: "x" }));
  });

  test("生成に失敗したら、waiting に戻すときに理由を書ける", async () => {
    await seedRoom(env, { status: "generating" });
    await assertSucceeds(
      updateDoc(roomRef(HOST), { status: "waiting", generationError: "API error" }),
    );
  });

  test("finished から戻せない", async () => {
    await seedRoom(env, { status: "finished" });
    await assertFails(updateDoc(roomRef(HOST), { status: "playing" }));
  });
});
