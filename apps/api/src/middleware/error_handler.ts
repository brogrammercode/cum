import type { ErrorRequestHandler } from "express";

import { AppError } from "../lib/errors";

export const errorHandler: ErrorRequestHandler = (error, _req, res, _next) => {
  const status = error instanceof AppError ? error.statusCode : 500;
  const message =
    error instanceof AppError ? error.message : "Unexpected server error";
  res.status(status).json({ message });
};
