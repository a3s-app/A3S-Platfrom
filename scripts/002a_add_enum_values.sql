-- ============================================================================
-- A3S PLATFORM - PART A: ADD ENUM VALUES
-- ============================================================================
-- 
-- IMPORTANT: Run this script FIRST, then run 002b_create_tables.sql
--
-- PostgreSQL requires new enum values to be COMMITTED before they can be 
-- used as DEFAULT values in table definitions. This script adds all missing
-- enum values and must complete before running part B.
--
-- TARGET: New database (kwxnfskctsfccvysokxo)
--
-- Usage:
--   Step 1: Run this script (002a_add_enum_values.sql)
--   Step 2: Run 002b_create_tables.sql
--
-- Last Generated: January 2026
-- ============================================================================

-- Enable required extensions
CREATE EXTENSION IF NOT EXISTS "uuid-ossp";
CREATE EXTENSION IF NOT EXISTS "pgcrypto";

-- ============================================================================
-- ADD MISSING VALUES TO EXISTING ENUMS
-- ============================================================================

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
-- CREATE NEW ENUMS (15 total)
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
-- VERIFICATION
-- ============================================================================
SELECT 'Enum values added successfully!' as status;
SELECT 'Now run 002b_create_tables.sql' as next_step;

