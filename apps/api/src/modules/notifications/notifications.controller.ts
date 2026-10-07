import type { Request, Response } from "express";
import { z } from "zod";

import { userId } from "../../middleware/auth";
import * as service from "./notifications.service";

const deviceSchema = z.object({
  token: z.string().min(1),
  platform: z.string().min(1),
});

export async function registerDevice(req: Request, res: Response) {
  const input = deviceSchema.parse(req.body);
  res.status(201).json({
    device: await service.registerDevice(
      userId(req),
      input.token,
      input.platform,
    ),
  });
}
