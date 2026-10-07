import type { Request, Response } from "express";

import { userId } from "../../middleware/auth";
import { startSchema } from "./presence.schema";
import * as service from "./presence.service";

export async function start(req: Request, res: Response) {
  res.status(201).json({
    session: await service.start(
      userId(req),
      startSchema.parse(req.body).package_name,
      startSchema.parse(req.body).game_name,
    ),
  });
}

export async function heartbeat(req: Request, res: Response) {
  res.json({
    updated: await service.heartbeat(userId(req), req.body.package_name),
  });
}

export async function stop(req: Request, res: Response) {
  res.json({ session: await service.stop(userId(req), req.body.package_name) });
}

export async function activityFeed(req: Request, res: Response) {
  res.json({ activities: await service.feed(userId(req)) });
}
