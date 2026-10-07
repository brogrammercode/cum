import { OAuth2Client } from "google-auth-library";
import { ulid } from "ulid";

import { env } from "../../config/env";
import { UnauthorizedError } from "../../lib/errors";
import { issueToken, verifyToken } from "../../lib/jwt";
import { prisma } from "../../lib/prisma";

const googleClient = new OAuth2Client(env.googleClientId);

export async function signInWithGoogle(idToken: string) {
  const audiences = [env.googleClientId, env.googleServerClientId].filter(
    Boolean,
  );
  const ticket = await googleClient.verifyIdToken({
    idToken,
    audience: audiences,
  });
  const payload = ticket.getPayload();
  if (!payload?.sub || !payload.email)
    throw new UnauthorizedError("Invalid Google token");
  let user = await prisma.user.findUnique({
    where: { google_id: payload.sub },
  });
  if (!user) {
    const emailPrefix =
      payload.email
        .split("@")[0]
        .replace(/[^a-zA-Z0-9_]/g, "")
        .slice(0, 20) || "player";
    user = await prisma.user.create({
      data: {
        google_id: payload.sub,
        email: payload.email,
        name: payload.name ?? emailPrefix,
        gamer_tag: `${emailPrefix}_${ulid().slice(-6).toLowerCase()}`,
        avatar_url: payload.picture,
      },
    });
  }
  if (user.status !== "ACTIVE")
    throw new UnauthorizedError("Account is disabled");
  return {
    accessToken: await issueToken(user.id, "access"),
    refreshToken: await issueToken(user.id, "refresh"),
    user: await presentUser(user),
  };
}

export async function getMe(userId: string) {
  const user = await prisma.user.findUnique({ where: { id: userId } });
  if (!user) throw new UnauthorizedError("User not found");
  return presentUser(user);
}

export async function refreshSession(refreshToken: string) {
  const payload = await verifyToken(refreshToken);
  if (!payload.userId || payload.type !== "refresh") {
    throw new UnauthorizedError("Invalid refresh token");
  }
  const user = await prisma.user.findUnique({ where: { id: payload.userId } });
  if (!user || user.status !== "ACTIVE") {
    throw new UnauthorizedError("User not found or disabled");
  }
  return {
    accessToken: await issueToken(user.id, "access"),
    refreshToken: await issueToken(user.id, "refresh"),
  };
}

export async function presentUser(user: {
  id: string;
  name: string;
  email: string;
  avatar_url: string | null;
  status: string;
  gamer_tag: string;
}) {
  const gameSetupComplete =
    (await prisma.userGame.count({ where: { user_id: user.id } })) > 0;
  return {
    id: user.id,
    name: user.name,
    email: user.email,
    avatar_url: user.avatar_url,
    status: user.status,
    gamer_tag: user.gamer_tag,
    game_setup_complete: gameSetupComplete,
  };
}
