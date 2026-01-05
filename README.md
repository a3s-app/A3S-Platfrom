# A3S Platform

<div align="center">

![A3S Platform](https://img.shields.io/badge/A3S-Platform-667eea?style=for-the-badge&logo=accessibility&logoColor=white)
![Next.js](https://img.shields.io/badge/Next.js-15%2F16-black?style=for-the-badge&logo=next.js)
![TypeScript](https://img.shields.io/badge/TypeScript-5.0-3178c6?style=for-the-badge&logo=typescript&logoColor=white)
![PostgreSQL](https://img.shields.io/badge/PostgreSQL-Supabase-4169e1?style=for-the-badge&logo=postgresql&logoColor=white)

**Enterprise Web Accessibility Compliance Platform**

[Quick Start](#-quick-start) • [Architecture](#-architecture) • [Setup Guide](#-complete-setup-guide) • [Environment Variables](#-environment-variables) • [Troubleshooting](#-troubleshooting)

</div>

---

## 📋 Table of Contents

1. [Overview](#-overview)
2. [Architecture](#-architecture)
3. [Quick Start](#-quick-start)
4. [Complete Setup Guide](#-complete-setup-guide)
5. [Environment Variables](#-environment-variables)
6. [Database Configuration](#-database-configuration)
7. [Authentication Setup (Clerk)](#-authentication-setup-clerk)
8. [Email Setup (Resend)](#-email-setup-resend)
9. [Storage Setup (Supabase)](#-storage-setup-supabase)
10. [Notification & Webhook System](#-notification--webhook-system)
11. [Development Workflow](#-development-workflow)
12. [Deployment Guide](#-deployment-guide)
13. [Troubleshooting](#-troubleshooting)
14. [API Reference](#-api-reference)

---

## 🎯 Overview

A3S (Accessibility as a Service) is a comprehensive accessibility management solution consisting of **two integrated applications** that share a common database but operate independently with separate authentication systems.

### Platform Components

| Application | Purpose | Port | Repository |
|-------------|---------|------|------------|
| **A3S Admin Dashboard** | Internal staff management | 3000 | [a3s-admin](https://github.com/a3s-app/a3s-admin) |
| **A3S Client Portal** | External client access | 3001 | [a3s-client-portal](https://github.com/a3s-app/a3s-client-portal) |

### Key Features

<table>
<tr>
<th>Admin Dashboard</th>
<th>Client Portal</th>
</tr>
<tr>
<td>

- ✅ Client & Project Management
- ✅ Accessibility Issue Tracking
- ✅ Google Sheets Sync
- ✅ AI-Powered Report Generation
- ✅ Team & Org Chart Management
- ✅ Internal Ticket System
- ✅ SLA Configuration

</td>
<td>

- ✅ Project Progress Viewing
- ✅ Filtered Issue Access
- ✅ Document Remediation Requests
- ✅ Support Ticket Submission
- ✅ Evidence Locker
- ✅ Team Member Management
- ✅ Notification Center

</td>
</tr>
</table>

---

## 🏗️ Architecture

### System Overview

```
╔══════════════════════════════════════════════════════════════════════════════════════╗
║                                                                                       ║
║                          🌐  A3S PLATFORM ECOSYSTEM                                   ║
║                                                                                       ║
║   ┌─────────────────────────────────┐       ┌─────────────────────────────────┐      ║
║   │                                 │       │                                 │      ║
║   │      A3S ADMIN DASHBOARD        │       │      A3S CLIENT PORTAL          │      ║
║   │      ══════════════════         │       │      ══════════════════         │      ║
║   │                                 │       │                                 │      ║
║   │   👨‍💼 FOR: Internal Staff        │       │   👥 FOR: External Clients       │      ║
║   │   📁 PATH: /a3s-admin           │       │   📁 PATH: /a3s-client-portal   │      ║
║   │   🌐 PORT: 3000 (dev)           │       │   🌐 PORT: 3001 (dev)           │      ║
║   │                                 │       │                                 │      ║
║   │   ✅ Create clients             │       │   ✅ View projects              │      ║
║   │   ✅ Create projects            │       │   ✅ View issues (filtered)     │      ║
║   │   ✅ Sync from Google Sheets    │       │   ✅ View reports               │      ║
║   │   ✅ Log ALL issues             │       │   ✅ Submit support tickets     │      ║
║   │   ✅ Generate AI reports        │       │   ✅ Manage team members        │      ║
║   │   ✅ Manage internal team       │       │   ✅ Document remediation       │      ║
║   │   ✅ Configure SLAs             │       │   ✅ Evidence locker            │      ║
║   │                                 │       │                                 │      ║
║   └───────────────┬─────────────────┘       └───────────────┬─────────────────┘      ║
║                   │                                         │                        ║
║                   │    ┌───────────────────────────┐       │                        ║
║                   │    │                           │       │                        ║
║                   └────►   🗄️ SHARED DATABASE      ◄───────┘                        ║
║                        │   (PostgreSQL/Supabase)   │                                ║
║                        │                           │                                ║
║                        └───────────────────────────┘                                ║
║                                                                                       ║
║   ⚠️  CRITICAL: Same database, but SEPARATE Clerk authentication apps!              ║
║                                                                                       ║
╚══════════════════════════════════════════════════════════════════════════════════════╝
```

### External Services

```
┌──────────────────────────────────────────────────────────────────────────────────────────┐
│                              EXTERNAL SERVICES                                           │
│  ┌──────────────┐  ┌──────────────┐  ┌──────────────┐  ┌──────────────┐                 │
│  │   Clerk      │  │   Resend     │  │  OpenRouter  │  │   Sentry     │                 │
│  │   (Auth)     │  │   (Email)    │  │   (AI)       │  │   (Errors)   │                 │
│  └──────────────┘  └──────────────┘  └──────────────┘  └──────────────┘                 │
│                                                                                          │
│  • Separate apps    • Report emails    • AI Reports      • Error tracking               │
│    for Admin &      • Team invites     • GPT-4o-mini     • Portal only                  │
│    Portal           • Notifications                                                      │
└──────────────────────────────────────────────────────────────────────────────────────────┘
```

### Tech Stack

| Component | Admin Dashboard | Client Portal |
|-----------|-----------------|---------------|
| **Framework** | Next.js 15 | Next.js 16 |
| **Language** | TypeScript 5 | TypeScript 5 |
| **Database ORM** | Drizzle | Drizzle |
| **Auth Provider** | Clerk (App 1) | Clerk (App 2) |
| **File Storage** | Supabase | Supabase |
| **Email** | Resend | Resend |
| **AI** | OpenRouter (GPT-4o-mini) | ❌ |
| **Error Tracking** | Optional | Sentry |
| **Data Fetching** | SWR | SWR |
| **UI Components** | shadcn/ui | shadcn/ui |
| **Styling** | Tailwind CSS 4 | Tailwind CSS 4 |

---

## 🚀 Quick Start

### Prerequisites

- **Node.js** 18.17 or later
- **pnpm** (recommended) or npm
- **Git**
- **PostgreSQL** database (Supabase recommended)
- **Clerk** account (2 separate applications)
- **Resend** account (for email)

### 1. Clone Repository with Submodules

```bash
# Clone with submodules
git clone --recurse-submodules https://github.com/a3s-app/A3S-Platfrom.git
cd A3S-Platfrom

# OR if already cloned without submodules
git submodule update --init --recursive
```

### 2. Install Dependencies

```bash
# Install Admin Dashboard dependencies
cd a3s-admin
pnpm install

# Install Client Portal dependencies
cd ../a3s-client-portal
pnpm install
```

### 3. Configure Environment Variables

Create `.env.local` files in both `a3s-admin/` and `a3s-client-portal/` directories (see [Environment Variables](#-environment-variables) section).

### 4. Setup Database

```bash
# From a3s-admin directory (ALWAYS run migrations from Admin)
cd a3s-admin
pnpm db:push
```

### 5. Run Applications

```bash
# Terminal 1: Admin Dashboard
cd a3s-admin
pnpm dev

# Terminal 2: Client Portal
cd a3s-client-portal
pnpm dev --port 3001
```

**Access the applications:**
- Admin Dashboard: http://localhost:3000
- Client Portal: http://localhost:3001

---

## 📋 Complete Setup Guide

### Step 1: Create Supabase Project

1. Go to [supabase.com](https://supabase.com) and create a new project
2. Note down your:
   - **Project URL**: `https://xxxxx.supabase.co`
   - **Anon Key**: For client-side access
   - **Service Role Key**: For server-side operations
   - **Database URL**: Connection string for Drizzle

### Step 2: Create Clerk Applications

⚠️ **CRITICAL**: Create **TWO SEPARATE** Clerk applications - one for Admin, one for Portal.

1. Go to [clerk.com/dashboard](https://clerk.com/dashboard)
2. Create **"A3S Admin"** application
   - Note: `NEXT_PUBLIC_CLERK_PUBLISHABLE_KEY` and `CLERK_SECRET_KEY`
3. Create **"A3S Portal"** application
   - Note: `NEXT_PUBLIC_CLERK_PUBLISHABLE_KEY` and `CLERK_SECRET_KEY`
   - Configure webhook (see [Clerk Webhooks](#clerk-webhooks-portal-only))

### Step 3: Create Resend Account

1. Go to [resend.com](https://resend.com)
2. Get your API key
3. Verify your domain for production emails

### Step 4: Configure Environment Files

See the detailed [Environment Variables](#-environment-variables) section below.

### Step 5: Run Database Migrations

```bash
# ALWAYS from a3s-admin directory
cd a3s-admin
pnpm db:push
```

### Step 6: Verify Setup

1. Start both applications
2. Sign up in Admin Dashboard
3. Create a test client with an email
4. Sign up in Client Portal with the same email
5. Verify auto-linking worked (user should see client data)

---

## 🔐 Environment Variables

### Admin Dashboard (`a3s-admin/.env.local`)

```bash
# ═══════════════════════════════════════════════════════════════════════════════
# A3S ADMIN DASHBOARD - ENVIRONMENT VARIABLES
# ═══════════════════════════════════════════════════════════════════════════════

# ─────────────────────────────────────────────────────────────────────────────────
# DATABASE (REQUIRED) - SHARED WITH CLIENT PORTAL
# ─────────────────────────────────────────────────────────────────────────────────
# Get from Supabase Dashboard > Settings > Database > Connection string (URI)
DATABASE_URL=postgresql://postgres.[project-ref]:[password]@aws-0-[region].pooler.supabase.com:6543/postgres

# ─────────────────────────────────────────────────────────────────────────────────
# CLERK AUTHENTICATION (REQUIRED)
# ⚠️ Use ADMIN-specific keys, NOT Portal keys!
# Get from: https://dashboard.clerk.com > Your Admin App > API Keys
# ─────────────────────────────────────────────────────────────────────────────────
NEXT_PUBLIC_CLERK_PUBLISHABLE_KEY=pk_test_YOUR_CLERK_PUBLISHABLE_KEY
CLERK_SECRET_KEY=sk_test_YOUR_CLERK_SECRET_KEY

# Clerk Redirect URLs
NEXT_PUBLIC_CLERK_SIGN_IN_URL=/sign-in
NEXT_PUBLIC_CLERK_SIGN_UP_URL=/sign-up
NEXT_PUBLIC_CLERK_AFTER_SIGN_IN_URL=/dashboard
NEXT_PUBLIC_CLERK_AFTER_SIGN_UP_URL=/dashboard

# ─────────────────────────────────────────────────────────────────────────────────
# EMAIL - RESEND (REQUIRED for Reports & Notifications)
# Get from: https://resend.com/api-keys
# ─────────────────────────────────────────────────────────────────────────────────
RESEND_API_KEY=re_YOUR_RESEND_API_KEY
RESEND_FROM_EMAIL=reports@yourdomain.com
RESEND_FROM_NAME=A3S Reports

# ─────────────────────────────────────────────────────────────────────────────────
# AI REPORT GENERATION - OPENROUTER (REQUIRED for AI Reports)
# Get from: https://openrouter.ai/keys
# ─────────────────────────────────────────────────────────────────────────────────
OPENROUTER_API_KEY=YOUR_OPENROUTER_API_KEY
OPENROUTER_MODEL=openai/gpt-4o-mini

# ─────────────────────────────────────────────────────────────────────────────────
# FILE STORAGE - SUPABASE (REQUIRED for File Uploads)
# Get from: Supabase Dashboard > Settings > API
# ─────────────────────────────────────────────────────────────────────────────────
NEXT_PUBLIC_SUPABASE_URL=https://xxxxx.supabase.co
NEXT_PUBLIC_SUPABASE_ANON_KEY=your-supabase-anon-key
SUPABASE_SERVICE_ROLE_KEY=your-supabase-service-role-key

# ─────────────────────────────────────────────────────────────────────────────────
# ENCRYPTION (REQUIRED for Credential Storage)
# Generate using: npx tsx scripts/generate-encryption-key.ts
# ─────────────────────────────────────────────────────────────────────────────────
ENCRYPTION_KEY=your-64-character-hex-encryption-key-here

# ─────────────────────────────────────────────────────────────────────────────────
# CLIENT PORTAL WEBHOOK (OPTIONAL - for Cross-Platform Notifications)
# ─────────────────────────────────────────────────────────────────────────────────
CLIENT_PORTAL_WEBHOOK_URL=https://portal.yourdomain.com/api/public/notifications
CLIENT_PORTAL_WEBHOOK_SECRET=your-shared-webhook-secret

# ─────────────────────────────────────────────────────────────────────────────────
# APPLICATION (OPTIONAL)
# ─────────────────────────────────────────────────────────────────────────────────
NEXT_PUBLIC_APP_URL=https://admin.yourdomain.com
NODE_ENV=production
```

### Client Portal (`a3s-client-portal/.env.local`)

```bash
# ═══════════════════════════════════════════════════════════════════════════════
# A3S CLIENT PORTAL - ENVIRONMENT VARIABLES
# ═══════════════════════════════════════════════════════════════════════════════

# ─────────────────────────────────────────────────────────────────────────────────
# DATABASE (REQUIRED) - SHARED WITH ADMIN DASHBOARD
# ⚠️ Must be the SAME database as Admin!
# ─────────────────────────────────────────────────────────────────────────────────
DATABASE_URL=postgresql://postgres.[project-ref]:[password]@aws-0-[region].pooler.supabase.com:6543/postgres

# ─────────────────────────────────────────────────────────────────────────────────
# CLERK AUTHENTICATION (REQUIRED)
# ⚠️ Use PORTAL-specific keys, NOT Admin keys!
# Get from: https://dashboard.clerk.com > Your Portal App > API Keys
# ─────────────────────────────────────────────────────────────────────────────────
NEXT_PUBLIC_CLERK_PUBLISHABLE_KEY=pk_test_YOUR_PORTAL_CLERK_PUBLISHABLE_KEY
CLERK_SECRET_KEY=sk_test_YOUR_PORTAL_CLERK_SECRET_KEY

# Clerk Webhook Secret (for auto-linking users)
# Get from: Clerk Dashboard > Webhooks > Your webhook > Signing Secret
CLERK_WEBHOOK_SECRET=whsec_YOUR_CLERK_WEBHOOK_SECRET

# Clerk Redirect URLs
NEXT_PUBLIC_CLERK_SIGN_IN_URL=/sign-in
NEXT_PUBLIC_CLERK_SIGN_UP_URL=/sign-up
NEXT_PUBLIC_CLERK_AFTER_SIGN_IN_URL=/dashboard
NEXT_PUBLIC_CLERK_AFTER_SIGN_UP_URL=/dashboard

# ─────────────────────────────────────────────────────────────────────────────────
# EMAIL - RESEND (REQUIRED for Team Invitations)
# ─────────────────────────────────────────────────────────────────────────────────
RESEND_API_KEY=re_YOUR_RESEND_API_KEY
RESEND_FROM_EMAIL=team@yourdomain.com

# ─────────────────────────────────────────────────────────────────────────────────
# FILE STORAGE - SUPABASE (REQUIRED for Document Remediation)
# ─────────────────────────────────────────────────────────────────────────────────
NEXT_PUBLIC_SUPABASE_URL=https://xxxxx.supabase.co
NEXT_PUBLIC_SUPABASE_ANON_KEY=your-supabase-anon-key
SUPABASE_SERVICE_ROLE_KEY=your-supabase-service-role-key

# ─────────────────────────────────────────────────────────────────────────────────
# ADMIN PANEL WEBHOOK (OPTIONAL - for Notifying Admin of New Tickets)
# ─────────────────────────────────────────────────────────────────────────────────
ADMIN_PANEL_API_URL=https://admin.yourdomain.com
ADMIN_WEBHOOK_SECRET=your-shared-webhook-secret

# ─────────────────────────────────────────────────────────────────────────────────
# ERROR TRACKING - SENTRY (OPTIONAL but Recommended)
# ─────────────────────────────────────────────────────────────────────────────────
NEXT_PUBLIC_SENTRY_DSN=https://xxxxx@sentry.io/xxxxx
SENTRY_AUTH_TOKEN=YOUR_SENTRY_AUTH_TOKEN
SENTRY_ORG=your-org
SENTRY_PROJECT=a3s-client-portal

# ─────────────────────────────────────────────────────────────────────────────────
# APPLICATION (OPTIONAL)
# ─────────────────────────────────────────────────────────────────────────────────
NEXT_PUBLIC_APP_URL=https://portal.yourdomain.com
NODE_ENV=production
```

---

## 🗄️ Database Configuration

### Database Schema Overview

Both applications share the same PostgreSQL database with different access patterns:

| Table Category | Tables | Access |
|----------------|--------|--------|
| **Shared** | `clients`, `projects`, `accessibility_issues`, `test_urls`, `reports` | Read/Write (Admin), Read (Portal) |
| **Admin Only** | `teams`, `team_members`, `tickets`, `project_developers`, `sync_logs` | Admin only |
| **Portal Only** | `client_users`, `client_team_members`, `client_tickets`, `notifications`, `document_remediations` | Portal only |

### Running Migrations

⚠️ **CRITICAL**: Always run migrations from `a3s-admin` directory. The Admin schema is the complete schema; the Portal schema is a subset.

```bash
# Generate migration files
cd a3s-admin
pnpm db:generate

# Push schema to database (development)
pnpm db:push

# Run migrations (production)
pnpm db:migrate

# Open Drizzle Studio to browse data
pnpm db:studio
```

### The Critical `sent_to_user` Field

The `accessibility_issues.sent_to_user` boolean field controls client visibility:

```
┌─────────────────────────────────────────────────────────────────────────────────┐
│                                                                                  │
│   sent_to_user = FALSE              │      sent_to_user = TRUE                   │
│   ═══════════════════               │      ═══════════════════                   │
│                                     │                                            │
│   ┌───────────────────┐             │      ┌───────────────────┐                │
│   │   ADMIN ONLY      │             │      │   BOTH PLATFORMS  │                │
│   │                   │             │      │                   │                │
│   │   ✅ Admin sees   │   ──────►   │      │   ✅ Admin sees   │                │
│   │   ❌ Client can't │   Admin     │      │   ✅ Client sees  │                │
│   │      see          │   marks     │      │                   │                │
│   │                   │   "send"    │      │                   │                │
│   └───────────────────┘             │      └───────────────────┘                │
│                                     │                                            │
│   USE CASE: Internal work           │      USE CASE: Ready for client review    │
│             in progress             │                                            │
│                                     │                                            │
└─────────────────────────────────────────────────────────────────────────────────┘
```

---

## 🔐 Authentication Setup (Clerk)

### Why Two Separate Clerk Applications?

- **Security**: Staff and clients have completely isolated authentication
- **User Management**: Different user pools for internal vs. external users
- **Customization**: Different sign-up flows, branding, and policies

### Admin Clerk Setup

1. Create application in Clerk Dashboard
2. Enable email/password authentication
3. No webhooks needed
4. Copy API keys to `a3s-admin/.env.local`

### Portal Clerk Setup

1. Create **separate** application in Clerk Dashboard
2. Enable email/password authentication
3. **Configure webhook** (see below)
4. Copy API keys to `a3s-client-portal/.env.local`

### Clerk Webhooks (Portal Only)

The Client Portal uses Clerk webhooks to auto-link users to clients.

**Webhook Configuration:**

1. Go to Clerk Dashboard > Your Portal App > Webhooks
2. Add endpoint: `https://your-portal.com/api/webhooks/clerk`
3. Select events:
   - `user.created`
   - `session.created`
4. Copy signing secret to `CLERK_WEBHOOK_SECRET`

**How Auto-Linking Works:**

```
1. User signs up in Portal Clerk
           │
           ▼
2. Webhook fires to /api/webhooks/clerk
           │
           ▼
3. System checks: Does user's email match clients.email?
           │
    ┌──────┴──────┐
    ▼             ▼
 YES: Match    NO: Check for invitation
    │             │
    ▼             ▼
 Create        Check client_team_members
 client_users  for pending invitation
 role="owner"        │
    │         ┌──────┴──────┐
    │         ▼             ▼
    │      FOUND        NOT FOUND
    │         │             │
    │         ▼             ▼
    │   Accept invite   No access
    │   role="viewer"   (empty dashboard)
    │         │
    ▼         ▼
 User has access to client data!
```

---

## 📧 Email Setup (Resend)

### Required Configuration

1. Sign up at [resend.com](https://resend.com)
2. Get API key from dashboard
3. **Verify your domain** for production (required to send from your domain)

### Email Features by Application

| Feature | Admin | Portal |
|---------|-------|--------|
| Send Reports | ✅ | ❌ |
| Team Invitations | ❌ | ✅ |
| Ticket Notifications | ✅ | ✅ |
| System Notifications | ✅ | ✅ |

### Domain Verification

For production, verify your domain in Resend:

1. Go to Resend Dashboard > Domains
2. Add your domain (e.g., `yourdomain.com`)
3. Add the required DNS records (MX, SPF, DKIM)
4. Wait for verification (usually minutes)

### Testing Email

```bash
# Test email sending (from a3s-client-portal)
cd a3s-client-portal
pnpm test:email
```

---

## 📁 Storage Setup (Supabase)

### Required Storage Buckets

Create these buckets in Supabase Dashboard > Storage:

| Bucket | Purpose | Public |
|--------|---------|--------|
| `client-documents` | Client files | No |
| `project-documents` | Project files | No |
| `accessibility-reports` | Generated reports | No |
| `issue-screenshots` | Issue screenshots | No |
| `document-originals` | PDF remediation originals | No |
| `document-remediated` | Remediated PDFs | No |

### Bucket Policies

For private buckets, set up RLS policies:

```sql
-- Allow authenticated users to read their own files
CREATE POLICY "Users can read own files"
ON storage.objects FOR SELECT
USING (auth.uid()::text = (storage.foldername(name))[1]);

-- Allow authenticated users to upload
CREATE POLICY "Users can upload files"
ON storage.objects FOR INSERT
WITH CHECK (auth.role() = 'authenticated');
```

---

## 🔔 Notification & Webhook System

### Cross-Platform Communication

The Admin and Portal communicate via webhooks for real-time notifications.

```
┌─────────────────────┐                    ┌─────────────────────┐
│    ADMIN PANEL      │                    │   CLIENT PORTAL     │
├─────────────────────┤                    ├─────────────────────┤
│                     │   Report Sent      │                     │
│  Report Generator   │ ─────────────────► │  Notification API   │
│                     │                    │                     │
│                     │   New Issues       │                     │
│  Issue Logger       │ ─────────────────► │  Dashboard Update   │
│                     │                    │                     │
│                     │   New Ticket       │                     │
│  Ticket Handler     │ ◄───────────────── │  Ticket Submission  │
│                     │                    │                     │
└─────────────────────┘                    └─────────────────────┘
```

### Webhook Configuration

**Admin → Portal:**

```env
# In a3s-admin/.env.local
CLIENT_PORTAL_WEBHOOK_URL=https://portal.yourdomain.com/api/public/notifications
CLIENT_PORTAL_WEBHOOK_SECRET=your-shared-secret-key
```

**Portal → Admin:**

```env
# In a3s-client-portal/.env.local
ADMIN_PANEL_API_URL=https://admin.yourdomain.com
ADMIN_WEBHOOK_SECRET=your-shared-secret-key
```

### Notification Types

| Type | Description | From | To |
|------|-------------|------|-----|
| `report_ready` | New report available | Admin | Portal |
| `project_update` | Project status changed | Admin | Portal |
| `document_approved` | Remediation approved | Admin | Portal |
| `document_rejected` | Remediation rejected | Admin | Portal |
| `ticket_update` | Ticket status changed | Both | Both |
| `team_invite` | Invitation sent | Portal | Email |

---

## 🔄 Development Workflow

### Branch Strategy

```
╔══════════════════════════════════════════════════════════════════════════════╗
║                                                                              ║
║    ┌──────────────┐      PR + Review      ┌───────────────┐                  ║
║    │              │ ───────────────────►  │               │                  ║
║    │  feature/*   │                       │  development  │                  ║
║    │              │ ◄─────────────────    │               │                  ║
║    └──────────────┘    Branch from        └───────────────┘                  ║
║           │                                      │                           ║
║           ▼                                      ▼                           ║
║    ╭──────────────╮                       ╭─────────────╮      Release       ║
║    │  Local Dev   │                       │   Staging   │ ─────────────────► ║
║    │  & Testing   │                       │   Testing   │                    ║
║    ╰──────────────╯                       ╰─────────────╯                    ║
║                                                  │                           ║
║                                                  ▼                           ║
║                                           ┌───────────┐                      ║
║                                           │   main    │ ──► 🚀 Production    ║
║                                           └───────────┘                      ║
║                                                                              ║
╚══════════════════════════════════════════════════════════════════════════════╝
```

### Branch Naming Convention

| Type | Pattern | Example |
|------|---------|---------|
| Feature | `feature/short-description` | `feature/user-dashboard-redesign` |
| Bug fix | `fix/short-description` | `fix/login-redirect-loop` |
| Improvement | `improve/short-description` | `improve/api-response-time` |
| Refactor | `refactor/short-description` | `refactor/auth-middleware` |

### Commit Message Format

Follow [Conventional Commits](https://www.conventionalcommits.org/):

```bash
feat(auth): add OAuth2 login support
fix(dashboard): resolve chart rendering on mobile
docs(readme): update installation instructions
refactor(api): simplify error handling middleware
```

### Working with Submodules

```bash
# Update all submodules to latest
git submodule update --remote --merge

# Commit submodule update in parent
git add a3s-admin a3s-client-portal
git commit -m "chore: update submodules to latest"
git push

# Work on a specific submodule
cd a3s-admin
git checkout -b feature/new-feature
# ... make changes ...
git add .
git commit -m "feat: add new feature"
git push origin feature/new-feature
```

---

## 🚀 Deployment Guide

### Recommended Platforms

| Application | Platform | Notes |
|-------------|----------|-------|
| Admin Dashboard | Vercel | Easy Next.js deployment |
| Client Portal | Vercel | Separate project |
| Database | Supabase | Managed PostgreSQL |

### Vercel Deployment

1. **Connect Repository**
   - Import each submodule repository separately in Vercel
   - Or deploy from the parent repo with root directory set

2. **Configure Environment Variables**
   - Add all environment variables from `.env.local`
   - Use Vercel's environment variable system

3. **Configure Build Settings**
   ```
   Build Command: pnpm build
   Output Directory: .next
   Install Command: pnpm install
   ```

4. **Set Up Domains**
   - Admin: `admin.yourdomain.com`
   - Portal: `portal.yourdomain.com`

### Post-Deployment Checklist

- [ ] Verify database connection
- [ ] Verify Clerk authentication
- [ ] Verify Resend email sending
- [ ] Configure Clerk webhook URL in production
- [ ] Verify cross-platform webhooks
- [ ] Test user auto-linking flow
- [ ] Verify file uploads work

---

## 🔧 Troubleshooting

### Problem: "Client can't see their projects"

**Diagnosis:**

```sql
-- Check if client record exists
SELECT * FROM clients WHERE email = 'client@example.com';

-- Check if client_users record exists
SELECT * FROM client_users 
WHERE email = 'client@example.com' 
AND is_active = true;

-- Check project_team_members assignments
SELECT ptm.*, p.name as project_name 
FROM project_team_members ptm
JOIN projects p ON p.id = ptm.project_id
WHERE ptm.team_member_id = 'client_user_uuid';
```

**Solutions:**
- If no `client_users` record: User needs to be invited or auto-linked
- If no `project_team_members`: Admin needs to assign projects
- If wrong Clerk app: User must sign up in Portal Clerk, not Admin Clerk

### Problem: "Issues not appearing for client"

**Diagnosis:**

```sql
-- Check sent_to_user flag
SELECT id, issue_title, sent_to_user 
FROM accessibility_issues 
WHERE project_id = 'project_uuid';
```

**Solutions:**
- Set `sent_to_user = TRUE` for issues ready for client
- Ensure client is assigned to the project

### Problem: "Invitation not working"

**Diagnosis:**

1. Check `client_team_members` for invitation status
2. Verify Resend email delivery
3. Check Clerk webhook configuration
4. Ensure user signs up with exact invited email

### Problem: "Webhook not firing"

**Diagnosis:**

1. Check webhook URL is correct
2. Verify webhook secret matches
3. Check Clerk webhook logs in dashboard
4. Verify endpoint returns 200 status

---

## 📚 API Reference

### Admin Dashboard API Endpoints

| Endpoint | Method | Description |
|----------|--------|-------------|
| `/api/clients` | GET, POST | Client CRUD |
| `/api/projects` | GET, POST | Project CRUD |
| `/api/issues` | GET, POST | Issue management |
| `/api/reports` | GET, POST | Report generation |
| `/api/reports/send` | POST | Send report via email |
| `/api/dashboard` | GET | Dashboard statistics |
| `/api/storage` | POST | File upload |

### Client Portal API Endpoints

| Endpoint | Method | Description |
|----------|--------|-------------|
| `/api/user/me` | GET | Current user + client context |
| `/api/projects` | GET | Filtered projects |
| `/api/issues` | GET | Filtered issues (sent_to_user=true) |
| `/api/tickets` | GET, POST | Support tickets |
| `/api/team` | GET, POST | Team management |
| `/api/notifications` | GET, PATCH | Notification management |
| `/api/webhooks/clerk` | POST | Clerk webhook handler |

---

## 📄 License

Proprietary - A3S App © 2024-2026

---

## 🔗 Links

| Resource | URL |
|----------|-----|
| **Website** | [a3s.app](https://a3s.app) |
| **Admin Dashboard** | [admin.a3s.app](https://admin.a3s.app) |
| **Client Portal** | [portal.a3s.app](https://portal.a3s.app) |
| **Admin Repo** | [github.com/a3s-app/a3s-admin](https://github.com/a3s-app/a3s-admin) |
| **Portal Repo** | [github.com/a3s-app/a3s-client-portal](https://github.com/a3s-app/a3s-client-portal) |

---

<div align="center">

**Built with ❤️ by the A3S Team**

</div>
