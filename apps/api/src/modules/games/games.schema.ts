import { z } from "zod";

export const selectedGamesSchema = z.object({
  games: z
    .array(
      z.object({
        name: z.string().min(1),
        package_name: z.string().min(1),
        catalog_game_id: z.string().nullable().optional(),
      }),
    )
    .min(1),
});
