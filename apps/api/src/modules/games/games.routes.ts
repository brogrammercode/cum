import { Router } from "express";

import { authenticate } from "../../middleware/auth";
import * as controller from "./games.controller";

export const gamesRouter = Router();
gamesRouter.get("/catalog", authenticate, controller.catalog);
gamesRouter.put("/selected", authenticate, controller.selected);
