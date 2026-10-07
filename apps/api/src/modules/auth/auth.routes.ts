import { Router } from "express";

import { authenticate } from "../../middleware/auth";
import * as controller from "./auth.controller";

export const authRouter = Router();
authRouter.post("/google", controller.google);
authRouter.post("/refresh", controller.refresh);
authRouter.get("/me", authenticate, controller.me);
authRouter.post("/logout", authenticate, controller.logout);
