import { Router } from "express";

import { authenticate } from "../../middleware/auth";
import * as controller from "./friends.controller";

export const friendsRouter = Router();
friendsRouter.use(authenticate);
friendsRouter.get("/search", controller.search);
friendsRouter.get("/", controller.list);
friendsRouter.post("/requests", controller.send);
friendsRouter.get("/requests", controller.requests);
friendsRouter.patch("/requests/:requestId", controller.respond);
friendsRouter.delete("/requests/:requestId", controller.cancel);
