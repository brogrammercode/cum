import type { Request, Response } from "express";

import { userId } from "../../middleware/auth";
import { selectedGamesSchema } from "./games.schema";
import * as service from "./games.service";

export async function catalog(_req: Request, res: Response) {
  res.json({ games: await service.getCatalog() });
}

export async function selected(req: Request, res: Response) {
  const input = selectedGamesSchema.parse(req.body);
  res.json({
    games: await service.replaceSelectedGames(userId(req), input.games),
  });
}
