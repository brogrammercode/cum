import { Router } from "express";

import { authenticate } from "../../middleware/auth";
import * as controller from "./chat.controller";

export const chatRouter = Router();
chatRouter.use(authenticate);
chatRouter.get("/", controller.list);
chatRouter.post("/", controller.create);
chatRouter.get("/:conversationId/messages", controller.messages);
chatRouter.post("/:conversationId/messages", controller.sendMessage);
chatRouter.patch("/:conversationId/read", controller.markRead);
