import { z } from "zod";

export const conversationSchema = z.object({
  title: z.string().max(120).optional(),
  member_ids: z.array(z.string().min(1)).min(1),
});

export const messageSchema = z.object({
  body: z.string().trim().min(1).max(5000),
});
