import { Router } from "express";

import { authenticate } from "../../middleware/auth";
import * as controller from "./notifications.controller";

export const notificationsRouter = Router();
notificationsRouter.post(
  "/device-token",
  authenticate,
  controller.registerDevice,
);
