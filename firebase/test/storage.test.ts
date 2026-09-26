import {
  assertFails,
  assertSucceeds,
  type RulesTestEnvironment,
} from "@firebase/rules-unit-testing";
import { getBytes, ref, uploadBytes } from "firebase/storage";
import { afterAll, beforeAll, beforeEach, describe, test } from "vitest";

import { HOST, MEMBER, ROOM, seedRoom, SPOT_GEO, SPOT_PLACE, STRANGER, setupEnvironment } from "./helpers";

let env: RulesTestEnvironment;

const JPEG = { contentType: "image/jpeg" };
const JSON_TYPE = { contentType: "application/json" };
const smallImage = new Uint8Array([0xff, 0xd8, 0xff, 0xd9]);

beforeAll(async () => {
  env = await setupEnvironment();
});

afterAll(async () => {
  await env.cleanup();
});

beforeEach(async () => {
  await env.clearFirestore();
  await env.clearStorage();
});

function storage(uid: string | null) {
  return uid === null
    ? env.unauthenticatedContext().storage()
    : env.authenticatedContext(uid).storage();
}

function thumbPath(spotId: string, uid: string) {
  return `rooms/${ROOM}/thumbs/${spotId}/${uid}.jpg`;
}

const bundlePath = `rooms/${ROOM}/mission/bundle.json`;
const missionImagePath = (spotId: string) => `rooms/${ROOM}/mission/images/${spotId}.jpg`;

async function seedObject(path: string) {
  await env.withSecurityRulesDisabled(async (context) => {
    await uploadBytes(ref(context.storage(), path), smallImage, JPEG);
  });
}

describe("未認証", () => {
  test("すべて拒否する", async () => {
    await seedRoom(env);
    await seedObject(missionImagePath(SPOT_PLACE));
    await assertFails(getBytes(ref(storage(null), missionImagePath(SPOT_PLACE))));
    await assertFails(uploadBytes(ref(storage(null), thumbPath(SPOT_PLACE, MEMBER)), smallImage, JPEG));
  });
});

describe("サムネ", () => {
  test("メンバーは自分の uid のパスに上げられる", async () => {
    await seedRoom(env);
    await assertSucceeds(
      uploadBytes(ref(storage(MEMBER), thumbPath(SPOT_PLACE, MEMBER)), smallImage, JPEG),
    );
  });

  test("geo: のスポット ID のパスにも上げられる", async () => {
    await seedRoom(env);
    await assertSucceeds(
      uploadBytes(ref(storage(MEMBER), thumbPath(SPOT_GEO, MEMBER)), smallImage, JPEG),
    );
    await assertSucceeds(getBytes(ref(storage(HOST), thumbPath(SPOT_GEO, MEMBER))));
  });

  test("他人の uid のパスには上げられない", async () => {
    await seedRoom(env);
    await assertFails(
      uploadBytes(ref(storage(MEMBER), thumbPath(SPOT_PLACE, HOST)), smallImage, JPEG),
    );
  });

  test("メンバーでない人は上げられず、読めない", async () => {
    await seedRoom(env);
    await seedObject(thumbPath(SPOT_PLACE, MEMBER));
    await assertFails(
      uploadBytes(ref(storage(STRANGER), thumbPath(SPOT_PLACE, STRANGER)), smallImage, JPEG),
    );
    await assertFails(getBytes(ref(storage(STRANGER), thumbPath(SPOT_PLACE, MEMBER))));
  });

  test("image/jpeg 以外やサイズの上限を超えるものは上げられない", async () => {
    await seedRoom(env);
    await assertFails(
      uploadBytes(ref(storage(MEMBER), thumbPath(SPOT_PLACE, MEMBER)), smallImage, {
        contentType: "image/png",
      }),
    );
    await assertFails(
      uploadBytes(
        ref(storage(MEMBER), thumbPath(SPOT_PLACE, MEMBER)),
        new Uint8Array(1024 * 1024 + 1),
        JPEG,
      ),
    );
  });

  test("遊べる期限を過ぎたら上げられないが、読める", async () => {
    await seedRoom(env, { expired: true });
    await seedObject(thumbPath(SPOT_PLACE, HOST));
    await assertFails(
      uploadBytes(ref(storage(MEMBER), thumbPath(SPOT_PLACE, MEMBER)), smallImage, JPEG),
    );
    await assertSucceeds(getBytes(ref(storage(MEMBER), thumbPath(SPOT_PLACE, HOST))));
  });
});

describe("ミッション", () => {
  test("ホストはバンドルと画像を上げられる", async () => {
    await seedRoom(env, { status: "generating" });
    await assertSucceeds(
      uploadBytes(ref(storage(HOST), bundlePath), new TextEncoder().encode("{}"), JSON_TYPE),
    );
    await assertSucceeds(
      uploadBytes(ref(storage(HOST), missionImagePath(SPOT_GEO)), smallImage, JPEG),
    );
  });

  test("ホスト以外はミッション画像を上げられない", async () => {
    await seedRoom(env, { status: "generating" });
    await assertFails(
      uploadBytes(ref(storage(MEMBER), missionImagePath(SPOT_PLACE)), smallImage, JPEG),
    );
  });

  test("メンバーは読めて、メンバーでない人は読めない", async () => {
    await seedRoom(env);
    await seedObject(missionImagePath(SPOT_PLACE));
    await assertSucceeds(getBytes(ref(storage(MEMBER), missionImagePath(SPOT_PLACE))));
    await assertFails(getBytes(ref(storage(STRANGER), missionImagePath(SPOT_PLACE))));
  });
});
