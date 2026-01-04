# A3S Platform

> **Comprehensive Web Accessibility Compliance Platform**

A3S (Accessibility as a Service) is a complete accessibility management solution consisting of two integrated applications that share a common database but operate independently.

---

## 🏗️ Architecture Overview

```
┌─────────────────────────────────────────────────────────────────────────┐
│                         A3S PLATFORM                                     │
├─────────────────────────────────────────────────────────────────────────┤
│                                                                          │
│   ┌─────────────────────┐              ┌─────────────────────┐          │
│   │    A3S ADMIN        │              │  A3S CLIENT PORTAL  │          │
│   │    DASHBOARD        │              │                     │          │
│   ├─────────────────────┤              ├─────────────────────┤          │
│   │ • Project Mgmt      │    Sends     │ • Project Viewing   │          │
│   │ • Issue Tracking    │──────────────▶ • Issue Tracking    │          │
│   │ • Client Mgmt       │  Notifies    │ • Doc Remediation   │          │
│   │ • Report Generation │              │ • Support Tickets   │          │
│   │ • WCAG Testing      │              │ • Evidence Locker   │          │
│   │ • Team Management   │              │ • Team Management   │          │
│   └─────────┬───────────┘              └──────────┬──────────┘          │
│             │                                      │                     │
│             │         ┌──────────────────┐        │                     │
│             └─────────▶  SHARED DATABASE  ◀───────┘                     │
│                       │   (PostgreSQL)   │                              │
│                       │   via Supabase   │                              │
│                       └──────────────────┘                              │
│                                                                          │
│             ┌──────────────────┐    ┌──────────────────┐                │
│             │  Clerk Auth #1   │    │  Clerk Auth #2   │                │
│             │  (Admin Users)   │    │ (Portal Users)   │                │
│             └──────────────────┘    └──────────────────┘                │
│                                                                          │
└─────────────────────────────────────────────────────────────────────────┘
```

---

## 📦 Repository Structure

This is a **parent repository** that contains both applications as **Git submodules**:

```
A3S-Platform/
├── README.md                 # This file
├── ARCHITECTURE.md           # Detailed architecture documentation
├── .gitmodules              # Submodule configuration
├── a3s-admin/               # Admin Dashboard (submodule)
│   └── → github.com/a3s-app/a3s-admin
└── a3s-client-portal/       # Client Portal (submodule)
    └── → github.com/a3s-app/a3s-client-portal
```

### Individual Repositories

| Repository | Description | Link |
|------------|-------------|------|
| **a3s-admin** | Admin Dashboard for managing accessibility projects | [View Repo](https://github.com/a3s-app/a3s-admin) |
| **a3s-client-portal** | Client-facing portal for viewing progress | [View Repo](https://github.com/a3s-app/a3s-client-portal) |

---

## 🚀 Getting Started

### Clone with Submodules

```bash
# Clone the parent repo with all submodules
git clone --recurse-submodules https://github.com/a3s-app/A3S-Platfrom.git

# OR if you already cloned, initialize submodules
cd A3S-Platfrom
git submodule update --init --recursive
```

### Update Submodules

```bash
# Pull latest changes for all submodules
git submodule update --remote --merge

# Or for a specific submodule
cd a3s-admin
git pull origin main
```

### Working with Individual Repos

Each submodule is a full Git repository. You can work on them independently:

```bash
# Work on Admin Dashboard
cd a3s-admin
git checkout -b feature/my-feature
# ... make changes ...
git add .
git commit -m "feat: add new feature"
git push origin feature/my-feature

# Work on Client Portal
cd ../a3s-client-portal
git checkout -b feature/portal-feature
# ... make changes ...
git add .
git commit -m "feat: add portal feature"
git push origin feature/portal-feature
```

---

## 🔧 Development Setup

### Prerequisites

- **Node.js** 18+ 
- **PostgreSQL** (or Supabase account)
- **Clerk** account (separate apps for Admin and Portal)
- **pnpm** or **npm**

### Environment Variables

Each application requires its own `.env.local` file:

#### Admin Dashboard (`a3s-admin/.env.local`)
```env
# Database
DATABASE_URL=postgresql://...

# Clerk Auth
NEXT_PUBLIC_CLERK_PUBLISHABLE_KEY=pk_...
CLERK_SECRET_KEY=sk_...

# Supabase Storage
NEXT_PUBLIC_SUPABASE_URL=https://...
NEXT_PUBLIC_SUPABASE_ANON_KEY=...
SUPABASE_SERVICE_ROLE_KEY=...

# Client Portal Webhook
CLIENT_PORTAL_WEBHOOK_URL=https://your-portal/api/public/notifications
CLIENT_PORTAL_WEBHOOK_SECRET=your-secret
```

#### Client Portal (`a3s-client-portal/.env.local`)
```env
# Database (same as Admin)
DATABASE_URL=postgresql://...

# Clerk Auth (DIFFERENT app!)
NEXT_PUBLIC_CLERK_PUBLISHABLE_KEY=pk_...
CLERK_SECRET_KEY=sk_...

# Supabase Storage
NEXT_PUBLIC_SUPABASE_URL=https://...
NEXT_PUBLIC_SUPABASE_ANON_KEY=...

# Admin Webhook Secret
ADMIN_WEBHOOK_SECRET=your-secret
```

### Running Both Applications

```bash
# Terminal 1: Admin Dashboard (port 3000)
cd a3s-admin
pnpm install
pnpm dev

# Terminal 2: Client Portal (port 3001)
cd a3s-client-portal
pnpm install
pnpm dev --port 3001
```

---

## 🔗 Platform Connections

### How Data Flows

| From | To | Mechanism | Purpose |
|------|----|-----------|---------|
| Admin → Portal | Webhooks | Client notifications (tickets, reports, remediations) |
| Portal → Admin | API calls | New ticket notifications |
| Both ↔ Database | Drizzle ORM | Shared data access |
| Admin → Client | `sent_to_user` flag | Controls issue visibility |

### User Linking

1. Admin creates client with email
2. Portal user signs up with same email
3. System auto-links user to client (becomes "owner")
4. Team members can be invited via email

---

## 📚 Documentation

| Document | Location |
|----------|----------|
| Platform Architecture | [ARCHITECTURE.md](./ARCHITECTURE.md) |
| Admin Dashboard Docs | [a3s-admin/docs/](./a3s-admin/docs/) |
| Client Portal Docs | [a3s-client-portal/docs/](./a3s-client-portal/docs/) |

---

## 🛠️ Tech Stack

| Technology | Purpose |
|------------|---------|
| **Next.js 14** | React framework (App Router) |
| **TypeScript** | Type safety |
| **Drizzle ORM** | Database access |
| **PostgreSQL** | Database (via Supabase) |
| **Clerk** | Authentication |
| **Supabase Storage** | File uploads |
| **Tailwind CSS** | Styling |
| **shadcn/ui** | UI components |
| **Recharts** | Data visualization |
| **Resend** | Email delivery |

---

## 📋 Key Features

### Admin Dashboard
- ✅ Project & client management
- ✅ Accessibility issue tracking
- ✅ WCAG compliance testing
- ✅ Report generation & sending
- ✅ Team & ticket management
- ✅ Document remediation workflow
- ✅ Evidence locker management
- ✅ Real-time dashboard analytics

### Client Portal
- ✅ Project progress tracking
- ✅ Issue viewing by category
- ✅ Document remediation requests
- ✅ Support ticket system
- ✅ Evidence locker access
- ✅ Team member management
- ✅ Notification center
- ✅ Report viewing

---

## 🤝 Contributing

1. Fork the individual repository you want to contribute to
2. Create a feature branch
3. Make your changes
4. Submit a pull request to the original repo

---

## 📄 License

Proprietary - A3S App © 2024-2026

---

## 🔗 Links

- **Website**: [a3s.app](https://a3s.app)
- **Admin Dashboard**: [admin.a3s.app](https://admin.a3s.app)
- **Client Portal**: [portal.a3s.app](https://portal.a3s.app)

