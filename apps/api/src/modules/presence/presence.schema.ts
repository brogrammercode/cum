import { z } from "zod";

export const startSchema = z.object({
  package_name: z.string().min(1),
  game_name: z.string().optional(),
});
