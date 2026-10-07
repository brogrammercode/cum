import cors from "cors";
import express from "express";
import rateLimit from "express-rate-limit";
import helmet from "helmet";

import { errorHandler } from "./middleware/error_handler";
import { apiRouter } from "./routes";

export function createApp() {
  const app = express();
  app.use(helmet());
  app.use(cors());
  app.use(express.json({ limit: "1mb" }));
  app.use(rateLimit({ windowMs: 60_000, limit: 300 }));
  app.use("/api/v1", apiRouter);
  app.use(errorHandler);
  return app;
}
