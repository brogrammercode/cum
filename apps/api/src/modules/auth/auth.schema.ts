import { z } from "zod";

export const googleSignInSchema = z.object({ idToken: z.string().min(1) });
export const refreshSchema = z.object({ refreshToken: z.string().min(1) });
