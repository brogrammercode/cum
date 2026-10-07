import { z } from "zod";

export const searchSchema = z.object({ q: z.string().min(1) });
export const requestSchema = z.object({ user_id: z.string().min(1) });
export const responseSchema = z.object({
  action: z.enum(["accept", "reject", "block"]),
});
export const requestDirectionSchema = z.object({
  direction: z.enum(["incoming", "outgoing"]).default("incoming"),
});
