import type { Request, Response } from "express";

import { userId } from "../../middleware/auth";
import {
  requestDirectionSchema,
  requestSchema,
  responseSchema,
  searchSchema,
} from "./friends.schema";
import * as service from "./friends.service";

export async function search(req: Request, res: Response) {
  res.json({
    users: await service.search(userId(req), searchSchema.parse(req.query).q),
  });
}

export async function list(req: Request, res: Response) {
  res.json({ friends: await service.list(userId(req)) });
}

export async function send(req: Request, res: Response) {
  res.status(201).json({
    request: await service.send(
      userId(req),
      requestSchema.parse(req.body).user_id,
    ),
  });
}

export async function requests(req: Request, res: Response) {
  const direction = requestDirectionSchema.parse(req.query).direction;
  res.json({ requests: await service.requests(userId(req), direction) });
}

export async function respond(req: Request, res: Response) {
  res.json({
    request: await service.respond(
      userId(req),
      req.params.requestId,
      responseSchema.parse(req.body).action,
    ),
  });
}

export async function cancel(req: Request, res: Response) {
  res.json({
    request: await service.cancel(userId(req), req.params.requestId),
  });
}
