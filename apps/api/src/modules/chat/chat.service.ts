import { ForbiddenError, NotFoundError } from "../../lib/errors";
import { prisma } from "../../lib/prisma";
import { notifyUsers } from "../notifications/notifications.service";

export async function listConversations(userId: string) {
  const rows = await prisma.conversation.findMany({
    where: { members: { some: { user_id: userId } } },
    include: {
      members: { include: { user: true } },
      messages: { orderBy: { created_at: "desc" }, take: 1 },
    },
    orderBy: { updated_at: "desc" },
  });
  const unread = await prisma.message.groupBy({
    by: ["conversation_id"],
    where: {
      conversation_id: { in: rows.map((row) => row.id) },
      sender_id: { not: userId },
      read_at: null,
    },
    _count: { _all: true },
  });
  const unreadByConversation = new Map(
    unread.map((item) => [item.conversation_id, item._count._all]),
  );
  return rows.map((row) => ({
    id: row.id,
    title:
      row.title ||
      row.members
        .filter((member) => member.user_id !== userId)
        .map((member) => member.user.name)
        .join(", "),
    member_count: row.members.length,
    last_message: row.messages[0]?.body ?? "",
    updated_at: row.updated_at,
    unread_count: unreadByConversation.get(row.id) ?? 0,
  }));
}

export async function markRead(userId: string, conversationId: string) {
  await assertMember(userId, conversationId);
  return prisma.message.updateMany({
    where: {
      conversation_id: conversationId,
      sender_id: { not: userId },
      read_at: null,
    },
    data: { read_at: new Date() },
  });
}

export async function createConversation(
  userId: string,
  title: string | undefined,
  memberIds: string[],
) {
  const ids = [...new Set([userId, ...memberIds])];
  return prisma.conversation.create({
    data: {
      title,
      is_group: ids.length > 2,
      members: { create: ids.map((id) => ({ user_id: id })) },
    },
  });
}

async function assertMember(userId: string, conversationId: string) {
  const member = await prisma.conversationMember.findUnique({
    where: {
      conversation_id_user_id: {
        conversation_id: conversationId,
        user_id: userId,
      },
    },
  });
  if (!member)
    throw new ForbiddenError("You are not a member of this conversation");
}

export async function messages(userId: string, conversationId: string) {
  await assertMember(userId, conversationId);
  const rows = await prisma.message.findMany({
    where: { conversation_id: conversationId },
    include: { sender: true },
    orderBy: { created_at: "asc" },
  });
  return rows.map((row) => ({
    id: row.id,
    body: row.body,
    sender: { name: row.sender.name },
    created_at: row.created_at,
    mine: row.sender_id === userId,
  }));
}

export async function sendMessage(
  userId: string,
  conversationId: string,
  body: string,
) {
  await assertMember(userId, conversationId);
  const conversation = await prisma.conversation.findUnique({
    where: { id: conversationId },
  });
  if (!conversation) throw new NotFoundError("Conversation not found");
  const message = await prisma.message.create({
    data: { conversation_id: conversationId, sender_id: userId, body },
  });
  await prisma.conversation.update({
    where: { id: conversationId },
    data: { updated_at: new Date() },
  });
  const members = await prisma.conversationMember.findMany({
    where: { conversation_id: conversationId, user_id: { not: userId } },
  });
  await notifyUsers(
    members.map((member) => member.user_id),
    "New Cruz message",
    body,
    { type: "chat", conversation_id: conversationId },
  );
  return message;
}
