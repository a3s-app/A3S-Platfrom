-- ============================================================================
-- A3S PLATFORM - MIGRATION SCRIPT TO MATCH PRODUCTION SCHEMA
-- ============================================================================
-- 
-- This script migrates a partial database to match the full production schema.
-- Run this on a database that has some tables but is missing others.
--
-- SOURCE: Production database (nsaovodiykewfluipkam)
-- TARGET: New database (kwxnfskctsfccvysokxo)
--
-- DIFFERENCES FOUND:
--   - 15 missing enums
--   - 13 missing tables
--   - 4 missing columns in existing tables
--
-- IDEMPOTENT: Safe to run multiple times
-- Last Generated: January 2026
-- ============================================================================

-- Enable required extensions
CREATE EXTENSION IF NOT EXISTS "uuid-ossp";
CREATE EXTENSION IF NOT EXISTS "pgcrypto";

-- ============================================================================
-- SECTION 0: ADD MISSING VALUES TO EXISTING ENUMS
-- ============================================================================
-- These enums exist in the new DB but are missing some values from production

-- ticket_status - add missing values
ALTER TYPE ticket_status ADD VALUE IF NOT EXISTS 'needs_attention';
ALTER TYPE ticket_status ADD VALUE IF NOT EXISTS 'third_party';
ALTER TYPE ticket_status ADD VALUE IF NOT EXISTS 'fixed';

-- ticket_priority - ensure all values exist
ALTER TYPE ticket_priority ADD VALUE IF NOT EXISTS 'low';
ALTER TYPE ticket_priority ADD VALUE IF NOT EXISTS 'medium';
ALTER TYPE ticket_priority ADD VALUE IF NOT EXISTS 'high';
ALTER TYPE ticket_priority ADD VALUE IF NOT EXISTS 'critical';
ALTER TYPE ticket_priority ADD VALUE IF NOT EXISTS 'urgent';

-- ============================================================================
-- SECTION 1: ADD MISSING ENUMS (15 total)
-- ============================================================================

-- 1. admin_notification_type
DO $$ BEGIN CREATE TYPE admin_notification_type AS ENUM ('system'); EXCEPTION WHEN duplicate_object THEN NULL; END $$;
ALTER TYPE admin_notification_type ADD VALUE IF NOT EXISTS 'new_ticket';
ALTER TYPE admin_notification_type ADD VALUE IF NOT EXISTS 'new_remediation_request';
ALTER TYPE admin_notification_type ADD VALUE IF NOT EXISTS 'new_document_request';
ALTER TYPE admin_notification_type ADD VALUE IF NOT EXISTS 'client_signup';
ALTER TYPE admin_notification_type ADD VALUE IF NOT EXISTS 'system';
ALTER TYPE admin_notification_type ADD VALUE IF NOT EXISTS 'custom';

-- 2. billing_addon_status
DO $$ BEGIN CREATE TYPE billing_addon_status AS ENUM ('active'); EXCEPTION WHEN duplicate_object THEN NULL; END $$;
ALTER TYPE billing_addon_status ADD VALUE IF NOT EXISTS 'active';
ALTER TYPE billing_addon_status ADD VALUE IF NOT EXISTS 'cancelled';
ALTER TYPE billing_addon_status ADD VALUE IF NOT EXISTS 'pending';

-- 3. billing_addon_type
DO $$ BEGIN CREATE TYPE billing_addon_type AS ENUM ('custom'); EXCEPTION WHEN duplicate_object THEN NULL; END $$;
ALTER TYPE billing_addon_type ADD VALUE IF NOT EXISTS 'team_members';
ALTER TYPE billing_addon_type ADD VALUE IF NOT EXISTS 'document_remediation';
ALTER TYPE billing_addon_type ADD VALUE IF NOT EXISTS 'evidence_locker';
ALTER TYPE billing_addon_type ADD VALUE IF NOT EXISTS 'custom';

-- 4. document_priority
DO $$ BEGIN CREATE TYPE document_priority AS ENUM ('medium'); EXCEPTION WHEN duplicate_object THEN NULL; END $$;
ALTER TYPE document_priority ADD VALUE IF NOT EXISTS 'low';
ALTER TYPE document_priority ADD VALUE IF NOT EXISTS 'medium';
ALTER TYPE document_priority ADD VALUE IF NOT EXISTS 'high';
ALTER TYPE document_priority ADD VALUE IF NOT EXISTS 'critical';

-- 5. document_request_status
DO $$ BEGIN CREATE TYPE document_request_status AS ENUM ('pending'); EXCEPTION WHEN duplicate_object THEN NULL; END $$;
ALTER TYPE document_request_status ADD VALUE IF NOT EXISTS 'pending';
ALTER TYPE document_request_status ADD VALUE IF NOT EXISTS 'in_progress';
ALTER TYPE document_request_status ADD VALUE IF NOT EXISTS 'completed';
ALTER TYPE document_request_status ADD VALUE IF NOT EXISTS 'rejected';

-- 6. document_status
DO $$ BEGIN CREATE TYPE document_status AS ENUM ('draft'); EXCEPTION WHEN duplicate_object THEN NULL; END $$;
ALTER TYPE document_status ADD VALUE IF NOT EXISTS 'draft';
ALTER TYPE document_status ADD VALUE IF NOT EXISTS 'pending_review';
ALTER TYPE document_status ADD VALUE IF NOT EXISTS 'certified';
ALTER TYPE document_status ADD VALUE IF NOT EXISTS 'active';
ALTER TYPE document_status ADD VALUE IF NOT EXISTS 'archived';

-- 7. invitation_status
DO $$ BEGIN CREATE TYPE invitation_status AS ENUM ('pending'); EXCEPTION WHEN duplicate_object THEN NULL; END $$;
ALTER TYPE invitation_status ADD VALUE IF NOT EXISTS 'pending';
ALTER TYPE invitation_status ADD VALUE IF NOT EXISTS 'sent';
ALTER TYPE invitation_status ADD VALUE IF NOT EXISTS 'accepted';
ALTER TYPE invitation_status ADD VALUE IF NOT EXISTS 'expired';
ALTER TYPE invitation_status ADD VALUE IF NOT EXISTS 'cancelled';

-- 8. message_sender_type
DO $$ BEGIN CREATE TYPE message_sender_type AS ENUM ('admin'); EXCEPTION WHEN duplicate_object THEN NULL; END $$;
ALTER TYPE message_sender_type ADD VALUE IF NOT EXISTS 'admin';
ALTER TYPE message_sender_type ADD VALUE IF NOT EXISTS 'client';

-- 9. notification_priority
DO $$ BEGIN CREATE TYPE notification_priority AS ENUM ('normal'); EXCEPTION WHEN duplicate_object THEN NULL; END $$;
ALTER TYPE notification_priority ADD VALUE IF NOT EXISTS 'low';
ALTER TYPE notification_priority ADD VALUE IF NOT EXISTS 'normal';
ALTER TYPE notification_priority ADD VALUE IF NOT EXISTS 'high';
ALTER TYPE notification_priority ADD VALUE IF NOT EXISTS 'urgent';

-- 10. notification_type
DO $$ BEGIN CREATE TYPE notification_type AS ENUM ('system'); EXCEPTION WHEN duplicate_object THEN NULL; END $$;
ALTER TYPE notification_type ADD VALUE IF NOT EXISTS 'system';
ALTER TYPE notification_type ADD VALUE IF NOT EXISTS 'project_update';
ALTER TYPE notification_type ADD VALUE IF NOT EXISTS 'document_ready';
ALTER TYPE notification_type ADD VALUE IF NOT EXISTS 'document_approved';
ALTER TYPE notification_type ADD VALUE IF NOT EXISTS 'document_rejected';
ALTER TYPE notification_type ADD VALUE IF NOT EXISTS 'report_ready';
ALTER TYPE notification_type ADD VALUE IF NOT EXISTS 'team_invite';
ALTER TYPE notification_type ADD VALUE IF NOT EXISTS 'ticket_update';
ALTER TYPE notification_type ADD VALUE IF NOT EXISTS 'evidence_update';
ALTER TYPE notification_type ADD VALUE IF NOT EXISTS 'billing';
ALTER TYPE notification_type ADD VALUE IF NOT EXISTS 'reminder';

-- 11. project_role
DO $$ BEGIN CREATE TYPE project_role AS ENUM ('project_member'); EXCEPTION WHEN duplicate_object THEN NULL; END $$;
ALTER TYPE project_role ADD VALUE IF NOT EXISTS 'project_admin';
ALTER TYPE project_role ADD VALUE IF NOT EXISTS 'project_member';

-- 12. remediation_status
DO $$ BEGIN CREATE TYPE remediation_status AS ENUM ('pending'); EXCEPTION WHEN duplicate_object THEN NULL; END $$;
ALTER TYPE remediation_status ADD VALUE IF NOT EXISTS 'pending';
ALTER TYPE remediation_status ADD VALUE IF NOT EXISTS 'pending_review';
ALTER TYPE remediation_status ADD VALUE IF NOT EXISTS 'approved';
ALTER TYPE remediation_status ADD VALUE IF NOT EXISTS 'in_progress';
ALTER TYPE remediation_status ADD VALUE IF NOT EXISTS 'completed';
ALTER TYPE remediation_status ADD VALUE IF NOT EXISTS 'rejected';

-- 13. remediation_type
DO $$ BEGIN CREATE TYPE remediation_type AS ENUM ('traditional_pdf'); EXCEPTION WHEN duplicate_object THEN NULL; END $$;
ALTER TYPE remediation_type ADD VALUE IF NOT EXISTS 'traditional_pdf';
ALTER TYPE remediation_type ADD VALUE IF NOT EXISTS 'html_alternative';

-- 14. ticket_category
DO $$ BEGIN CREATE TYPE ticket_category AS ENUM ('general'); EXCEPTION WHEN duplicate_object THEN NULL; END $$;
ALTER TYPE ticket_category ADD VALUE IF NOT EXISTS 'technical';
ALTER TYPE ticket_category ADD VALUE IF NOT EXISTS 'billing';
ALTER TYPE ticket_category ADD VALUE IF NOT EXISTS 'general';
ALTER TYPE ticket_category ADD VALUE IF NOT EXISTS 'feature_request';
ALTER TYPE ticket_category ADD VALUE IF NOT EXISTS 'bug_report';
ALTER TYPE ticket_category ADD VALUE IF NOT EXISTS 'other';

-- 15. user_role
DO $$ BEGIN CREATE TYPE user_role AS ENUM ('viewer'); EXCEPTION WHEN duplicate_object THEN NULL; END $$;
ALTER TYPE user_role ADD VALUE IF NOT EXISTS 'owner';
ALTER TYPE user_role ADD VALUE IF NOT EXISTS 'admin';
ALTER TYPE user_role ADD VALUE IF NOT EXISTS 'member';
ALTER TYPE user_role ADD VALUE IF NOT EXISTS 'viewer';
ALTER TYPE user_role ADD VALUE IF NOT EXISTS 'editor';

-- ============================================================================
-- SECTION 2: ADD MISSING TABLES (13 total)
-- ============================================================================

-- 2.1 Client Users Table
CREATE TABLE IF NOT EXISTS client_users (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    clerk_user_id VARCHAR(255) NOT NULL,
    client_id UUID NOT NULL REFERENCES clients(id) ON DELETE CASCADE,
    email VARCHAR(255) NOT NULL,
    first_name VARCHAR(100),
    last_name VARCHAR(100),
    role user_role NOT NULL DEFAULT 'viewer',
    is_active BOOLEAN NOT NULL DEFAULT true,
    email_notifications BOOLEAN NOT NULL DEFAULT true,
    last_login_at TIMESTAMP,
    created_at TIMESTAMP NOT NULL DEFAULT NOW(),
    updated_at TIMESTAMP NOT NULL DEFAULT NOW()
);

-- 2.2 Client Team Members Table
CREATE TABLE IF NOT EXISTS client_team_members (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    client_id UUID NOT NULL REFERENCES clients(id) ON DELETE CASCADE,
    name VARCHAR(255) NOT NULL,
    email VARCHAR(255) NOT NULL,
    description TEXT,
    invitation_status invitation_status NOT NULL DEFAULT 'pending',
    invitation_sent_at TIMESTAMP,
    invitation_token VARCHAR(255),
    invited_by_user_id UUID,
    accepted_at TIMESTAMP,
    linked_user_id UUID,
    created_at TIMESTAMP NOT NULL DEFAULT NOW(),
    updated_at TIMESTAMP NOT NULL DEFAULT NOW(),
    clerk_invitation_id VARCHAR(255),
    pending_project_ids JSONB DEFAULT '[]'
);

-- 2.3 Project Team Members Table
CREATE TABLE IF NOT EXISTS project_team_members (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    project_id UUID NOT NULL REFERENCES projects(id) ON DELETE CASCADE,
    team_member_id UUID NOT NULL REFERENCES client_team_members(id) ON DELETE CASCADE,
    role project_role NOT NULL DEFAULT 'project_member',
    created_at TIMESTAMP NOT NULL DEFAULT NOW(),
    updated_at TIMESTAMP NOT NULL DEFAULT NOW(),
    display_name VARCHAR(255)
);

-- 2.4 Client Tickets Table
CREATE TABLE IF NOT EXISTS client_tickets (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    client_id UUID NOT NULL REFERENCES clients(id) ON DELETE CASCADE,
    project_id UUID REFERENCES projects(id) ON DELETE SET NULL,
    title VARCHAR(500) NOT NULL,
    description TEXT NOT NULL,
    status ticket_status NOT NULL DEFAULT 'needs_attention',
    priority ticket_priority NOT NULL DEFAULT 'medium',
    category VARCHAR(50) NOT NULL DEFAULT 'technical',
    created_by UUID,
    assigned_to UUID,
    created_at TIMESTAMP NOT NULL DEFAULT NOW(),
    updated_at TIMESTAMP NOT NULL DEFAULT NOW(),
    issues_id VARCHAR(255),
    created_by_user_id UUID,
    related_issue_id UUID,
    internal_notes TEXT,
    resolution TEXT,
    resolved_at TIMESTAMP,
    closed_at TIMESTAMP
);

-- 2.5 Client Ticket Issues Junction Table
CREATE TABLE IF NOT EXISTS client_ticket_issues (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    ticket_id UUID NOT NULL REFERENCES client_tickets(id) ON DELETE CASCADE,
    issue_id UUID NOT NULL REFERENCES accessibility_issues(id) ON DELETE CASCADE,
    created_at TIMESTAMP NOT NULL DEFAULT NOW()
);

-- 2.6 Evidence Documents Table
CREATE TABLE IF NOT EXISTS evidence_documents (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    client_id UUID NOT NULL REFERENCES clients(id) ON DELETE CASCADE,
    project_id UUID REFERENCES projects(id) ON DELETE SET NULL,
    title VARCHAR(500) NOT NULL,
    description TEXT,
    document_type document_type NOT NULL,
    status document_status NOT NULL DEFAULT 'draft',
    priority document_priority NOT NULL DEFAULT 'medium',
    wcag_coverage JSONB DEFAULT '[]',
    file_url VARCHAR(1000),
    file_name VARCHAR(255),
    file_size INTEGER,
    file_type VARCHAR(50),
    version VARCHAR(50) DEFAULT '1.0',
    valid_until TIMESTAMP,
    certified_at TIMESTAMP,
    certified_by VARCHAR(255),
    notes TEXT,
    created_by VARCHAR(255),
    created_at TIMESTAMP NOT NULL DEFAULT NOW(),
    updated_at TIMESTAMP NOT NULL DEFAULT NOW()
);

-- 2.7 Evidence Document Requests Table
CREATE TABLE IF NOT EXISTS evidence_document_requests (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    client_id UUID NOT NULL REFERENCES clients(id) ON DELETE CASCADE,
    requested_by_user_id UUID NOT NULL,
    document_type document_type NOT NULL,
    title VARCHAR(500) NOT NULL,
    description TEXT,
    priority document_priority NOT NULL DEFAULT 'medium',
    status document_request_status NOT NULL DEFAULT 'pending',
    admin_notes TEXT,
    completed_document_id UUID,
    created_at TIMESTAMP NOT NULL DEFAULT NOW(),
    updated_at TIMESTAMP NOT NULL DEFAULT NOW()
);

-- 2.8 Document Remediations Table
CREATE TABLE IF NOT EXISTS document_remediations (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    client_id UUID NOT NULL REFERENCES clients(id) ON DELETE CASCADE,
    uploaded_by_user_id UUID NOT NULL,
    batch_id VARCHAR(100),
    original_file_name VARCHAR(500) NOT NULL,
    original_file_url VARCHAR(1000) NOT NULL,
    original_file_size INTEGER,
    original_file_type VARCHAR(50),
    page_count INTEGER NOT NULL DEFAULT 1,
    remediation_type remediation_type NOT NULL,
    status remediation_status NOT NULL DEFAULT 'pending',
    price_per_page NUMERIC(10,2) NOT NULL,
    total_price NUMERIC(10,2) NOT NULL,
    remediated_file_name VARCHAR(500),
    remediated_file_url VARCHAR(1000),
    remediated_file_size INTEGER,
    remediated_file_type VARCHAR(50),
    notes TEXT,
    admin_notes TEXT,
    completed_at TIMESTAMP,
    created_at TIMESTAMP NOT NULL DEFAULT NOW(),
    updated_at TIMESTAMP NOT NULL DEFAULT NOW(),
    price_adjusted BOOLEAN DEFAULT false,
    original_price_per_page NUMERIC(10,2),
    original_total_price NUMERIC(10,2),
    reviewed_by_user_id UUID,
    reviewed_at TIMESTAMP,
    rejection_reason TEXT
);

-- 2.9 Client Billing Addons Table
CREATE TABLE IF NOT EXISTS client_billing_addons (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    client_id UUID NOT NULL REFERENCES clients(id) ON DELETE CASCADE,
    addon_type billing_addon_type NOT NULL,
    name VARCHAR(255) NOT NULL,
    description TEXT,
    quantity INTEGER NOT NULL DEFAULT 1,
    unit_price NUMERIC(10,2) NOT NULL,
    total_monthly_price NUMERIC(10,2) NOT NULL,
    status billing_addon_status NOT NULL DEFAULT 'active',
    activated_at TIMESTAMP NOT NULL DEFAULT NOW(),
    cancelled_at TIMESTAMP,
    metadata JSONB DEFAULT '{}',
    approved_by_user_id UUID,
    created_at TIMESTAMP NOT NULL DEFAULT NOW(),
    updated_at TIMESTAMP NOT NULL DEFAULT NOW()
);

-- 2.10 Notifications Table (Client Portal)
CREATE TABLE IF NOT EXISTS notifications (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    client_id UUID REFERENCES clients(id) ON DELETE CASCADE,
    user_id UUID,
    type notification_type NOT NULL DEFAULT 'system',
    priority notification_priority NOT NULL DEFAULT 'normal',
    title VARCHAR(255) NOT NULL,
    message TEXT NOT NULL,
    action_url VARCHAR(500),
    action_label VARCHAR(100),
    related_project_id UUID,
    related_document_id UUID,
    related_ticket_id UUID,
    metadata JSONB DEFAULT '{}',
    is_read BOOLEAN NOT NULL DEFAULT false,
    read_at TIMESTAMP,
    is_archived BOOLEAN NOT NULL DEFAULT false,
    archived_at TIMESTAMP,
    expires_at TIMESTAMP,
    created_at TIMESTAMP NOT NULL DEFAULT NOW(),
    updated_at TIMESTAMP NOT NULL DEFAULT NOW()
);

-- 2.11 Admin Notifications Table
CREATE TABLE IF NOT EXISTS admin_notifications (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    title VARCHAR(255) NOT NULL,
    message TEXT NOT NULL,
    type admin_notification_type DEFAULT 'system',
    priority VARCHAR(20) DEFAULT 'normal',
    read BOOLEAN NOT NULL DEFAULT false,
    action_url VARCHAR(500),
    action_label VARCHAR(100),
    metadata JSONB DEFAULT '{}',
    related_client_id UUID REFERENCES clients(id) ON DELETE SET NULL,
    related_ticket_id UUID,
    created_at TIMESTAMP NOT NULL DEFAULT NOW(),
    read_at TIMESTAMP
);

-- 2.12 Clerk User ID Backups Table
CREATE TABLE IF NOT EXISTS clerk_user_id_backups (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    client_user_id UUID NOT NULL,
    email VARCHAR(255) NOT NULL,
    old_clerk_user_id VARCHAR(255) NOT NULL,
    new_clerk_user_id VARCHAR(255) NOT NULL,
    migrated_at TIMESTAMP NOT NULL DEFAULT NOW(),
    rolled_back_at TIMESTAMP,
    notes TEXT
);

-- 2.13 Ticket Messages Table
CREATE TABLE IF NOT EXISTS ticket_messages (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    ticket_id UUID NOT NULL REFERENCES client_tickets(id) ON DELETE CASCADE,
    sender_type message_sender_type NOT NULL,
    sender_id UUID,
    sender_name VARCHAR(255),
    content TEXT NOT NULL,
    attachments JSONB DEFAULT '[]',
    is_internal BOOLEAN NOT NULL DEFAULT false,
    read_at TIMESTAMP,
    created_at TIMESTAMP NOT NULL DEFAULT NOW(),
    updated_at TIMESTAMP NOT NULL DEFAULT NOW()
);

-- ============================================================================
-- SECTION 3: ADD MISSING COLUMNS TO EXISTING TABLES (4 columns)
-- ============================================================================

-- Helper function
CREATE OR REPLACE FUNCTION add_column_if_not_exists(
    _table TEXT,
    _column TEXT,
    _type TEXT,
    _default TEXT DEFAULT NULL
) RETURNS VOID AS $$
BEGIN
    IF NOT EXISTS (
        SELECT 1 FROM information_schema.columns 
        WHERE table_schema = 'public' 
        AND table_name = _table 
        AND column_name = _column
    ) THEN
        IF _default IS NOT NULL THEN
            EXECUTE format('ALTER TABLE %I ADD COLUMN %I %s DEFAULT %s', _table, _column, _type, _default);
        ELSE
            EXECUTE format('ALTER TABLE %I ADD COLUMN %I %s', _table, _column, _type);
        END IF;
        RAISE NOTICE 'Added column %.%', _table, _column;
    END IF;
EXCEPTION WHEN others THEN
    RAISE NOTICE 'Could not add column %.%: %', _table, _column, SQLERRM;
END;
$$ LANGUAGE plpgsql;

-- 3.1 clients.team_member_limit
SELECT add_column_if_not_exists('clients', 'team_member_limit', 'INTEGER NOT NULL', '5');

-- 3.2 reports.is_public
SELECT add_column_if_not_exists('reports', 'is_public', 'BOOLEAN NOT NULL', 'false');

-- 3.3 reports.public_token
SELECT add_column_if_not_exists('reports', 'public_token', 'VARCHAR(64)', 'NULL');

-- 3.4 team_members.email_notifications
SELECT add_column_if_not_exists('team_members', 'email_notifications', 'BOOLEAN NOT NULL', 'true');

-- Cleanup helper function
DROP FUNCTION IF EXISTS add_column_if_not_exists(TEXT, TEXT, TEXT, TEXT);

-- ============================================================================
-- SECTION 4: CREATE INDEXES FOR NEW TABLES
-- ============================================================================

-- Client Users indexes
CREATE INDEX IF NOT EXISTS idx_client_users_clerk_user_id ON client_users(clerk_user_id);
CREATE INDEX IF NOT EXISTS idx_client_users_client_id ON client_users(client_id);
CREATE INDEX IF NOT EXISTS idx_client_users_email ON client_users(email);
CREATE UNIQUE INDEX IF NOT EXISTS client_users_clerk_user_id_key ON client_users(clerk_user_id);

-- Client Team Members indexes
CREATE INDEX IF NOT EXISTS idx_client_team_members_client_id ON client_team_members(client_id);
CREATE INDEX IF NOT EXISTS idx_client_team_members_email ON client_team_members(email);
CREATE INDEX IF NOT EXISTS idx_client_team_members_invitation_status ON client_team_members(invitation_status);

-- Project Team Members indexes
CREATE INDEX IF NOT EXISTS idx_project_team_members_project_id ON project_team_members(project_id);
CREATE INDEX IF NOT EXISTS idx_project_team_members_team_member_id ON project_team_members(team_member_id);
CREATE UNIQUE INDEX IF NOT EXISTS project_team_members_project_team_unique ON project_team_members(project_id, team_member_id);

-- Client Tickets indexes
CREATE INDEX IF NOT EXISTS idx_client_tickets_client_id ON client_tickets(client_id);
CREATE INDEX IF NOT EXISTS idx_client_tickets_project_id ON client_tickets(project_id);
CREATE INDEX IF NOT EXISTS idx_client_tickets_status ON client_tickets(status);
CREATE INDEX IF NOT EXISTS idx_client_tickets_created_by ON client_tickets(created_by);

-- Client Ticket Issues indexes
CREATE INDEX IF NOT EXISTS idx_client_ticket_issues_ticket_id ON client_ticket_issues(ticket_id);
CREATE INDEX IF NOT EXISTS idx_client_ticket_issues_issue_id ON client_ticket_issues(issue_id);
CREATE UNIQUE INDEX IF NOT EXISTS client_ticket_issues_unique ON client_ticket_issues(ticket_id, issue_id);

-- Evidence Documents indexes
CREATE INDEX IF NOT EXISTS idx_evidence_documents_client_id ON evidence_documents(client_id);
CREATE INDEX IF NOT EXISTS idx_evidence_documents_project_id ON evidence_documents(project_id);
CREATE INDEX IF NOT EXISTS idx_evidence_documents_status ON evidence_documents(status);
CREATE INDEX IF NOT EXISTS idx_evidence_documents_document_type ON evidence_documents(document_type);

-- Evidence Document Requests indexes
CREATE INDEX IF NOT EXISTS idx_evidence_document_requests_client_id ON evidence_document_requests(client_id);
CREATE INDEX IF NOT EXISTS idx_evidence_document_requests_status ON evidence_document_requests(status);
CREATE INDEX IF NOT EXISTS idx_evidence_document_requests_requested_by ON evidence_document_requests(requested_by_user_id);

-- Document Remediations indexes
CREATE INDEX IF NOT EXISTS idx_document_remediations_client_id ON document_remediations(client_id);
CREATE INDEX IF NOT EXISTS idx_document_remediations_status ON document_remediations(status);
CREATE INDEX IF NOT EXISTS idx_document_remediations_uploaded_by ON document_remediations(uploaded_by_user_id);
CREATE INDEX IF NOT EXISTS idx_document_remediations_batch_id ON document_remediations(batch_id);

-- Client Billing Addons indexes
CREATE INDEX IF NOT EXISTS idx_client_billing_addons_client_id ON client_billing_addons(client_id);
CREATE INDEX IF NOT EXISTS idx_client_billing_addons_status ON client_billing_addons(status);
CREATE INDEX IF NOT EXISTS idx_client_billing_addons_addon_type ON client_billing_addons(addon_type);

-- Notifications indexes
CREATE INDEX IF NOT EXISTS idx_notifications_client_id ON notifications(client_id);
CREATE INDEX IF NOT EXISTS idx_notifications_user_id ON notifications(user_id);
CREATE INDEX IF NOT EXISTS idx_notifications_type ON notifications(type);
CREATE INDEX IF NOT EXISTS idx_notifications_is_read ON notifications(is_read);
CREATE INDEX IF NOT EXISTS idx_notifications_created_at ON notifications(created_at DESC);

-- Admin Notifications indexes
CREATE INDEX IF NOT EXISTS idx_admin_notifications_read ON admin_notifications(read);
CREATE INDEX IF NOT EXISTS idx_admin_notifications_type ON admin_notifications(type);
CREATE INDEX IF NOT EXISTS idx_admin_notifications_created_at ON admin_notifications(created_at DESC);
CREATE INDEX IF NOT EXISTS idx_admin_notifications_related_client_id ON admin_notifications(related_client_id);

-- Clerk User ID Backups indexes
CREATE INDEX IF NOT EXISTS idx_clerk_user_id_backups_client_user_id ON clerk_user_id_backups(client_user_id);
CREATE INDEX IF NOT EXISTS idx_clerk_user_id_backups_email ON clerk_user_id_backups(email);

-- Ticket Messages indexes
CREATE INDEX IF NOT EXISTS idx_ticket_messages_ticket_id ON ticket_messages(ticket_id);
CREATE INDEX IF NOT EXISTS idx_ticket_messages_sender_id ON ticket_messages(sender_id);
CREATE INDEX IF NOT EXISTS idx_ticket_messages_created_at ON ticket_messages(created_at DESC);

-- ============================================================================
-- SECTION 5: ADD FOREIGN KEY CONSTRAINTS
-- ============================================================================

-- Add FK constraints with safe handling
DO $$ BEGIN
    ALTER TABLE client_team_members ADD CONSTRAINT fk_client_team_members_invited_by 
        FOREIGN KEY (invited_by_user_id) REFERENCES client_users(id) ON DELETE SET NULL;
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

DO $$ BEGIN
    ALTER TABLE client_team_members ADD CONSTRAINT fk_client_team_members_linked_user 
        FOREIGN KEY (linked_user_id) REFERENCES client_users(id) ON DELETE SET NULL;
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

DO $$ BEGIN
    ALTER TABLE client_tickets ADD CONSTRAINT fk_client_tickets_created_by 
        FOREIGN KEY (created_by) REFERENCES client_users(id) ON DELETE SET NULL;
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

DO $$ BEGIN
    ALTER TABLE client_tickets ADD CONSTRAINT fk_client_tickets_related_issue 
        FOREIGN KEY (related_issue_id) REFERENCES accessibility_issues(id) ON DELETE SET NULL;
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

DO $$ BEGIN
    ALTER TABLE evidence_document_requests ADD CONSTRAINT fk_evidence_requests_requested_by 
        FOREIGN KEY (requested_by_user_id) REFERENCES client_users(id) ON DELETE CASCADE;
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

DO $$ BEGIN
    ALTER TABLE evidence_document_requests ADD CONSTRAINT fk_evidence_requests_completed_doc 
        FOREIGN KEY (completed_document_id) REFERENCES evidence_documents(id) ON DELETE SET NULL;
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

DO $$ BEGIN
    ALTER TABLE document_remediations ADD CONSTRAINT fk_document_remediations_uploaded_by 
        FOREIGN KEY (uploaded_by_user_id) REFERENCES client_users(id) ON DELETE CASCADE;
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

DO $$ BEGIN
    ALTER TABLE document_remediations ADD CONSTRAINT fk_document_remediations_reviewed_by 
        FOREIGN KEY (reviewed_by_user_id) REFERENCES client_users(id) ON DELETE SET NULL;
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

DO $$ BEGIN
    ALTER TABLE client_billing_addons ADD CONSTRAINT fk_client_billing_addons_approved_by 
        FOREIGN KEY (approved_by_user_id) REFERENCES client_users(id) ON DELETE SET NULL;
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

DO $$ BEGIN
    ALTER TABLE notifications ADD CONSTRAINT fk_notifications_user 
        FOREIGN KEY (user_id) REFERENCES client_users(id) ON DELETE CASCADE;
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

DO $$ BEGIN
    ALTER TABLE notifications ADD CONSTRAINT fk_notifications_project 
        FOREIGN KEY (related_project_id) REFERENCES projects(id) ON DELETE SET NULL;
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

DO $$ BEGIN
    ALTER TABLE notifications ADD CONSTRAINT fk_notifications_document 
        FOREIGN KEY (related_document_id) REFERENCES evidence_documents(id) ON DELETE SET NULL;
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

DO $$ BEGIN
    ALTER TABLE notifications ADD CONSTRAINT fk_notifications_ticket 
        FOREIGN KEY (related_ticket_id) REFERENCES client_tickets(id) ON DELETE SET NULL;
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

DO $$ BEGIN
    ALTER TABLE admin_notifications ADD CONSTRAINT fk_admin_notifications_ticket 
        FOREIGN KEY (related_ticket_id) REFERENCES client_tickets(id) ON DELETE SET NULL;
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

DO $$ BEGIN
    ALTER TABLE clerk_user_id_backups ADD CONSTRAINT fk_clerk_backups_client_user 
        FOREIGN KEY (client_user_id) REFERENCES client_users(id) ON DELETE CASCADE;
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- ============================================================================
-- SECTION 6: UPDATE TRIGGERS
-- ============================================================================

-- Create/update function for updated_at trigger
CREATE OR REPLACE FUNCTION update_updated_at_column()
RETURNS TRIGGER AS $$
BEGIN
    NEW.updated_at = NOW();
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- Add triggers to new tables
DO $$
DECLARE
    t RECORD;
BEGIN
    FOR t IN 
        SELECT table_name 
        FROM information_schema.columns 
        WHERE column_name = 'updated_at' 
        AND table_schema = 'public'
        AND table_name IN (
            'client_users', 'client_team_members', 'project_team_members',
            'client_tickets', 'evidence_documents', 'evidence_document_requests',
            'document_remediations', 'client_billing_addons', 'notifications',
            'ticket_messages'
        )
    LOOP
        EXECUTE format('DROP TRIGGER IF EXISTS update_%I_updated_at ON %I', t.table_name, t.table_name);
        EXECUTE format('
            CREATE TRIGGER update_%I_updated_at
            BEFORE UPDATE ON %I
            FOR EACH ROW
            EXECUTE FUNCTION update_updated_at_column()
        ', t.table_name, t.table_name);
    END LOOP;
END $$;

-- ============================================================================
-- SECTION 7: VERIFICATION
-- ============================================================================

SELECT 'Migration Summary:' as info;
SELECT 'Tables:' as metric, COUNT(*) as count FROM information_schema.tables WHERE table_schema = 'public' AND table_type = 'BASE TABLE';
SELECT 'Enums:' as metric, COUNT(*) as count FROM pg_type WHERE typtype = 'e' AND typnamespace = (SELECT oid FROM pg_namespace WHERE nspname = 'public');
SELECT 'Indexes:' as metric, COUNT(*) as count FROM pg_indexes WHERE schemaname = 'public';

SELECT 'Migration to production schema complete!' as status;

