# A3S Platform - Developer Setup Guide

> **Quick reference for getting the entire platform running locally**

---

## Prerequisites

| Requirement | Version | Check Command |
|-------------|---------|---------------|
| Node.js | 18.x or 20.x | `node -v` |
| pnpm | 8.x+ | `pnpm -v` |
| Git | 2.x+ | `git --version` |
| PostgreSQL | 15+ (or Supabase) | `psql --version` |

---

## Quick Start (5 Minutes)

### 1. Clone with Submodules

```bash
# Clone the parent repo with all submodules
git clone --recursive https://github.com/a3s-app/A3S-Platfrom.git
cd A3S-Platfrom

# If already cloned without --recursive:
git submodule update --init --recursive
```

### 2. Install Dependencies

```bash
# Install in both submodules
cd a3s-admin && pnpm install && cd ..
cd a3s-client-portal && pnpm install && cd ..
```

### 3. Create Environment Files

```bash
# Copy templates
cp a3s-admin/.env.example a3s-admin/.env.local
cp a3s-client-portal/.env.example a3s-client-portal/.env.local
```

### 4. Configure Environment Variables

See [Environment Variables Quick Reference](#environment-variables-quick-reference) below.

### 5. Run Both Applications

```bash
# Terminal 1 - Admin Dashboard
cd a3s-admin && pnpm dev
# → Opens on http://localhost:3000

# Terminal 2 - Client Portal
cd a3s-client-portal && pnpm dev
# → Opens on http://localhost:3001
```

---

## Environment Variables Quick Reference

### Minimum Required Variables

#### Admin Dashboard (`a3s-admin/.env.local`)

```env
# Database (REQUIRED)
DATABASE_URL=postgresql://postgres.[PROJECT]:[PASSWORD]@aws-0-[REGION].pooler.supabase.com:6543/postgres

# Clerk Auth (REQUIRED)
NEXT_PUBLIC_CLERK_PUBLISHABLE_KEY=pk_test_xxxxx
CLERK_SECRET_KEY=sk_test_xxxxx

# Email Service (REQUIRED for reports)
RESEND_API_KEY=re_xxxxx
RESEND_FROM_EMAIL=reports@yourdomain.com

# AI Reports (REQUIRED for AI features)
OPENROUTER_API_KEY=sk-or-v1-xxxxx

# Supabase Storage (REQUIRED for file uploads)
NEXT_PUBLIC_SUPABASE_URL=https://[PROJECT].supabase.co
NEXT_PUBLIC_SUPABASE_ANON_KEY=eyJxxxxx
SUPABASE_SERVICE_ROLE_KEY=eyJxxxxx

# Portal Sync (OPTIONAL but recommended)
CLIENT_PORTAL_WEBHOOK_URL=http://localhost:3001/api/public/notifications
CLIENT_PORTAL_WEBHOOK_SECRET=dev-secret-min-32-characters-long
```

#### Client Portal (`a3s-client-portal/.env.local`)

```env
# Database (REQUIRED - same as Admin!)
DATABASE_URL=postgresql://postgres.[PROJECT]:[PASSWORD]@aws-0-[REGION].pooler.supabase.com:6543/postgres

# Clerk Auth (REQUIRED - DIFFERENT Clerk app!)
NEXT_PUBLIC_CLERK_PUBLISHABLE_KEY=pk_test_yyyyy
CLERK_SECRET_KEY=sk_test_yyyyy

# Supabase Storage (REQUIRED - same project as Admin)
NEXT_PUBLIC_SUPABASE_URL=https://[PROJECT].supabase.co
NEXT_PUBLIC_SUPABASE_ANON_KEY=eyJxxxxx
SUPABASE_SERVICE_ROLE_KEY=eyJxxxxx

# Admin Sync (REQUIRED for webhooks)
A3S_SECRET_KEY=dev-secret-min-32-characters-long
ADMIN_PANEL_API_URL=http://localhost:3000
ADMIN_WEBHOOK_SECRET=another-dev-secret-32-chars-min
```

### Variable Matching Rules

| Variable | Admin | Portal | Must Match? |
|----------|-------|--------|-------------|
| `DATABASE_URL` | ✅ | ✅ | **YES** (same database) |
| `NEXT_PUBLIC_SUPABASE_URL` | ✅ | ✅ | **YES** (same Supabase project) |
| `CLERK_SECRET_KEY` | ✅ | ✅ | **NO** (different Clerk apps) |
| `CLIENT_PORTAL_WEBHOOK_SECRET` (Admin) | ✅ | - | - |
| `A3S_SECRET_KEY` (Portal) | - | ✅ | **YES** (must match above) |

---

## Database Setup

### Option A: Use Existing Supabase

1. Go to [Supabase Dashboard](https://app.supabase.com)
2. Create a new project or use existing
3. Copy connection string from Settings → Database → Connection String → Transaction Pooler

### Option B: Run Full Setup Script

```bash
# Run the idempotent setup script
psql -d your_database_url -f scripts/000_full_database_setup.sql
```

This script safely creates:
- 54 enum types
- 30+ tables
- 163 indexes
- All constraints and triggers

### Option C: Use Drizzle Migrations

```bash
# In a3s-admin directory
pnpm drizzle-kit push

# Or generate and run migrations
pnpm drizzle-kit generate
pnpm drizzle-kit migrate
```

---

## Clerk Setup

### Why Two Clerk Apps?

The platform uses **separate Clerk applications** for Admin and Portal:

```
┌─────────────────────┐     ┌─────────────────────┐
│   Clerk App #1      │     │   Clerk App #2      │
│   (Admin Users)     │     │   (Client Users)    │
├─────────────────────┤     ├─────────────────────┤
│ • Internal staff    │     │ • External clients  │
│ • No self-signup    │     │ • Self-signup OK    │
│ • SSO optional      │     │ • Invitation flow   │
└─────────────────────┘     └─────────────────────┘
```

### Create Clerk Applications

1. Go to [clerk.com/dashboard](https://clerk.com/dashboard)
2. Create **two separate applications**:
   - "A3S Admin" → Get keys for Admin Dashboard
   - "A3S Portal" → Get keys for Client Portal
3. Configure each app's settings:
   - Sign-in/Sign-up URLs
   - Allowed redirect URLs

### Portal Clerk Webhook

The Portal needs a Clerk webhook to link users to clients:

1. In Portal Clerk Dashboard → Webhooks
2. Add endpoint: `https://portal.yourdomain.com/api/webhooks/clerk`
3. Select events: `user.created`, `user.updated`
4. Copy webhook secret to `CLERK_WEBHOOK_SECRET`

---

## Working with Submodules

### Update Submodules

```bash
# Update all submodules to latest
git submodule update --remote --merge

# Update specific submodule
cd a3s-admin
git pull origin main
cd ..
git add a3s-admin
git commit -m "chore: update a3s-admin submodule"
```

### Make Changes to Submodules

```bash
# 1. Enter submodule
cd a3s-admin

# 2. Create branch
git checkout -b feature/my-feature

# 3. Make changes and commit
git add .
git commit -m "feat: my new feature"

# 4. Push to submodule repo
git push origin feature/my-feature

# 5. Update parent to track new commit
cd ..
git add a3s-admin
git commit -m "chore: update a3s-admin to feature branch"
```

### Switch Submodule Branch

```bash
# Configure submodule to track a branch
git config -f .gitmodules submodule.a3s-admin.branch development
git submodule update --remote a3s-admin
```

---

## Common Development Tasks

### Run Linting

```bash
# Admin
cd a3s-admin && pnpm lint

# Portal
cd a3s-client-portal && pnpm lint
```

### Run Type Checking

```bash
cd a3s-admin && pnpm tsc --noEmit
cd a3s-client-portal && pnpm tsc --noEmit
```

### Database Operations

```bash
# Generate Drizzle types
cd a3s-admin && pnpm drizzle-kit generate

# Open Drizzle Studio (GUI)
cd a3s-admin && pnpm drizzle-kit studio
```

### Test Webhooks Locally

```bash
# Test Admin → Portal notification
curl -X POST http://localhost:3001/api/public/notifications \
  -H "Content-Type: application/json" \
  -H "X-API-Key: dev-secret-min-32-characters-long" \
  -d '{
    "client_email": "test@example.com",
    "target": "all",
    "title": "Test",
    "message": "Test message"
  }'
```

---

## Project Structure

```
A3S-Platfrom/
├── README.md                 # Main documentation
├── ARCHITECTURE.md           # Detailed architecture
├── DATABASE_SCHEMA.md        # Database documentation
├── ADMIN_CLIENT_SYNC_GUIDE.md # Webhook/sync setup
├── DEVELOPMENT_SETUP.md      # This file
├── scripts/
│   └── 000_full_database_setup.sql  # DB setup script
├── a3s-admin/               # Admin Dashboard (submodule)
│   ├── app/                 # Next.js App Router pages
│   ├── components/          # React components
│   ├── drizzle/            # Database schema
│   ├── lib/                # Utilities, hooks, services
│   └── docs/               # Admin-specific docs
└── a3s-client-portal/       # Client Portal (submodule)
    ├── app/                 # Next.js App Router pages
    ├── components/          # React components
    ├── drizzle/            # Database schema (shared)
    ├── lib/                # Utilities, hooks, services
    └── docs/               # Portal-specific docs
```

---

## Troubleshooting

### "Module not found" errors

```bash
# Clear node_modules and reinstall
rm -rf a3s-admin/node_modules a3s-client-portal/node_modules
cd a3s-admin && pnpm install && cd ..
cd a3s-client-portal && pnpm install && cd ..
```

### Database connection issues

```bash
# Test connection
psql $DATABASE_URL -c "SELECT 1"

# If using connection pooler, ensure you're using port 6543
# Direct connection uses port 5432
```

### Clerk redirect issues

1. Check `NEXT_PUBLIC_CLERK_SIGN_IN_URL` matches your route
2. Ensure `NEXT_PUBLIC_CLERK_AFTER_SIGN_IN_URL` is set
3. Verify allowed redirect URLs in Clerk Dashboard

### Submodule not updating

```bash
# Force submodule update
git submodule deinit -f a3s-admin
git submodule update --init a3s-admin
```

### Port already in use

```bash
# Find what's using the port
lsof -i :3000

# Kill the process
kill -9 <PID>

# Or use different ports
PORT=3002 pnpm dev
```

---

## Useful Links

| Resource | URL |
|----------|-----|
| Supabase Dashboard | https://app.supabase.com |
| Clerk Dashboard | https://clerk.com/dashboard |
| Resend Dashboard | https://resend.com/dashboard |
| OpenRouter | https://openrouter.ai |
| Drizzle Docs | https://orm.drizzle.team |
| Next.js Docs | https://nextjs.org/docs |

---

## Getting Help

1. Check the [Troubleshooting](#troubleshooting) section above
2. Review existing documentation:
   - [ARCHITECTURE.md](./ARCHITECTURE.md)
   - [DATABASE_SCHEMA.md](./DATABASE_SCHEMA.md)
   - [ADMIN_CLIENT_SYNC_GUIDE.md](./ADMIN_CLIENT_SYNC_GUIDE.md)
3. Check submodule-specific docs:
   - `a3s-admin/docs/`
   - `a3s-client-portal/docs/`

---

*Last updated: January 2026*


