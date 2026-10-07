import { SignJWT, jwtVerify } from "jose";

import { env } from "../config/env";

const secret = new TextEncoder().encode(env.jwtSecret);

export async function issueToken(userId: string, type: "access" | "refresh") {
  return new SignJWT({ type })
    .setProtectedHeader({ alg: "HS256" })
    .setSubject(userId)
    .setIssuedAt()
    .setExpirationTime(type === "access" ? "15m" : "30d")
    .sign(secret);
}

export async function verifyToken(token: string) {
  const result = await jwtVerify(token, secret);
  return { userId: result.payload.sub ?? "", type: result.payload.type };
}
