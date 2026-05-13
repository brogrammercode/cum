# Settings Page Discussion (Revised)

Following our discussion, the **Settings Page** will be structured as follows:

## 1. Profile Settings
- **Edit Profile**: Modify GamerTag, bio, and avatar.
- **Account Security**: Password and account linking (Google/Apple).

## 2. Gang Section (Logic)
The "Gang Name" option label in Settings will behave dynamically based on the user's status:

### Case A: User has NOT joined a gang
- **Label**: "Join a Gang"
- **Action**: Opens **Join Gang Page**.
    - **Features**: Search for existing gangs to join.
    - **Backend**: Upon joining, a `player` document is created with:
        - `role`: Member
        - `permissions`: `[]` (Empty)
    - **Secondary Option**: "Create Gang" (Link/Button at the bottom).
        - Opens **Create Gang Page**.
        - **Backend**: Creating a gang results in:
            - A new `gang` document.
            - A `player` document for the creator with `role`: Owner and `permissions`: `["ALL"]`.
            - An automatic `Member` role created for the gang with `permissions`: `[]`.

### Case B: User is the OWNER of a gang
- **Label**: [Gang Name]
- **Action**: Opens **Edit Gang Page**.
    - **Features**: Edit gang name/description.
    - **Sub-pages**:
        - **Edit Players**: Remove players from the gang.
        - **Edit Profile**: Edit the owner's player profile within the gang.
        - **Edit Roles**: Manage permission lists for specific roles.

### Case C: User is a MEMBER (or other non-owner role)
- **Label**: [Gang Name]
- **Action**: Opens **Edit Profile Page**.
    - **Features**: Edit the user's specific player profile within the gang context.

## 3. Notification Settings
- **Global Alerts**: Toggle for all app notifications.
- **Game Launch Sync**: Control over who is notified when you start playing.

## 4. Technical & Experience Settings
- **Voice & Audio**: Low-latency mode, Push-to-Talk, and Overlay controls.
- **Performance Monitor**: Background resource limiting and battery optimization.
- **Theme & Appearance**: Dark Mode / OLED Black.

---
**This logic establishes a clear hierarchy and flow. Shall we proceed with defining the data models for Gangs and Players next?**
