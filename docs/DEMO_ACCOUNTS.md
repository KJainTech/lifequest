# Vidya demo accounts

Shared password for all demo accounts: **`Vidya2026!`**

| Role | Email | Where to sign in |
|------|-------|------------------|
| **Child (Vidya)** | `vidya.child@lifequest.app` | Kid app splash → **Play as Vidya (demo)** |
| **Parent** | `vidya.parent@lifequest.app` | [Parent dashboard](https://lifequest-dashboard.web.app) → **Fill demo login** |
| **Admin** | `vidya.admin@lifequest.app` | [Admin console](https://lifequest-admin.web.app/login) → **Fill demo login** |

Registration remains open — anyone can create a new parent account at `/register`.

## One-time setup (Firebase Console)

1. **Authentication → Sign-in method → Email/Password → Enable**
2. Deploy functions + rules, then seed demo data (see below).

## Seed demo data

After deploy, run once:

```bash
curl -X POST \
  "https://europe-west1-lifequest-97bf9.cloudfunctions.net/seedDemoVidya" \
  -H "Content-Type: application/json" \
  -d '{"data":{"secret":"lifequest-vidya-seed"}}'
```

Or locally with Application Default Credentials:

```bash
cd functions && npm run build && node ../scripts/seed-demo-vidya.mjs
```

This creates all three accounts, links Vidya child → parent, seeds progress/stats, and adds a welcome notification.

## Notifications

- **Bell icon** on Home shows Firestore notifications + session break alerts
- **Stage complete** notifications are written by `completeLesson` Cloud Function
- **Break reminder** appears after 30 minutes of play (with 15-min snooze)

## Test flow

1. Kid app → **Play as Vidya** → Home → bell → see welcome notification  
2. Parent dashboard → demo login → see Vidya's live progress  
3. Admin → demo login → console access  
