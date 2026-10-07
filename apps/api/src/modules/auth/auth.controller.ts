import type { Request, Response } from "express";

import { userId } from "../../middleware/auth";
import { googleSignInSchema, refreshSchema } from "./auth.schema";
import * as service from "./auth.service";

export async function google(req: Request, res: Response) {
  const input = googleSignInSchema.parse(req.body);
  res.json(await service.signInWithGoogle(input.idToken));
}

export async function me(req: Request, res: Response) {
  res.json({ user: await service.getMe(userId(req)) });
}

export async function refresh(req: Request, res: Response) {
  res.json(
    await service.refreshSession(refreshSchema.parse(req.body).refreshToken),
  );
}

export async function logout(_req: Request, res: Response) {
  res.status(204).send();
}
