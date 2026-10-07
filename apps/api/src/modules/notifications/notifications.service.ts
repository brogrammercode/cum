import { cert, getApps, initializeApp } from "firebase-admin/app";
import { getMessaging } from "firebase-admin/messaging";

import { env } from "../../config/env";
import { prisma } from "../../lib/prisma";

function messaging() {
  if (
    !env.firebaseProjectId ||
    !env.firebaseClientEmail ||
    !env.firebasePrivateKey
  )
    return null;
  const app =
    getApps()[0] ??
    initializeApp({
      credential: cert({
        projectId: env.firebaseProjectId,
        clientEmail: env.firebaseClientEmail,
        privateKey: env.firebasePrivateKey,
      }),
    });
  return getMessaging(app);
}

export async function notifyUsers(
  userIds: string[],
  title: string,
  body: string,
  data: Record<string, string>,
) {
  const tokens = await prisma.deviceToken.findMany({
    where: { user_id: { in: userIds } },
  });
  const service = messaging();
  if (!service || tokens.length === 0) return;
  try {
    await service.sendEachForMulticast({
      tokens: tokens.map((token) => token.token),
      notification: { title, body },
      data,
    });
  } catch (_) {
    // Push delivery must not make the originating domain action fail.
    return;
  }
}

export async function registerDevice(
  userId: string,
  token: string,
  platform: string,
) {
  return prisma.deviceToken.upsert({
    where: { token },
    create: { user_id: userId, token, platform },
    update: { user_id: userId, platform, updated_at: new Date() },
  });
}

export async function notifyFriendsAboutActivity(
  userId: string,
  gameName: string,
  action: "started" | "stopped",
) {
  const friendships = await prisma.friendship.findMany({
    where: {
      status: "ACCEPTED",
      OR: [{ requester_id: userId }, { addressee_id: userId }],
    },
    include: { requester: true, addressee: true },
  });
  const friendIds = friendships.map((friendship) =>
    friendship.requester_id === userId
      ? friendship.addressee_id
      : friendship.requester_id,
  );
  await notifyUsers(
    friendIds,
    action === "started" ? "Friend started playing" : "Friend stopped playing",
    action === "started"
      ? `Someone in your Cruz squad is playing ${gameName}.`
      : `A Cruz friend stopped playing ${gameName}.`,
    { type: "presence", game_name: gameName, action },
  );
}
