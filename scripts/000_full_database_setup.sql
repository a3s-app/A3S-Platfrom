-- ============================================================================
-- A3S PLATFORM - COMPLETE DATABASE SETUP SCRIPT
-- ============================================================================
-- 
-- This script creates all tables, enums, indexes, and constraints needed for
-- both the Admin Dashboard and Client Portal applications.
--
-- IDEMPOTENT: Safe to run multiple times - uses IF NOT EXISTS patterns
-- 
-- ENUM HANDLING: 
--   - Creates enum if it doesn't exist
--   - Adds missing values to existing enums (won't break existing data)
--
-- Usage:
--   psql -d your_database -f 000_full_database_setup.sql
--   OR
--   Run via Supabase SQL Editor
--
-- Last Updated: January 2026
-- ============================================================================

-- Enable UUID extension (required for gen_random_uuid())
CREATE EXTENSION IF NOT EXISTS "uuid-ossp";
CREATE EXTENSION IF NOT EXISTS "pgcrypto";

-- ============================================================================
-- SECTION 1: ENUM TYPES
-- ============================================================================
-- 
-- Strategy: First try to create enum, then add any missing values
-- This ensures both fresh installs AND updates work correctly
--
-- Note: ALTER TYPE ... ADD VALUE cannot run inside a transaction block
-- in older PostgreSQL versions, so we use separate DO blocks

-- -----------------------------------------------------------------------------
-- Helper function to safely add enum values
-- -----------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION add_enum_value_if_not_exists(
    enum_type_name TEXT,
    new_value TEXT
) RETURNS VOID AS $$
BEGIN
    -- Check if the value already exists
    IF NOT EXISTS (
        SELECT 1 FROM pg_enum 
        WHERE enumtypid = enum_type_name::regtype 
        AND enumlabel = new_value
    ) THEN
        EXECUTE format('ALTER TYPE %I ADD VALUE IF NOT EXISTS %L', enum_type_name, new_value);
    END IF;
EXCEPTION
    WHEN others THEN
        RAISE NOTICE 'Could not add value % to enum %: %', new_value, enum_type_name, SQLERRM;
END;
$$ LANGUAGE plpgsql;

-- -----------------------------------------------------------------------------
-- 1.1 Client & Organization Enums
-- -----------------------------------------------------------------------------

-- client_status
DO $$ BEGIN
    CREATE TYPE client_status AS ENUM ('pending');
EXCEPTION WHEN duplicate_object THEN NULL; END $$;
ALTER TYPE client_status ADD VALUE IF NOT EXISTS 'pending';
ALTER TYPE client_status ADD VALUE IF NOT EXISTS 'active';
ALTER TYPE client_status ADD VALUE IF NOT EXISTS 'inactive';
ALTER TYPE client_status ADD VALUE IF NOT EXISTS 'suspended';
ALTER TYPE client_status ADD VALUE IF NOT EXISTS 'archived';

-- client_type
DO $$ BEGIN
    CREATE TYPE client_type AS ENUM ('a3s');
EXCEPTION WHEN duplicate_object THEN NULL; END $$;
ALTER TYPE client_type ADD VALUE IF NOT EXISTS 'a3s';
ALTER TYPE client_type ADD VALUE IF NOT EXISTS 'p15r';
ALTER TYPE client_type ADD VALUE IF NOT EXISTS 'partner';

-- policy_status
DO $$ BEGIN
    CREATE TYPE policy_status AS ENUM ('none');
EXCEPTION WHEN duplicate_object THEN NULL; END $$;
ALTER TYPE policy_status ADD VALUE IF NOT EXISTS 'none';
ALTER TYPE policy_status ADD VALUE IF NOT EXISTS 'draft';
ALTER TYPE policy_status ADD VALUE IF NOT EXISTS 'review';
ALTER TYPE policy_status ADD VALUE IF NOT EXISTS 'approved';
ALTER TYPE policy_status ADD VALUE IF NOT EXISTS 'has_policy';
ALTER TYPE policy_status ADD VALUE IF NOT EXISTS 'needs_review';
ALTER TYPE policy_status ADD VALUE IF NOT EXISTS 'needs_creation';
ALTER TYPE policy_status ADD VALUE IF NOT EXISTS 'in_progress';
ALTER TYPE policy_status ADD VALUE IF NOT EXISTS 'completed';

-- company_size
DO $$ BEGIN
    CREATE TYPE company_size AS ENUM ('1-10');
EXCEPTION WHEN duplicate_object THEN NULL; END $$;
ALTER TYPE company_size ADD VALUE IF NOT EXISTS '1-10';
ALTER TYPE company_size ADD VALUE IF NOT EXISTS '11-50';
ALTER TYPE company_size ADD VALUE IF NOT EXISTS '51-200';
ALTER TYPE company_size ADD VALUE IF NOT EXISTS '201-1000';
ALTER TYPE company_size ADD VALUE IF NOT EXISTS '1000+';

-- pricing_tier
DO $$ BEGIN
    CREATE TYPE pricing_tier AS ENUM ('basic');
EXCEPTION WHEN duplicate_object THEN NULL; END $$;
ALTER TYPE pricing_tier ADD VALUE IF NOT EXISTS 'basic';
ALTER TYPE pricing_tier ADD VALUE IF NOT EXISTS 'professional';
ALTER TYPE pricing_tier ADD VALUE IF NOT EXISTS 'enterprise';
ALTER TYPE pricing_tier ADD VALUE IF NOT EXISTS 'custom';

-- payment_method
DO $$ BEGIN
    CREATE TYPE payment_method AS ENUM ('credit_card');
EXCEPTION WHEN duplicate_object THEN NULL; END $$;
ALTER TYPE payment_method ADD VALUE IF NOT EXISTS 'credit_card';
ALTER TYPE payment_method ADD VALUE IF NOT EXISTS 'ach';
ALTER TYPE payment_method ADD VALUE IF NOT EXISTS 'wire';
ALTER TYPE payment_method ADD VALUE IF NOT EXISTS 'check';

-- communication_preference
DO $$ BEGIN
    CREATE TYPE communication_preference AS ENUM ('email');
EXCEPTION WHEN duplicate_object THEN NULL; END $$;
ALTER TYPE communication_preference ADD VALUE IF NOT EXISTS 'email';
ALTER TYPE communication_preference ADD VALUE IF NOT EXISTS 'phone';
ALTER TYPE communication_preference ADD VALUE IF NOT EXISTS 'slack';
ALTER TYPE communication_preference ADD VALUE IF NOT EXISTS 'teams';

-- timeline
DO $$ BEGIN
    CREATE TYPE timeline AS ENUM ('immediate');
EXCEPTION WHEN duplicate_object THEN NULL; END $$;
ALTER TYPE timeline ADD VALUE IF NOT EXISTS 'immediate';
ALTER TYPE timeline ADD VALUE IF NOT EXISTS '1-3_months';
ALTER TYPE timeline ADD VALUE IF NOT EXISTS '3-6_months';
ALTER TYPE timeline ADD VALUE IF NOT EXISTS '6-12_months';
ALTER TYPE timeline ADD VALUE IF NOT EXISTS 'ongoing';

-- accessibility_level
DO $$ BEGIN
    CREATE TYPE accessibility_level AS ENUM ('none');
EXCEPTION WHEN duplicate_object THEN NULL; END $$;
ALTER TYPE accessibility_level ADD VALUE IF NOT EXISTS 'none';
ALTER TYPE accessibility_level ADD VALUE IF NOT EXISTS 'basic';
ALTER TYPE accessibility_level ADD VALUE IF NOT EXISTS 'partial';
ALTER TYPE accessibility_level ADD VALUE IF NOT EXISTS 'compliant';

-- reporting_frequency
DO $$ BEGIN
    CREATE TYPE reporting_frequency AS ENUM ('weekly');
EXCEPTION WHEN duplicate_object THEN NULL; END $$;
ALTER TYPE reporting_frequency ADD VALUE IF NOT EXISTS 'weekly';
ALTER TYPE reporting_frequency ADD VALUE IF NOT EXISTS 'bi-weekly';
ALTER TYPE reporting_frequency ADD VALUE IF NOT EXISTS 'monthly';
ALTER TYPE reporting_frequency ADD VALUE IF NOT EXISTS 'quarterly';

-- billing_frequency
DO $$ BEGIN
    CREATE TYPE billing_frequency AS ENUM ('daily');
EXCEPTION WHEN duplicate_object THEN NULL; END $$;
ALTER TYPE billing_frequency ADD VALUE IF NOT EXISTS 'daily';
ALTER TYPE billing_frequency ADD VALUE IF NOT EXISTS 'weekly';
ALTER TYPE billing_frequency ADD VALUE IF NOT EXISTS 'bi-weekly';
ALTER TYPE billing_frequency ADD VALUE IF NOT EXISTS 'monthly';
ALTER TYPE billing_frequency ADD VALUE IF NOT EXISTS 'quarterly';
ALTER TYPE billing_frequency ADD VALUE IF NOT EXISTS 'half-yearly';
ALTER TYPE billing_frequency ADD VALUE IF NOT EXISTS 'yearly';

-- -----------------------------------------------------------------------------
-- 1.2 Project Enums
-- -----------------------------------------------------------------------------

-- project_status
DO $$ BEGIN
    CREATE TYPE project_status AS ENUM ('planning');
EXCEPTION WHEN duplicate_object THEN NULL; END $$;
ALTER TYPE project_status ADD VALUE IF NOT EXISTS 'planning';
ALTER TYPE project_status ADD VALUE IF NOT EXISTS 'active';
ALTER TYPE project_status ADD VALUE IF NOT EXISTS 'on_hold';
ALTER TYPE project_status ADD VALUE IF NOT EXISTS 'completed';
ALTER TYPE project_status ADD VALUE IF NOT EXISTS 'cancelled';
ALTER TYPE project_status ADD VALUE IF NOT EXISTS 'archived';

-- project_priority
DO $$ BEGIN
    CREATE TYPE project_priority AS ENUM ('low');
EXCEPTION WHEN duplicate_object THEN NULL; END $$;
ALTER TYPE project_priority ADD VALUE IF NOT EXISTS 'low';
ALTER TYPE project_priority ADD VALUE IF NOT EXISTS 'medium';
ALTER TYPE project_priority ADD VALUE IF NOT EXISTS 'high';
ALTER TYPE project_priority ADD VALUE IF NOT EXISTS 'urgent';

-- project_type
DO $$ BEGIN
    CREATE TYPE project_type AS ENUM ('audit');
EXCEPTION WHEN duplicate_object THEN NULL; END $$;
ALTER TYPE project_type ADD VALUE IF NOT EXISTS 'audit';
ALTER TYPE project_type ADD VALUE IF NOT EXISTS 'remediation';
ALTER TYPE project_type ADD VALUE IF NOT EXISTS 'monitoring';
ALTER TYPE project_type ADD VALUE IF NOT EXISTS 'training';
ALTER TYPE project_type ADD VALUE IF NOT EXISTS 'consultation';
ALTER TYPE project_type ADD VALUE IF NOT EXISTS 'full_compliance';
ALTER TYPE project_type ADD VALUE IF NOT EXISTS 'a3s_program';

-- project_platform
DO $$ BEGIN
    CREATE TYPE project_platform AS ENUM ('website');
EXCEPTION WHEN duplicate_object THEN NULL; END $$;
ALTER TYPE project_platform ADD VALUE IF NOT EXISTS 'website';
ALTER TYPE project_platform ADD VALUE IF NOT EXISTS 'mobile_app';
ALTER TYPE project_platform ADD VALUE IF NOT EXISTS 'desktop_app';
ALTER TYPE project_platform ADD VALUE IF NOT EXISTS 'web_app';
ALTER TYPE project_platform ADD VALUE IF NOT EXISTS 'api';
ALTER TYPE project_platform ADD VALUE IF NOT EXISTS 'other';

-- tech_stack
DO $$ BEGIN
    CREATE TYPE tech_stack AS ENUM ('wordpress');
EXCEPTION WHEN duplicate_object THEN NULL; END $$;
ALTER TYPE tech_stack ADD VALUE IF NOT EXISTS 'wordpress';
ALTER TYPE tech_stack ADD VALUE IF NOT EXISTS 'react';
ALTER TYPE tech_stack ADD VALUE IF NOT EXISTS 'vue';
ALTER TYPE tech_stack ADD VALUE IF NOT EXISTS 'angular';
ALTER TYPE tech_stack ADD VALUE IF NOT EXISTS 'nextjs';
ALTER TYPE tech_stack ADD VALUE IF NOT EXISTS 'nuxt';
ALTER TYPE tech_stack ADD VALUE IF NOT EXISTS 'laravel';
ALTER TYPE tech_stack ADD VALUE IF NOT EXISTS 'django';
ALTER TYPE tech_stack ADD VALUE IF NOT EXISTS 'rails';
ALTER TYPE tech_stack ADD VALUE IF NOT EXISTS 'nodejs';
ALTER TYPE tech_stack ADD VALUE IF NOT EXISTS 'express';
ALTER TYPE tech_stack ADD VALUE IF NOT EXISTS 'fastapi';
ALTER TYPE tech_stack ADD VALUE IF NOT EXISTS 'spring';
ALTER TYPE tech_stack ADD VALUE IF NOT EXISTS 'aspnet';
ALTER TYPE tech_stack ADD VALUE IF NOT EXISTS 'flutter';
ALTER TYPE tech_stack ADD VALUE IF NOT EXISTS 'react_native';
ALTER TYPE tech_stack ADD VALUE IF NOT EXISTS 'ionic';
ALTER TYPE tech_stack ADD VALUE IF NOT EXISTS 'xamarin';
ALTER TYPE tech_stack ADD VALUE IF NOT EXISTS 'electron';
ALTER TYPE tech_stack ADD VALUE IF NOT EXISTS 'tauri';
ALTER TYPE tech_stack ADD VALUE IF NOT EXISTS 'wails';
ALTER TYPE tech_stack ADD VALUE IF NOT EXISTS 'android_native';
ALTER TYPE tech_stack ADD VALUE IF NOT EXISTS 'ios_native';
ALTER TYPE tech_stack ADD VALUE IF NOT EXISTS 'unity';
ALTER TYPE tech_stack ADD VALUE IF NOT EXISTS 'unreal';
ALTER TYPE tech_stack ADD VALUE IF NOT EXISTS 'other';

-- billing_type
DO $$ BEGIN
    CREATE TYPE billing_type AS ENUM ('fixed');
EXCEPTION WHEN duplicate_object THEN NULL; END $$;
ALTER TYPE billing_type ADD VALUE IF NOT EXISTS 'fixed';
ALTER TYPE billing_type ADD VALUE IF NOT EXISTS 'hourly';
ALTER TYPE billing_type ADD VALUE IF NOT EXISTS 'milestone';

-- project_wcag_level
DO $$ BEGIN
    CREATE TYPE project_wcag_level AS ENUM ('A');
EXCEPTION WHEN duplicate_object THEN NULL; END $$;
ALTER TYPE project_wcag_level ADD VALUE IF NOT EXISTS 'A';
ALTER TYPE project_wcag_level ADD VALUE IF NOT EXISTS 'AA';
ALTER TYPE project_wcag_level ADD VALUE IF NOT EXISTS 'AAA';

-- client_wcag_level
DO $$ BEGIN
    CREATE TYPE client_wcag_level AS ENUM ('A');
EXCEPTION WHEN duplicate_object THEN NULL; END $$;
ALTER TYPE client_wcag_level ADD VALUE IF NOT EXISTS 'A';
ALTER TYPE client_wcag_level ADD VALUE IF NOT EXISTS 'AA';
ALTER TYPE client_wcag_level ADD VALUE IF NOT EXISTS 'AAA';

-- -----------------------------------------------------------------------------
-- 1.3 WCAG & Accessibility Enums
-- -----------------------------------------------------------------------------

-- conformance_level
DO $$ BEGIN
    CREATE TYPE conformance_level AS ENUM ('A');
EXCEPTION WHEN duplicate_object THEN NULL; END $$;
ALTER TYPE conformance_level ADD VALUE IF NOT EXISTS 'A';
ALTER TYPE conformance_level ADD VALUE IF NOT EXISTS 'AA';
ALTER TYPE conformance_level ADD VALUE IF NOT EXISTS 'AAA';

-- severity
DO $$ BEGIN
    CREATE TYPE severity AS ENUM ('1_critical');
EXCEPTION WHEN duplicate_object THEN NULL; END $$;
ALTER TYPE severity ADD VALUE IF NOT EXISTS '1_critical';
ALTER TYPE severity ADD VALUE IF NOT EXISTS '2_high';
ALTER TYPE severity ADD VALUE IF NOT EXISTS '3_medium';
ALTER TYPE severity ADD VALUE IF NOT EXISTS '4_low';

-- issue_type
DO $$ BEGIN
    CREATE TYPE issue_type AS ENUM ('automated_tools');
EXCEPTION WHEN duplicate_object THEN NULL; END $$;
ALTER TYPE issue_type ADD VALUE IF NOT EXISTS 'automated_tools';
ALTER TYPE issue_type ADD VALUE IF NOT EXISTS 'screen_reader';
ALTER TYPE issue_type ADD VALUE IF NOT EXISTS 'keyboard_navigation';
ALTER TYPE issue_type ADD VALUE IF NOT EXISTS 'color_contrast';
ALTER TYPE issue_type ADD VALUE IF NOT EXISTS 'text_spacing';
ALTER TYPE issue_type ADD VALUE IF NOT EXISTS 'browser_zoom';
ALTER TYPE issue_type ADD VALUE IF NOT EXISTS 'other';

-- dev_status
DO $$ BEGIN
    CREATE TYPE dev_status AS ENUM ('not_started');
EXCEPTION WHEN duplicate_object THEN NULL; END $$;
ALTER TYPE dev_status ADD VALUE IF NOT EXISTS 'not_started';
ALTER TYPE dev_status ADD VALUE IF NOT EXISTS 'in_progress';
ALTER TYPE dev_status ADD VALUE IF NOT EXISTS 'done';
ALTER TYPE dev_status ADD VALUE IF NOT EXISTS 'blocked';
ALTER TYPE dev_status ADD VALUE IF NOT EXISTS '3rd_party';
ALTER TYPE dev_status ADD VALUE IF NOT EXISTS 'wont_fix';

-- qa_status
DO $$ BEGIN
    CREATE TYPE qa_status AS ENUM ('not_started');
EXCEPTION WHEN duplicate_object THEN NULL; END $$;
ALTER TYPE qa_status ADD VALUE IF NOT EXISTS 'not_started';
ALTER TYPE qa_status ADD VALUE IF NOT EXISTS 'in_progress';
ALTER TYPE qa_status ADD VALUE IF NOT EXISTS 'fixed';
ALTER TYPE qa_status ADD VALUE IF NOT EXISTS 'verified';
ALTER TYPE qa_status ADD VALUE IF NOT EXISTS 'failed';
ALTER TYPE qa_status ADD VALUE IF NOT EXISTS '3rd_party';

-- url_category
DO $$ BEGIN
    CREATE TYPE url_category AS ENUM ('home');
EXCEPTION WHEN duplicate_object THEN NULL; END $$;
ALTER TYPE url_category ADD VALUE IF NOT EXISTS 'home';
ALTER TYPE url_category ADD VALUE IF NOT EXISTS 'content';
ALTER TYPE url_category ADD VALUE IF NOT EXISTS 'form';
ALTER TYPE url_category ADD VALUE IF NOT EXISTS 'admin';
ALTER TYPE url_category ADD VALUE IF NOT EXISTS 'other';

-- -----------------------------------------------------------------------------
-- 1.4 Ticket Enums
-- -----------------------------------------------------------------------------

-- ticket_status
DO $$ BEGIN
    CREATE TYPE ticket_status AS ENUM ('open');
EXCEPTION WHEN duplicate_object THEN NULL; END $$;
ALTER TYPE ticket_status ADD VALUE IF NOT EXISTS 'open';
ALTER TYPE ticket_status ADD VALUE IF NOT EXISTS 'in_progress';
ALTER TYPE ticket_status ADD VALUE IF NOT EXISTS 'resolved';
ALTER TYPE ticket_status ADD VALUE IF NOT EXISTS 'closed';

-- ticket_priority
DO $$ BEGIN
    CREATE TYPE ticket_priority AS ENUM ('low');
EXCEPTION WHEN duplicate_object THEN NULL; END $$;
ALTER TYPE ticket_priority ADD VALUE IF NOT EXISTS 'low';
ALTER TYPE ticket_priority ADD VALUE IF NOT EXISTS 'medium';
ALTER TYPE ticket_priority ADD VALUE IF NOT EXISTS 'high';
ALTER TYPE ticket_priority ADD VALUE IF NOT EXISTS 'critical';

-- ticket_type
DO $$ BEGIN
    CREATE TYPE ticket_type AS ENUM ('bug');
EXCEPTION WHEN duplicate_object THEN NULL; END $$;
ALTER TYPE ticket_type ADD VALUE IF NOT EXISTS 'bug';
ALTER TYPE ticket_type ADD VALUE IF NOT EXISTS 'feature';
ALTER TYPE ticket_type ADD VALUE IF NOT EXISTS 'task';
ALTER TYPE ticket_type ADD VALUE IF NOT EXISTS 'accessibility';
ALTER TYPE ticket_type ADD VALUE IF NOT EXISTS 'improvement';

-- ticket_category
DO $$ BEGIN
    CREATE TYPE ticket_category AS ENUM ('technical');
EXCEPTION WHEN duplicate_object THEN NULL; END $$;
ALTER TYPE ticket_category ADD VALUE IF NOT EXISTS 'technical';
ALTER TYPE ticket_category ADD VALUE IF NOT EXISTS 'billing';
ALTER TYPE ticket_category ADD VALUE IF NOT EXISTS 'general';
ALTER TYPE ticket_category ADD VALUE IF NOT EXISTS 'feature_request';
ALTER TYPE ticket_category ADD VALUE IF NOT EXISTS 'bug_report';
ALTER TYPE ticket_category ADD VALUE IF NOT EXISTS 'other';

-- -----------------------------------------------------------------------------
-- 1.5 Report Enums
-- -----------------------------------------------------------------------------

-- report_type
DO $$ BEGIN
    CREATE TYPE report_type AS ENUM ('executive_summary');
EXCEPTION WHEN duplicate_object THEN NULL; END $$;
ALTER TYPE report_type ADD VALUE IF NOT EXISTS 'executive_summary';
ALTER TYPE report_type ADD VALUE IF NOT EXISTS 'technical_report';
ALTER TYPE report_type ADD VALUE IF NOT EXISTS 'compliance_report';
ALTER TYPE report_type ADD VALUE IF NOT EXISTS 'monthly_progress';
ALTER TYPE report_type ADD VALUE IF NOT EXISTS 'custom';

-- report_status
DO $$ BEGIN
    CREATE TYPE report_status AS ENUM ('draft');
EXCEPTION WHEN duplicate_object THEN NULL; END $$;
ALTER TYPE report_status ADD VALUE IF NOT EXISTS 'draft';
ALTER TYPE report_status ADD VALUE IF NOT EXISTS 'generated';
ALTER TYPE report_status ADD VALUE IF NOT EXISTS 'edited';
ALTER TYPE report_status ADD VALUE IF NOT EXISTS 'sent';
ALTER TYPE report_status ADD VALUE IF NOT EXISTS 'archived';

-- -----------------------------------------------------------------------------
-- 1.6 Team & User Enums
-- -----------------------------------------------------------------------------

-- team_type
DO $$ BEGIN
    CREATE TYPE team_type AS ENUM ('internal');
EXCEPTION WHEN duplicate_object THEN NULL; END $$;
ALTER TYPE team_type ADD VALUE IF NOT EXISTS 'internal';
ALTER TYPE team_type ADD VALUE IF NOT EXISTS 'external';

-- employee_role
DO $$ BEGIN
    CREATE TYPE employee_role AS ENUM ('ceo');
EXCEPTION WHEN duplicate_object THEN NULL; END $$;
ALTER TYPE employee_role ADD VALUE IF NOT EXISTS 'ceo';
ALTER TYPE employee_role ADD VALUE IF NOT EXISTS 'manager';
ALTER TYPE employee_role ADD VALUE IF NOT EXISTS 'team_lead';
ALTER TYPE employee_role ADD VALUE IF NOT EXISTS 'senior_developer';
ALTER TYPE employee_role ADD VALUE IF NOT EXISTS 'developer';
ALTER TYPE employee_role ADD VALUE IF NOT EXISTS 'junior_developer';
ALTER TYPE employee_role ADD VALUE IF NOT EXISTS 'designer';
ALTER TYPE employee_role ADD VALUE IF NOT EXISTS 'qa_engineer';
ALTER TYPE employee_role ADD VALUE IF NOT EXISTS 'project_manager';
ALTER TYPE employee_role ADD VALUE IF NOT EXISTS 'business_analyst';
ALTER TYPE employee_role ADD VALUE IF NOT EXISTS 'consultant';
ALTER TYPE employee_role ADD VALUE IF NOT EXISTS 'contractor';

-- employment_status
DO $$ BEGIN
    CREATE TYPE employment_status AS ENUM ('active');
EXCEPTION WHEN duplicate_object THEN NULL; END $$;
ALTER TYPE employment_status ADD VALUE IF NOT EXISTS 'active';
ALTER TYPE employment_status ADD VALUE IF NOT EXISTS 'inactive';
ALTER TYPE employment_status ADD VALUE IF NOT EXISTS 'on_leave';
ALTER TYPE employment_status ADD VALUE IF NOT EXISTS 'terminated';

-- developer_role
DO $$ BEGIN
    CREATE TYPE developer_role AS ENUM ('project_lead');
EXCEPTION WHEN duplicate_object THEN NULL; END $$;
ALTER TYPE developer_role ADD VALUE IF NOT EXISTS 'project_lead';
ALTER TYPE developer_role ADD VALUE IF NOT EXISTS 'senior_developer';
ALTER TYPE developer_role ADD VALUE IF NOT EXISTS 'developer';
ALTER TYPE developer_role ADD VALUE IF NOT EXISTS 'qa_engineer';
ALTER TYPE developer_role ADD VALUE IF NOT EXISTS 'accessibility_specialist';

-- user_role
DO $$ BEGIN
    CREATE TYPE user_role AS ENUM ('viewer');
EXCEPTION WHEN duplicate_object THEN NULL; END $$;
ALTER TYPE user_role ADD VALUE IF NOT EXISTS 'viewer';
ALTER TYPE user_role ADD VALUE IF NOT EXISTS 'editor';
ALTER TYPE user_role ADD VALUE IF NOT EXISTS 'admin';
ALTER TYPE user_role ADD VALUE IF NOT EXISTS 'owner';

-- project_role
DO $$ BEGIN
    CREATE TYPE project_role AS ENUM ('project_admin');
EXCEPTION WHEN duplicate_object THEN NULL; END $$;
ALTER TYPE project_role ADD VALUE IF NOT EXISTS 'project_admin';
ALTER TYPE project_role ADD VALUE IF NOT EXISTS 'project_member';

-- invitation_status
DO $$ BEGIN
    CREATE TYPE invitation_status AS ENUM ('pending');
EXCEPTION WHEN duplicate_object THEN NULL; END $$;
ALTER TYPE invitation_status ADD VALUE IF NOT EXISTS 'pending';
ALTER TYPE invitation_status ADD VALUE IF NOT EXISTS 'sent';
ALTER TYPE invitation_status ADD VALUE IF NOT EXISTS 'accepted';
ALTER TYPE invitation_status ADD VALUE IF NOT EXISTS 'expired';
ALTER TYPE invitation_status ADD VALUE IF NOT EXISTS 'cancelled';

-- -----------------------------------------------------------------------------
-- 1.7 Document Enums
-- -----------------------------------------------------------------------------

-- document_type
DO $$ BEGIN
    CREATE TYPE document_type AS ENUM ('audit_report');
EXCEPTION WHEN duplicate_object THEN NULL; END $$;
ALTER TYPE document_type ADD VALUE IF NOT EXISTS 'audit_report';
ALTER TYPE document_type ADD VALUE IF NOT EXISTS 'remediation_plan';
ALTER TYPE document_type ADD VALUE IF NOT EXISTS 'test_results';
ALTER TYPE document_type ADD VALUE IF NOT EXISTS 'compliance_certificate';
ALTER TYPE document_type ADD VALUE IF NOT EXISTS 'meeting_notes';
ALTER TYPE document_type ADD VALUE IF NOT EXISTS 'vpat';
ALTER TYPE document_type ADD VALUE IF NOT EXISTS 'accessibility_summary';
ALTER TYPE document_type ADD VALUE IF NOT EXISTS 'legal_response';
ALTER TYPE document_type ADD VALUE IF NOT EXISTS 'monthly_monitoring';
ALTER TYPE document_type ADD VALUE IF NOT EXISTS 'custom';
ALTER TYPE document_type ADD VALUE IF NOT EXISTS 'other';

-- document_status
DO $$ BEGIN
    CREATE TYPE document_status AS ENUM ('draft');
EXCEPTION WHEN duplicate_object THEN NULL; END $$;
ALTER TYPE document_status ADD VALUE IF NOT EXISTS 'draft';
ALTER TYPE document_status ADD VALUE IF NOT EXISTS 'pending_review';
ALTER TYPE document_status ADD VALUE IF NOT EXISTS 'certified';
ALTER TYPE document_status ADD VALUE IF NOT EXISTS 'active';
ALTER TYPE document_status ADD VALUE IF NOT EXISTS 'archived';

-- document_request_status
DO $$ BEGIN
    CREATE TYPE document_request_status AS ENUM ('pending');
EXCEPTION WHEN duplicate_object THEN NULL; END $$;
ALTER TYPE document_request_status ADD VALUE IF NOT EXISTS 'pending';
ALTER TYPE document_request_status ADD VALUE IF NOT EXISTS 'in_progress';
ALTER TYPE document_request_status ADD VALUE IF NOT EXISTS 'completed';
ALTER TYPE document_request_status ADD VALUE IF NOT EXISTS 'rejected';

-- document_priority
DO $$ BEGIN
    CREATE TYPE document_priority AS ENUM ('low');
EXCEPTION WHEN duplicate_object THEN NULL; END $$;
ALTER TYPE document_priority ADD VALUE IF NOT EXISTS 'low';
ALTER TYPE document_priority ADD VALUE IF NOT EXISTS 'medium';
ALTER TYPE document_priority ADD VALUE IF NOT EXISTS 'high';
ALTER TYPE document_priority ADD VALUE IF NOT EXISTS 'critical';

-- remediation_type
DO $$ BEGIN
    CREATE TYPE remediation_type AS ENUM ('traditional_pdf');
EXCEPTION WHEN duplicate_object THEN NULL; END $$;
ALTER TYPE remediation_type ADD VALUE IF NOT EXISTS 'traditional_pdf';
ALTER TYPE remediation_type ADD VALUE IF NOT EXISTS 'html_alternative';

-- remediation_status
DO $$ BEGIN
    CREATE TYPE remediation_status AS ENUM ('pending_review');
EXCEPTION WHEN duplicate_object THEN NULL; END $$;
ALTER TYPE remediation_status ADD VALUE IF NOT EXISTS 'pending_review';
ALTER TYPE remediation_status ADD VALUE IF NOT EXISTS 'approved';
ALTER TYPE remediation_status ADD VALUE IF NOT EXISTS 'in_progress';
ALTER TYPE remediation_status ADD VALUE IF NOT EXISTS 'completed';
ALTER TYPE remediation_status ADD VALUE IF NOT EXISTS 'rejected';

-- -----------------------------------------------------------------------------
-- 1.8 Notification Enums
-- -----------------------------------------------------------------------------

-- notification_type
DO $$ BEGIN
    CREATE TYPE notification_type AS ENUM ('system');
EXCEPTION WHEN duplicate_object THEN NULL; END $$;
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

-- notification_priority
DO $$ BEGIN
    CREATE TYPE notification_priority AS ENUM ('low');
EXCEPTION WHEN duplicate_object THEN NULL; END $$;
ALTER TYPE notification_priority ADD VALUE IF NOT EXISTS 'low';
ALTER TYPE notification_priority ADD VALUE IF NOT EXISTS 'normal';
ALTER TYPE notification_priority ADD VALUE IF NOT EXISTS 'high';
ALTER TYPE notification_priority ADD VALUE IF NOT EXISTS 'urgent';

-- -----------------------------------------------------------------------------
-- 1.9 Other Enums
-- -----------------------------------------------------------------------------

-- activity_action
DO $$ BEGIN
    CREATE TYPE activity_action AS ENUM ('created');
EXCEPTION WHEN duplicate_object THEN NULL; END $$;
ALTER TYPE activity_action ADD VALUE IF NOT EXISTS 'created';
ALTER TYPE activity_action ADD VALUE IF NOT EXISTS 'updated';
ALTER TYPE activity_action ADD VALUE IF NOT EXISTS 'milestone_completed';
ALTER TYPE activity_action ADD VALUE IF NOT EXISTS 'developer_assigned';
ALTER TYPE activity_action ADD VALUE IF NOT EXISTS 'status_changed';
ALTER TYPE activity_action ADD VALUE IF NOT EXISTS 'document_uploaded';
ALTER TYPE activity_action ADD VALUE IF NOT EXISTS 'time_logged';
ALTER TYPE activity_action ADD VALUE IF NOT EXISTS 'staging_credentials_updated';

-- milestone_status
DO $$ BEGIN
    CREATE TYPE milestone_status AS ENUM ('pending');
EXCEPTION WHEN duplicate_object THEN NULL; END $$;
ALTER TYPE milestone_status ADD VALUE IF NOT EXISTS 'pending';
ALTER TYPE milestone_status ADD VALUE IF NOT EXISTS 'in_progress';
ALTER TYPE milestone_status ADD VALUE IF NOT EXISTS 'completed';
ALTER TYPE milestone_status ADD VALUE IF NOT EXISTS 'overdue';

-- time_entry_category
DO $$ BEGIN
    CREATE TYPE time_entry_category AS ENUM ('development');
EXCEPTION WHEN duplicate_object THEN NULL; END $$;
ALTER TYPE time_entry_category ADD VALUE IF NOT EXISTS 'development';
ALTER TYPE time_entry_category ADD VALUE IF NOT EXISTS 'testing';
ALTER TYPE time_entry_category ADD VALUE IF NOT EXISTS 'review';
ALTER TYPE time_entry_category ADD VALUE IF NOT EXISTS 'meeting';
ALTER TYPE time_entry_category ADD VALUE IF NOT EXISTS 'documentation';
ALTER TYPE time_entry_category ADD VALUE IF NOT EXISTS 'research';

-- credential_type
DO $$ BEGIN
    CREATE TYPE credential_type AS ENUM ('staging');
EXCEPTION WHEN duplicate_object THEN NULL; END $$;
ALTER TYPE credential_type ADD VALUE IF NOT EXISTS 'staging';
ALTER TYPE credential_type ADD VALUE IF NOT EXISTS 'production';
ALTER TYPE credential_type ADD VALUE IF NOT EXISTS 'development';
ALTER TYPE credential_type ADD VALUE IF NOT EXISTS 'testing';
ALTER TYPE credential_type ADD VALUE IF NOT EXISTS 'wordpress';
ALTER TYPE credential_type ADD VALUE IF NOT EXISTS 'httpauth';
ALTER TYPE credential_type ADD VALUE IF NOT EXISTS 'sftp';
ALTER TYPE credential_type ADD VALUE IF NOT EXISTS 'database';
ALTER TYPE credential_type ADD VALUE IF NOT EXISTS 'app_store';
ALTER TYPE credential_type ADD VALUE IF NOT EXISTS 'play_store';
ALTER TYPE credential_type ADD VALUE IF NOT EXISTS 'firebase';
ALTER TYPE credential_type ADD VALUE IF NOT EXISTS 'aws';
ALTER TYPE credential_type ADD VALUE IF NOT EXISTS 'azure';
ALTER TYPE credential_type ADD VALUE IF NOT EXISTS 'gcp';
ALTER TYPE credential_type ADD VALUE IF NOT EXISTS 'heroku';
ALTER TYPE credential_type ADD VALUE IF NOT EXISTS 'vercel';
ALTER TYPE credential_type ADD VALUE IF NOT EXISTS 'netlify';
ALTER TYPE credential_type ADD VALUE IF NOT EXISTS 'github';
ALTER TYPE credential_type ADD VALUE IF NOT EXISTS 'gitlab';
ALTER TYPE credential_type ADD VALUE IF NOT EXISTS 'bitbucket';
ALTER TYPE credential_type ADD VALUE IF NOT EXISTS 'docker';
ALTER TYPE credential_type ADD VALUE IF NOT EXISTS 'kubernetes';
ALTER TYPE credential_type ADD VALUE IF NOT EXISTS 'cms';
ALTER TYPE credential_type ADD VALUE IF NOT EXISTS 'api_key';
ALTER TYPE credential_type ADD VALUE IF NOT EXISTS 'oauth';
ALTER TYPE credential_type ADD VALUE IF NOT EXISTS 'ssh_key';
ALTER TYPE credential_type ADD VALUE IF NOT EXISTS 'ssl_certificate';
ALTER TYPE credential_type ADD VALUE IF NOT EXISTS 'cdn';
ALTER TYPE credential_type ADD VALUE IF NOT EXISTS 'analytics';
ALTER TYPE credential_type ADD VALUE IF NOT EXISTS 'monitoring';
ALTER TYPE credential_type ADD VALUE IF NOT EXISTS 'other';

-- comment_type
DO $$ BEGIN
    CREATE TYPE comment_type AS ENUM ('general');
EXCEPTION WHEN duplicate_object THEN NULL; END $$;
ALTER TYPE comment_type ADD VALUE IF NOT EXISTS 'general';
ALTER TYPE comment_type ADD VALUE IF NOT EXISTS 'dev_update';
ALTER TYPE comment_type ADD VALUE IF NOT EXISTS 'qa_feedback';
ALTER TYPE comment_type ADD VALUE IF NOT EXISTS 'technical_note';
ALTER TYPE comment_type ADD VALUE IF NOT EXISTS 'resolution';

-- author_role
DO $$ BEGIN
    CREATE TYPE author_role AS ENUM ('developer');
EXCEPTION WHEN duplicate_object THEN NULL; END $$;
ALTER TYPE author_role ADD VALUE IF NOT EXISTS 'developer';
ALTER TYPE author_role ADD VALUE IF NOT EXISTS 'qa_tester';
ALTER TYPE author_role ADD VALUE IF NOT EXISTS 'accessibility_expert';
ALTER TYPE author_role ADD VALUE IF NOT EXISTS 'project_manager';
ALTER TYPE author_role ADD VALUE IF NOT EXISTS 'client';

-- billing_addon_type
DO $$ BEGIN
    CREATE TYPE billing_addon_type AS ENUM ('team_members');
EXCEPTION WHEN duplicate_object THEN NULL; END $$;
ALTER TYPE billing_addon_type ADD VALUE IF NOT EXISTS 'team_members';
ALTER TYPE billing_addon_type ADD VALUE IF NOT EXISTS 'document_remediation';
ALTER TYPE billing_addon_type ADD VALUE IF NOT EXISTS 'evidence_locker';
ALTER TYPE billing_addon_type ADD VALUE IF NOT EXISTS 'custom';

-- billing_addon_status
DO $$ BEGIN
    CREATE TYPE billing_addon_status AS ENUM ('active');
EXCEPTION WHEN duplicate_object THEN NULL; END $$;
ALTER TYPE billing_addon_status ADD VALUE IF NOT EXISTS 'active';
ALTER TYPE billing_addon_status ADD VALUE IF NOT EXISTS 'cancelled';
ALTER TYPE billing_addon_status ADD VALUE IF NOT EXISTS 'pending';

-- ============================================================================
-- SECTION 2: CORE TABLES (SHARED BY ADMIN & PORTAL)
-- ============================================================================

-- -----------------------------------------------------------------------------
-- 2.1 Clients Table
-- -----------------------------------------------------------------------------

CREATE TABLE IF NOT EXISTS clients (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    name VARCHAR(255) NOT NULL,
    email VARCHAR(255) NOT NULL UNIQUE,
    company VARCHAR(255) NOT NULL,
    phone VARCHAR(50),
    address TEXT,
    billing_amount NUMERIC(10, 2) NOT NULL,
    billing_start_date TIMESTAMP NOT NULL,
    billing_frequency billing_frequency NOT NULL,
    status client_status NOT NULL DEFAULT 'pending',
    client_type client_type NOT NULL DEFAULT 'a3s',
    company_size company_size,
    industry VARCHAR(100),
    website VARCHAR(500),
    current_accessibility_level accessibility_level,
    compliance_deadline TIMESTAMP,
    pricing_tier pricing_tier,
    payment_method payment_method,
    services_needed TEXT[],
    wcag_level client_wcag_level,
    priority_areas TEXT[],
    timeline timeline,
    communication_preference communication_preference,
    reporting_frequency reporting_frequency,
    point_of_contact VARCHAR(255),
    time_zone VARCHAR(100),
    has_accessibility_policy BOOLEAN NOT NULL DEFAULT FALSE,
    accessibility_policy_url VARCHAR(500),
    policy_status policy_status NOT NULL DEFAULT 'none',
    policy_notes TEXT,
    notes TEXT,
    client_documents TEXT,
    team_member_limit INTEGER NOT NULL DEFAULT 5,
    created_at TIMESTAMP NOT NULL DEFAULT NOW(),
    updated_at TIMESTAMP NOT NULL DEFAULT NOW()
);

-- Client indexes
CREATE INDEX IF NOT EXISTS idx_clients_status ON clients(status);
CREATE INDEX IF NOT EXISTS idx_clients_type ON clients(client_type);
CREATE INDEX IF NOT EXISTS idx_clients_type_count ON clients(client_type);
CREATE INDEX IF NOT EXISTS idx_clients_email ON clients(email);

-- -----------------------------------------------------------------------------
-- 2.2 Projects Table
-- -----------------------------------------------------------------------------

CREATE TABLE IF NOT EXISTS projects (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    client_id UUID REFERENCES clients(id) ON DELETE CASCADE,
    name VARCHAR(255) NOT NULL,
    description TEXT,
    sheet_id VARCHAR(255),
    status VARCHAR(50) DEFAULT 'planning',
    priority VARCHAR(50) DEFAULT 'medium',
    wcag_level VARCHAR(50) DEFAULT 'AA',
    project_type VARCHAR(50),
    project_platform VARCHAR(50) NOT NULL DEFAULT 'website',
    tech_stack VARCHAR(50) NOT NULL DEFAULT 'other',
    compliance_requirements TEXT[] NOT NULL DEFAULT '{}',
    website_url VARCHAR(500),
    testing_methodology TEXT[] NOT NULL DEFAULT '{}',
    testing_schedule TEXT,
    bug_severity_workflow TEXT,
    start_date TIMESTAMP,
    end_date TIMESTAMP,
    estimated_hours NUMERIC(8, 2),
    actual_hours NUMERIC(8, 2) DEFAULT 0,
    budget NUMERIC(12, 2),
    billing_type VARCHAR(50) NOT NULL DEFAULT 'fixed',
    hourly_rate NUMERIC(8, 2),
    progress_percentage INTEGER NOT NULL DEFAULT 0,
    milestones_completed INTEGER NOT NULL DEFAULT 0,
    total_milestones INTEGER NOT NULL DEFAULT 0,
    deliverables TEXT[] NOT NULL DEFAULT '{}',
    acceptance_criteria TEXT[] NOT NULL DEFAULT '{}',
    default_testing_month VARCHAR(20),
    default_testing_year INTEGER,
    critical_issue_sla_days INTEGER DEFAULT 45,
    high_issue_sla_days INTEGER DEFAULT 30,
    sync_status_summary JSONB DEFAULT '{}',
    last_sync_details JSONB DEFAULT '{}',
    credentials JSONB DEFAULT '[]',
    credentials_backup JSONB,
    tags TEXT[] NOT NULL DEFAULT '{}',
    notes TEXT,
    created_at TIMESTAMP NOT NULL DEFAULT NOW(),
    updated_at TIMESTAMP NOT NULL DEFAULT NOW(),
    created_by VARCHAR(255) NOT NULL,
    last_modified_by VARCHAR(255) NOT NULL
);

-- Add constraints if they don't exist
DO $$ BEGIN
    ALTER TABLE projects ADD CONSTRAINT check_critical_sla_days 
        CHECK (critical_issue_sla_days >= 1 AND critical_issue_sla_days <= 365);
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

DO $$ BEGIN
    ALTER TABLE projects ADD CONSTRAINT check_high_sla_days 
        CHECK (high_issue_sla_days >= 1 AND high_issue_sla_days <= 365);
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- Project indexes
CREATE INDEX IF NOT EXISTS idx_projects_client_id ON projects(client_id);
CREATE INDEX IF NOT EXISTS idx_projects_status ON projects(status);
CREATE INDEX IF NOT EXISTS idx_projects_sheet_id ON projects(sheet_id);
CREATE INDEX IF NOT EXISTS idx_projects_type ON projects(project_type);
CREATE INDEX IF NOT EXISTS idx_projects_wcag_level ON projects(wcag_level);
CREATE INDEX IF NOT EXISTS idx_projects_created_at ON projects(created_at DESC);
CREATE INDEX IF NOT EXISTS idx_projects_status_type ON projects(status, project_type);
CREATE INDEX IF NOT EXISTS idx_projects_status_type_updated ON projects(status, project_type, updated_at DESC);
CREATE INDEX IF NOT EXISTS idx_projects_critical_sla ON projects(critical_issue_sla_days);
CREATE INDEX IF NOT EXISTS idx_projects_high_sla ON projects(high_issue_sla_days);
CREATE INDEX IF NOT EXISTS idx_projects_complex ON projects(status, project_type, client_id);

-- -----------------------------------------------------------------------------
-- 2.3 Test URLs Table
-- -----------------------------------------------------------------------------

CREATE TABLE IF NOT EXISTS test_urls (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    project_id UUID NOT NULL REFERENCES projects(id) ON DELETE CASCADE,
    url VARCHAR(1000) NOT NULL,
    page_title VARCHAR(500),
    url_category url_category DEFAULT 'content',
    testing_month VARCHAR(20),
    testing_year INTEGER,
    remediation_month VARCHAR(20),
    remediation_year INTEGER,
    is_active BOOLEAN DEFAULT TRUE,
    status TEXT,
    automated_tools TEXT,
    nvda_chrome TEXT,
    voiceover_iphone_safari TEXT,
    color_contrast TEXT,
    browser_zoom TEXT,
    keyboard_only TEXT,
    text_spacing TEXT,
    created_at TIMESTAMP NOT NULL DEFAULT NOW(),
    updated_at TIMESTAMP NOT NULL DEFAULT NOW()
);

-- Test URLs indexes
CREATE UNIQUE INDEX IF NOT EXISTS test_urls_project_url_idx ON test_urls(project_id, url);
CREATE INDEX IF NOT EXISTS idx_test_urls_project_id ON test_urls(project_id);

-- -----------------------------------------------------------------------------
-- 2.4 Accessibility Issues Table (CRITICAL TABLE)
-- -----------------------------------------------------------------------------

CREATE TABLE IF NOT EXISTS accessibility_issues (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    project_id UUID NOT NULL REFERENCES projects(id) ON DELETE CASCADE,
    issue_id TEXT NOT NULL,
    url_id UUID NOT NULL REFERENCES test_urls(id) ON DELETE CASCADE,
    issue_title VARCHAR(500) NOT NULL,
    issue_description TEXT,
    issue_type VARCHAR(50) NOT NULL,
    severity VARCHAR(50) NOT NULL,
    testing_month VARCHAR(20),
    testing_year INTEGER,
    testing_environment VARCHAR(200),
    browser VARCHAR(100),
    operating_system VARCHAR(100),
    assistive_technology VARCHAR(100),
    expected_result TEXT NOT NULL,
    actual_result TEXT,
    failed_wcag_criteria TEXT[] DEFAULT '{}',
    conformance_level conformance_level,
    screencast_url VARCHAR(1000),
    screenshot_urls TEXT[] DEFAULT '{}',
    dev_status VARCHAR(50) DEFAULT 'not_started',
    dev_comments TEXT,
    dev_assigned_to VARCHAR(255),
    qa_status VARCHAR(50) DEFAULT 'not_started',
    qa_comments TEXT,
    qa_assigned_to VARCHAR(255),
    discovered_at TIMESTAMP NOT NULL DEFAULT NOW(),
    dev_started_at TIMESTAMP,
    dev_completed_at TIMESTAMP,
    qa_started_at TIMESTAMP,
    qa_completed_at TIMESTAMP,
    resolved_at TIMESTAMP,
    is_active BOOLEAN DEFAULT TRUE,
    is_duplicate BOOLEAN DEFAULT FALSE,
    duplicate_of_id UUID,
    external_ticket_id VARCHAR(255),
    external_ticket_url VARCHAR(1000),
    import_batch_id VARCHAR(255),
    source_file_name VARCHAR(255),
    -- CRITICAL: Controls client visibility
    sent_to_user BOOLEAN DEFAULT FALSE,
    sent_date TIMESTAMP,
    sent_month VARCHAR(20),
    report_id UUID,
    metadata JSONB,
    dev_status_updated_at TIMESTAMP,
    qa_status_updated_at TIMESTAMP,
    sheet_name TEXT,
    sheet_row_number INTEGER,
    created_at TIMESTAMP NOT NULL DEFAULT NOW(),
    updated_at TIMESTAMP NOT NULL DEFAULT NOW()
);

-- Add unique constraint if it doesn't exist
DO $$ BEGIN
    ALTER TABLE accessibility_issues ADD CONSTRAINT unique_project_issue_id UNIQUE (project_id, issue_id);
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- Accessibility Issues indexes (MOST QUERIED TABLE - comprehensive indexing)
CREATE UNIQUE INDEX IF NOT EXISTS accessibility_issues_project_url_title_unique ON accessibility_issues(project_id, url_id, issue_title);
CREATE INDEX IF NOT EXISTS idx_accessibility_issues_issue_id ON accessibility_issues(issue_id);
CREATE INDEX IF NOT EXISTS accessibility_issues_project_url_idx ON accessibility_issues(project_id, url_id);
CREATE INDEX IF NOT EXISTS accessibility_issues_dev_status_idx ON accessibility_issues(dev_status);
CREATE INDEX IF NOT EXISTS accessibility_issues_qa_status_idx ON accessibility_issues(qa_status);
CREATE INDEX IF NOT EXISTS accessibility_issues_severity_idx ON accessibility_issues(severity);
CREATE INDEX IF NOT EXISTS accessibility_issues_type_idx ON accessibility_issues(issue_type);
CREATE INDEX IF NOT EXISTS accessibility_issues_sent_to_user_idx ON accessibility_issues(sent_to_user);
CREATE INDEX IF NOT EXISTS accessibility_issues_report_id_idx ON accessibility_issues(report_id);
CREATE INDEX IF NOT EXISTS accessibility_issues_duplicate_of_idx ON accessibility_issues(duplicate_of_id);
CREATE INDEX IF NOT EXISTS accessibility_issues_import_batch_idx ON accessibility_issues(import_batch_id);
CREATE INDEX IF NOT EXISTS idx_issues_project_id ON accessibility_issues(project_id);
CREATE INDEX IF NOT EXISTS idx_issues_created_at ON accessibility_issues(created_at);
CREATE INDEX IF NOT EXISTS idx_issues_updated_at ON accessibility_issues(updated_at);
CREATE INDEX IF NOT EXISTS idx_issues_severity ON accessibility_issues(severity);
CREATE INDEX IF NOT EXISTS idx_issues_dev_status ON accessibility_issues(dev_status);
CREATE INDEX IF NOT EXISTS idx_issues_qa_status ON accessibility_issues(qa_status);
CREATE INDEX IF NOT EXISTS idx_issues_is_active ON accessibility_issues(is_active);
CREATE INDEX IF NOT EXISTS idx_issues_project_severity ON accessibility_issues(project_id, severity);
CREATE INDEX IF NOT EXISTS idx_issues_project_status ON accessibility_issues(project_id, dev_status);
CREATE INDEX IF NOT EXISTS idx_issues_complex ON accessibility_issues(project_id, severity, dev_status, is_active);
CREATE INDEX IF NOT EXISTS idx_accessibility_issues_dev_status_updated_at ON accessibility_issues(dev_status_updated_at);
CREATE INDEX IF NOT EXISTS idx_accessibility_issues_qa_status_updated_at ON accessibility_issues(qa_status_updated_at);
CREATE INDEX IF NOT EXISTS idx_accessibility_issues_metadata ON accessibility_issues USING GIN (metadata);

-- -----------------------------------------------------------------------------
-- 2.5 Reports Table
-- -----------------------------------------------------------------------------

CREATE TABLE IF NOT EXISTS reports (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    project_id UUID NOT NULL REFERENCES projects(id) ON DELETE CASCADE,
    title VARCHAR(255) NOT NULL,
    report_type report_type NOT NULL,
    report_month VARCHAR(20),
    report_year INTEGER,
    ai_generated_content TEXT,
    edited_content TEXT,
    status report_status NOT NULL DEFAULT 'draft',
    sent_at TIMESTAMP,
    sent_to JSONB,
    email_subject VARCHAR(255),
    email_body TEXT,
    pdf_path VARCHAR(500),
    created_by VARCHAR(255),
    is_public BOOLEAN NOT NULL DEFAULT FALSE,
    public_token VARCHAR(64) UNIQUE,
    created_at TIMESTAMP NOT NULL DEFAULT NOW(),
    updated_at TIMESTAMP NOT NULL DEFAULT NOW()
);

-- Report indexes
CREATE INDEX IF NOT EXISTS idx_reports_project_id ON reports(project_id);
CREATE INDEX IF NOT EXISTS idx_reports_status ON reports(status);
CREATE INDEX IF NOT EXISTS idx_reports_type ON reports(report_type);
CREATE INDEX IF NOT EXISTS idx_reports_created_at ON reports(created_at DESC);
CREATE INDEX IF NOT EXISTS idx_reports_sent_at ON reports(sent_at);
CREATE INDEX IF NOT EXISTS idx_reports_project_status ON reports(project_id, status);
CREATE INDEX IF NOT EXISTS idx_reports_project_status_created ON reports(project_id, status, created_at DESC);
CREATE INDEX IF NOT EXISTS idx_reports_complex ON reports(project_id, status, created_at);

-- -----------------------------------------------------------------------------
-- 2.6 Report Issues Junction Table
-- -----------------------------------------------------------------------------

CREATE TABLE IF NOT EXISTS report_issues (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    report_id UUID NOT NULL REFERENCES reports(id) ON DELETE CASCADE,
    issue_id UUID NOT NULL REFERENCES accessibility_issues(id) ON DELETE CASCADE,
    included_at TIMESTAMP NOT NULL DEFAULT NOW()
);

-- Add unique constraint if it doesn't exist
DO $$ BEGIN
    ALTER TABLE report_issues ADD CONSTRAINT unique_report_issue UNIQUE (report_id, issue_id);
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

CREATE INDEX IF NOT EXISTS idx_report_issues_report_id ON report_issues(report_id);
CREATE INDEX IF NOT EXISTS idx_report_issues_issue_id ON report_issues(issue_id);

-- -----------------------------------------------------------------------------
-- 2.7 Report Comments Table
-- -----------------------------------------------------------------------------

CREATE TABLE IF NOT EXISTS report_comments (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    report_id UUID NOT NULL REFERENCES reports(id) ON DELETE CASCADE,
    comment TEXT NOT NULL,
    comment_type VARCHAR(50) NOT NULL DEFAULT 'general',
    author_id VARCHAR(255),
    author_name VARCHAR(255),
    is_internal BOOLEAN NOT NULL DEFAULT TRUE,
    created_at TIMESTAMP NOT NULL DEFAULT NOW()
);

CREATE INDEX IF NOT EXISTS idx_report_comments_report_id ON report_comments(report_id);

-- -----------------------------------------------------------------------------
-- 2.8 Issues Table (LEGACY - for backward compatibility)
-- -----------------------------------------------------------------------------

CREATE TABLE IF NOT EXISTS issues (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    project_id UUID NOT NULL REFERENCES projects(id),
    sheet_name TEXT NOT NULL,
    url TEXT,
    issue_title TEXT,
    issue_description TEXT,
    issue_type TEXT,
    url_id TEXT,
    severity TEXT,
    testing_month TEXT,
    testing_year TEXT,
    testing_environment TEXT,
    dev_status TEXT,
    wcag TEXT,
    status TEXT,
    assignee TEXT,
    priority TEXT,
    assigned_to TEXT,
    due_date TEXT,
    resolution_notes TEXT,
    is_resolved TEXT,
    is_duplicate TEXT,
    browser TEXT,
    qa_status TEXT,
    expected_result TEXT,
    actual_result TEXT,
    failed_wcag_criteria TEXT,
    conformance_level TEXT,
    screencast_url TEXT,
    screenshot_urls TEXT,
    dev_comments TEXT,
    dev_assigned_to TEXT,
    qa_comments TEXT,
    qa_assigned_to TEXT,
    is_active TEXT,
    operating_system TEXT,
    assistive_technology TEXT,
    notes TEXT,
    created_at TIMESTAMP NOT NULL DEFAULT NOW(),
    updated_at TIMESTAMP NOT NULL DEFAULT NOW(),
    dev_status_updated_at TIMESTAMP,
    qa_status_updated_at TIMESTAMP,
    metadata JSONB,
    issue_logged_at TIMESTAMP DEFAULT NOW(),
    issue_updated_at TIMESTAMP
);

-- Add unique constraint if it doesn't exist
DO $$ BEGIN
    ALTER TABLE issues ADD CONSTRAINT issues_project_id_sheet_name_url_issue_title_key 
        UNIQUE (project_id, sheet_name, url, issue_title);
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

CREATE INDEX IF NOT EXISTS idx_issues_status ON issues(status);
CREATE INDEX IF NOT EXISTS idx_issues_url ON issues(url);
CREATE INDEX IF NOT EXISTS idx_issues_project_url ON issues(project_id, url);
CREATE INDEX IF NOT EXISTS idx_issues_is_resolved ON issues(is_resolved);
CREATE INDEX IF NOT EXISTS idx_issues_metadata ON issues USING GIN (metadata);
CREATE INDEX IF NOT EXISTS idx_issues_issue_logged_at ON issues(issue_logged_at);
CREATE INDEX IF NOT EXISTS idx_issues_issue_updated_at ON issues(issue_updated_at);
CREATE INDEX IF NOT EXISTS idx_issues_dev_status_updated_at ON issues(dev_status_updated_at);
CREATE INDEX IF NOT EXISTS idx_issues_qa_status_updated_at ON issues(qa_status_updated_at);

-- ============================================================================
-- SECTION 3: CLIENT PORTAL TABLES
-- ============================================================================

-- -----------------------------------------------------------------------------
-- 3.1 Client Users Table
-- -----------------------------------------------------------------------------

CREATE TABLE IF NOT EXISTS client_users (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    clerk_user_id VARCHAR(255) NOT NULL,
    client_id UUID NOT NULL REFERENCES clients(id) ON DELETE CASCADE,
    email VARCHAR(255) NOT NULL,
    first_name VARCHAR(100),
    last_name VARCHAR(100),
    role user_role NOT NULL DEFAULT 'viewer',
    is_active BOOLEAN NOT NULL DEFAULT TRUE,
    email_notifications BOOLEAN NOT NULL DEFAULT TRUE,
    last_login_at TIMESTAMP,
    created_at TIMESTAMP NOT NULL DEFAULT NOW(),
    updated_at TIMESTAMP NOT NULL DEFAULT NOW()
);

-- Add unique constraint if it doesn't exist
DO $$ BEGIN
    ALTER TABLE client_users ADD CONSTRAINT unique_clerk_client UNIQUE (clerk_user_id, client_id);
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

CREATE INDEX IF NOT EXISTS idx_client_users_clerk_user_id ON client_users(clerk_user_id);
CREATE INDEX IF NOT EXISTS idx_client_users_client_id ON client_users(client_id);
CREATE INDEX IF NOT EXISTS idx_client_users_email ON client_users(email);

-- -----------------------------------------------------------------------------
-- 3.2 Client Team Members Table (Invitations)
-- -----------------------------------------------------------------------------

CREATE TABLE IF NOT EXISTS client_team_members (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    client_id UUID NOT NULL REFERENCES clients(id) ON DELETE CASCADE,
    name VARCHAR(255) NOT NULL,
    email VARCHAR(255) NOT NULL,
    description TEXT,
    invitation_status invitation_status NOT NULL DEFAULT 'pending',
    invitation_sent_at TIMESTAMP,
    invitation_token VARCHAR(255),
    clerk_invitation_id VARCHAR(255),
    invited_by_user_id UUID REFERENCES client_users(id) ON DELETE SET NULL,
    accepted_at TIMESTAMP,
    linked_user_id UUID REFERENCES client_users(id) ON DELETE SET NULL,
    pending_project_ids JSONB DEFAULT '[]',
    created_at TIMESTAMP NOT NULL DEFAULT NOW(),
    updated_at TIMESTAMP NOT NULL DEFAULT NOW()
);

-- Add unique constraint if it doesn't exist
DO $$ BEGIN
    ALTER TABLE client_team_members ADD CONSTRAINT unique_client_team_member_email UNIQUE (client_id, email);
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

CREATE INDEX IF NOT EXISTS idx_client_team_members_client_id ON client_team_members(client_id);
CREATE INDEX IF NOT EXISTS idx_client_team_members_email ON client_team_members(email);
CREATE INDEX IF NOT EXISTS idx_client_team_members_invitation_status ON client_team_members(invitation_status);
CREATE INDEX IF NOT EXISTS idx_client_team_members_invitation_token ON client_team_members(invitation_token);

-- -----------------------------------------------------------------------------
-- 3.3 Project Team Members Table (User-Project Access)
-- -----------------------------------------------------------------------------

CREATE TABLE IF NOT EXISTS project_team_members (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    project_id UUID NOT NULL REFERENCES projects(id) ON DELETE CASCADE,
    team_member_id UUID NOT NULL REFERENCES client_users(id) ON DELETE CASCADE,
    role project_role NOT NULL DEFAULT 'project_member',
    created_at TIMESTAMP NOT NULL DEFAULT NOW(),
    updated_at TIMESTAMP NOT NULL DEFAULT NOW()
);

-- Add unique constraint if it doesn't exist
DO $$ BEGIN
    ALTER TABLE project_team_members ADD CONSTRAINT unique_project_team_member UNIQUE (project_id, team_member_id);
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

CREATE INDEX IF NOT EXISTS idx_project_team_members_project_id ON project_team_members(project_id);
CREATE INDEX IF NOT EXISTS idx_project_team_members_team_member_id ON project_team_members(team_member_id);

-- -----------------------------------------------------------------------------
-- 3.4 Client Tickets Table
-- -----------------------------------------------------------------------------

CREATE TABLE IF NOT EXISTS client_tickets (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    client_id UUID NOT NULL REFERENCES clients(id) ON DELETE CASCADE,
    project_id UUID REFERENCES projects(id) ON DELETE SET NULL,
    created_by_user_id UUID NOT NULL REFERENCES client_users(id) ON DELETE CASCADE,
    title VARCHAR(500) NOT NULL,
    description TEXT NOT NULL,
    status ticket_status NOT NULL DEFAULT 'open',
    priority ticket_priority NOT NULL DEFAULT 'medium',
    category ticket_category NOT NULL DEFAULT 'general',
    related_issue_id UUID REFERENCES accessibility_issues(id) ON DELETE SET NULL,
    assigned_to VARCHAR(255),
    internal_notes TEXT,
    resolution TEXT,
    resolved_at TIMESTAMP,
    closed_at TIMESTAMP,
    created_at TIMESTAMP NOT NULL DEFAULT NOW(),
    updated_at TIMESTAMP NOT NULL DEFAULT NOW()
);

CREATE INDEX IF NOT EXISTS idx_client_tickets_client_id ON client_tickets(client_id);
CREATE INDEX IF NOT EXISTS idx_client_tickets_project_id ON client_tickets(project_id);
CREATE INDEX IF NOT EXISTS idx_client_tickets_status ON client_tickets(status);
CREATE INDEX IF NOT EXISTS idx_client_tickets_created_at ON client_tickets(created_at DESC);

-- -----------------------------------------------------------------------------
-- 3.5 Client Ticket Issues Junction Table
-- -----------------------------------------------------------------------------

CREATE TABLE IF NOT EXISTS client_ticket_issues (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    ticket_id UUID NOT NULL REFERENCES client_tickets(id) ON DELETE CASCADE,
    issue_id UUID NOT NULL REFERENCES accessibility_issues(id) ON DELETE CASCADE,
    created_at TIMESTAMP NOT NULL DEFAULT NOW()
);

-- Add unique constraint if it doesn't exist
DO $$ BEGIN
    ALTER TABLE client_ticket_issues ADD CONSTRAINT unique_ticket_issue UNIQUE (ticket_id, issue_id);
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

CREATE INDEX IF NOT EXISTS idx_client_ticket_issues_ticket_id ON client_ticket_issues(ticket_id);
CREATE INDEX IF NOT EXISTS idx_client_ticket_issues_issue_id ON client_ticket_issues(issue_id);

-- -----------------------------------------------------------------------------
-- 3.6 Evidence Documents Table
-- -----------------------------------------------------------------------------

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

CREATE INDEX IF NOT EXISTS idx_evidence_documents_client_id ON evidence_documents(client_id);
CREATE INDEX IF NOT EXISTS idx_evidence_documents_project_id ON evidence_documents(project_id);
CREATE INDEX IF NOT EXISTS idx_evidence_documents_status ON evidence_documents(status);
CREATE INDEX IF NOT EXISTS idx_evidence_documents_document_type ON evidence_documents(document_type);
CREATE INDEX IF NOT EXISTS idx_evidence_documents_updated_at ON evidence_documents(updated_at DESC);

-- -----------------------------------------------------------------------------
-- 3.7 Evidence Document Requests Table
-- -----------------------------------------------------------------------------

CREATE TABLE IF NOT EXISTS evidence_document_requests (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    client_id UUID NOT NULL REFERENCES clients(id) ON DELETE CASCADE,
    requested_by_user_id UUID NOT NULL REFERENCES client_users(id) ON DELETE CASCADE,
    document_type document_type NOT NULL,
    title VARCHAR(500) NOT NULL,
    description TEXT,
    priority document_priority NOT NULL DEFAULT 'medium',
    status document_request_status NOT NULL DEFAULT 'pending',
    admin_notes TEXT,
    completed_document_id UUID REFERENCES evidence_documents(id) ON DELETE SET NULL,
    created_at TIMESTAMP NOT NULL DEFAULT NOW(),
    updated_at TIMESTAMP NOT NULL DEFAULT NOW()
);

CREATE INDEX IF NOT EXISTS idx_evidence_document_requests_client_id ON evidence_document_requests(client_id);
CREATE INDEX IF NOT EXISTS idx_evidence_document_requests_requested_by ON evidence_document_requests(requested_by_user_id);
CREATE INDEX IF NOT EXISTS idx_evidence_document_requests_status ON evidence_document_requests(status);
CREATE INDEX IF NOT EXISTS idx_evidence_document_requests_created_at ON evidence_document_requests(created_at DESC);

-- -----------------------------------------------------------------------------
-- 3.8 Document Remediations Table
-- -----------------------------------------------------------------------------

CREATE TABLE IF NOT EXISTS document_remediations (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    client_id UUID NOT NULL REFERENCES clients(id) ON DELETE CASCADE,
    uploaded_by_user_id UUID NOT NULL REFERENCES client_users(id) ON DELETE CASCADE,
    batch_id VARCHAR(100),
    original_file_name VARCHAR(500) NOT NULL,
    original_file_url VARCHAR(1000) NOT NULL,
    original_file_size INTEGER,
    original_file_type VARCHAR(50),
    page_count INTEGER NOT NULL DEFAULT 1,
    remediation_type remediation_type NOT NULL,
    status remediation_status NOT NULL DEFAULT 'pending_review',
    price_per_page NUMERIC(10, 2) NOT NULL,
    total_price NUMERIC(10, 2) NOT NULL,
    price_adjusted BOOLEAN DEFAULT FALSE,
    original_price_per_page NUMERIC(10, 2),
    original_total_price NUMERIC(10, 2),
    remediated_file_name VARCHAR(500),
    remediated_file_url VARCHAR(1000),
    remediated_file_size INTEGER,
    remediated_file_type VARCHAR(50),
    notes TEXT,
    admin_notes TEXT,
    reviewed_by_user_id UUID,
    reviewed_at TIMESTAMP,
    rejection_reason TEXT,
    completed_at TIMESTAMP,
    created_at TIMESTAMP NOT NULL DEFAULT NOW(),
    updated_at TIMESTAMP NOT NULL DEFAULT NOW()
);

CREATE INDEX IF NOT EXISTS idx_document_remediations_client_id ON document_remediations(client_id);
CREATE INDEX IF NOT EXISTS idx_document_remediations_uploaded_by ON document_remediations(uploaded_by_user_id);
CREATE INDEX IF NOT EXISTS idx_document_remediations_status ON document_remediations(status);
CREATE INDEX IF NOT EXISTS idx_document_remediations_batch_id ON document_remediations(batch_id);
CREATE INDEX IF NOT EXISTS idx_document_remediations_created_at ON document_remediations(created_at DESC);

-- -----------------------------------------------------------------------------
-- 3.9 Client Billing Add-ons Table
-- -----------------------------------------------------------------------------

CREATE TABLE IF NOT EXISTS client_billing_addons (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    client_id UUID NOT NULL REFERENCES clients(id) ON DELETE CASCADE,
    addon_type billing_addon_type NOT NULL,
    name VARCHAR(255) NOT NULL,
    description TEXT,
    quantity INTEGER NOT NULL DEFAULT 1,
    unit_price NUMERIC(10, 2) NOT NULL,
    total_monthly_price NUMERIC(10, 2) NOT NULL,
    status billing_addon_status NOT NULL DEFAULT 'active',
    activated_at TIMESTAMP NOT NULL DEFAULT NOW(),
    cancelled_at TIMESTAMP,
    metadata JSONB DEFAULT '{}',
    approved_by_user_id UUID REFERENCES client_users(id) ON DELETE SET NULL,
    created_at TIMESTAMP NOT NULL DEFAULT NOW(),
    updated_at TIMESTAMP NOT NULL DEFAULT NOW()
);

CREATE INDEX IF NOT EXISTS idx_client_billing_addons_client_id ON client_billing_addons(client_id);
CREATE INDEX IF NOT EXISTS idx_client_billing_addons_addon_type ON client_billing_addons(addon_type);
CREATE INDEX IF NOT EXISTS idx_client_billing_addons_status ON client_billing_addons(status);

-- -----------------------------------------------------------------------------
-- 3.10 Notifications Table
-- -----------------------------------------------------------------------------

CREATE TABLE IF NOT EXISTS notifications (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    client_id UUID REFERENCES clients(id) ON DELETE CASCADE,
    user_id UUID REFERENCES client_users(id) ON DELETE CASCADE,
    type notification_type NOT NULL DEFAULT 'system',
    priority notification_priority NOT NULL DEFAULT 'normal',
    title VARCHAR(255) NOT NULL,
    message TEXT NOT NULL,
    action_url VARCHAR(500),
    action_label VARCHAR(100),
    related_project_id UUID REFERENCES projects(id) ON DELETE SET NULL,
    related_document_id UUID,
    related_ticket_id UUID REFERENCES client_tickets(id) ON DELETE SET NULL,
    metadata JSONB DEFAULT '{}',
    is_read BOOLEAN NOT NULL DEFAULT FALSE,
    read_at TIMESTAMP,
    is_archived BOOLEAN NOT NULL DEFAULT FALSE,
    archived_at TIMESTAMP,
    expires_at TIMESTAMP,
    created_at TIMESTAMP NOT NULL DEFAULT NOW(),
    updated_at TIMESTAMP NOT NULL DEFAULT NOW()
);

CREATE INDEX IF NOT EXISTS idx_notifications_client_id ON notifications(client_id);
CREATE INDEX IF NOT EXISTS idx_notifications_user_id ON notifications(user_id);
CREATE INDEX IF NOT EXISTS idx_notifications_type ON notifications(type);
CREATE INDEX IF NOT EXISTS idx_notifications_is_read ON notifications(is_read);
CREATE INDEX IF NOT EXISTS idx_notifications_is_archived ON notifications(is_archived);
CREATE INDEX IF NOT EXISTS idx_notifications_created_at ON notifications(created_at DESC);

-- ============================================================================
-- SECTION 4: ADMIN-ONLY TABLES
-- ============================================================================

-- -----------------------------------------------------------------------------
-- 4.1 Internal Tickets Table
-- -----------------------------------------------------------------------------

CREATE TABLE IF NOT EXISTS tickets (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    project_id UUID REFERENCES projects(id) ON DELETE CASCADE,
    client_id UUID REFERENCES clients(id),
    title VARCHAR(255) NOT NULL,
    description TEXT NOT NULL,
    status ticket_status NOT NULL DEFAULT 'open',
    priority ticket_priority NOT NULL DEFAULT 'medium',
    type ticket_type NOT NULL,
    assignee_id VARCHAR(255),
    reporter_id VARCHAR(255) NOT NULL,
    estimated_hours INTEGER,
    actual_hours INTEGER DEFAULT 0,
    wcag_criteria TEXT[],
    tags TEXT[] NOT NULL DEFAULT '{}',
    ticket_category VARCHAR(50) DEFAULT 'general',
    related_issue_ids TEXT[] DEFAULT '{}',
    due_date TIMESTAMP,
    resolved_at TIMESTAMP,
    closed_at TIMESTAMP,
    created_at TIMESTAMP NOT NULL DEFAULT NOW(),
    updated_at TIMESTAMP NOT NULL DEFAULT NOW()
);

CREATE INDEX IF NOT EXISTS idx_tickets_project_id ON tickets(project_id);
CREATE INDEX IF NOT EXISTS idx_tickets_client ON tickets(client_id);
CREATE INDEX IF NOT EXISTS idx_tickets_status ON tickets(status);
CREATE INDEX IF NOT EXISTS idx_tickets_status_count ON tickets(status);
CREATE INDEX IF NOT EXISTS idx_tickets_category ON tickets(ticket_category);

-- -----------------------------------------------------------------------------
-- 4.2 Ticket Attachments Table
-- -----------------------------------------------------------------------------

CREATE TABLE IF NOT EXISTS ticket_attachments (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    ticket_id UUID NOT NULL REFERENCES tickets(id) ON DELETE CASCADE,
    filename VARCHAR(255) NOT NULL,
    original_name VARCHAR(255) NOT NULL,
    file_path VARCHAR(500) NOT NULL,
    file_size NUMERIC(15, 0) NOT NULL,
    mime_type VARCHAR(100) NOT NULL,
    uploaded_by VARCHAR(255) NOT NULL,
    uploaded_at TIMESTAMP NOT NULL DEFAULT NOW()
);

CREATE INDEX IF NOT EXISTS idx_ticket_attachments_ticket_id ON ticket_attachments(ticket_id);

-- -----------------------------------------------------------------------------
-- 4.3 Ticket Comments Table
-- -----------------------------------------------------------------------------

CREATE TABLE IF NOT EXISTS ticket_comments (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    ticket_id UUID NOT NULL REFERENCES tickets(id) ON DELETE CASCADE,
    user_id VARCHAR(255) NOT NULL,
    user_name VARCHAR(255) NOT NULL,
    comment TEXT NOT NULL,
    is_internal BOOLEAN NOT NULL DEFAULT FALSE,
    created_at TIMESTAMP NOT NULL DEFAULT NOW(),
    updated_at TIMESTAMP NOT NULL DEFAULT NOW()
);

CREATE INDEX IF NOT EXISTS idx_ticket_comments_ticket_id ON ticket_comments(ticket_id);

-- -----------------------------------------------------------------------------
-- 4.4 Teams Table
-- -----------------------------------------------------------------------------

CREATE TABLE IF NOT EXISTS teams (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    name VARCHAR(255) NOT NULL,
    description TEXT,
    team_type team_type NOT NULL,
    manager_id UUID,
    is_active BOOLEAN NOT NULL DEFAULT TRUE,
    created_at TIMESTAMP NOT NULL DEFAULT NOW(),
    updated_at TIMESTAMP NOT NULL DEFAULT NOW()
);

CREATE INDEX IF NOT EXISTS idx_teams_team_type ON teams(team_type);
CREATE INDEX IF NOT EXISTS idx_teams_is_active ON teams(is_active);

-- -----------------------------------------------------------------------------
-- 4.5 Team Members Table
-- -----------------------------------------------------------------------------

CREATE TABLE IF NOT EXISTS team_members (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    team_id UUID NOT NULL REFERENCES teams(id) ON DELETE CASCADE,
    first_name VARCHAR(100) NOT NULL,
    last_name VARCHAR(100) NOT NULL,
    email VARCHAR(255) NOT NULL UNIQUE,
    phone VARCHAR(20),
    role employee_role NOT NULL,
    title VARCHAR(255),
    department VARCHAR(100),
    reports_to_id UUID,
    employment_status employment_status NOT NULL DEFAULT 'active',
    start_date TIMESTAMP,
    end_date TIMESTAMP,
    hourly_rate INTEGER,
    salary INTEGER,
    skills TEXT,
    bio TEXT,
    profile_image_url VARCHAR(500),
    linkedin_url VARCHAR(500),
    github_url VARCHAR(500),
    is_active BOOLEAN NOT NULL DEFAULT TRUE,
    created_at TIMESTAMP NOT NULL DEFAULT NOW(),
    updated_at TIMESTAMP NOT NULL DEFAULT NOW()
);

CREATE INDEX IF NOT EXISTS idx_team_members_team_id ON team_members(team_id);
CREATE INDEX IF NOT EXISTS idx_team_members_email ON team_members(email);
CREATE INDEX IF NOT EXISTS idx_team_members_role ON team_members(role);
CREATE INDEX IF NOT EXISTS idx_team_members_is_active ON team_members(is_active);

-- -----------------------------------------------------------------------------
-- 4.6 Project Team Assignments Table
-- -----------------------------------------------------------------------------

CREATE TABLE IF NOT EXISTS project_team_assignments (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    project_id UUID NOT NULL REFERENCES projects(id) ON DELETE CASCADE,
    team_member_id UUID NOT NULL REFERENCES team_members(id) ON DELETE CASCADE,
    project_role VARCHAR(100),
    assigned_at TIMESTAMP NOT NULL DEFAULT NOW(),
    unassigned_at TIMESTAMP,
    is_active BOOLEAN NOT NULL DEFAULT TRUE
);

CREATE INDEX IF NOT EXISTS idx_project_team_assignments_project_id ON project_team_assignments(project_id);
CREATE INDEX IF NOT EXISTS idx_project_team_assignments_team_member_id ON project_team_assignments(team_member_id);

-- -----------------------------------------------------------------------------
-- 4.7 Project Staging Credentials Table
-- -----------------------------------------------------------------------------

CREATE TABLE IF NOT EXISTS project_staging_credentials (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    project_id UUID NOT NULL REFERENCES projects(id) ON DELETE CASCADE,
    type credential_type NOT NULL DEFAULT 'staging',
    environment VARCHAR(100) NOT NULL,
    url VARCHAR(500) NOT NULL,
    username VARCHAR(255),
    password TEXT,
    api_key TEXT,
    access_token TEXT,
    ssh_key TEXT,
    database_url TEXT,
    remote_folder_path VARCHAR(500),
    additional_urls TEXT[] DEFAULT '{}',
    notes TEXT,
    is_active BOOLEAN NOT NULL DEFAULT TRUE,
    expires_at TIMESTAMP,
    credentials JSONB DEFAULT '{}',
    created_by VARCHAR(255) NOT NULL,
    created_at TIMESTAMP NOT NULL DEFAULT NOW(),
    updated_at TIMESTAMP NOT NULL DEFAULT NOW()
);

CREATE INDEX IF NOT EXISTS idx_project_staging_credentials_project_id ON project_staging_credentials(project_id);
CREATE INDEX IF NOT EXISTS project_staging_credentials_credentials_idx ON project_staging_credentials USING GIN (credentials);

-- -----------------------------------------------------------------------------
-- 4.8 Client Credentials Table
-- -----------------------------------------------------------------------------

CREATE TABLE IF NOT EXISTS client_credentials (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    client_id UUID NOT NULL REFERENCES clients(id) ON DELETE CASCADE,
    name VARCHAR(255) NOT NULL,
    username VARCHAR(255),
    password TEXT,
    api_key TEXT,
    notes TEXT,
    type VARCHAR(50) NOT NULL,
    created_at TIMESTAMP NOT NULL DEFAULT NOW(),
    updated_at TIMESTAMP NOT NULL DEFAULT NOW()
);

CREATE INDEX IF NOT EXISTS idx_client_credentials_client_id ON client_credentials(client_id);

-- -----------------------------------------------------------------------------
-- 4.9 Client Files Table
-- -----------------------------------------------------------------------------

CREATE TABLE IF NOT EXISTS client_files (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    client_id UUID NOT NULL REFERENCES clients(id) ON DELETE CASCADE,
    filename VARCHAR(255) NOT NULL,
    original_name VARCHAR(255) NOT NULL,
    category VARCHAR(50) NOT NULL,
    file_path VARCHAR(500) NOT NULL,
    file_size NUMERIC(15, 0) NOT NULL,
    mime_type VARCHAR(100) NOT NULL,
    is_encrypted BOOLEAN NOT NULL DEFAULT FALSE,
    uploaded_by VARCHAR(255) NOT NULL,
    uploaded_at TIMESTAMP NOT NULL DEFAULT NOW(),
    access_level VARCHAR(20) NOT NULL DEFAULT 'public',
    metadata TEXT
);

CREATE INDEX IF NOT EXISTS idx_client_files_client_id ON client_files(client_id);

-- -----------------------------------------------------------------------------
-- 4.10 Project Documents Table
-- -----------------------------------------------------------------------------

CREATE TABLE IF NOT EXISTS project_documents (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    project_id UUID NOT NULL REFERENCES projects(id) ON DELETE CASCADE,
    name VARCHAR(255) NOT NULL,
    type document_type NOT NULL,
    file_path VARCHAR(500) NOT NULL,
    uploaded_by VARCHAR(255) NOT NULL,
    uploaded_at TIMESTAMP NOT NULL DEFAULT NOW(),
    version VARCHAR(50) NOT NULL DEFAULT '1.0',
    is_latest BOOLEAN NOT NULL DEFAULT TRUE,
    tags TEXT[] NOT NULL DEFAULT '{}',
    file_size NUMERIC(15, 0) NOT NULL,
    mime_type VARCHAR(100) NOT NULL
);

CREATE INDEX IF NOT EXISTS idx_project_documents_project_id ON project_documents(project_id);

-- -----------------------------------------------------------------------------
-- 4.11 Project Activities Table
-- -----------------------------------------------------------------------------

CREATE TABLE IF NOT EXISTS project_activities (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    project_id UUID NOT NULL REFERENCES projects(id) ON DELETE CASCADE,
    user_id VARCHAR(255) NOT NULL,
    user_name VARCHAR(255) NOT NULL,
    action activity_action NOT NULL,
    description TEXT NOT NULL,
    metadata TEXT,
    timestamp TIMESTAMP NOT NULL DEFAULT NOW()
);

CREATE INDEX IF NOT EXISTS idx_activities_project_id ON project_activities(project_id);
CREATE INDEX IF NOT EXISTS idx_activities_timestamp ON project_activities(timestamp);
CREATE INDEX IF NOT EXISTS idx_activities_recent_timestamp ON project_activities(timestamp DESC);

-- -----------------------------------------------------------------------------
-- 4.12 Project Developers Table
-- -----------------------------------------------------------------------------

CREATE TABLE IF NOT EXISTS project_developers (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    project_id UUID NOT NULL REFERENCES projects(id) ON DELETE CASCADE,
    developer_id VARCHAR(255) NOT NULL,
    role developer_role NOT NULL,
    responsibilities TEXT[] NOT NULL DEFAULT '{}',
    assigned_at TIMESTAMP NOT NULL DEFAULT NOW(),
    assigned_by VARCHAR(255) NOT NULL,
    is_active BOOLEAN NOT NULL DEFAULT TRUE,
    hourly_rate NUMERIC(8, 2),
    max_hours_per_week INTEGER
);

CREATE INDEX IF NOT EXISTS idx_project_developers_project_id ON project_developers(project_id);

-- -----------------------------------------------------------------------------
-- 4.13 Project Milestones Table
-- -----------------------------------------------------------------------------

CREATE TABLE IF NOT EXISTS project_milestones (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    project_id UUID NOT NULL REFERENCES projects(id) ON DELETE CASCADE,
    title VARCHAR(255) NOT NULL,
    description TEXT,
    due_date TIMESTAMP NOT NULL,
    completed_date TIMESTAMP,
    status milestone_status NOT NULL DEFAULT 'pending',
    assigned_to VARCHAR(255),
    deliverables TEXT[] NOT NULL DEFAULT '{}',
    acceptance_criteria TEXT[] NOT NULL DEFAULT '{}',
    "order" INTEGER NOT NULL,
    wcag_criteria TEXT[],
    created_at TIMESTAMP NOT NULL DEFAULT NOW(),
    updated_at TIMESTAMP NOT NULL DEFAULT NOW()
);

CREATE INDEX IF NOT EXISTS idx_project_milestones_project_id ON project_milestones(project_id);

-- -----------------------------------------------------------------------------
-- 4.14 Project Time Entries Table
-- -----------------------------------------------------------------------------

CREATE TABLE IF NOT EXISTS project_time_entries (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    project_id UUID NOT NULL REFERENCES projects(id) ON DELETE CASCADE,
    developer_id VARCHAR(255) NOT NULL,
    date TIMESTAMP NOT NULL,
    hours NUMERIC(4, 2) NOT NULL,
    description TEXT NOT NULL,
    category time_entry_category NOT NULL,
    billable BOOLEAN NOT NULL DEFAULT TRUE,
    approved BOOLEAN NOT NULL DEFAULT FALSE,
    approved_by VARCHAR(255),
    approved_at TIMESTAMP,
    created_at TIMESTAMP NOT NULL DEFAULT NOW()
);

CREATE INDEX IF NOT EXISTS idx_project_time_entries_project_id ON project_time_entries(project_id);

-- -----------------------------------------------------------------------------
-- 4.15 Sync Logs Table
-- -----------------------------------------------------------------------------

CREATE TABLE IF NOT EXISTS sync_logs (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    project_id UUID NOT NULL REFERENCES projects(id),
    sheet_id TEXT,
    sync_type TEXT NOT NULL,
    status TEXT NOT NULL,
    rows_processed TEXT,
    rows_inserted TEXT,
    rows_updated TEXT,
    rows_skipped TEXT,
    rows_failed TEXT,
    error_message TEXT,
    error_type TEXT,
    structure_mismatch_details TEXT,
    started_at TIMESTAMP NOT NULL,
    completed_at TIMESTAMP,
    created_at TIMESTAMP NOT NULL DEFAULT NOW()
);

CREATE INDEX IF NOT EXISTS idx_sync_logs_project_id ON sync_logs(project_id);
CREATE INDEX IF NOT EXISTS idx_sync_logs_created_at ON sync_logs(created_at DESC);
CREATE INDEX IF NOT EXISTS idx_sync_logs_started_at ON sync_logs(started_at DESC);
CREATE INDEX IF NOT EXISTS idx_sync_logs_status ON sync_logs(status);
CREATE INDEX IF NOT EXISTS idx_sync_logs_sync_type ON sync_logs(sync_type);
CREATE INDEX IF NOT EXISTS idx_sync_logs_project_type ON sync_logs(project_id, sync_type);

-- -----------------------------------------------------------------------------
-- 4.16 Project Sync Status Table
-- -----------------------------------------------------------------------------

CREATE TABLE IF NOT EXISTS project_sync_status (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    project_id UUID NOT NULL REFERENCES projects(id),
    sheet_id VARCHAR(255) NOT NULL,
    sync_type VARCHAR(50) NOT NULL,
    sync_status VARCHAR(20) NOT NULL,
    started_at TIMESTAMP NOT NULL DEFAULT NOW(),
    completed_at TIMESTAMP,
    duration_ms INTEGER,
    total_rows_processed INTEGER DEFAULT 0,
    rows_inserted INTEGER DEFAULT 0,
    rows_updated INTEGER DEFAULT 0,
    rows_skipped INTEGER DEFAULT 0,
    rows_failed INTEGER DEFAULT 0,
    error_type VARCHAR(100),
    error_message TEXT,
    error_details JSONB,
    sheet_name VARCHAR(255),
    expected_columns TEXT[],
    actual_columns TEXT[],
    structure_match BOOLEAN,
    sync_config JSONB,
    retry_count INTEGER DEFAULT 0,
    max_retries INTEGER DEFAULT 3,
    sync_version VARCHAR(20) DEFAULT '1.0',
    created_by VARCHAR(255) DEFAULT 'a3s-server',
    created_at TIMESTAMP NOT NULL DEFAULT NOW(),
    updated_at TIMESTAMP NOT NULL DEFAULT NOW()
);

CREATE INDEX IF NOT EXISTS idx_project_sync_status_project_id ON project_sync_status(project_id);
CREATE INDEX IF NOT EXISTS idx_project_sync_status_created_at ON project_sync_status(created_at DESC);
CREATE INDEX IF NOT EXISTS idx_project_sync_status_sheet_id ON project_sync_status(sheet_id);
CREATE INDEX IF NOT EXISTS idx_project_sync_status_started_at ON project_sync_status(started_at);
CREATE INDEX IF NOT EXISTS idx_project_sync_status_status ON project_sync_status(sync_status);
CREATE INDEX IF NOT EXISTS idx_project_sync_status_sync_type ON project_sync_status(sync_type);
CREATE INDEX IF NOT EXISTS idx_sync_project_id ON project_sync_status(project_id);
CREATE INDEX IF NOT EXISTS idx_sync_started_at ON project_sync_status(started_at);
CREATE INDEX IF NOT EXISTS idx_sync_status ON project_sync_status(sync_status);

-- -----------------------------------------------------------------------------
-- 4.17 Checkpoint Sync Table
-- -----------------------------------------------------------------------------

CREATE TABLE IF NOT EXISTS checkpoint_sync (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    project_id UUID NOT NULL REFERENCES projects(id),
    sheet_id TEXT NOT NULL,
    last_synced_row TEXT NOT NULL,
    created_at TIMESTAMP NOT NULL DEFAULT NOW(),
    updated_at TIMESTAMP NOT NULL DEFAULT NOW()
);

-- Add unique constraint if it doesn't exist
DO $$ BEGIN
    ALTER TABLE checkpoint_sync ADD CONSTRAINT checkpoint_sync_project_id_sheet_id_key UNIQUE (project_id, sheet_id);
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

CREATE INDEX IF NOT EXISTS idx_checkpoint_sync_project_id ON checkpoint_sync(project_id);
CREATE INDEX IF NOT EXISTS idx_checkpoint_sync_created_at ON checkpoint_sync(created_at DESC);

-- -----------------------------------------------------------------------------
-- 4.18 Status Table
-- -----------------------------------------------------------------------------

CREATE TABLE IF NOT EXISTS status (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    project_id UUID NOT NULL REFERENCES projects(id),
    url TEXT NOT NULL,
    status TEXT,
    notes TEXT,
    page_title TEXT,
    url_category TEXT,
    testing_month TEXT,
    testing_year TEXT,
    remediation_month TEXT,
    automated_tools TEXT,
    nvda_chrome TEXT,
    voiceover_iphone_safari TEXT,
    color_contrast TEXT,
    is_active TEXT,
    created_at TIMESTAMP NOT NULL DEFAULT NOW(),
    updated_at TIMESTAMP NOT NULL DEFAULT NOW()
);

-- Add unique constraint if it doesn't exist
DO $$ BEGIN
    ALTER TABLE status ADD CONSTRAINT status_project_id_url_key UNIQUE (project_id, url);
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

CREATE INDEX IF NOT EXISTS idx_status_project_id ON status(project_id);
CREATE INDEX IF NOT EXISTS idx_status_url ON status(url);
CREATE INDEX IF NOT EXISTS idx_status_status ON status(status);
CREATE INDEX IF NOT EXISTS idx_status_created_at ON status(created_at DESC);
CREATE INDEX IF NOT EXISTS idx_status_project_url ON status(project_id, url);

-- -----------------------------------------------------------------------------
-- 4.19 Status Check Table
-- -----------------------------------------------------------------------------

CREATE TABLE IF NOT EXISTS status_check (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    project_id UUID NOT NULL REFERENCES projects(id),
    test_scenario TEXT,
    url TEXT,
    status TEXT,
    notes TEXT,
    created_at TIMESTAMP NOT NULL DEFAULT NOW(),
    updated_at TIMESTAMP NOT NULL DEFAULT NOW()
);

-- Add unique constraint if it doesn't exist
DO $$ BEGIN
    ALTER TABLE status_check ADD CONSTRAINT status_check_project_id_test_scenario_url_key UNIQUE (project_id, test_scenario, url);
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

CREATE INDEX IF NOT EXISTS idx_status_check_project_id ON status_check(project_id);
CREATE INDEX IF NOT EXISTS idx_status_check_url ON status_check(url);
CREATE INDEX IF NOT EXISTS idx_status_check_status ON status_check(status);
CREATE INDEX IF NOT EXISTS idx_status_check_created_at ON status_check(created_at DESC);
CREATE INDEX IF NOT EXISTS idx_status_check_project_url ON status_check(project_id, url);

-- -----------------------------------------------------------------------------
-- 4.20 Issue Comments Table
-- -----------------------------------------------------------------------------

CREATE TABLE IF NOT EXISTS issue_comments (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    issue_id UUID NOT NULL REFERENCES accessibility_issues(id) ON DELETE CASCADE,
    comment_text TEXT NOT NULL,
    comment_type comment_type DEFAULT 'general',
    author_name VARCHAR(255),
    author_role author_role,
    created_at TIMESTAMP NOT NULL DEFAULT NOW(),
    updated_at TIMESTAMP NOT NULL DEFAULT NOW()
);

CREATE INDEX IF NOT EXISTS issue_comments_issue_idx ON issue_comments(issue_id);

-- -----------------------------------------------------------------------------
-- 4.21 WCAG URL Check Table (For detailed WCAG tracking per URL)
-- -----------------------------------------------------------------------------

CREATE TABLE IF NOT EXISTS wcag_url_check (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    project_id UUID NOT NULL REFERENCES projects(id),
    test_scenario TEXT,
    -- WCAG 1.x criteria
    "_111_non_text_content_a" TEXT,
    "_121_audio_only_and_video_only_prerecorded_a" TEXT,
    "_122_captions_prerecorded_a" TEXT,
    "_123_audio_description_or_media_alternative_prerecorded_a" TEXT,
    "_124_captions_live_aa" TEXT,
    "_125_audio_description_prerecorded_aa" TEXT,
    "_131_info_and_relationships_a" TEXT,
    "_132_meaningful_sequence_a" TEXT,
    "_133_sensory_characteristics_a" TEXT,
    "_134_orientation_aa" TEXT,
    "_135_identify_input_purpose_aa" TEXT,
    "_141_use_of_color_a" TEXT,
    "_142_audio_control_a" TEXT,
    "_143_contrast_minimum_aa" TEXT,
    "_144_resize_text_aa" TEXT,
    "_145_images_of_text_aa" TEXT,
    "_1410_reflow_aa" TEXT,
    "_1411_non_text_contrast_aa" TEXT,
    "_1412_text_spacing_aa" TEXT,
    "_1413_content_on_hover_or_focus_aa" TEXT,
    -- WCAG 2.x criteria
    "_211_keyboard_a" TEXT,
    "_212_no_keyboard_trap_a" TEXT,
    "_214_character_key_shortcuts_a" TEXT,
    "_221_timing_adjustable_a" TEXT,
    "_222_pause_stop_hide_a" TEXT,
    "_231_three_flashes_or_below_threshold_a" TEXT,
    "_241_bypass_blocks_a" TEXT,
    "_242_page_titled_a" TEXT,
    "_243_focus_order_a" TEXT,
    "_244_link_purpose_in_context_a" TEXT,
    "_245_multiple_ways_aa" TEXT,
    "_246_headings_and_labels_aa" TEXT,
    "_247_focus_visible_aa" TEXT,
    "_251_pointer_gestures_a" TEXT,
    "_252_pointer_cancellation_a" TEXT,
    "_253_label_in_name_a" TEXT,
    "_254_motion_actuation_a" TEXT,
    "_257_dragging_movements_aa" TEXT,
    "_258_target_size_minimum_aa" TEXT,
    "_2411_focus_not_obscured_minimum_aa" TEXT,
    -- WCAG 3.x criteria  
    "_311_language_of_page_a" TEXT,
    "_312_language_of_parts_aa" TEXT,
    "_321_on_focus_a" TEXT,
    "_322_on_input_a" TEXT,
    "_323_consistent_navigation_aa" TEXT,
    "_324_consistent_identification_aa" TEXT,
    "_326_consistent_help_aa" TEXT,
    "_331_error_identification_a" TEXT,
    "_332_labels_or_instructions_a" TEXT,
    "_333_error_suggestion_aa" TEXT,
    "_334_error_prevention_legal_financial_data_aa" TEXT,
    "_337_redundant_entry_a" TEXT,
    "_338_accessible_authentication_minimum_aa" TEXT,
    -- WCAG 4.x criteria
    "_411_parsing_aa" TEXT,
    "_412_name_role_value_a" TEXT,
    "_413_status_messages_aa" TEXT,
    created_at TIMESTAMP NOT NULL DEFAULT NOW(),
    updated_at TIMESTAMP NOT NULL DEFAULT NOW()
);

CREATE INDEX IF NOT EXISTS idx_wcag_url_check_project_id ON wcag_url_check(project_id);
CREATE INDEX IF NOT EXISTS idx_wcag_url_check_test_scenario ON wcag_url_check(test_scenario);
CREATE INDEX IF NOT EXISTS idx_wcag_url_check_created_at ON wcag_url_check(created_at DESC);
CREATE INDEX IF NOT EXISTS idx_wcag_url_check_project_scenario ON wcag_url_check(project_id, test_scenario);

-- ============================================================================
-- SECTION 5: TRIGGERS FOR AUTO-UPDATING updated_at
-- ============================================================================

-- Create a reusable function for updating timestamps
CREATE OR REPLACE FUNCTION update_updated_at_column()
RETURNS TRIGGER AS $$
BEGIN
    NEW.updated_at = NOW();
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- Apply trigger to all tables with updated_at column
DO $$
DECLARE
    t RECORD;
BEGIN
    FOR t IN 
        SELECT table_name 
        FROM information_schema.columns 
        WHERE column_name = 'updated_at' 
        AND table_schema = 'public'
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
-- SECTION 6: CLEANUP HELPER FUNCTION
-- ============================================================================

-- Drop the helper function if we created it
DROP FUNCTION IF EXISTS add_enum_value_if_not_exists(TEXT, TEXT);

-- ============================================================================
-- SECTION 7: VERIFICATION QUERIES
-- ============================================================================

-- Display all created tables
SELECT 'Tables created:' as info;
SELECT table_name 
FROM information_schema.tables 
WHERE table_schema = 'public' 
AND table_type = 'BASE TABLE'
ORDER BY table_name;

-- Display all created enum types
SELECT 'Enum types created:' as info;
SELECT typname 
FROM pg_type 
WHERE typtype = 'e' 
AND typnamespace = (SELECT oid FROM pg_namespace WHERE nspname = 'public')
ORDER BY typname;

-- Count tables and enums
SELECT 
    'Summary:' as info,
    (SELECT COUNT(*) FROM information_schema.tables WHERE table_schema = 'public' AND table_type = 'BASE TABLE') as table_count,
    (SELECT COUNT(*) FROM pg_type WHERE typtype = 'e' AND typnamespace = (SELECT oid FROM pg_namespace WHERE nspname = 'public')) as enum_count;

-- ============================================================================
-- END OF SCRIPT
-- ============================================================================

SELECT 'A3S Platform database setup complete!' as status;
