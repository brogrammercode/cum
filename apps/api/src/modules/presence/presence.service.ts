import { prisma } from "../../lib/prisma";
import { notifyFriendsAboutActivity } from "../notifications/notifications.service";

export async function start(
  userId: string,
  packageName: string,
  requestedName?: string,
) {
  const game = await prisma.userGame.findFirst({
    where: { user_id: userId, package_name: packageName },
  });
  if (!game) return null;
  const current = await prisma.presenceSession.findFirst({
    where: { user_id: userId, package_name: packageName, status: "PLAYING" },
    orderBy: { started_at: "desc" },
  });
  if (current) {
    await prisma.presenceSession.update({
      where: { id: current.id },
      data: { updated_at: new Date() },
    });
    return current;
  }
  await prisma.presenceSession.updateMany({
    where: { user_id: userId, status: "PLAYING" },
    data: { status: "ENDED", ended_at: new Date() },
  });
  const session = await prisma.presenceSession.create({
    data: {
      user_id: userId,
      package_name: packageName,
      game_name: requestedName || game.name,
    },
  });
  await notifyFriendsAboutActivity(userId, session.game_name, "started");
  return session;
}

export async function heartbeat(userId: string, packageName: string) {
  return prisma.presenceSession.updateMany({
    where: { user_id: userId, package_name: packageName, status: "PLAYING" },
    data: { updated_at: new Date() },
  });
}

export async function stop(userId: string, packageName?: string) {
  const session = await prisma.presenceSession.findFirst({
    where: {
      user_id: userId,
      status: "PLAYING",
      ...(packageName ? { package_name: packageName } : {}),
    },
    orderBy: { started_at: "desc" },
  });
  if (!session) return null;
  const updated = await prisma.presenceSession.update({
    where: { id: session.id },
    data: { status: "ENDED", ended_at: new Date() },
  });
  await notifyFriendsAboutActivity(userId, updated.game_name, "stopped");
  return updated;
}

export async function feed(userId: string) {
  const friends = await prisma.friendship.findMany({
    where: {
      status: "ACCEPTED",
      OR: [{ requester_id: userId }, { addressee_id: userId }],
    },
  });
  const friendIds = friends.map((friend) =>
    friend.requester_id === userId ? friend.addressee_id : friend.requester_id,
  );
  const sessions = await prisma.presenceSession.findMany({
    where: { user_id: { in: friendIds } },
    include: { user: true },
    orderBy: { started_at: "desc" },
    take: 100,
  });
  return sessions.map((session) => ({
    id: session.id,
    friend: { name: session.user.name, gamer_tag: session.user.gamer_tag },
    game: { name: session.game_name },
    status: session.status,
    started_at: session.started_at,
    ended_at: session.ended_at,
  }));
}
