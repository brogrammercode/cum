# Cruz

Cruz is a Flutter gaming-presence and chat application with an Android-first
background game detector and a TypeScript/Prisma API.

## Projects

- `apps/mobile`: Cruz Flutter application.
- `apps/api`: Cruz Express and Prisma API.

## Local development

Run `flutter pub get` in `apps/mobile`, copy `.env.example` to `.env`, and set
the API and Google client values. Run `pnpm install` and `pnpm run db:push` in
`apps/api`, then start the API with `pnpm run dev`.

Android game detection requires Usage Access permission and a foreground
service. The service persists its selected packages and resumes after boot.
