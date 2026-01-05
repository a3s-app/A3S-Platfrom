# A3S Platform - Complete Database Schema Documentation

> **Last Updated:** January 2026  
> **Database:** PostgreSQL (via Supabase)  
> **ORM:** Drizzle ORM (TypeScript)

---

## Table of Contents

1. [Overview](#overview)
2. [Database Architecture](#database-architecture)
3. [Enum Types Reference](#enum-types-reference)
4. [Table Reference](#table-reference)
   - [Core Tables (Shared)](#core-tables-shared)
   - [Admin-Only Tables](#admin-only-tables)
   - [Client Portal Tables](#client-portal-tables)
5. [Entity Relationship Diagram](#entity-relationship-diagram)
6. [Critical Fields & Data Flow](#critical-fields--data-flow)
7. [Indexes & Performance](#indexes--performance)
8. [Common Query Patterns](#common-query-patterns)

---

## Overview

The A3S Platform uses a **single PostgreSQL database** shared between two applications:

| Application | Purpose | Primary Users |
|-------------|---------|---------------|
| **A3S Admin Dashboard** | Internal operations, issue tracking, reporting | Staff, QA Engineers, Project Managers |
| **A3S Client Portal** | Client-facing project views, support tickets | External Clients, Team Members |

### Key Concepts

1. **Shared Database**: Both apps connect to the same PostgreSQL instance (Supabase)
2. **Data Visibility Control**: The `sent_to_user` field in `accessibility_issues` controls what clients see
3. **Separate Authentication**: Each app has its own Clerk instance (users are NOT shared)
4. **Client User Linking**: Portal users are linked to clients via the `client_users` table

---

## Database Architecture

```
╔══════════════════════════════════════════════════════════════════════════════════╗
║                        A3S PLATFORM DATABASE ARCHITECTURE                         ║
╠══════════════════════════════════════════════════════════════════════════════════╣
║                                                                                   ║
║   ┌─────────────────────────────────────────────────────────────────────────┐    ║
║   │                         SHARED TABLES                                    │    ║
║   │  (Both Admin Dashboard & Client Portal read/write)                       │    ║
║   ├─────────────────────────────────────────────────────────────────────────┤    ║
║   │  • clients              - Organization/company records                   │    ║
║   │  • projects             - Accessibility testing projects                 │    ║
║   │  • test_urls            - URLs being tested for accessibility           │    ║
║   │  • accessibility_issues - Primary issues table (CRITICAL: sent_to_user) │    ║
║   │  • reports              - Generated accessibility reports               │    ║
║   │  • report_issues        - Junction: reports ↔ issues                    │    ║
║   │  • report_comments      - Comments on reports                           │    ║
║   │  • issues               - Legacy issues table (deprecated)              │    ║
║   └─────────────────────────────────────────────────────────────────────────┘    ║
║                                                                                   ║
║   ┌─────────────────────────────────────────────────────────────────────────┐    ║
║   │                       ADMIN-ONLY TABLES                                  │    ║
║   │  (Only Admin Dashboard reads/writes)                                     │    ║
║   ├─────────────────────────────────────────────────────────────────────────┤    ║
║   │  • tickets                   - Internal work tickets                     │    ║
║   │  • ticket_attachments        - Files attached to tickets                │    ║
║   │  • ticket_comments           - Internal ticket comments                 │    ║
║   │  • teams                     - Internal teams                           │    ║
║   │  • team_members              - Internal team members                    │    ║
║   │  • project_team_assignments  - Team → Project assignments               │    ║
║   │  • project_staging_credentials - Staging/prod credentials              │    ║
║   │  • client_credentials        - Client platform credentials              │    ║
║   │  • client_files              - Client document uploads                  │    ║
║   │  • project_documents         - Project-level documents                  │    ║
║   │  • project_activities        - Activity log/audit trail                 │    ║
║   │  • project_developers        - Developer assignments                    │    ║
║   │  • project_milestones        - Project milestones                       │    ║
║   │  • project_time_entries      - Time tracking                            │    ║
║   │  • sync_logs                 - Google Sheets sync logs                  │    ║
║   │  • project_sync_status       - Detailed sync status                     │    ║
║   │  • checkpoint_sync           - Sync checkpoints                         │    ║
║   │  • status                    - URL status tracking                      │    ║
║   │  • status_check              - Status check records                     │    ║
║   │  • wcag_url_check            - WCAG criteria per URL                    │    ║
║   │  • issue_comments            - Comments on accessibility issues         │    ║
║   └─────────────────────────────────────────────────────────────────────────┘    ║
║                                                                                   ║
║   ┌─────────────────────────────────────────────────────────────────────────┐    ║
║   │                     CLIENT PORTAL TABLES                                 │    ║
║   │  (Only Client Portal reads/writes; Admin may read)                       │    ║
║   ├─────────────────────────────────────────────────────────────────────────┤    ║
║   │  • client_users              - Portal user accounts (Clerk-linked)      │    ║
║   │  • client_team_members       - Team member invitations                  │    ║
║   │  • project_team_members      - User → Project access (portal)           │    ║
║   │  • client_tickets            - Support tickets from clients             │    ║
║   │  • client_ticket_issues      - Junction: tickets ↔ issues               │    ║
║   │  • evidence_documents        - Compliance documents (Evidence Locker)   │    ║
║   │  • evidence_document_requests - Document requests from clients          │    ║
║   │  • document_remediations     - PDF remediation requests                 │    ║
║   │  • client_billing_addons     - Additional billing items                 │    ║
║   │  • notifications             - System/admin notifications               │    ║
║   └─────────────────────────────────────────────────────────────────────────┘    ║
║                                                                                   ║
╚══════════════════════════════════════════════════════════════════════════════════╝
```

---

## Enum Types Reference

### Client & Organization Enums

| Enum Name | Values | Used In |
|-----------|--------|---------|
| `client_status` | `pending`, `active`, `inactive`, `suspended`, `archived` | `clients.status` |
| `client_type` | `a3s`, `p15r`, `partner` | `clients.client_type` |
| `policy_status` | `none`, `draft`, `review`, `approved`, `has_policy`, `needs_review`, `needs_creation`, `in_progress`, `completed` | `clients.policy_status` |
| `company_size` | `1-10`, `11-50`, `51-200`, `201-1000`, `1000+` | `clients.company_size` |
| `pricing_tier` | `basic`, `professional`, `enterprise`, `custom` | `clients.pricing_tier` |
| `payment_method` | `credit_card`, `ach`, `wire`, `check` | `clients.payment_method` |
| `communication_preference` | `email`, `phone`, `slack`, `teams` | `clients.communication_preference` |
| `timeline` | `immediate`, `1-3_months`, `3-6_months`, `6-12_months`, `ongoing` | `clients.timeline` |

### Project Enums

| Enum Name | Values | Used In |
|-----------|--------|---------|
| `project_status` | `planning`, `active`, `on_hold`, `completed`, `cancelled`, `archived` | `projects.status` |
| `project_priority` | `low`, `medium`, `high`, `urgent` | `projects.priority` |
| `project_type` | `audit`, `remediation`, `monitoring`, `training`, `consultation`, `full_compliance`, `a3s_program` | `projects.project_type` |
| `project_platform` | `website`, `mobile_app`, `desktop_app`, `web_app`, `api`, `other` | `projects.project_platform` |
| `tech_stack` | `wordpress`, `react`, `vue`, `angular`, `nextjs`, `nuxt`, `laravel`, `django`, `rails`, `nodejs`, `express`, `fastapi`, `spring`, `aspnet`, `flutter`, `react_native`, `ionic`, `xamarin`, `electron`, `tauri`, `wails`, `android_native`, `ios_native`, `unity`, `unreal`, `other` | `projects.tech_stack` |
| `billing_type` | `fixed`, `hourly`, `milestone` | `projects.billing_type` |
| `billing_frequency` | `daily`, `weekly`, `bi-weekly`, `monthly`, `quarterly`, `half-yearly`, `yearly` | `clients.billing_frequency` |

### WCAG & Accessibility Enums

| Enum Name | Values | Used In |
|-----------|--------|---------|
| `conformance_level` | `A`, `AA`, `AAA` | `accessibility_issues.conformance_level`, `projects.wcag_level` |
| `severity` | `1_critical`, `2_high`, `3_medium`, `4_low` | `accessibility_issues.severity` |
| `issue_type` | `automated_tools`, `screen_reader`, `keyboard_navigation`, `color_contrast`, `text_spacing`, `browser_zoom`, `other` | `accessibility_issues.issue_type` |
| `dev_status` | `not_started`, `in_progress`, `done`, `blocked`, `3rd_party`, `wont_fix` | `accessibility_issues.dev_status` |
| `qa_status` | `not_started`, `in_progress`, `fixed`, `verified`, `failed`, `3rd_party` | `accessibility_issues.qa_status` |
| `url_category` | `home`, `content`, `form`, `admin`, `other` | `test_urls.url_category` |

### Ticket Enums

| Enum Name | Values | Used In |
|-----------|--------|---------|
| `ticket_status` | `open`, `in_progress`, `resolved`, `closed` | `tickets.status`, `client_tickets.status` |
| `ticket_priority` | `low`, `medium`, `high`, `critical` | `tickets.priority`, `client_tickets.priority` |
| `ticket_type` | `bug`, `feature`, `task`, `accessibility`, `improvement` | `tickets.type` |
| `ticket_category` | `technical`, `billing`, `general`, `feature_request`, `bug_report`, `other` | `client_tickets.category` |

### Report Enums

| Enum Name | Values | Used In |
|-----------|--------|---------|
| `report_type` | `executive_summary`, `technical_report`, `compliance_report`, `monthly_progress`, `custom` | `reports.report_type` |
| `report_status` | `draft`, `generated`, `edited`, `sent`, `archived` | `reports.status` |

### Team & User Enums

| Enum Name | Values | Used In |
|-----------|--------|---------|
| `team_type` | `internal`, `external` | `teams.team_type` |
| `employee_role` | `ceo`, `manager`, `team_lead`, `senior_developer`, `developer`, `junior_developer`, `designer`, `qa_engineer`, `project_manager`, `business_analyst`, `consultant`, `contractor` | `team_members.role` |
| `employment_status` | `active`, `inactive`, `on_leave`, `terminated` | `team_members.employment_status` |
| `developer_role` | `project_lead`, `senior_developer`, `developer`, `qa_engineer`, `accessibility_specialist` | `project_developers.role` |
| `user_role` | `viewer`, `editor`, `admin`, `owner` | `client_users.role` |
| `project_role` | `project_admin`, `project_member` | `project_team_members.role` |
| `invitation_status` | `pending`, `sent`, `accepted`, `expired`, `cancelled` | `client_team_members.invitation_status` |

### Document Enums

| Enum Name | Values | Used In |
|-----------|--------|---------|
| `document_type` | `audit_report`, `remediation_plan`, `test_results`, `compliance_certificate`, `meeting_notes`, `vpat`, `accessibility_summary`, `legal_response`, `monthly_monitoring`, `custom`, `other` | `project_documents.type`, `evidence_documents.document_type` |
| `document_status` | `draft`, `pending_review`, `certified`, `active`, `archived` | `evidence_documents.status` |
| `document_request_status` | `pending`, `in_progress`, `completed`, `rejected` | `evidence_document_requests.status` |
| `document_priority` | `low`, `medium`, `high`, `critical` | `evidence_documents.priority` |
| `remediation_type` | `traditional_pdf`, `html_alternative` | `document_remediations.remediation_type` |
| `remediation_status` | `pending_review`, `approved`, `in_progress`, `completed`, `rejected` | `document_remediations.status` |

### Notification Enums

| Enum Name | Values | Used In |
|-----------|--------|---------|
| `notification_type` | `system`, `project_update`, `document_ready`, `document_approved`, `document_rejected`, `report_ready`, `team_invite`, `ticket_update`, `evidence_update`, `billing`, `reminder` | `notifications.type` |
| `notification_priority` | `low`, `normal`, `high`, `urgent` | `notifications.priority` |

### Other Enums

| Enum Name | Values | Used In |
|-----------|--------|---------|
| `activity_action` | `created`, `updated`, `milestone_completed`, `developer_assigned`, `status_changed`, `document_uploaded`, `time_logged`, `staging_credentials_updated` | `project_activities.action` |
| `milestone_status` | `pending`, `in_progress`, `completed`, `overdue` | `project_milestones.status` |
| `time_entry_category` | `development`, `testing`, `review`, `meeting`, `documentation`, `research` | `project_time_entries.category` |
| `credential_type` | `staging`, `production`, `development`, `testing`, `wordpress`, `httpauth`, `sftp`, `database`, `app_store`, `play_store`, `firebase`, `aws`, `azure`, `gcp`, `heroku`, `vercel`, `netlify`, `github`, `gitlab`, `bitbucket`, `docker`, `kubernetes`, `cms`, `api_key`, `oauth`, `ssh_key`, `ssl_certificate`, `cdn`, `analytics`, `monitoring`, `other` | `project_staging_credentials.type` |
| `comment_type` | `general`, `dev_update`, `qa_feedback`, `technical_note`, `resolution` | `issue_comments.comment_type` |
| `author_role` | `developer`, `qa_tester`, `accessibility_expert`, `project_manager`, `client` | `issue_comments.author_role` |
| `billing_addon_type` | `team_members`, `document_remediation`, `evidence_locker`, `custom` | `client_billing_addons.addon_type` |
| `billing_addon_status` | `active`, `cancelled`, `pending` | `client_billing_addons.status` |

---

## Table Reference

### Core Tables (Shared)

#### `clients`

The central table for client organizations. Both Admin and Portal reference this.

| Column | Type | Nullable | Default | Description |
|--------|------|----------|---------|-------------|
| `id` | UUID | NO | `gen_random_uuid()` | Primary key |
| `name` | VARCHAR(255) | NO | - | Client contact name |
| `email` | VARCHAR(255) | NO | - | Primary email (unique) |
| `company` | VARCHAR(255) | NO | - | Company/organization name |
| `phone` | VARCHAR(50) | YES | - | Contact phone |
| `address` | TEXT | YES | - | Mailing address |
| `billing_amount` | NUMERIC(10,2) | NO | - | Monthly billing amount |
| `billing_start_date` | TIMESTAMP | NO | - | When billing started |
| `billing_frequency` | ENUM | NO | - | How often billed |
| `status` | ENUM | NO | `pending` | Account status |
| `client_type` | ENUM | NO | `a3s` | Type of client |
| `company_size` | ENUM | YES | - | Employee count range |
| `industry` | VARCHAR(100) | YES | - | Business industry |
| `website` | VARCHAR(500) | YES | - | Company website |
| `current_accessibility_level` | ENUM | YES | - | Current compliance level |
| `compliance_deadline` | TIMESTAMP | YES | - | Compliance due date |
| `pricing_tier` | ENUM | YES | - | Service tier |
| `payment_method` | ENUM | YES | - | Payment method |
| `services_needed` | TEXT[] | YES | - | Array of services |
| `wcag_level` | ENUM | YES | - | Target WCAG level |
| `priority_areas` | TEXT[] | YES | - | Focus areas |
| `timeline` | ENUM | YES | - | Implementation timeline |
| `communication_preference` | ENUM | YES | - | Preferred contact method |
| `reporting_frequency` | ENUM | YES | - | How often to report |
| `point_of_contact` | VARCHAR(255) | YES | - | Main contact person |
| `time_zone` | VARCHAR(100) | YES | - | Client timezone |
| `has_accessibility_policy` | BOOLEAN | NO | `false` | Has policy? |
| `accessibility_policy_url` | VARCHAR(500) | YES | - | Policy URL |
| `policy_status` | ENUM | NO | `none` | Policy status |
| `policy_notes` | TEXT | YES | - | Notes about policy |
| `notes` | TEXT | YES | - | General notes |
| `client_documents` | TEXT | YES | - | Document references |
| `team_member_limit` | INTEGER | NO | `5` | Max team members (Portal) |
| `created_at` | TIMESTAMP | NO | `NOW()` | Created timestamp |
| `updated_at` | TIMESTAMP | NO | `NOW()` | Last update |

**Indexes:**
- `clients_email_unique` (UNIQUE) on `email`
- `idx_clients_type` on `client_type`
- `idx_clients_type_count` on `client_type`

---

#### `projects`

Accessibility testing projects linked to clients.

| Column | Type | Nullable | Default | Description |
|--------|------|----------|---------|-------------|
| `id` | UUID | NO | `gen_random_uuid()` | Primary key |
| `client_id` | UUID | YES | - | FK to clients |
| `name` | VARCHAR(255) | NO | - | Project name |
| `description` | TEXT | YES | - | Project description |
| `sheet_id` | VARCHAR(255) | YES | - | Google Sheet ID for sync |
| `status` | VARCHAR(50) | YES | `planning` | Project status |
| `priority` | VARCHAR(50) | YES | `medium` | Priority level |
| `wcag_level` | VARCHAR(50) | YES | `AA` | Target WCAG level |
| `project_type` | VARCHAR(50) | YES | - | Type of project |
| `project_platform` | VARCHAR(50) | NO | `website` | Platform type |
| `tech_stack` | VARCHAR(50) | NO | `other` | Technology stack |
| `compliance_requirements` | TEXT[] | NO | `{}` | Compliance requirements |
| `website_url` | VARCHAR(500) | YES | - | Project URL |
| `testing_methodology` | TEXT[] | NO | `{}` | Testing methods |
| `testing_schedule` | TEXT | YES | - | Testing schedule |
| `bug_severity_workflow` | TEXT | YES | - | Severity workflow |
| `start_date` | TIMESTAMP | YES | - | Project start |
| `end_date` | TIMESTAMP | YES | - | Project end |
| `estimated_hours` | NUMERIC(8,2) | YES | - | Estimated hours |
| `actual_hours` | NUMERIC(8,2) | YES | `0` | Actual hours logged |
| `budget` | NUMERIC(12,2) | YES | - | Project budget |
| `billing_type` | VARCHAR(50) | NO | `fixed` | Billing type |
| `hourly_rate` | NUMERIC(8,2) | YES | - | Hourly rate |
| `progress_percentage` | INTEGER | NO | `0` | Completion % |
| `milestones_completed` | INTEGER | NO | `0` | Completed milestones |
| `total_milestones` | INTEGER | NO | `0` | Total milestones |
| `deliverables` | TEXT[] | NO | `{}` | Project deliverables |
| `acceptance_criteria` | TEXT[] | NO | `{}` | Acceptance criteria |
| `default_testing_month` | VARCHAR(20) | YES | - | Default testing month |
| `default_testing_year` | INTEGER | YES | - | Default testing year |
| `critical_issue_sla_days` | INTEGER | YES | `45` | SLA for critical issues |
| `high_issue_sla_days` | INTEGER | YES | `30` | SLA for high issues |
| `sync_status_summary` | JSONB | YES | `{}` | Sync status JSON |
| `last_sync_details` | JSONB | YES | `{}` | Last sync details |
| `credentials` | JSONB | YES | `[]` | Project credentials |
| `credentials_backup` | JSONB | YES | - | Credentials backup |
| `tags` | TEXT[] | NO | `{}` | Project tags |
| `notes` | TEXT | YES | - | General notes |
| `created_at` | TIMESTAMP | NO | `NOW()` | Created timestamp |
| `updated_at` | TIMESTAMP | NO | `NOW()` | Last update |
| `created_by` | VARCHAR(255) | NO | - | Creator user ID |
| `last_modified_by` | VARCHAR(255) | NO | - | Last modifier ID |

**Indexes:**
- `idx_projects_client_id` on `client_id`
- `idx_projects_status` on `status`
- `idx_projects_sheet_id` on `sheet_id`
- `idx_projects_type` on `project_type`
- `idx_projects_wcag_level` on `wcag_level`
- `idx_projects_created_at` on `created_at DESC`
- `idx_projects_status_type` on `(status, project_type)`
- `idx_projects_critical_sla` on `critical_issue_sla_days`
- `idx_projects_high_sla` on `high_issue_sla_days`
- Partial: `idx_projects_active_with_client` WHERE `status IN ('active', 'planning')`

**Constraints:**
- `check_critical_sla_days`: `critical_issue_sla_days BETWEEN 1 AND 365`
- `check_high_sla_days`: `high_issue_sla_days BETWEEN 1 AND 365`
- FK to `clients(id)` ON DELETE CASCADE

---

#### `test_urls`

URLs being tested for accessibility within projects.

| Column | Type | Nullable | Default | Description |
|--------|------|----------|---------|-------------|
| `id` | UUID | NO | `gen_random_uuid()` | Primary key |
| `project_id` | UUID | NO | - | FK to projects |
| `url` | VARCHAR(1000) | NO | - | URL to test |
| `page_title` | VARCHAR(500) | YES | - | Page title |
| `url_category` | ENUM/TEXT | YES | `content` | URL category |
| `testing_month` | VARCHAR(20) | YES | - | Testing month |
| `testing_year` | INTEGER | YES | - | Testing year |
| `remediation_month` | VARCHAR(20) | YES | - | Remediation month |
| `remediation_year` | INTEGER | YES | - | Remediation year |
| `is_active` | BOOLEAN | YES | `true` | Is URL active? |
| `status` | TEXT | YES | - | URL status |
| `automated_tools` | TEXT | YES | - | Automated test result |
| `nvda_chrome` | TEXT | YES | - | NVDA Chrome result |
| `voiceover_iphone_safari` | TEXT | YES | - | VoiceOver result |
| `color_contrast` | TEXT | YES | - | Contrast result |
| `browser_zoom` | TEXT | YES | - | Zoom result |
| `keyboard_only` | TEXT | YES | - | Keyboard nav result |
| `text_spacing` | TEXT | YES | - | Text spacing result |
| `created_at` | TIMESTAMP | NO | `NOW()` | Created timestamp |
| `updated_at` | TIMESTAMP | NO | `NOW()` | Last update |

**Indexes:**
- `test_urls_project_url_idx` (UNIQUE) on `(project_id, url)`

**Constraints:**
- FK to `projects(id)` ON DELETE CASCADE

---

#### `accessibility_issues` ⭐ CRITICAL TABLE

**This is the most important table for the platform.** Contains all accessibility issues found during testing.

> ⚠️ **CRITICAL FIELD**: `sent_to_user` - When `true`, the issue is visible to clients in the Portal. When `false`, only Admin can see it.

| Column | Type | Nullable | Default | Description |
|--------|------|----------|---------|-------------|
| `id` | UUID | NO | `gen_random_uuid()` | Primary key |
| `project_id` | UUID | NO | - | FK to projects |
| `issue_id` | TEXT | NO | - | Human-readable issue ID |
| `url_id` | UUID | NO | - | FK to test_urls |
| `issue_title` | VARCHAR(500) | NO | - | Issue title |
| `issue_description` | TEXT | YES | - | Detailed description |
| `issue_type` | VARCHAR(50) | NO | - | Type of issue |
| `severity` | VARCHAR(50) | NO | - | Severity level |
| `testing_month` | VARCHAR(20) | YES | - | When tested |
| `testing_year` | INTEGER | YES | - | Testing year |
| `testing_environment` | VARCHAR(200) | YES | - | Test environment |
| `browser` | VARCHAR(100) | YES | - | Browser used |
| `operating_system` | VARCHAR(100) | YES | - | OS used |
| `assistive_technology` | VARCHAR(100) | YES | - | AT used |
| `expected_result` | TEXT | NO | - | Expected behavior |
| `actual_result` | TEXT | YES | - | Actual behavior |
| `failed_wcag_criteria` | TEXT[] | YES | `{}` | Failed WCAG criteria |
| `conformance_level` | ENUM | YES | - | WCAG level |
| `screencast_url` | VARCHAR(1000) | YES | - | Video URL |
| `screenshot_urls` | TEXT[] | YES | `{}` | Screenshot URLs |
| `dev_status` | VARCHAR(50) | YES | `not_started` | Development status |
| `dev_comments` | TEXT | YES | - | Dev comments |
| `dev_assigned_to` | VARCHAR(255) | YES | - | Assigned developer |
| `qa_status` | VARCHAR(50) | YES | `not_started` | QA status |
| `qa_comments` | TEXT | YES | - | QA comments |
| `qa_assigned_to` | VARCHAR(255) | YES | - | Assigned QA |
| `discovered_at` | TIMESTAMP | NO | `NOW()` | When discovered |
| `dev_started_at` | TIMESTAMP | YES | - | Dev start date |
| `dev_completed_at` | TIMESTAMP | YES | - | Dev completion date |
| `qa_started_at` | TIMESTAMP | YES | - | QA start date |
| `qa_completed_at` | TIMESTAMP | YES | - | QA completion date |
| `resolved_at` | TIMESTAMP | YES | - | Resolution date |
| `is_active` | BOOLEAN | YES | `true` | Is issue active? |
| `is_duplicate` | BOOLEAN | YES | `false` | Is duplicate? |
| `duplicate_of_id` | UUID | YES | - | Original issue if dup |
| `external_ticket_id` | VARCHAR(255) | YES | - | External ticket ref |
| `external_ticket_url` | VARCHAR(1000) | YES | - | External ticket URL |
| `import_batch_id` | VARCHAR(255) | YES | - | Import batch ID |
| `source_file_name` | VARCHAR(255) | YES | - | Source file |
| **`sent_to_user`** | BOOLEAN | YES | `false` | **VISIBLE TO CLIENT?** |
| `sent_date` | TIMESTAMP | YES | - | When sent to client |
| `sent_month` | VARCHAR(20) | YES | - | Month sent |
| `report_id` | UUID | YES | - | Linked report |
| `metadata` | JSONB | YES | - | Additional metadata |
| `dev_status_updated_at` | TIMESTAMP | YES | - | Dev status change time |
| `qa_status_updated_at` | TIMESTAMP | YES | - | QA status change time |
| `sheet_name` | TEXT | YES | - | Source sheet name |
| `sheet_row_number` | INTEGER | YES | - | Source row number |
| `created_at` | TIMESTAMP | NO | `NOW()` | Created timestamp |
| `updated_at` | TIMESTAMP | NO | `NOW()` | Last update |

**Indexes (Comprehensive - Most Queried Table):**
- `unique_project_issue_id` (UNIQUE) on `(project_id, issue_id)`
- `accessibility_issues_project_url_title_unique` (UNIQUE) on `(project_id, url_id, issue_title)`
- `idx_accessibility_issues_issue_id` on `issue_id`
- `accessibility_issues_project_url_idx` on `(project_id, url_id)`
- `accessibility_issues_dev_status_idx` on `dev_status`
- `accessibility_issues_qa_status_idx` on `qa_status`
- `accessibility_issues_severity_idx` on `severity`
- `accessibility_issues_type_idx` on `issue_type`
- `accessibility_issues_sent_to_user_idx` on `sent_to_user`
- `accessibility_issues_report_id_idx` on `report_id`
- `accessibility_issues_duplicate_of_idx` on `duplicate_of_id`
- `accessibility_issues_import_batch_idx` on `import_batch_id`
- `idx_issues_project_id` on `project_id`
- `idx_issues_created_at` on `created_at`
- `idx_issues_updated_at` on `updated_at`
- `idx_accessibility_issues_metadata` (GIN) on `metadata`
- Partial indexes for performance optimization

**Constraints:**
- FK to `projects(id)` ON DELETE CASCADE
- FK to `test_urls(id)` ON DELETE CASCADE

---

#### `reports`

Generated accessibility reports for projects.

| Column | Type | Nullable | Default | Description |
|--------|------|----------|---------|-------------|
| `id` | UUID | NO | `gen_random_uuid()` | Primary key |
| `project_id` | UUID | NO | - | FK to projects |
| `title` | VARCHAR(255) | NO | - | Report title |
| `report_type` | ENUM | NO | - | Type of report |
| `report_month` | VARCHAR(20) | YES | - | Report month |
| `report_year` | INTEGER | YES | - | Report year |
| `ai_generated_content` | TEXT | YES | - | AI-generated content |
| `edited_content` | TEXT | YES | - | Edited content |
| `status` | ENUM | NO | `draft` | Report status |
| `sent_at` | TIMESTAMP | YES | - | When sent |
| `sent_to` | JSONB | YES | - | Recipients |
| `email_subject` | VARCHAR(255) | YES | - | Email subject |
| `email_body` | TEXT | YES | - | Email body |
| `pdf_path` | VARCHAR(500) | YES | - | PDF file path |
| `created_by` | VARCHAR(255) | YES | - | Creator ID |
| `is_public` | BOOLEAN | NO | `false` | Publicly accessible? |
| `public_token` | VARCHAR(64) | YES | - | Public access token |
| `created_at` | TIMESTAMP | NO | `NOW()` | Created timestamp |
| `updated_at` | TIMESTAMP | NO | `NOW()` | Last update |

**Indexes:**
- `idx_reports_project_id` on `project_id`
- `idx_reports_status` on `status`
- `idx_reports_type` on `report_type`
- `idx_reports_created_at` on `created_at DESC`
- `idx_reports_sent_at` on `sent_at`
- `idx_reports_title_search` (GIN) on `to_tsvector(title)`

**Constraints:**
- `public_token` UNIQUE
- FK to `projects(id)` ON DELETE CASCADE

---

#### `report_issues`

Junction table linking reports to accessibility issues.

| Column | Type | Nullable | Default | Description |
|--------|------|----------|---------|-------------|
| `id` | UUID | NO | `gen_random_uuid()` | Primary key |
| `report_id` | UUID | NO | - | FK to reports |
| `issue_id` | UUID | NO | - | FK to accessibility_issues |
| `included_at` | TIMESTAMP | NO | `NOW()` | When included |

**Constraints:**
- `unique_report_issue` (UNIQUE) on `(report_id, issue_id)`
- FK to `reports(id)` ON DELETE CASCADE
- FK to `accessibility_issues(id)` ON DELETE CASCADE

---

### Client Portal Tables

#### `client_users`

Portal user accounts linked to Clerk and clients.

| Column | Type | Nullable | Default | Description |
|--------|------|----------|---------|-------------|
| `id` | UUID | NO | `gen_random_uuid()` | Primary key |
| `clerk_user_id` | VARCHAR(255) | NO | - | Clerk user ID |
| `client_id` | UUID | NO | - | FK to clients |
| `email` | VARCHAR(255) | NO | - | User email |
| `first_name` | VARCHAR(100) | YES | - | First name |
| `last_name` | VARCHAR(100) | YES | - | Last name |
| `role` | ENUM | NO | `viewer` | User role |
| `is_active` | BOOLEAN | NO | `true` | Is user active? |
| `email_notifications` | BOOLEAN | NO | `true` | Receive emails? |
| `last_login_at` | TIMESTAMP | YES | - | Last login time |
| `created_at` | TIMESTAMP | NO | `NOW()` | Created timestamp |
| `updated_at` | TIMESTAMP | NO | `NOW()` | Last update |

**Indexes:**
- `idx_client_users_clerk_user_id` on `clerk_user_id`
- `idx_client_users_client_id` on `client_id`
- `idx_client_users_email` on `email`
- Partial: `idx_client_users_is_active` WHERE `is_active = true`

**Constraints:**
- `unique_clerk_client` (UNIQUE) on `(clerk_user_id, client_id)`
- FK to `clients(id)` ON DELETE CASCADE

---

#### `client_team_members`

Team member invitations before acceptance.

| Column | Type | Nullable | Default | Description |
|--------|------|----------|---------|-------------|
| `id` | UUID | NO | `gen_random_uuid()` | Primary key |
| `client_id` | UUID | NO | - | FK to clients |
| `name` | VARCHAR(255) | NO | - | Member name |
| `email` | VARCHAR(255) | NO | - | Member email |
| `description` | TEXT | YES | - | Description/role |
| `invitation_status` | ENUM | NO | `pending` | Invitation status |
| `invitation_sent_at` | TIMESTAMP | YES | - | When sent |
| `invitation_token` | VARCHAR(255) | YES | - | Invitation token |
| `clerk_invitation_id` | VARCHAR(255) | YES | - | Clerk invitation ID |
| `invited_by_user_id` | UUID | YES | - | Who invited |
| `accepted_at` | TIMESTAMP | YES | - | When accepted |
| `linked_user_id` | UUID | YES | - | Linked client_user |
| `pending_project_ids` | JSONB | YES | `[]` | Projects to assign |
| `created_at` | TIMESTAMP | NO | `NOW()` | Created timestamp |
| `updated_at` | TIMESTAMP | NO | `NOW()` | Last update |

**Indexes:**
- `idx_client_team_members_client_id` on `client_id`
- `idx_client_team_members_email` on `email`
- `idx_client_team_members_invitation_status` on `invitation_status`
- `idx_client_team_members_invitation_token` on `invitation_token`

**Constraints:**
- `unique_client_team_member_email` (UNIQUE) on `(client_id, email)`
- FK to `clients(id)` ON DELETE CASCADE
- FK to `client_users(id)` ON DELETE SET NULL (for invited_by_user_id, linked_user_id)

---

#### `project_team_members`

Links client users to specific projects with roles.

| Column | Type | Nullable | Default | Description |
|--------|------|----------|---------|-------------|
| `id` | UUID | NO | `gen_random_uuid()` | Primary key |
| `project_id` | UUID | NO | - | FK to projects |
| `team_member_id` | UUID | NO | - | FK to client_users |
| `role` | ENUM | NO | `project_member` | Project role |
| `created_at` | TIMESTAMP | NO | `NOW()` | Created timestamp |
| `updated_at` | TIMESTAMP | NO | `NOW()` | Last update |

**Indexes:**
- `idx_project_team_members_project_id` on `project_id`
- `idx_project_team_members_team_member_id` on `team_member_id`

**Constraints:**
- `unique_project_team_member` (UNIQUE) on `(project_id, team_member_id)`
- FK to `projects(id)` ON DELETE CASCADE
- FK to `client_users(id)` ON DELETE CASCADE

---

#### `client_tickets`

Support tickets submitted by clients.

| Column | Type | Nullable | Default | Description |
|--------|------|----------|---------|-------------|
| `id` | UUID | NO | `gen_random_uuid()` | Primary key |
| `client_id` | UUID | NO | - | FK to clients |
| `project_id` | UUID | YES | - | FK to projects |
| `created_by_user_id` | UUID | NO | - | FK to client_users |
| `title` | VARCHAR(500) | NO | - | Ticket title |
| `description` | TEXT | NO | - | Ticket description |
| `status` | ENUM | NO | `open` | Ticket status |
| `priority` | ENUM | NO | `medium` | Priority level |
| `category` | ENUM | NO | `general` | Ticket category |
| `related_issue_id` | UUID | YES | - | Legacy: single issue |
| `assigned_to` | VARCHAR(255) | YES | - | Assigned admin |
| `internal_notes` | TEXT | YES | - | Admin-only notes |
| `resolution` | TEXT | YES | - | Resolution details |
| `resolved_at` | TIMESTAMP | YES | - | Resolution time |
| `closed_at` | TIMESTAMP | YES | - | Close time |
| `created_at` | TIMESTAMP | NO | `NOW()` | Created timestamp |
| `updated_at` | TIMESTAMP | NO | `NOW()` | Last update |

**Indexes:**
- `idx_client_tickets_client_id` on `client_id`
- `idx_client_tickets_project_id` on `project_id`
- `idx_client_tickets_status` on `status`
- `idx_client_tickets_created_at` on `created_at DESC`

**Constraints:**
- FK to `clients(id)` ON DELETE CASCADE
- FK to `projects(id)` ON DELETE SET NULL
- FK to `client_users(id)` ON DELETE CASCADE
- FK to `accessibility_issues(id)` ON DELETE SET NULL (for related_issue_id)

---

#### `client_ticket_issues`

Junction table for tickets with multiple related issues.

| Column | Type | Nullable | Default | Description |
|--------|------|----------|---------|-------------|
| `id` | UUID | NO | `gen_random_uuid()` | Primary key |
| `ticket_id` | UUID | NO | - | FK to client_tickets |
| `issue_id` | UUID | NO | - | FK to accessibility_issues |
| `created_at` | TIMESTAMP | NO | `NOW()` | Created timestamp |

**Constraints:**
- `unique_ticket_issue` (UNIQUE) on `(ticket_id, issue_id)`
- FK to `client_tickets(id)` ON DELETE CASCADE
- FK to `accessibility_issues(id)` ON DELETE CASCADE

---

#### `notifications`

System and admin notifications for clients.

| Column | Type | Nullable | Default | Description |
|--------|------|----------|---------|-------------|
| `id` | UUID | NO | `gen_random_uuid()` | Primary key |
| `client_id` | UUID | YES | - | FK to clients (null=all) |
| `user_id` | UUID | YES | - | FK to client_users |
| `type` | ENUM | NO | `system` | Notification type |
| `priority` | ENUM | NO | `normal` | Priority level |
| `title` | VARCHAR(255) | NO | - | Notification title |
| `message` | TEXT | NO | - | Message content |
| `action_url` | VARCHAR(500) | YES | - | Link URL |
| `action_label` | VARCHAR(100) | YES | - | Link label |
| `related_project_id` | UUID | YES | - | Related project |
| `related_document_id` | UUID | YES | - | Related document |
| `related_ticket_id` | UUID | YES | - | Related ticket |
| `metadata` | JSONB | YES | `{}` | Additional data |
| `is_read` | BOOLEAN | NO | `false` | Is read? |
| `read_at` | TIMESTAMP | YES | - | When read |
| `is_archived` | BOOLEAN | NO | `false` | Is archived? |
| `archived_at` | TIMESTAMP | YES | - | When archived |
| `expires_at` | TIMESTAMP | YES | - | Expiration time |
| `created_at` | TIMESTAMP | NO | `NOW()` | Created timestamp |
| `updated_at` | TIMESTAMP | NO | `NOW()` | Last update |

**Indexes:**
- `idx_notifications_client_id` on `client_id`
- `idx_notifications_user_id` on `user_id`
- `idx_notifications_type` on `type`
- `idx_notifications_is_read` on `is_read`
- `idx_notifications_is_archived` on `is_archived`
- `idx_notifications_created_at` on `created_at DESC`
- Partial: `idx_notifications_expires_at` WHERE `expires_at IS NOT NULL`
- Partial: `idx_notifications_user_unread` WHERE `is_read = false AND is_archived = false`
- Partial: `idx_notifications_client_unread` WHERE `is_read = false AND is_archived = false`

---

#### `evidence_documents`

Compliance documents in the Evidence Locker.

| Column | Type | Nullable | Default | Description |
|--------|------|----------|---------|-------------|
| `id` | UUID | NO | `gen_random_uuid()` | Primary key |
| `client_id` | UUID | NO | - | FK to clients |
| `project_id` | UUID | YES | - | FK to projects |
| `title` | VARCHAR(500) | NO | - | Document title |
| `description` | TEXT | YES | - | Description |
| `document_type` | ENUM | NO | - | Type of document |
| `status` | ENUM | NO | `draft` | Document status |
| `priority` | ENUM | NO | `medium` | Priority |
| `wcag_coverage` | JSONB | YES | `[]` | WCAG criteria covered |
| `file_url` | VARCHAR(1000) | YES | - | File URL |
| `file_name` | VARCHAR(255) | YES | - | File name |
| `file_size` | INTEGER | YES | - | Size in bytes |
| `file_type` | VARCHAR(50) | YES | - | File type |
| `version` | VARCHAR(50) | YES | `1.0` | Version number |
| `valid_until` | TIMESTAMP | YES | - | Validity end date |
| `certified_at` | TIMESTAMP | YES | - | Certification date |
| `certified_by` | VARCHAR(255) | YES | - | Certifier |
| `notes` | TEXT | YES | - | Notes |
| `created_by` | VARCHAR(255) | YES | - | Creator |
| `created_at` | TIMESTAMP | NO | `NOW()` | Created timestamp |
| `updated_at` | TIMESTAMP | NO | `NOW()` | Last update |

**Indexes:**
- `idx_evidence_documents_client_id` on `client_id`
- `idx_evidence_documents_project_id` on `project_id`
- `idx_evidence_documents_status` on `status`
- `idx_evidence_documents_document_type` on `document_type`
- `idx_evidence_documents_updated_at` on `updated_at DESC`

---

#### `document_remediations`

PDF remediation requests from clients.

| Column | Type | Nullable | Default | Description |
|--------|------|----------|---------|-------------|
| `id` | UUID | NO | `gen_random_uuid()` | Primary key |
| `client_id` | UUID | NO | - | FK to clients |
| `uploaded_by_user_id` | UUID | NO | - | FK to client_users |
| `batch_id` | VARCHAR(100) | YES | - | Upload batch ID |
| `original_file_name` | VARCHAR(500) | NO | - | Original filename |
| `original_file_url` | VARCHAR(1000) | NO | - | Original file URL |
| `original_file_size` | INTEGER | YES | - | File size |
| `original_file_type` | VARCHAR(50) | YES | - | File type |
| `page_count` | INTEGER | NO | `1` | Number of pages |
| `remediation_type` | ENUM | NO | - | Remediation type |
| `status` | ENUM | NO | `pending_review` | Status |
| `price_per_page` | NUMERIC(10,2) | NO | - | Per-page price |
| `total_price` | NUMERIC(10,2) | NO | - | Total price |
| `price_adjusted` | BOOLEAN | YES | `false` | Price adjusted? |
| `original_price_per_page` | NUMERIC(10,2) | YES | - | Original price |
| `original_total_price` | NUMERIC(10,2) | YES | - | Original total |
| `remediated_file_name` | VARCHAR(500) | YES | - | Output filename |
| `remediated_file_url` | VARCHAR(1000) | YES | - | Output URL |
| `remediated_file_size` | INTEGER | YES | - | Output size |
| `remediated_file_type` | VARCHAR(50) | YES | - | Output type |
| `notes` | TEXT | YES | - | Client notes |
| `admin_notes` | TEXT | YES | - | Admin notes |
| `reviewed_by_user_id` | UUID | YES | - | Reviewer |
| `reviewed_at` | TIMESTAMP | YES | - | Review time |
| `rejection_reason` | TEXT | YES | - | Rejection reason |
| `completed_at` | TIMESTAMP | YES | - | Completion time |
| `created_at` | TIMESTAMP | NO | `NOW()` | Created timestamp |
| `updated_at` | TIMESTAMP | NO | `NOW()` | Last update |

**Indexes:**
- `idx_document_remediations_client_id` on `client_id`
- `idx_document_remediations_uploaded_by` on `uploaded_by_user_id`
- `idx_document_remediations_status` on `status`
- `idx_document_remediations_batch_id` on `batch_id`
- `idx_document_remediations_created_at` on `created_at DESC`

---

### Admin-Only Tables

*For brevity, see the SQL setup script for complete column definitions of:*

- `tickets` - Internal work tickets
- `ticket_attachments` - Files on tickets
- `ticket_comments` - Ticket comments
- `teams` - Internal teams
- `team_members` - Internal team members
- `project_team_assignments` - Team → Project links
- `project_staging_credentials` - Environment credentials
- `client_credentials` - Client platform creds
- `client_files` - Client document uploads
- `project_documents` - Project docs
- `project_activities` - Activity log
- `project_developers` - Dev assignments
- `project_milestones` - Milestones
- `project_time_entries` - Time tracking
- `sync_logs` - Sync logs
- `project_sync_status` - Sync status
- `checkpoint_sync` - Sync checkpoints
- `status` - URL status
- `status_check` - Status checks
- `wcag_url_check` - WCAG per URL
- `issue_comments` - Issue comments

---

## Entity Relationship Diagram

```
┌─────────────────────────────────────────────────────────────────────────────────────────┐
│                              ENTITY RELATIONSHIP DIAGRAM                                 │
└─────────────────────────────────────────────────────────────────────────────────────────┘

                                    ┌───────────────┐
                                    │    clients    │
                                    │───────────────│
                                    │ id (PK)       │
                                    │ name          │
                                    │ email (UQ)    │
                                    │ company       │
                                    │ status        │
                                    │ client_type   │
                                    │ ...           │
                                    └───────┬───────┘
                                            │
              ┌─────────────────────────────┼─────────────────────────────┐
              │                             │                             │
              ▼                             ▼                             ▼
    ┌─────────────────┐           ┌─────────────────┐           ┌─────────────────┐
    │  client_users   │           │    projects     │           │ client_tickets  │
    │─────────────────│           │─────────────────│           │─────────────────│
    │ id (PK)         │           │ id (PK)         │           │ id (PK)         │
    │ clerk_user_id   │◄──────────│ client_id (FK)  │──────────►│ client_id (FK)  │
    │ client_id (FK)  │           │ name            │           │ project_id (FK) │
    │ email           │           │ sheet_id        │           │ created_by (FK) │
    │ role            │           │ status          │           │ status          │
    │ ...             │           │ wcag_level      │           │ ...             │
    └────────┬────────┘           │ ...             │           └─────────────────┘
             │                    └────────┬────────┘
             │                             │
             │              ┌──────────────┴──────────────┐
             │              │                             │
             │              ▼                             ▼
             │    ┌─────────────────┐           ┌─────────────────┐
             │    │   test_urls     │           │    reports      │
             │    │─────────────────│           │─────────────────│
             │    │ id (PK)         │           │ id (PK)         │
             │    │ project_id (FK) │           │ project_id (FK) │
             │    │ url             │           │ title           │
             │    │ page_title      │           │ report_type     │
             │    │ ...             │           │ status          │
             │    └────────┬────────┘           │ ...             │
             │             │                    └────────┬────────┘
             │             │                             │
             │             ▼                             │
             │    ┌────────────────────────┐             │
             │    │  accessibility_issues  │             │
             │    │  ⭐ CRITICAL TABLE ⭐   │             │
             │    │────────────────────────│             │
             │    │ id (PK)                │             │
             │    │ project_id (FK)        │             │
             │    │ url_id (FK)            │◄────────────┤
             │    │ issue_id               │             │
             │    │ issue_title            │             │
             │    │ severity               │             │
             │    │ dev_status             │             │
             │    │ qa_status              │             │
             │    │ ⚠️ sent_to_user ⚠️     │             │
             │    │ ...                    │             │
             │    └────────────────────────┘             │
             │                                          │
             │              ┌───────────────────────────┘
             │              │
             │              ▼
             │    ┌─────────────────┐
             │    │  report_issues  │
             │    │─────────────────│
             │    │ id (PK)         │
             │    │ report_id (FK)  │
             │    │ issue_id (FK)   │
             │    └─────────────────┘
             │
             ▼
    ┌────────────────────┐           ┌────────────────────┐
    │ project_team_      │           │ client_team_       │
    │ members            │           │ members            │
    │────────────────────│           │────────────────────│
    │ id (PK)            │           │ id (PK)            │
    │ project_id (FK)    │           │ client_id (FK)     │
    │ team_member_id (FK)│           │ name               │
    │ role               │           │ email              │
    │ ...                │           │ invitation_status  │
    └────────────────────┘           │ linked_user_id (FK)│
                                     │ ...                │
                                     └────────────────────┘
```

---

## Critical Fields & Data Flow

### Issue Visibility Flow

```
┌───────────────────────────────────────────────────────────────────────────────────────┐
│                           ISSUE VISIBILITY CONTROL FLOW                                │
├───────────────────────────────────────────────────────────────────────────────────────┤
│                                                                                        │
│   ADMIN DASHBOARD                                                                      │
│   ═══════════════                                                                      │
│                                                                                        │
│   1. QA finds issue → Creates in Admin                                                 │
│      ┌─────────────────────────────────────────┐                                      │
│      │ accessibility_issues                     │                                      │
│      │   sent_to_user: FALSE  ← Not visible    │                                      │
│      │   severity: "1_critical"                 │                                      │
│      │   dev_status: "not_started"             │                                      │
│      └─────────────────────────────────────────┘                                      │
│                                                                                        │
│   2. Admin reviews & approves → Marks sent_to_user = TRUE                             │
│      ┌─────────────────────────────────────────┐                                      │
│      │ accessibility_issues                     │                                      │
│      │   sent_to_user: TRUE   ← NOW VISIBLE    │                                      │
│      │   sent_date: "2026-01-05"               │                                      │
│      │   sent_month: "January"                 │                                      │
│      └─────────────────────────────────────────┘                                      │
│                                                                                        │
│   CLIENT PORTAL                                                                        │
│   ═════════════                                                                        │
│                                                                                        │
│   3. Client Portal queries:                                                           │
│      SELECT * FROM accessibility_issues                                               │
│      WHERE project_id = $1                                                            │
│        AND sent_to_user = TRUE  ← CRITICAL FILTER                                     │
│        AND is_active = TRUE                                                           │
│                                                                                        │
│   4. Client sees only approved issues in their dashboard                              │
│                                                                                        │
└───────────────────────────────────────────────────────────────────────────────────────┘
```

### User Authentication Flow

```
┌───────────────────────────────────────────────────────────────────────────────────────┐
│                          CLIENT USER AUTHENTICATION FLOW                               │
├───────────────────────────────────────────────────────────────────────────────────────┤
│                                                                                        │
│   1. New client signs up on Portal                                                    │
│      └─► Clerk creates user in Portal Clerk App                                       │
│                                                                                        │
│   2. Clerk webhook fires to Portal API                                                │
│      └─► POST /api/webhooks/clerk                                                     │
│          {                                                                            │
│            "type": "user.created",                                                    │
│            "data": { "id": "user_abc123", "email": "user@example.com" }               │
│          }                                                                            │
│                                                                                        │
│   3. Portal creates/updates client_users record                                       │
│      ┌─────────────────────────────────────────┐                                      │
│      │ client_users                            │                                      │
│      │   clerk_user_id: "user_abc123"          │                                      │
│      │   client_id: (matched by email)         │                                      │
│      │   email: "user@example.com"             │                                      │
│      │   role: "owner" (first user) / "viewer" │                                      │
│      └─────────────────────────────────────────┘                                      │
│                                                                                        │
│   4. User logs in → Portal queries:                                                   │
│      SELECT * FROM clients c                                                          │
│      JOIN client_users cu ON c.id = cu.client_id                                      │
│      WHERE cu.clerk_user_id = $1                                                      │
│        AND cu.is_active = TRUE                                                        │
│                                                                                        │
│   5. User sees their client's projects, issues, reports                               │
│                                                                                        │
└───────────────────────────────────────────────────────────────────────────────────────┘
```

---

## Indexes & Performance

### Most Important Indexes

| Table | Index | Purpose |
|-------|-------|---------|
| `accessibility_issues` | `sent_to_user_idx` | Portal issue filtering |
| `accessibility_issues` | `project_id_idx` | Project issue lookup |
| `accessibility_issues` | `severity_idx` | Dashboard stats |
| `projects` | `client_id_idx` | Client project lookup |
| `client_users` | `clerk_user_id_idx` | Auth lookup |
| `notifications` | `user_unread_idx` | Notification bell |

### Performance Tips

1. **Always filter by `sent_to_user`** in Portal queries
2. **Use project_id first** in compound queries
3. **Partial indexes** are created for common WHERE clauses
4. **JSONB indexes** (GIN) exist on metadata columns

---

## Common Query Patterns

### Portal: Get Client's Visible Issues

```sql
SELECT ai.*
FROM accessibility_issues ai
JOIN projects p ON ai.project_id = p.id
WHERE p.client_id = $1
  AND ai.sent_to_user = TRUE
  AND ai.is_active = TRUE
ORDER BY ai.severity ASC, ai.created_at DESC;
```

### Portal: Get User's Accessible Projects

```sql
SELECT p.*
FROM projects p
JOIN project_team_members ptm ON p.id = ptm.project_id
JOIN client_users cu ON ptm.team_member_id = cu.id
WHERE cu.clerk_user_id = $1
  AND cu.is_active = TRUE
ORDER BY p.updated_at DESC;
```

### Admin: Get All Issues (Including Hidden)

```sql
SELECT ai.*, tu.url, tu.page_title
FROM accessibility_issues ai
LEFT JOIN test_urls tu ON ai.url_id = tu.id
WHERE ai.project_id = $1
  AND ai.is_active = TRUE
ORDER BY ai.severity ASC, ai.discovered_at DESC;
```

### Admin: Mark Issues as Visible to Client

```sql
UPDATE accessibility_issues
SET 
  sent_to_user = TRUE,
  sent_date = NOW(),
  sent_month = TO_CHAR(NOW(), 'Month'),
  updated_at = NOW()
WHERE id = ANY($1::uuid[])
  AND sent_to_user = FALSE;
```

---

## Next Steps

1. Run `scripts/000_full_database_setup.sql` to set up a fresh database
2. Review the SQL script for all table definitions and indexes
3. Use Drizzle ORM for type-safe database operations in TypeScript

---

*This documentation is auto-generated from the Drizzle schema files in both `a3s-admin` and `a3s-client-portal`.*

