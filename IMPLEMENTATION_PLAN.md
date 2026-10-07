# Cruz Mobile App — Implementation Plan

Status: in-repo implementation complete on `rebirth`; external/device validation remains

This document records the approved redesign and implementation audit for the requested use case.

The working branch has been created as `rebirth`.

Approved decisions for this pass:

- Mobile implementation in `apps/mobile` and backend implementation in a new `apps/api` project.
- Remove obsolete prototype features and rebuild the mobile code using Gym’s feature/core/repository conventions.
- Android-first foreground-service monitoring with real app detection and boot/background recovery.
- Cruz branding, package names, application IDs, labels, and other native identifiers.
- Friend discovery by username, email, gamer tag, and shareable identity where supported by the API.
- Direct and group chat.
- Activity notifications to all approved friends by default.
- Curated game catalog plus manual launchable-app selection.
- Friends-only visibility by default and permanent activity history retention.
- The background-monitoring implementation will adapt the lifecycle/recovery pattern from `C:\F0526\Dousoft\oo.rg\apps\mobile\v2`, while using Usage Access rather than its unrelated location-tracking permissions.

## 1. Requested outcome

Turn the current Flutter mobile prototype into **Cruz**, a social gaming presence app that:

1. Uses Gym’s mobile login experience and visual language.
2. Allows Google-only authentication.
3. Lets a user select games installed on the phone.
4. Detects the selected game being used and publishes the user’s current game activity.
5. Shows friends’ offline/online/in-game status and elapsed play time.
6. Supports friend requests and approval.
7. Provides a home screen with two primary segments: Activity Log and Chat.
8. Notifies friends when the user starts or stops playing.
9. Uses the provided logo asset at `apps/mobile/assets/logo.png` and changes user-facing branding to `Cruz`.

## 2. Repository findings

### Target app: `cum/apps/mobile`

- Flutter app with feature folders for auth, home, gang, game, settings, and notifications.
- Current entry point routes directly to a legacy `LoginPage`.
- Current login is an indigo gamer-themed placeholder and does not perform real Google Sign-In.
- Current home is a static placeholder containing “Active Squads” and “In-Game Friends”.
- Game models exist, but there is no game-selection flow, app-package persistence, foreground detection, presence sync, friend system, chat system, or notification delivery pipeline.
- API base URL is hardcoded to `http://localhost:4000/api/v1`.
- The provided logo is currently untracked at `apps/mobile/assets/logo.png`.
- Android still uses the default `mobile` label and `com.example.mobile` identifiers; iOS still uses `Mobile`/`mobile` and `com.example.mobile` identifiers.

### Reference app: `gym/apps/mobile`

- Gym’s auth experience is implemented in `lib/features/auth/pages/onboarding_page.dart`.
- Its visual pattern is a dark near-black background, amber brand glow/arcs, large left-aligned headline, logo, Google-only CTA, loading state, error state, and legal copy.
- Gym uses `google_sign_in`, Bloc-based auth, responsive layout calculations, and ScreenUtil.
- Gym’s application shell uses a more mature theme and native branding configuration than the target prototype.

## 3. Product flow to implement

```text
Launch Cruz
  -> restore session or show Gym-style Google login
  -> first login: select installed games
  -> save selected game packages
  -> open Cruz home
       -> Activity Log: friends’ offline and in-game activity
       -> Chat: direct/group friend conversations
       -> Add Friend in the top bar
  -> when a selected game becomes active
       -> start presence session
       -> notify approved friends
       -> update elapsed time and game status
  -> when the game is no longer active
       -> close the presence session
       -> publish offline/last-played state
```

## 4. Work plan

### Phase A — Branding and project identity

- Register `assets/` in the target `pubspec.yaml` and centralize the logo path in `AppAssets`.
- Replace direct logo strings with the centralized asset constant.
- Apply the supplied logo to the login screen, app shell, launch screen, and platform app icons where the source dimensions permit.
- Change user-facing names from the current prototype/default values to `Cruz` in Flutter metadata, Android label, iOS display name, launch surfaces, legal copy, and visible empty/error states.
- Decide whether to also migrate internal package/bundle identifiers from `com.example.mobile` to a Cruz-specific identifier. This is a native identity migration and should be treated separately from visible naming because it affects installed-app identity, signing, and backend configuration.
- Preserve unrelated API/database field names until their contracts are explicitly migrated; “Cruz everywhere” will mean user-facing branding unless approval explicitly includes a breaking identifier migration.

### Phase B — Gym-style authentication

- Add and configure `google_sign_in` using the same login interaction pattern as Gym.
- Replace the current prototype login screen with a Cruz-branded adaptation of Gym’s auth screen:
  - dark background and glow/arc treatment;
  - provided Cruz logo;
  - Google-only sign-in CTA;
  - loading, failure, and retry states;
  - legal/consent copy updated to Cruz;
  - ScreenUtil-responsive spacing and typography.
- Keep authentication state in the existing Cubit/repository structure, but make the login flow real rather than navigating directly to onboarding.
- Add session restoration on launch and route authenticated users to game setup/home.
- Remove or retire unused Facebook/email/social-login options if they are introduced later; the approved scope is Google-only.

### Phase C — First-run game selection

- Add a first-run screen that explains why Cruz needs game visibility.
- Android: query visible launchable applications and present a searchable, selectable list with app icon, display name, and package name.
- Persist selected package IDs and display metadata locally, then sync the selection to the API.
- Add permission education and an explicit “Open Usage Access settings” action where required.
- Add empty, denied-permission, no-games-found, and retry states.
- Avoid claiming that every installed app is a game; the UI will use a game catalog/category signal where available and allow manual inclusion of an app if product approval permits.

### Phase D — Home information architecture and UI

- Rebuild the home screen around the requested two-segment model:
  - **Activity Log**: friend presence cards grouped by playing now/offline/recently played, with game name, avatar, status, start time, and elapsed duration.
  - **Chat**: conversation list and unread states, with a route into a conversation screen.
- Add an Add Friend action in the top bar.
- Add friend request screens/states for pending sent, pending received, accepted, rejected, cancelled, and blocked requests.
- Keep the layout, scale, radius, spacing, typography, controls, loading behavior, and error treatment aligned with Gym’s visual system, while adapting the content for gaming.
- Replace the current static “gang” terminology and placeholder cards in the user-facing flow with friends, activity, and chat. Existing gang files will be removed, migrated, or left isolated only after call-site analysis.
- Add reusable widgets for presence rows, game chips, request cards, chat rows, segment control, empty states, and status indicators.

### Phase E — Presence and activity domain

- Introduce explicit models for:
  - selected game/app;
  - friend relationship and request;
  - presence session;
  - activity event;
  - chat conversation/message;
  - notification preference.
- Add repositories and Cubits for game selection, friends, activity feed, presence, and chat, following the existing feature-based architecture.
- Define idempotent start/heartbeat/stop behavior so repeated lifecycle events do not create duplicate sessions.
- Show server timestamps and calculate elapsed time from timestamps rather than trusting a local timer alone.
- Add reconnect and offline-queue behavior for activity transitions.

### Phase F — Game-running detection

#### Android MVP

- Use Android Usage Access/`UsageStatsManager` or an equivalent native service to observe the selected package moving into the foreground.
- Run a lightweight monitoring service only after explicit user consent.
- Send a start event when a selected package becomes active, heartbeat while it remains active, and a stop event after a confirmed transition away or timeout.
- Handle Android background limits, battery optimization, process death, reboot, permission revocation, and manufacturer-specific restrictions.
- Make the current detected app visible in Cruz so the user can pause/disable sharing.

#### iOS limitation and fallback

- iOS does not provide a general-purpose API for a third-party app to continuously inspect which arbitrary game app is running in the background.
- The first cross-platform release should therefore use an iOS-compatible fallback: manual “I’m playing” status, deep links/shortcuts where available, or integrations from supported games.
- Do not present iOS background detection as equivalent to Android until an approved game-specific integration exists.

#### Product/privacy requirements

- Explain exactly what package/app activity is collected and who receives it.
- Provide pause/incognito controls and a per-friend audience policy if required.
- Stop sharing immediately when the user disables monitoring, logs out, or revokes permission.

### Phase G — Notifications and chat transport

- Add device-token registration and push notification handling for activity start, friend requests, and chat messages.
- Add notification deep links into the relevant activity or conversation.
- Use a realtime transport for chat and presence updates where available; fall back to polling only for development or degraded connectivity.
- Add read/unread state, message retry, ordering, duplicate prevention, and offline handling.
- Ensure the backend—not the client alone—authorizes recipient visibility and friend relationships.

### Phase H — API/backend contract

The current workspace contains only the mobile client, so the following server capabilities must exist or be added in the backend project:

- Google token verification and session issuance.
- Current-user/session endpoint.
- Game catalog and selected-game CRUD.
- Friend search, request, approval, rejection, cancellation, and blocking.
- Presence start, heartbeat, stop, and current-friends feed.
- Activity history/retention policy.
- Conversations, messages, read receipts, and realtime delivery.
- Device-token registration and push fan-out.
- Privacy/audience settings and server-side authorization.

The mobile implementation will use typed endpoint constants and repositories rather than embedding business rules in widgets. If the backend is not part of this workspace, the first implementation pass must either target an agreed existing API or include a separately approved mock/demo mode.

## 5. Planned target file areas

### Existing files likely to change

- `apps/mobile/pubspec.yaml`
- `apps/mobile/lib/main.dart`
- `apps/mobile/lib/core/routes.dart`
- `apps/mobile/lib/core/theme.dart`
- `apps/mobile/lib/core/color.dart`
- `apps/mobile/lib/constants/assets.dart`
- `apps/mobile/lib/features/auth/**`
- `apps/mobile/lib/features/home/**`
- `apps/mobile/lib/services/**`
- `apps/mobile/lib/constants/api.dart`
- `apps/mobile/android/app/src/main/AndroidManifest.xml`
- `apps/mobile/android/app/build.gradle.kts`
- `apps/mobile/android/app/src/main/kotlin/**/MainActivity.kt`
- `apps/mobile/ios/Runner/Info.plist`
- `apps/mobile/ios/Runner.xcodeproj/project.pbxproj`
- Android/iOS launch and icon assets.

### New feature areas likely to be added

- `apps/mobile/lib/features/friends/`
- `apps/mobile/lib/features/activity/`
- `apps/mobile/lib/features/chat/`
- `apps/mobile/lib/features/game_selection/`
- `apps/mobile/lib/features/presence/`
- `apps/mobile/lib/services/app_usage/`
- `apps/mobile/lib/services/notifications/`
- Platform channel/native monitoring code under Android and, if feasible, iOS.

## 6. Verification plan

- Run formatting and static analysis for `apps/mobile`.
- Add unit tests for auth state transitions, game selection persistence, friend-request transitions, presence event idempotency, elapsed-time rendering, and notification routing.
- Add widget tests for Gym-style login states, first-run game selection, both home segments, Add Friend, request approval, and chat empty/loading/error states.
- Test Android on at least one emulator/device with Usage Access granted and revoked, app force-stopped, battery optimization enabled, and device rebooted.
- Test iOS fallback behavior without claiming unsupported background app detection.
- Verify the Cruz logo/name on login, home, settings, launch screen, Android launcher, and iOS app icon/display name.
- Verify unauthenticated, offline, expired-session, denied-permission, no-friends, and notification-tap flows.

## 7. Approved decisions

- **Scope:** mobile work in `apps/mobile`; backend work in `apps/api`.
- **Platform:** Android-first real app detection with a persistent foreground service and boot recovery.
- **Branding:** Cruz package, bundle, label, display name, and visible assets.
- **Friend identity:** email, username/name, gamer tag, and supported shareable identity.
- **Chat:** direct and group conversations.
- **Notifications:** all approved friends by default.
- **Game selection:** curated catalog plus manual launchable-app selection.
- **Privacy and retention:** friends-only visibility and permanent activity history.

## 8. Implementation result

The approved in-repo implementation was completed on branch `rebirth` in this order:

1. Lock the approved product/platform decisions.
2. Apply Cruz branding and Gym-style authentication.
3. Implement first-run game selection and Android permission flow.
4. Implement home segments, friends, and activity data models/repositories.
5. Implement Android presence detection, boot/background recovery, pause/incognito control, and friends-only notifications.
6. Implement friend requests, direct/group chat, read receipts, unread counts, push notification events, and notification tap routing.
7. Add a polling fallback for activity/chat refresh and mobile model tests.
8. Verify the API type contracts, Flutter analyzer, Flutter tests, and Android debug APK.

## 9. Completion audit — 2026-10-07

Completed in this workspace:

- Google-only Gym-style login, Cruz branding, logo asset, package/bundle identifiers, and native labels.
- Android curated/manual game selection with Usage Access, foreground service polling, lock-screen handling, token refresh, heartbeat, stop/start transitions, reboot recovery, and notification permission request.
- Native reliability surfaces: battery-optimization exemption flow, Usage Access revocation handling, boot/package-update restart, durable retry persistence, FCM notification channel, Cruz launcher icons, Cruz launch splash, iOS remote-notification mode, and native monitoring credential cleanup on logout.
- Home Activity Log and Chat segments, Add Friend action, approved-friend activity feed, direct/group chat, unread counts, read receipts, and 30-second polling fallback.
- Friend search, request inbox/sent views, accept/reject/block, cancellation, repeat-after-rejection/cancellation, and friend-request push events.
- Presence push events to approved friends, chat push events, and mobile notification deep links for presence, requests, and chat.
- Incognito/pause control that stops sharing and can resume monitoring; server-side visibility remains approved-friends-only.
- iOS-safe manual “I’m playing” fallback using the selected-game catalog; automatic arbitrary app detection remains correctly unavailable on iOS.
- Android durable presence event retry queue with bounded persistence, token refresh retry, and idempotent server start handling.
- API Prisma schema, typed routes/services, permanent activity history model, and mobile model tests.

Remaining before production release:

- Supply Google OAuth client IDs, Firebase Android/iOS configuration and server credentials, and PostgreSQL `DATABASE_URL`; run Prisma database synchronization/ migration in the deployment environment.
- Validate Usage Access, battery-optimization exemptions, force-stop behavior, reboot recovery, permission revocation, notification delivery, and token refresh on physical Android devices across supported OEMs.
- Add production realtime transport (WebSocket/SSE) if 30-second polling is not sufficient; the current polling fallback and Android presence retry queue are implemented.
- Add API integration tests against a disposable PostgreSQL database and end-to-end notification/device tests once the external services are configured.

