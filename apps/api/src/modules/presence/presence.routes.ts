import { Router } from "express";

import { authenticate } from "../../middleware/auth";
import * as controller from "./presence.controller";

export const presenceRouter = Router();
presenceRouter.use(authenticate);
presenceRouter.post("/sessions/start", controller.start);
presenceRouter.post("/sessions/heartbeat", controller.heartbeat);
presenceRouter.post("/sessions/stop", controller.stop);
presenceRouter.get("/activity/feed", controller.activityFeed);
