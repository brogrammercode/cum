import { FriendshipStatus } from "@prisma/client";

import { ForbiddenError, NotFoundError } from "../../lib/errors";
import { prisma } from "../../lib/prisma";
import { presentUser } from "../auth/auth.service";
import { notifyUsers } from "../notifications/notifications.service";

export async function search(userId: string, query: string) {
  const users = await prisma.user.findMany({
    where: {
      id: { not: userId },
      status: "ACTIVE",
      OR: [
        { email: { contains: query, mode: "insensitive" } },
        { name: { contains: query, mode: "insensitive" } },
        { gamer_tag: { contains: query, mode: "insensitive" } },
      ],
    },
    take: 25,
  });
  const relationships = await prisma.friendship.findMany({
    where: { OR: [{ requester_id: userId }, { addressee_id: userId }] },
  });
  return Promise.all(
    users.map(async (user) => ({
      ...(await presentUser(user)),
      relationship_status: relationshipFor(relationships, userId, user.id),
    })),
  );
}

export async function list(userId: string) {
  const relations = await prisma.friendship.findMany({
    where: {
      status: "ACCEPTED",
      OR: [{ requester_id: userId }, { addressee_id: userId }],
    },
    include: { requester: true, addressee: true },
  });
  return Promise.all(
    relations.map(async (relation) => {
      const friend =
        relation.requester_id === userId
          ? relation.addressee
          : relation.requester;
      return {
        ...(await presentUser(friend)),
        relationship_status: "ACCEPTED",
      };
    }),
  );
}

export async function send(userId: string, addresseeId: string) {
  if (userId === addresseeId)
    throw new ForbiddenError("You cannot add yourself");
  const user = await prisma.user.findUnique({ where: { id: addresseeId } });
  if (!user) throw new NotFoundError("Cruz player not found");
  const existing = await prisma.friendship.findFirst({
    where: {
      OR: [
        { requester_id: userId, addressee_id: addresseeId },
        { requester_id: addresseeId, addressee_id: userId },
      ],
    },
  });
  if (existing) {
    if (existing.status === "REJECTED" || existing.status === "CANCELLED") {
      return prisma.friendship.update({
        where: { id: existing.id },
        data: {
          requester_id: userId,
          addressee_id: addresseeId,
          status: "PENDING",
        },
      });
    }
    return existing;
  }
  const request = await prisma.friendship.create({
    data: { requester_id: userId, addressee_id: addresseeId },
  });
  await notifyUsers(
    [addresseeId],
    "New friend request",
    "Someone wants to connect with you on Cruz.",
    { type: "friend_request" },
  );
  return request;
}

export async function requests(
  userId: string,
  direction: "incoming" | "outgoing",
) {
  const relations = await prisma.friendship.findMany({
    where:
      direction === "incoming"
        ? { addressee_id: userId, status: "PENDING" }
        : { requester_id: userId, status: "PENDING" },
    include: { requester: true, addressee: true },
    orderBy: { created_at: "desc" },
  });
  return Promise.all(
    relations.map(async (relation) => ({
      id: relation.id,
      status: relation.status,
      created_at: relation.created_at,
      user: await presentUser(
        direction === "incoming" ? relation.requester : relation.addressee,
      ),
    })),
  );
}

export async function respond(
  userId: string,
  requestId: string,
  action: "accept" | "reject" | "block",
) {
  const relation = await prisma.friendship.findUnique({
    where: { id: requestId },
  });
  if (!relation || relation.addressee_id !== userId)
    throw new NotFoundError("Friend request not found");
  const status: FriendshipStatus =
    action === "accept"
      ? "ACCEPTED"
      : action === "block"
        ? "BLOCKED"
        : "REJECTED";
  return prisma.friendship.update({
    where: { id: requestId },
    data: { status },
  });
}

export async function cancel(userId: string, requestId: string) {
  const relation = await prisma.friendship.findUnique({
    where: { id: requestId },
  });
  if (!relation || relation.requester_id !== userId || relation.status !== "PENDING")
    throw new NotFoundError("Friend request not found");
  return prisma.friendship.update({
    where: { id: requestId },
    data: { status: FriendshipStatus.CANCELLED },
  });
}

function relationshipFor(
  relations: Array<{
    requester_id: string;
    addressee_id: string;
    status: FriendshipStatus;
  }>,
  userId: string,
  otherId: string,
) {
  const relation = relations.find(
    (item) =>
      (item.requester_id === userId && item.addressee_id === otherId) ||
      (item.requester_id === otherId && item.addressee_id === userId),
  );
  return relation?.status ?? "NONE";
}
