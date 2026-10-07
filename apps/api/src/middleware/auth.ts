import type { NextFunction, Request, Response } from "express";

import { UnauthorizedError } from "../lib/errors";
import { verifyToken } from "../lib/jwt";

export async function authenticate(
  req: Request,
  _res: Response,
  next: NextFunction,
) {
  try {
    const header = req.header("authorization");
    const token = header?.startsWith("Bearer ") ? header.slice(7) : "";
    if (!token) throw new UnauthorizedError();
    const payload = await verifyToken(token);
    if (!payload.userId || payload.type !== "access")
      throw new UnauthorizedError();
    req.userId = payload.userId;
    next();
  } catch (_) {
    next(new UnauthorizedError());
  }
}

export function userId(req: Request) {
  if (!req.userId) throw new UnauthorizedError();
  return req.userId;
}
