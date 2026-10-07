import { Router } from "express";

import { authRouter } from "../modules/auth/auth.routes";
import { chatRouter } from "../modules/chat/chat.routes";
import { friendsRouter } from "../modules/friends/friends.routes";
import { gamesRouter } from "../modules/games/games.routes";
import { notificationsRouter } from "../modules/notifications/notifications.routes";
import { presenceRouter } from "../modules/presence/presence.routes";

export const apiRouter = Router();
apiRouter.get("/health", (_req, res) =>
  res.json({ name: "cruz-api", status: "ok" }),
);
apiRouter.use("/auth", authRouter);
apiRouter.use("/games", gamesRouter);
apiRouter.use("/friends", friendsRouter);
apiRouter.use("/", presenceRouter);
apiRouter.use("/conversations", chatRouter);
apiRouter.use("/notifications", notificationsRouter);
