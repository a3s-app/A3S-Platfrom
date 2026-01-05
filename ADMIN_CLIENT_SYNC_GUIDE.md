# A3S Platform - Admin ↔ Client Portal Sync Guide

> **Complete guide to setting up bidirectional communication between Admin Dashboard and Client Portal**

---

## Table of Contents

1. [Overview](#overview)
2. [Architecture](#architecture)
3. [Environment Variables](#environment-variables)
4. [Admin → Portal Communication](#admin--portal-communication)
5. [Portal → Admin Communication](#portal--admin-communication)
6. [Webhook API Reference](#webhook-api-reference)
7. [Database Sync Patterns](#database-sync-patterns)
8. [Testing the Integration](#testing-the-integration)
9. [Troubleshooting](#troubleshooting)
10. [Security Best Practices](#security-best-practices)

---

## Overview

The A3S Platform uses a **shared database** with **webhook notifications** for real-time communication between the Admin Dashboard and Client Portal.

### Sync Methods

| Method | Use Case | Direction |
|--------|----------|-----------|
| **Shared Database** | All data syncs automatically | Bidirectional |
| **Webhooks** | Real-time notifications | Bidirectional |
| **Email (Resend)** | Client notifications | Admin → Client |

### Key Principle

> ⚠️ **Both apps connect to the SAME PostgreSQL database**, so data is always in sync. Webhooks are only used for **real-time notifications** - not for data transfer.

---

## Architecture

```
╔══════════════════════════════════════════════════════════════════════════════════════╗
║                        ADMIN ↔ CLIENT PORTAL SYNC ARCHITECTURE                        ║
╠══════════════════════════════════════════════════════════════════════════════════════╣
║                                                                                       ║
║   ┌─────────────────────────────────┐       ┌─────────────────────────────────┐      ║
║   │                                 │       │                                 │      ║
║   │      A3S ADMIN DASHBOARD        │       │      A3S CLIENT PORTAL          │      ║
║   │      ══════════════════         │       │      ══════════════════         │      ║
║   │                                 │       │                                 │      ║
║   │   🌐 https://admin.domain.com   │       │   🌐 https://portal.domain.com  │      ║
║   │   📁 /a3s-admin                 │       │   📁 /a3s-client-portal         │      ║
║   │                                 │       │                                 │      ║
║   │   ENV VARS:                     │       │   ENV VARS:                     │      ║
║   │   ├─ DATABASE_URL ─────────┐    │       │   ├─ DATABASE_URL ─────────┐    │      ║
║   │   ├─ CLIENT_PORTAL_WEBHOOK_URL │       │   ├─ ADMIN_PANEL_API_URL    │    │      ║
║   │   ├─ CLIENT_PORTAL_WEBHOOK_SECRET     │   ├─ ADMIN_WEBHOOK_SECRET    │    │      ║
║   │   └─ A3S_SECRET_KEY ──────┐    │       │   └─ A3S_SECRET_KEY ────────┘    │      ║
║   │                            │    │       │         │                       │      ║
║   └─────────────┬──────────────┘    │       └─────────┼───────────────────────┘      ║
║                 │                   │                 │                              ║
║                 │                   │                 │                              ║
║   ══════════════╪═══════════════════╪═════════════════╪══════════════════════════   ║
║   SYNC LAYER    │                   │                 │                              ║
║   ══════════════╪═══════════════════╪═════════════════╪══════════════════════════   ║
║                 │                   │                 │                              ║
║                 │   ┌───────────────┴─────────────────┴───┐                         ║
║                 │   │                                      │                         ║
║                 │   │     🗄️  SHARED POSTGRESQL DATABASE   │                         ║
║                 └───▶        (Supabase)                   ◀───┘                      ║
║                     │                                      │                         ║
║                     │  Same tables, same data, same enums │                         ║
║                     │  ─────────────────────────────────── │                         ║
║                     │  • clients                           │                         ║
║                     │  • projects                          │                         ║
║                     │  • accessibility_issues              │                         ║
║                     │  • reports                           │                         ║
║                     │  • notifications                     │                         ║
║                     │  • client_users                      │                         ║
║                     │  • ... (30+ tables)                  │                         ║
║                     │                                      │                         ║
║                     └──────────────────────────────────────┘                         ║
║                                                                                       ║
║   ══════════════════════════════════════════════════════════════════════════════   ║
║   WEBHOOK LAYER (Real-time Notifications Only)                                       ║
║   ══════════════════════════════════════════════════════════════════════════════   ║
║                                                                                       ║
║   ┌─────────────────────────────────┐       ┌─────────────────────────────────┐      ║
║   │    ADMIN → PORTAL WEBHOOK       │       │    PORTAL → ADMIN WEBHOOK       │      ║
║   ├─────────────────────────────────┤       ├─────────────────────────────────┤      ║
║   │                                 │       │                                 │      ║
║   │  POST /api/public/notifications │       │  POST /api/public/admin-        │      ║
║   │                                 │       │       notifications             │      ║
║   │  Auth: X-API-Key header         │       │  Auth: X-Admin-Webhook-Secret   │      ║
║   │  Secret: A3S_SECRET_KEY         │       │  Secret: ADMIN_WEBHOOK_SECRET   │      ║
║   │                                 │       │                                 │      ║
║   │  Triggers:                      │       │  Triggers:                      │      ║
║   │  • Report sent to client        │       │  • New support ticket           │      ║
║   │  • Issues marked sent_to_user   │       │  • Document upload request      │      ║
║   │  • Project status change        │       │  • Team member invitation       │      ║
║   │  • Document ready               │       │  • Evidence document request    │      ║
║   │                                 │       │                                 │      ║
║   └─────────────────────────────────┘       └─────────────────────────────────┘      ║
║                                                                                       ║
╚══════════════════════════════════════════════════════════════════════════════════════╝
```

---

## Environment Variables

### Complete Setup for Both Applications

#### Admin Dashboard (`.env.local` in `a3s-admin/`)

```env
# ═══════════════════════════════════════════════════════════════════════════════
# REQUIRED: DATABASE (Same URL for both apps!)
# ═══════════════════════════════════════════════════════════════════════════════
DATABASE_URL=postgresql://postgres.[PROJECT_REF]:[PASSWORD]@aws-0-[REGION].pooler.supabase.com:6543/postgres

# ═══════════════════════════════════════════════════════════════════════════════
# REQUIRED: CLERK AUTHENTICATION (Admin's own Clerk app)
# ═══════════════════════════════════════════════════════════════════════════════
NEXT_PUBLIC_CLERK_PUBLISHABLE_KEY=pk_test_ADMIN_CLERK_KEY
CLERK_SECRET_KEY=sk_test_ADMIN_CLERK_SECRET
NEXT_PUBLIC_CLERK_SIGN_IN_URL=/sign-in
NEXT_PUBLIC_CLERK_SIGN_UP_URL=/sign-up
NEXT_PUBLIC_CLERK_AFTER_SIGN_IN_URL=/dashboard
NEXT_PUBLIC_CLERK_AFTER_SIGN_UP_URL=/dashboard

# ═══════════════════════════════════════════════════════════════════════════════
# REQUIRED FOR SYNC: Webhook to Client Portal
# ═══════════════════════════════════════════════════════════════════════════════
# URL where the Client Portal is hosted
CLIENT_PORTAL_WEBHOOK_URL=https://portal.yourdomain.com/api/public/notifications

# Shared secret (MUST match A3S_SECRET_KEY in Client Portal)
CLIENT_PORTAL_WEBHOOK_SECRET=your-super-secure-shared-secret-min-32-chars

# ═══════════════════════════════════════════════════════════════════════════════
# REQUIRED: Email Service (Resend)
# ═══════════════════════════════════════════════════════════════════════════════
RESEND_API_KEY=re_xxxxxxxxxxxxxxxxxxxxxxxxxxxx
RESEND_FROM_EMAIL=reports@yourdomain.com
RESEND_FROM_NAME=A3S Accessibility Services

# ═══════════════════════════════════════════════════════════════════════════════
# REQUIRED: AI Report Generation (OpenRouter)
# ═══════════════════════════════════════════════════════════════════════════════
OPENROUTER_API_KEY=sk-or-v1-xxxxxxxxxxxxxxxxxxxxxxxxxxxx
OPENROUTER_MODEL=openai/gpt-4o-mini

# ═══════════════════════════════════════════════════════════════════════════════
# REQUIRED: Supabase Storage (for file uploads)
# ═══════════════════════════════════════════════════════════════════════════════
NEXT_PUBLIC_SUPABASE_URL=https://[PROJECT_REF].supabase.co
NEXT_PUBLIC_SUPABASE_ANON_KEY=eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...
SUPABASE_SERVICE_ROLE_KEY=eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...

# ═══════════════════════════════════════════════════════════════════════════════
# OPTIONAL: Application URL
# ═══════════════════════════════════════════════════════════════════════════════
NEXT_PUBLIC_APP_URL=https://admin.yourdomain.com
```

---

#### Client Portal (`.env.local` in `a3s-client-portal/`)

```env
# ═══════════════════════════════════════════════════════════════════════════════
# REQUIRED: DATABASE (Same URL as Admin!)
# ═══════════════════════════════════════════════════════════════════════════════
DATABASE_URL=postgresql://postgres.[PROJECT_REF]:[PASSWORD]@aws-0-[REGION].pooler.supabase.com:6543/postgres

# ═══════════════════════════════════════════════════════════════════════════════
# REQUIRED: CLERK AUTHENTICATION (Portal's own SEPARATE Clerk app!)
# ═══════════════════════════════════════════════════════════════════════════════
# ⚠️ IMPORTANT: This is a DIFFERENT Clerk application than Admin!
NEXT_PUBLIC_CLERK_PUBLISHABLE_KEY=pk_test_PORTAL_CLERK_KEY
CLERK_SECRET_KEY=sk_test_PORTAL_CLERK_SECRET
NEXT_PUBLIC_CLERK_SIGN_IN_URL=/sign-in
NEXT_PUBLIC_CLERK_SIGN_UP_URL=/sign-up
NEXT_PUBLIC_CLERK_AFTER_SIGN_IN_URL=/dashboard
NEXT_PUBLIC_CLERK_AFTER_SIGN_UP_URL=/dashboard

# ═══════════════════════════════════════════════════════════════════════════════
# REQUIRED FOR SYNC: API Key for receiving webhooks from Admin
# ═══════════════════════════════════════════════════════════════════════════════
# This secret authenticates incoming webhooks from Admin Dashboard
# MUST match CLIENT_PORTAL_WEBHOOK_SECRET in Admin
A3S_SECRET_KEY=your-super-secure-shared-secret-min-32-chars

# ═══════════════════════════════════════════════════════════════════════════════
# REQUIRED FOR SYNC: Webhook to Admin Panel
# ═══════════════════════════════════════════════════════════════════════════════
# URL where the Admin Dashboard is hosted
ADMIN_PANEL_API_URL=https://admin.yourdomain.com

# Secret for Portal → Admin webhooks
ADMIN_WEBHOOK_SECRET=another-super-secure-secret-for-admin-webhooks

# ═══════════════════════════════════════════════════════════════════════════════
# REQUIRED: Supabase Storage (for file uploads)
# ═══════════════════════════════════════════════════════════════════════════════
NEXT_PUBLIC_SUPABASE_URL=https://[PROJECT_REF].supabase.co
NEXT_PUBLIC_SUPABASE_ANON_KEY=eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...
SUPABASE_SERVICE_ROLE_KEY=eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...

# ═══════════════════════════════════════════════════════════════════════════════
# OPTIONAL: Email Service (for client notifications)
# ═══════════════════════════════════════════════════════════════════════════════
RESEND_API_KEY=re_xxxxxxxxxxxxxxxxxxxxxxxxxxxx
RESEND_FROM_EMAIL=notifications@yourdomain.com

# ═══════════════════════════════════════════════════════════════════════════════
# OPTIONAL: Error Tracking (Sentry)
# ═══════════════════════════════════════════════════════════════════════════════
NEXT_PUBLIC_SENTRY_DSN=https://xxxx@xxx.ingest.sentry.io/xxxx
SENTRY_AUTH_TOKEN=sntrys_xxxxxxxxxxxx

# ═══════════════════════════════════════════════════════════════════════════════
# OPTIONAL: Application URL
# ═══════════════════════════════════════════════════════════════════════════════
NEXT_PUBLIC_APP_URL=https://portal.yourdomain.com
```

---

### Quick Reference: Matching Keys

| Purpose | Admin Variable | Portal Variable | Must Match? |
|---------|---------------|-----------------|-------------|
| Database | `DATABASE_URL` | `DATABASE_URL` | ✅ **YES** (same DB) |
| Admin→Portal Auth | `CLIENT_PORTAL_WEBHOOK_SECRET` | `A3S_SECRET_KEY` | ✅ **YES** |
| Portal→Admin Auth | *(receives)* | `ADMIN_WEBHOOK_SECRET` | Checked by Admin |
| Clerk Auth | `CLERK_SECRET_KEY` | `CLERK_SECRET_KEY` | ❌ **NO** (different apps) |
| Supabase | `NEXT_PUBLIC_SUPABASE_URL` | `NEXT_PUBLIC_SUPABASE_URL` | ✅ **YES** (same project) |

---

## Admin → Portal Communication

### When Does Admin Send to Portal?

1. **Report Sent** - When admin sends a report to client
2. **Issues Released** - When `sent_to_user` is set to `true`
3. **Document Ready** - When admin uploads/completes a document
4. **Project Updates** - Status changes on projects

### Code Implementation (Admin Side)

```typescript
// a3s-admin/lib/notifications.ts

interface PortalNotification {
  client_id: string;
  target: 'all' | 'owner';
  title: string;
  message: string;
  type: 'report_ready' | 'project_update' | 'document_ready' | 'system';
  priority?: 'low' | 'normal' | 'high' | 'urgent';
  action_url?: string;
  action_label?: string;
  related_project_id?: string;
  metadata?: Record<string, any>;
}

export async function sendPortalNotification(notification: PortalNotification) {
  const webhookUrl = process.env.CLIENT_PORTAL_WEBHOOK_URL;
  const webhookSecret = process.env.CLIENT_PORTAL_WEBHOOK_SECRET;
  
  if (!webhookUrl || !webhookSecret) {
    console.warn('[Portal Notification] Webhook not configured, skipping');
    return { success: false, error: 'Webhook not configured' };
  }

  try {
    const response = await fetch(webhookUrl, {
      method: 'POST',
      headers: {
        'Content-Type': 'application/json',
        'X-API-Key': webhookSecret,  // Verified by Portal's A3S_SECRET_KEY
      },
      body: JSON.stringify(notification),
    });

    if (!response.ok) {
      throw new Error(`HTTP ${response.status}: ${await response.text()}`);
    }

    return { success: true };
  } catch (error) {
    console.error('[Portal Notification] Failed:', error);
    return { success: false, error: error.message };
  }
}

// Usage Example: When sending a report
async function sendReport(reportId: string, clientId: string) {
  // ... send email via Resend ...
  
  // Also notify the Portal
  await sendPortalNotification({
    client_id: clientId,
    target: 'all',  // Notify all client users
    title: 'New Accessibility Report Available',
    message: 'Your monthly accessibility report is ready for review.',
    type: 'report_ready',
    priority: 'normal',
    action_url: `/reports/${reportId}`,
    action_label: 'View Report',
    related_project_id: projectId,
  });
}
```

### Portal Endpoint (Receiver)

```
POST /api/public/notifications
```

**Location:** `a3s-client-portal/app/api/public/notifications/route.ts`

**Authentication:** `X-API-Key` header must match `A3S_SECRET_KEY`

**What it does:**
1. Validates the API key
2. Looks up the client by ID or email
3. Creates notification records for target users (all or owner only)
4. Returns success with notification IDs

---

## Portal → Admin Communication

### When Does Portal Send to Admin?

1. **New Support Ticket** - Client submits a ticket
2. **Document Request** - Client requests a document (VPAT, etc.)
3. **Document Remediation** - Client uploads PDF for remediation
4. **Team Changes** - New team member added

### Code Implementation (Portal Side)

```typescript
// a3s-client-portal/lib/admin-notifications.ts

import type { AdminNotificationPayload } from "./types"

const ADMIN_PANEL_API_URL = process.env.ADMIN_PANEL_API_URL
const ADMIN_WEBHOOK_SECRET = process.env.ADMIN_WEBHOOK_SECRET

export async function sendAdminNotification(
  payload: AdminNotificationPayload
): Promise<{ success: boolean; error?: string }> {
  if (!ADMIN_PANEL_API_URL || !ADMIN_WEBHOOK_SECRET) {
    console.warn("[Admin Notification] Not configured, skipping")
    return { success: false, error: "Not configured" }
  }

  try {
    const response = await fetch(
      `${ADMIN_PANEL_API_URL}/api/public/admin-notifications`,
      {
        method: "POST",
        headers: {
          "Content-Type": "application/json",
          "X-Admin-Webhook-Secret": ADMIN_WEBHOOK_SECRET,
        },
        body: JSON.stringify(payload),
      }
    )

    if (!response.ok) {
      throw new Error(`HTTP ${response.status}`)
    }

    return { success: true }
  } catch (error) {
    console.error("[Admin Notification] Failed:", error)
    return { success: false, error: error.message }
  }
}

// Usage Example: When client creates a ticket
async function createTicket(ticketData: CreateTicketInput) {
  // ... save ticket to database ...
  
  // Notify admin
  await sendAdminNotification({
    type: 'new_ticket',
    title: `New Support Ticket: ${ticketData.title}`,
    message: `${clientName} submitted a ${ticketData.priority} priority ticket`,
    priority: mapTicketPriorityToNotificationPriority(ticketData.priority),
    clientId: ticketData.clientId,
    metadata: {
      ticketId: newTicket.id,
      category: ticketData.category,
    },
  })
}
```

### Admin Endpoint (Receiver)

```
POST /api/public/admin-notifications
```

**Authentication:** `X-Admin-Webhook-Secret` header

**Note:** You may need to create this endpoint in Admin if it doesn't exist.

---

## Webhook API Reference

### POST /api/public/notifications (Portal Endpoint)

**Purpose:** Admin sends notifications to client users

**Headers:**
```
Content-Type: application/json
X-API-Key: {A3S_SECRET_KEY}
```

**Request Body:**
```json
{
  "client_id": "uuid-of-client",        // Required (or client_email)
  "client_email": "client@example.com", // Alternative to client_id
  "target": "all",                       // "all" or "owner"
  "title": "Notification Title",         // Required
  "message": "Notification message...",  // Required
  "type": "report_ready",                // Optional (default: "system")
  "priority": "normal",                  // Optional (default: "normal")
  "action_url": "/reports/123",          // Optional
  "action_label": "View Report",         // Optional
  "related_project_id": "uuid",          // Optional
  "related_document_id": "uuid",         // Optional
  "related_ticket_id": "uuid",           // Optional
  "metadata": { "key": "value" },        // Optional
  "expires_at": "2026-02-01T00:00:00Z"   // Optional (ISO 8601)
}
```

**Response (Success - 200):**
```json
{
  "success": true,
  "data": {
    "notifications_created": 3,
    "notification_ids": ["uuid-1", "uuid-2", "uuid-3"],
    "target_users": 3,
    "client": {
      "id": "client-uuid",
      "name": "John Doe",
      "company": "Acme Corp"
    }
  }
}
```

**Response (Error - 401):**
```json
{
  "success": false,
  "error": "Invalid API key"
}
```

**Response (Error - 404):**
```json
{
  "success": false,
  "error": "Client with ID 'xxx' not found"
}
```

### Notification Types

| Type | Description | When to Use |
|------|-------------|-------------|
| `system` | General system notifications | Default, general updates |
| `project_update` | Project status changes | Project activated, completed, etc. |
| `document_ready` | Document available | VPAT ready, report generated |
| `document_approved` | Remediation approved | PDF remediation approved |
| `document_rejected` | Remediation rejected | PDF remediation rejected |
| `report_ready` | New report available | Monthly report sent |
| `team_invite` | Team invitation | New team member invited |
| `ticket_update` | Ticket status change | Ticket resolved, replied |
| `evidence_update` | Evidence locker update | New compliance document |
| `billing` | Billing related | Invoice, payment |
| `reminder` | Reminder notification | Follow-up reminders |

### Priority Levels

| Priority | Description | UI Treatment |
|----------|-------------|--------------|
| `low` | Non-urgent | Normal display |
| `normal` | Standard | Normal display |
| `high` | Important | Highlighted |
| `urgent` | Critical | Red highlight, possible sound |

---

## Database Sync Patterns

### Data That Syncs Automatically (Shared Database)

Since both apps use the same database, these tables are always in sync:

| Table | Written By | Read By |
|-------|------------|---------|
| `clients` | Admin | Both |
| `projects` | Admin | Both |
| `accessibility_issues` | Admin | Both (Portal filters by `sent_to_user`) |
| `reports` | Admin | Both |
| `test_urls` | Admin | Both |
| `client_users` | Portal | Both |
| `client_tickets` | Portal | Both |
| `notifications` | Both | Both |
| `document_remediations` | Portal | Both |
| `evidence_documents` | Both | Both |

### Critical: Issue Visibility Filter

```sql
-- Portal ALWAYS filters issues by sent_to_user
SELECT * FROM accessibility_issues
WHERE project_id = $1
  AND sent_to_user = TRUE  -- ← CRITICAL: Only see released issues
  AND is_active = TRUE;
```

**Admin can see ALL issues:**
```sql
-- Admin sees everything
SELECT * FROM accessibility_issues
WHERE project_id = $1
  AND is_active = TRUE;
  -- No sent_to_user filter
```

---

## Testing the Integration

### Step 1: Generate Secrets

```bash
# Generate secure random secrets
openssl rand -base64 32
# Example output: K7x9mPqR2sT4uV6wX8yZ0aB1cD3eF5gH7iJ9kL1mN3o=

# Generate another for the reverse direction
openssl rand -base64 32
```

### Step 2: Set Environment Variables

```bash
# Admin (.env.local)
CLIENT_PORTAL_WEBHOOK_URL=http://localhost:3001/api/public/notifications
CLIENT_PORTAL_WEBHOOK_SECRET=K7x9mPqR2sT4uV6wX8yZ0aB1cD3eF5gH7iJ9kL1mN3o=

# Portal (.env.local)
A3S_SECRET_KEY=K7x9mPqR2sT4uV6wX8yZ0aB1cD3eF5gH7iJ9kL1mN3o=
ADMIN_PANEL_API_URL=http://localhost:3000
ADMIN_WEBHOOK_SECRET=another-secret-here
```

### Step 3: Test Admin → Portal Webhook

```bash
# Test from command line
curl -X POST http://localhost:3001/api/public/notifications \
  -H "Content-Type: application/json" \
  -H "X-API-Key: K7x9mPqR2sT4uV6wX8yZ0aB1cD3eF5gH7iJ9kL1mN3o=" \
  -d '{
    "client_email": "client@example.com",
    "target": "all",
    "title": "Test Notification",
    "message": "This is a test notification from Admin",
    "type": "system",
    "priority": "normal"
  }'
```

**Expected Response:**
```json
{
  "success": true,
  "data": {
    "notifications_created": 1,
    "notification_ids": ["..."],
    "target_users": 1,
    "client": { ... }
  }
}
```

### Step 4: Verify in Portal

1. Log into Client Portal as a client user
2. Check the notifications bell icon
3. Verify the test notification appears

### Step 5: Test Portal → Admin Webhook

```bash
# If the endpoint exists in Admin
curl -X POST http://localhost:3000/api/public/admin-notifications \
  -H "Content-Type: application/json" \
  -H "X-Admin-Webhook-Secret: another-secret-here" \
  -d '{
    "type": "new_ticket",
    "title": "Test Ticket Notification",
    "message": "A client submitted a test ticket",
    "priority": "normal",
    "clientId": "client-uuid-here"
  }'
```

---

## Troubleshooting

### Common Issues

#### 1. "API key is required" Error

**Cause:** Missing or incorrect `X-API-Key` header

**Fix:**
```bash
# Check your secret is set
echo $A3S_SECRET_KEY

# Ensure header is exactly "X-API-Key" (case-sensitive)
curl -H "X-API-Key: your-secret" ...
```

#### 2. "Client not found" Error

**Cause:** Client ID/email doesn't exist in database

**Fix:**
```sql
-- Check if client exists
SELECT id, email, company FROM clients WHERE email = 'client@example.com';
```

#### 3. "No active users found" Error

**Cause:** No `client_users` records for the client

**Fix:**
```sql
-- Check client_users
SELECT * FROM client_users WHERE client_id = 'uuid';

-- Ensure is_active = true
UPDATE client_users SET is_active = true WHERE client_id = 'uuid';
```

#### 4. Webhook Not Received

**Causes:**
- Wrong URL
- Network/firewall blocking
- Secret mismatch

**Debug:**
```typescript
// Add logging in your webhook handler
console.log('Received webhook:', {
  headers: Object.fromEntries(request.headers),
  body: await request.json(),
});
```

#### 5. CORS Errors (Browser)

**Note:** Webhooks are server-to-server, not browser-to-server. If you see CORS errors, you're making the request from the wrong place.

---

## Security Best Practices

### 1. Use Strong Secrets

```bash
# Generate 32+ character random strings
openssl rand -base64 32
```

### 2. Never Expose Secrets in Client Code

```typescript
// ❌ WRONG - Don't use in client components
const secret = process.env.NEXT_PUBLIC_WEBHOOK_SECRET;

// ✅ CORRECT - Only use in server-side code
// (API routes, Server Components, Server Actions)
const secret = process.env.A3S_SECRET_KEY;
```

### 3. Validate All Inputs

```typescript
// Always validate incoming webhook data
if (!body.client_id && !body.client_email) {
  return { error: "client_id or client_email required" };
}

if (!VALID_TYPES.includes(body.type)) {
  return { error: "Invalid notification type" };
}
```

### 4. Rate Limiting

Consider adding rate limiting to prevent abuse:

```typescript
// Example using upstash/ratelimit
import { Ratelimit } from "@upstash/ratelimit";

const ratelimit = new Ratelimit({
  limiter: Ratelimit.slidingWindow(10, "1 m"), // 10 requests per minute
});
```

### 5. Log All Webhook Activity

```typescript
logger.info("Webhook received", {
  type: body.type,
  clientId: body.client_id,
  source: request.headers.get("user-agent"),
  ip: request.headers.get("x-forwarded-for"),
});
```

### 6. Use HTTPS in Production

```env
# Production URLs must use HTTPS
CLIENT_PORTAL_WEBHOOK_URL=https://portal.yourdomain.com/api/public/notifications
ADMIN_PANEL_API_URL=https://admin.yourdomain.com
```

---

## Quick Setup Checklist

### Admin Dashboard

- [ ] Set `DATABASE_URL` (same as Portal)
- [ ] Set `CLIENT_PORTAL_WEBHOOK_URL`
- [ ] Set `CLIENT_PORTAL_WEBHOOK_SECRET`
- [ ] Set Clerk keys (Admin Clerk app)
- [ ] Set Supabase keys
- [ ] Set Resend API key

### Client Portal

- [ ] Set `DATABASE_URL` (same as Admin)
- [ ] Set `A3S_SECRET_KEY` (must match Admin's `CLIENT_PORTAL_WEBHOOK_SECRET`)
- [ ] Set `ADMIN_PANEL_API_URL`
- [ ] Set `ADMIN_WEBHOOK_SECRET`
- [ ] Set Clerk keys (Portal Clerk app - DIFFERENT from Admin!)
- [ ] Set Supabase keys

### Verification

- [ ] Test Admin → Portal notification
- [ ] Test Portal → Admin notification (if endpoint exists)
- [ ] Verify notifications appear in Portal UI
- [ ] Check database for notification records

---

## Summary

| Component | What It Does | Required Env Vars |
|-----------|--------------|-------------------|
| **Shared Database** | All data syncs automatically | `DATABASE_URL` (same for both) |
| **Admin → Portal Webhook** | Real-time notifications to clients | `CLIENT_PORTAL_WEBHOOK_URL`, `CLIENT_PORTAL_WEBHOOK_SECRET` |
| **Portal → Admin Webhook** | Alert admin of client actions | `ADMIN_PANEL_API_URL`, `ADMIN_WEBHOOK_SECRET` |
| **Issue Visibility** | Controlled by `sent_to_user` field | No extra config needed |

---

*For database schema details, see [DATABASE_SCHEMA.md](./DATABASE_SCHEMA.md)*  
*For overall architecture, see [ARCHITECTURE.md](./ARCHITECTURE.md)*

