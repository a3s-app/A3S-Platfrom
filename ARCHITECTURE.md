# A3S Platform Architecture

## Overview

The A3S Platform consists of two Next.js applications that share a PostgreSQL database but maintain separate authentication systems. This document explains how the platforms are connected and how data flows between them.

---

## System Architecture

```
                                   INTERNET
                                      │
            ┌─────────────────────────┼─────────────────────────┐
            │                         │                         │
            ▼                         │                         ▼
    ┌───────────────┐                 │                 ┌───────────────┐
    │  ADMIN USERS  │                 │                 │ CLIENT USERS  │
    │  (A3S Staff)  │                 │                 │  (Customers)  │
    └───────┬───────┘                 │                 └───────┬───────┘
            │                         │                         │
            ▼                         │                         ▼
    ┌───────────────┐                 │                 ┌───────────────┐
    │  Clerk Auth   │                 │                 │  Clerk Auth   │
    │   App #1      │                 │                 │   App #2      │
    │ (Admin Auth)  │                 │                 │ (Portal Auth) │
    └───────┬───────┘                 │                 └───────┬───────┘
            │                         │                         │
            ▼                         │                         ▼
┌───────────────────────┐             │             ┌───────────────────────┐
│                       │             │             │                       │
│   A3S ADMIN DASHBOARD │             │             │   A3S CLIENT PORTAL   │
│                       │             │             │                       │
│   Next.js App         │             │             │   Next.js App         │
│   Port: 3000          │◀────────────┼────────────▶│   Port: 3001          │
│                       │   Webhooks  │             │                       │
│   Features:           │             │             │   Features:           │
│   • Project Mgmt      │             │             │   • View Projects     │
│   • Issue Tracking    │             │             │   • Track Issues      │
│   • Client Mgmt       │             │             │   • Doc Remediation   │
│   • Reports           │             │             │   • Support Tickets   │
│   • WCAG Testing      │             │             │   • Evidence Locker   │
│                       │             │             │                       │
└───────────┬───────────┘             │             └───────────┬───────────┘
            │                         │                         │
            │      Drizzle ORM        │        Drizzle ORM      │
            │                         │                         │
            └─────────────────────────┼─────────────────────────┘
                                      │
                                      ▼
                          ┌───────────────────────┐
                          │                       │
                          │   PostgreSQL Database │
                          │      (Supabase)       │
                          │                       │
                          │   Shared Tables:      │
                          │   • clients           │
                          │   • projects          │
                          │   • issues            │
                          │   • client_users      │
                          │   • client_tickets    │
                          │   • notifications     │
                          │   • etc...            │
                          │                       │
                          └───────────────────────┘
                                      │
                                      ▼
                          ┌───────────────────────┐
                          │   Supabase Storage    │
                          │                       │
                          │   Buckets:            │
                          │   • project-documents │
                          │   • client-files      │
                          │   • remediations      │
                          │   • evidence-locker   │
                          │                       │
                          └───────────────────────┘
```

---

## Database Schema

### Core Tables

```
┌─────────────────┐     ┌──────────────────┐     ┌─────────────────────┐
│     clients     │────▶│     projects     │────▶│   accessibility     │
│                 │     │                  │     │      Issues         │
│ • id            │     │ • id             │     │                     │
│ • name          │     │ • client_id (FK) │     │ • id                │
│ • email         │     │ • name           │     │ • project_id (FK)   │
│ • company       │     │ • status         │     │ • severity          │
│ • portal_access │     │ • wcag_level     │     │ • dev_status        │
│                 │     │                  │     │ • sent_to_user ←────┼─── Controls Portal visibility
└────────┬────────┘     └──────────────────┘     └─────────────────────┘
         │
         │
         ▼
┌─────────────────┐     ┌──────────────────┐
│  client_users   │────▶│  client_team     │
│                 │     │    _members      │
│ • id            │     │                  │
│ • clerk_user_id │     │ • id             │
│ • client_id(FK) │     │ • client_id (FK) │
│ • email         │     │ • user_id (FK)   │
│ • role          │     │ • role           │
│                 │     │                  │
└─────────────────┘     └──────────────────┘
```

### Support Tables

```
┌──────────────────┐     ┌──────────────────┐     ┌──────────────────────┐
│  client_tickets  │     │   document       │     │   evidence           │
│                  │     │   _remediations  │     │   _documents         │
│ • id             │     │                  │     │                      │
│ • client_id (FK) │     │ • id             │     │ • id                 │
│ • created_by     │     │ • client_id (FK) │     │ • client_id (FK)     │
│ • status         │     │ • status         │     │ • document_type      │
│ • priority       │     │ • page_count     │     │ • status             │
│                  │     │ • total_price    │     │                      │
└──────────────────┘     └──────────────────┘     └──────────────────────┘
```

---

## Authentication Flow

### Admin Dashboard

```
Admin User Login
       │
       ▼
┌──────────────┐     ┌─────────────────────┐
│ Clerk App #1 │────▶│ Verify Admin Role   │
│              │     │ (Clerk metadata)    │
└──────────────┘     └─────────┬───────────┘
                               │
                               ▼
                     ┌─────────────────────┐
                     │ Access Admin APIs   │
                     │ (Full DB access)    │
                     └─────────────────────┘
```

### Client Portal

```
Portal User Login
       │
       ▼
┌──────────────┐     ┌─────────────────────┐
│ Clerk App #2 │────▶│ Clerk Webhook       │
│              │     │ (user.created)      │
└──────────────┘     └─────────┬───────────┘
                               │
                               ▼
                     ┌─────────────────────┐
                     │ Auto-Link to Client │
                     │ (by email match)    │
                     └─────────┬───────────┘
                               │
        ┌──────────────────────┴──────────────────────┐
        │                                              │
        ▼                                              ▼
┌───────────────────┐                      ┌───────────────────┐
│ Email matches     │                      │ Email matches     │
│ client email      │                      │ team invitation   │
│       ↓           │                      │       ↓           │
│ Becomes "owner"   │                      │ Becomes "member"  │
└───────────────────┘                      └───────────────────┘
```

---

## Data Flow: Admin → Portal

### 1. Issue Visibility Control

```
Admin Dashboard                              Client Portal
      │                                            │
      │  ┌─────────────────────────────────┐      │
      │  │ UPDATE issues                    │      │
      ├──│ SET sent_to_user = true          │──────┤
      │  │ WHERE id = 'issue-123'           │      │
      │  └─────────────────────────────────┘      │
      │                                            │
      │                                     ┌──────┴──────┐
      │                                     │ Issue now   │
      │                                     │ visible in  │
      │                                     │ Portal      │
      │                                     └─────────────┘
```

### 2. Client Notifications (Webhook)

```
Admin Dashboard                              Client Portal
      │                                            │
      │  POST /api/public/notifications            │
      │  ┌─────────────────────────────────┐      │
      │  │ {                                │      │
      ├──│   "clientId": "...",             │──────┤
      │  │   "title": "Report Ready",       │      │
      │  │   "type": "report_ready",        │      │
      │  │   "secret": "webhook-secret"     │      │
      │  │ }                                │      │
      │  └─────────────────────────────────┘      │
      │                                            │
      │                                     ┌──────┴──────┐
      │                                     │ Creates     │
      │                                     │ notification│
      │                                     │ for client  │
      │                                     └─────────────┘
```

### 3. Report Delivery

```
┌──────────────────────────────────────────────────────────────┐
│                      REPORT FLOW                              │
├──────────────────────────────────────────────────────────────┤
│                                                               │
│  1. Admin creates report                                      │
│     └─▶ Saved to database (reports table)                    │
│                                                               │
│  2. Admin sends report                                        │
│     └─▶ Email sent via Resend                                │
│     └─▶ Notification webhook to Portal                       │
│                                                               │
│  3. Client receives                                           │
│     └─▶ Email with report link                               │
│     └─▶ Portal notification                                  │
│     └─▶ Report visible in Portal reports list                │
│                                                               │
└──────────────────────────────────────────────────────────────┘
```

---

## Data Flow: Portal → Admin

### 1. Support Ticket Notification

```
Client Portal                                Admin Dashboard
      │                                            │
      │  POST /api/public/admin-notifications      │
      │  ┌─────────────────────────────────┐      │
      │  │ {                                │      │
      ├──│   "type": "new_client_ticket",   │──────┤
      │  │   "ticketId": "...",             │      │
      │  │   "clientId": "..."              │      │
      │  │ }                                │      │
      │  └─────────────────────────────────┘      │
      │                                            │
      │                                     ┌──────┴──────┐
      │                                     │ Admin gets  │
      │                                     │ notification│
      │                                     │ in dashboard│
      │                                     └─────────────┘
```

---

## Storage Architecture

### Bucket Structure

```
Supabase Storage
│
├── project-documents/
│   └── {projectId}/
│       ├── reports/
│       ├── screenshots/
│       └── attachments/
│
├── client-files/
│   └── {clientId}/
│       ├── contracts/
│       └── uploads/
│
├── remediations/
│   └── {remediationId}/
│       ├── original/
│       └── remediated/
│
└── evidence-locker/
    └── {clientId}/
        ├── vpats/
        ├── legal/
        └── audits/
```

---

## Security Model

### Admin Dashboard Access
- Full read/write to all tables
- Can manage all clients and projects
- Controls what data is visible to clients

### Client Portal Access
- Read-only to assigned projects
- Read issues WHERE `sent_to_user = true`
- Full CRUD on own tickets, team, remediation requests
- No access to other clients' data

### API Security

| Endpoint | Auth Method | Access Level |
|----------|-------------|--------------|
| `/api/*` (Admin) | Clerk JWT | Admin users only |
| `/api/*` (Portal) | Clerk JWT | Client users only |
| `/api/public/*` | Webhook secret | Cross-platform |

---

## Deployment Architecture

```
┌─────────────────────────────────────────────────────────────┐
│                        Vercel                                │
├─────────────────────────────────────────────────────────────┤
│                                                              │
│   ┌─────────────────┐         ┌─────────────────┐           │
│   │  admin.a3s.app  │         │ portal.a3s.app  │           │
│   │                 │         │                 │           │
│   │  a3s-admin      │         │ a3s-client-     │           │
│   │  deployment     │         │ portal deploy   │           │
│   └────────┬────────┘         └────────┬────────┘           │
│            │                           │                     │
│            └───────────┬───────────────┘                     │
│                        │                                     │
└────────────────────────┼─────────────────────────────────────┘
                         │
                         ▼
              ┌─────────────────────┐
              │   Supabase Cloud    │
              │                     │
              │   • PostgreSQL      │
              │   • Storage         │
              │   • Realtime (opt)  │
              └─────────────────────┘
```

---

## Environment Configuration

### Required Services

| Service | Purpose | Shared? |
|---------|---------|---------|
| PostgreSQL | Database | ✅ Yes |
| Supabase Storage | File storage | ✅ Yes |
| Clerk | Authentication | ❌ No (separate apps) |
| Resend | Email delivery | ✅ Yes (same API key) |
| Vercel | Hosting | ❌ No (separate projects) |

---

## Monitoring & Observability

### Recommended Setup

```
┌─────────────────────────────────────────────────────────────┐
│                    Monitoring Stack                          │
├─────────────────────────────────────────────────────────────┤
│                                                              │
│   ┌─────────────┐   ┌─────────────┐   ┌─────────────┐       │
│   │   Sentry    │   │  Vercel     │   │  Supabase   │       │
│   │             │   │  Analytics  │   │  Dashboard  │       │
│   │ Error       │   │             │   │             │       │
│   │ Tracking    │   │ Performance │   │ DB Metrics  │       │
│   └─────────────┘   └─────────────┘   └─────────────┘       │
│                                                              │
└─────────────────────────────────────────────────────────────┘
```


