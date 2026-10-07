import "dotenv/config";

export const env = {
  port: Number(process.env.PORT ?? 4000),
  databaseUrl: process.env.DATABASE_URL ?? "",
  jwtSecret: process.env.JWT_SECRET ?? "cruz-development-secret",
  googleClientId: process.env.GOOGLE_CLIENT_ID ?? "",
  googleServerClientId: process.env.GOOGLE_SERVER_CLIENT_ID ?? "",
  firebaseProjectId: process.env.FIREBASE_PROJECT_ID ?? "",
  firebaseClientEmail: process.env.FIREBASE_CLIENT_EMAIL ?? "",
  firebasePrivateKey:
    process.env.FIREBASE_PRIVATE_KEY?.replace(/\\n/g, "\n") ?? "",
};
