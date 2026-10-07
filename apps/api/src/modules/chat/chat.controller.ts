import type { Request, Response } from "express";

import { userId } from "../../middleware/auth";
import { conversationSchema, messageSchema } from "./chat.schema";
import * as service from "./chat.service";

export async function list(req: Request, res: Response) {
  res.json({ conversations: await service.listConversations(userId(req)) });
}

export async function create(req: Request, res: Response) {
  const input = conversationSchema.parse(req.body);
  res.status(201).json({
    conversation: await service.createConversation(
      userId(req),
      input.title,
      input.member_ids,
    ),
  });
}

export async function messages(req: Request, res: Response) {
  res.json({
    messages: await service.messages(userId(req), req.params.conversationId),
  });
}

export async function sendMessage(req: Request, res: Response) {
  res.status(201).json({
    message: await service.sendMessage(
      userId(req),
      req.params.conversationId,
      messageSchema.parse(req.body).body,
    ),
  });
}

export async function markRead(req: Request, res: Response) {
  await service.markRead(userId(req), req.params.conversationId);
  res.status(204).send();
}
