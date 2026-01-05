-- ============================================================================
-- A3S PLATFORM - COMPLETE DATABASE SETUP SCRIPT
-- ============================================================================
-- 
-- This script creates all tables, enums, indexes, and constraints needed for
-- both the Admin Dashboard and Client Portal applications.
--
-- IDEMPOTENT: Safe to run multiple times - uses IF NOT EXISTS patterns
-- 
-- IMPORTANT: This script matches the PRODUCTION database exactly.
--
-- NOTE ON EXISTING TABLES:
--   CREATE TABLE IF NOT EXISTS only creates NEW tables - it does NOT add
--   missing columns to existing tables. If you have existing tables that
--   might be missing columns, run 001_add_missing_columns.sql afterwards.
--
-- Usage:
--   1. psql -d your_database -f 000_full_database_setup.sql
--   2. psql -d your_database -f 001_add_missing_columns.sql  (if tables existed)
--   OR
--   Run via Supabase SQL Editor (both scripts in sequence)
--
-- Last Updated: January 2026
-- ============================================================================

-- Enable UUID extension (required for gen_random_uuid())
CREATE EXTENSION IF NOT EXISTS "uuid-ossp";
CREATE EXTENSION IF NOT EXISTS "pgcrypto";

-- ============================================================================
-- SECTION 1: ENUM TYPES (60 total)
-- ============================================================================

-- Helper: Create enum if not exists, then add values
DO $$ BEGIN CREATE TYPE accessibility_level AS ENUM ('none'); EXCEPTION WHEN duplicate_object THEN NULL; END $$;
ALTER TYPE accessibility_level ADD VALUE IF NOT EXISTS 'none';
ALTER TYPE accessibility_level ADD VALUE IF NOT EXISTS 'basic';
ALTER TYPE accessibility_level ADD VALUE IF NOT EXISTS 'partial';
ALTER TYPE accessibility_level ADD VALUE IF NOT EXISTS 'compliant';

DO $$ BEGIN CREATE TYPE activity_action AS ENUM ('created'); EXCEPTION WHEN duplicate_object THEN NULL; END $$;
ALTER TYPE activity_action ADD VALUE IF NOT EXISTS 'created';
ALTER TYPE activity_action ADD VALUE IF NOT EXISTS 'updated';
ALTER TYPE activity_action ADD VALUE IF NOT EXISTS 'milestone_completed';
ALTER TYPE activity_action ADD VALUE IF NOT EXISTS 'developer_assigned';
ALTER TYPE activity_action ADD VALUE IF NOT EXISTS 'status_changed';
ALTER TYPE activity_action ADD VALUE IF NOT EXISTS 'document_uploaded';
ALTER TYPE activity_action ADD VALUE IF NOT EXISTS 'time_logged';
ALTER TYPE activity_action ADD VALUE IF NOT EXISTS 'staging_credentials_updated';

DO $$ BEGIN CREATE TYPE admin_notification_type AS ENUM ('system'); EXCEPTION WHEN duplicate_object THEN NULL; END $$;
ALTER TYPE admin_notification_type ADD VALUE IF NOT EXISTS 'system';
ALTER TYPE admin_notification_type ADD VALUE IF NOT EXISTS 'new_ticket';
ALTER TYPE admin_notification_type ADD VALUE IF NOT EXISTS 'new_remediation_request';
ALTER TYPE admin_notification_type ADD VALUE IF NOT EXISTS 'new_document_request';
ALTER TYPE admin_notification_type ADD VALUE IF NOT EXISTS 'client_signup';
ALTER TYPE admin_notification_type ADD VALUE IF NOT EXISTS 'custom';

DO $$ BEGIN CREATE TYPE author_role AS ENUM ('developer'); EXCEPTION WHEN duplicate_object THEN NULL; END $$;
ALTER TYPE author_role ADD VALUE IF NOT EXISTS 'developer';
ALTER TYPE author_role ADD VALUE IF NOT EXISTS 'qa_tester';
ALTER TYPE author_role ADD VALUE IF NOT EXISTS 'accessibility_expert';
ALTER TYPE author_role ADD VALUE IF NOT EXISTS 'project_manager';
ALTER TYPE author_role ADD VALUE IF NOT EXISTS 'client';

DO $$ BEGIN CREATE TYPE billing_addon_status AS ENUM ('active'); EXCEPTION WHEN duplicate_object THEN NULL; END $$;
ALTER TYPE billing_addon_status ADD VALUE IF NOT EXISTS 'active';
ALTER TYPE billing_addon_status ADD VALUE IF NOT EXISTS 'cancelled';
ALTER TYPE billing_addon_status ADD VALUE IF NOT EXISTS 'pending';

DO $$ BEGIN CREATE TYPE billing_addon_type AS ENUM ('team_members'); EXCEPTION WHEN duplicate_object THEN NULL; END $$;
ALTER TYPE billing_addon_type ADD VALUE IF NOT EXISTS 'team_members';
ALTER TYPE billing_addon_type ADD VALUE IF NOT EXISTS 'document_remediation';
ALTER TYPE billing_addon_type ADD VALUE IF NOT EXISTS 'evidence_locker';
ALTER TYPE billing_addon_type ADD VALUE IF NOT EXISTS 'custom';

DO $$ BEGIN CREATE TYPE billing_frequency AS ENUM ('monthly'); EXCEPTION WHEN duplicate_object THEN NULL; END $$;
ALTER TYPE billing_frequency ADD VALUE IF NOT EXISTS 'daily';
ALTER TYPE billing_frequency ADD VALUE IF NOT EXISTS 'weekly';
ALTER TYPE billing_frequency ADD VALUE IF NOT EXISTS 'bi-weekly';
ALTER TYPE billing_frequency ADD VALUE IF NOT EXISTS 'monthly';
ALTER TYPE billing_frequency ADD VALUE IF NOT EXISTS 'quarterly';
ALTER TYPE billing_frequency ADD VALUE IF NOT EXISTS 'half-yearly';
ALTER TYPE billing_frequency ADD VALUE IF NOT EXISTS 'yearly';

DO $$ BEGIN CREATE TYPE billing_type AS ENUM ('fixed'); EXCEPTION WHEN duplicate_object THEN NULL; END $$;
ALTER TYPE billing_type ADD VALUE IF NOT EXISTS 'fixed';
ALTER TYPE billing_type ADD VALUE IF NOT EXISTS 'hourly';
ALTER TYPE billing_type ADD VALUE IF NOT EXISTS 'milestone';

DO $$ BEGIN CREATE TYPE client_status AS ENUM ('pending'); EXCEPTION WHEN duplicate_object THEN NULL; END $$;
ALTER TYPE client_status ADD VALUE IF NOT EXISTS 'pending';
ALTER TYPE client_status ADD VALUE IF NOT EXISTS 'active';
ALTER TYPE client_status ADD VALUE IF NOT EXISTS 'inactive';
ALTER TYPE client_status ADD VALUE IF NOT EXISTS 'suspended';
ALTER TYPE client_status ADD VALUE IF NOT EXISTS 'archived';

DO $$ BEGIN CREATE TYPE client_type AS ENUM ('a3s'); EXCEPTION WHEN duplicate_object THEN NULL; END $$;
ALTER TYPE client_type ADD VALUE IF NOT EXISTS 'a3s';
ALTER TYPE client_type ADD VALUE IF NOT EXISTS 'p15r';
ALTER TYPE client_type ADD VALUE IF NOT EXISTS 'partner';

DO $$ BEGIN CREATE TYPE client_wcag_level AS ENUM ('A'); EXCEPTION WHEN duplicate_object THEN NULL; END $$;
ALTER TYPE client_wcag_level ADD VALUE IF NOT EXISTS 'A';
ALTER TYPE client_wcag_level ADD VALUE IF NOT EXISTS 'AA';
ALTER TYPE client_wcag_level ADD VALUE IF NOT EXISTS 'AAA';

DO $$ BEGIN CREATE TYPE comment_type AS ENUM ('general'); EXCEPTION WHEN duplicate_object THEN NULL; END $$;
ALTER TYPE comment_type ADD VALUE IF NOT EXISTS 'general';
ALTER TYPE comment_type ADD VALUE IF NOT EXISTS 'dev_update';
ALTER TYPE comment_type ADD VALUE IF NOT EXISTS 'qa_feedback';
ALTER TYPE comment_type ADD VALUE IF NOT EXISTS 'technical_note';
ALTER TYPE comment_type ADD VALUE IF NOT EXISTS 'resolution';

DO $$ BEGIN CREATE TYPE communication_preference AS ENUM ('email'); EXCEPTION WHEN duplicate_object THEN NULL; END $$;
ALTER TYPE communication_preference ADD VALUE IF NOT EXISTS 'email';
ALTER TYPE communication_preference ADD VALUE IF NOT EXISTS 'phone';
ALTER TYPE communication_preference ADD VALUE IF NOT EXISTS 'slack';
ALTER TYPE communication_preference ADD VALUE IF NOT EXISTS 'teams';

DO $$ BEGIN CREATE TYPE company_size AS ENUM ('1-10'); EXCEPTION WHEN duplicate_object THEN NULL; END $$;
ALTER TYPE company_size ADD VALUE IF NOT EXISTS '1-10';
ALTER TYPE company_size ADD VALUE IF NOT EXISTS '11-50';
ALTER TYPE company_size ADD VALUE IF NOT EXISTS '51-200';
ALTER TYPE company_size ADD VALUE IF NOT EXISTS '201-1000';
ALTER TYPE company_size ADD VALUE IF NOT EXISTS '1000+';

DO $$ BEGIN CREATE TYPE conformance_level AS ENUM ('A'); EXCEPTION WHEN duplicate_object THEN NULL; END $$;
ALTER TYPE conformance_level ADD VALUE IF NOT EXISTS 'A';
ALTER TYPE conformance_level ADD VALUE IF NOT EXISTS 'AA';
ALTER TYPE conformance_level ADD VALUE IF NOT EXISTS 'AAA';

DO $$ BEGIN CREATE TYPE credential_type AS ENUM ('staging'); EXCEPTION WHEN duplicate_object THEN NULL; END $$;
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

DO $$ BEGIN CREATE TYPE department AS ENUM ('executive'); EXCEPTION WHEN duplicate_object THEN NULL; END $$;
ALTER TYPE department ADD VALUE IF NOT EXISTS 'executive';
ALTER TYPE department ADD VALUE IF NOT EXISTS 'development';
ALTER TYPE department ADD VALUE IF NOT EXISTS 'design';
ALTER TYPE department ADD VALUE IF NOT EXISTS 'quality_assurance';
ALTER TYPE department ADD VALUE IF NOT EXISTS 'project_management';
ALTER TYPE department ADD VALUE IF NOT EXISTS 'accessibility';
ALTER TYPE department ADD VALUE IF NOT EXISTS 'consulting';
ALTER TYPE department ADD VALUE IF NOT EXISTS 'operations';

DO $$ BEGIN CREATE TYPE dev_status AS ENUM ('not_started'); EXCEPTION WHEN duplicate_object THEN NULL; END $$;
ALTER TYPE dev_status ADD VALUE IF NOT EXISTS 'not_started';
ALTER TYPE dev_status ADD VALUE IF NOT EXISTS 'in_progress';
ALTER TYPE dev_status ADD VALUE IF NOT EXISTS 'done';
ALTER TYPE dev_status ADD VALUE IF NOT EXISTS 'blocked';
ALTER TYPE dev_status ADD VALUE IF NOT EXISTS '3rd_party';
ALTER TYPE dev_status ADD VALUE IF NOT EXISTS 'wont_fix';

DO $$ BEGIN CREATE TYPE developer_role AS ENUM ('developer'); EXCEPTION WHEN duplicate_object THEN NULL; END $$;
ALTER TYPE developer_role ADD VALUE IF NOT EXISTS 'project_lead';
ALTER TYPE developer_role ADD VALUE IF NOT EXISTS 'senior_developer';
ALTER TYPE developer_role ADD VALUE IF NOT EXISTS 'developer';
ALTER TYPE developer_role ADD VALUE IF NOT EXISTS 'qa_engineer';
ALTER TYPE developer_role ADD VALUE IF NOT EXISTS 'accessibility_specialist';

DO $$ BEGIN CREATE TYPE document_priority AS ENUM ('medium'); EXCEPTION WHEN duplicate_object THEN NULL; END $$;
ALTER TYPE document_priority ADD VALUE IF NOT EXISTS 'low';
ALTER TYPE document_priority ADD VALUE IF NOT EXISTS 'medium';
ALTER TYPE document_priority ADD VALUE IF NOT EXISTS 'high';
ALTER TYPE document_priority ADD VALUE IF NOT EXISTS 'critical';

DO $$ BEGIN CREATE TYPE document_request_status AS ENUM ('pending'); EXCEPTION WHEN duplicate_object THEN NULL; END $$;
ALTER TYPE document_request_status ADD VALUE IF NOT EXISTS 'pending';
ALTER TYPE document_request_status ADD VALUE IF NOT EXISTS 'in_progress';
ALTER TYPE document_request_status ADD VALUE IF NOT EXISTS 'completed';
ALTER TYPE document_request_status ADD VALUE IF NOT EXISTS 'rejected';

DO $$ BEGIN CREATE TYPE document_status AS ENUM ('draft'); EXCEPTION WHEN duplicate_object THEN NULL; END $$;
ALTER TYPE document_status ADD VALUE IF NOT EXISTS 'draft';
ALTER TYPE document_status ADD VALUE IF NOT EXISTS 'pending_review';
ALTER TYPE document_status ADD VALUE IF NOT EXISTS 'certified';
ALTER TYPE document_status ADD VALUE IF NOT EXISTS 'active';
ALTER TYPE document_status ADD VALUE IF NOT EXISTS 'archived';

DO $$ BEGIN CREATE TYPE document_type AS ENUM ('other'); EXCEPTION WHEN duplicate_object THEN NULL; END $$;
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

DO $$ BEGIN CREATE TYPE employee_role AS ENUM ('developer'); EXCEPTION WHEN duplicate_object THEN NULL; END $$;
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

DO $$ BEGIN CREATE TYPE employment_status AS ENUM ('active'); EXCEPTION WHEN duplicate_object THEN NULL; END $$;
ALTER TYPE employment_status ADD VALUE IF NOT EXISTS 'active';
ALTER TYPE employment_status ADD VALUE IF NOT EXISTS 'inactive';
ALTER TYPE employment_status ADD VALUE IF NOT EXISTS 'on_leave';
ALTER TYPE employment_status ADD VALUE IF NOT EXISTS 'terminated';

DO $$ BEGIN CREATE TYPE invitation_status AS ENUM ('pending'); EXCEPTION WHEN duplicate_object THEN NULL; END $$;
ALTER TYPE invitation_status ADD VALUE IF NOT EXISTS 'pending';
ALTER TYPE invitation_status ADD VALUE IF NOT EXISTS 'sent';
ALTER TYPE invitation_status ADD VALUE IF NOT EXISTS 'accepted';
ALTER TYPE invitation_status ADD VALUE IF NOT EXISTS 'expired';
ALTER TYPE invitation_status ADD VALUE IF NOT EXISTS 'cancelled';

DO $$ BEGIN CREATE TYPE issue_type AS ENUM ('other'); EXCEPTION WHEN duplicate_object THEN NULL; END $$;
ALTER TYPE issue_type ADD VALUE IF NOT EXISTS 'automated_tools';
ALTER TYPE issue_type ADD VALUE IF NOT EXISTS 'screen_reader';
ALTER TYPE issue_type ADD VALUE IF NOT EXISTS 'keyboard_navigation';
ALTER TYPE issue_type ADD VALUE IF NOT EXISTS 'color_contrast';
ALTER TYPE issue_type ADD VALUE IF NOT EXISTS 'text_spacing';
ALTER TYPE issue_type ADD VALUE IF NOT EXISTS 'browser_zoom';
ALTER TYPE issue_type ADD VALUE IF NOT EXISTS 'other';

DO $$ BEGIN CREATE TYPE member_role AS ENUM ('developer'); EXCEPTION WHEN duplicate_object THEN NULL; END $$;
ALTER TYPE member_role ADD VALUE IF NOT EXISTS 'developer';
ALTER TYPE member_role ADD VALUE IF NOT EXISTS 'ceo';
ALTER TYPE member_role ADD VALUE IF NOT EXISTS 'team_lead';
ALTER TYPE member_role ADD VALUE IF NOT EXISTS 'senior_developer';
ALTER TYPE member_role ADD VALUE IF NOT EXISTS 'designer';
ALTER TYPE member_role ADD VALUE IF NOT EXISTS 'qa_engineer';
ALTER TYPE member_role ADD VALUE IF NOT EXISTS 'project_manager';
ALTER TYPE member_role ADD VALUE IF NOT EXISTS 'accessibility_specialist';
ALTER TYPE member_role ADD VALUE IF NOT EXISTS 'consultant';
ALTER TYPE member_role ADD VALUE IF NOT EXISTS 'intern';

DO $$ BEGIN CREATE TYPE member_status AS ENUM ('active'); EXCEPTION WHEN duplicate_object THEN NULL; END $$;
ALTER TYPE member_status ADD VALUE IF NOT EXISTS 'active';
ALTER TYPE member_status ADD VALUE IF NOT EXISTS 'inactive';
ALTER TYPE member_status ADD VALUE IF NOT EXISTS 'on_leave';
ALTER TYPE member_status ADD VALUE IF NOT EXISTS 'terminated';

DO $$ BEGIN CREATE TYPE message_sender_type AS ENUM ('admin'); EXCEPTION WHEN duplicate_object THEN NULL; END $$;
ALTER TYPE message_sender_type ADD VALUE IF NOT EXISTS 'admin';
ALTER TYPE message_sender_type ADD VALUE IF NOT EXISTS 'client';

DO $$ BEGIN CREATE TYPE milestone_status AS ENUM ('pending'); EXCEPTION WHEN duplicate_object THEN NULL; END $$;
ALTER TYPE milestone_status ADD VALUE IF NOT EXISTS 'pending';
ALTER TYPE milestone_status ADD VALUE IF NOT EXISTS 'in_progress';
ALTER TYPE milestone_status ADD VALUE IF NOT EXISTS 'completed';
ALTER TYPE milestone_status ADD VALUE IF NOT EXISTS 'overdue';

DO $$ BEGIN CREATE TYPE notification_priority AS ENUM ('normal'); EXCEPTION WHEN duplicate_object THEN NULL; END $$;
ALTER TYPE notification_priority ADD VALUE IF NOT EXISTS 'low';
ALTER TYPE notification_priority ADD VALUE IF NOT EXISTS 'normal';
ALTER TYPE notification_priority ADD VALUE IF NOT EXISTS 'high';
ALTER TYPE notification_priority ADD VALUE IF NOT EXISTS 'urgent';

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

DO $$ BEGIN CREATE TYPE payment_method AS ENUM ('credit_card'); EXCEPTION WHEN duplicate_object THEN NULL; END $$;
ALTER TYPE payment_method ADD VALUE IF NOT EXISTS 'credit_card';
ALTER TYPE payment_method ADD VALUE IF NOT EXISTS 'ach';
ALTER TYPE payment_method ADD VALUE IF NOT EXISTS 'wire';
ALTER TYPE payment_method ADD VALUE IF NOT EXISTS 'check';

DO $$ BEGIN CREATE TYPE policy_status AS ENUM ('none'); EXCEPTION WHEN duplicate_object THEN NULL; END $$;
ALTER TYPE policy_status ADD VALUE IF NOT EXISTS 'none';
ALTER TYPE policy_status ADD VALUE IF NOT EXISTS 'draft';
ALTER TYPE policy_status ADD VALUE IF NOT EXISTS 'review';
ALTER TYPE policy_status ADD VALUE IF NOT EXISTS 'approved';
ALTER TYPE policy_status ADD VALUE IF NOT EXISTS 'has_policy';
ALTER TYPE policy_status ADD VALUE IF NOT EXISTS 'needs_review';
ALTER TYPE policy_status ADD VALUE IF NOT EXISTS 'needs_creation';
ALTER TYPE policy_status ADD VALUE IF NOT EXISTS 'in_progress';
ALTER TYPE policy_status ADD VALUE IF NOT EXISTS 'completed';

DO $$ BEGIN CREATE TYPE pricing_tier AS ENUM ('basic'); EXCEPTION WHEN duplicate_object THEN NULL; END $$;
ALTER TYPE pricing_tier ADD VALUE IF NOT EXISTS 'basic';
ALTER TYPE pricing_tier ADD VALUE IF NOT EXISTS 'professional';
ALTER TYPE pricing_tier ADD VALUE IF NOT EXISTS 'enterprise';
ALTER TYPE pricing_tier ADD VALUE IF NOT EXISTS 'custom';

DO $$ BEGIN CREATE TYPE project_platform AS ENUM ('website'); EXCEPTION WHEN duplicate_object THEN NULL; END $$;
ALTER TYPE project_platform ADD VALUE IF NOT EXISTS 'website';
ALTER TYPE project_platform ADD VALUE IF NOT EXISTS 'mobile_app';
ALTER TYPE project_platform ADD VALUE IF NOT EXISTS 'desktop_app';
ALTER TYPE project_platform ADD VALUE IF NOT EXISTS 'web_app';
ALTER TYPE project_platform ADD VALUE IF NOT EXISTS 'api';
ALTER TYPE project_platform ADD VALUE IF NOT EXISTS 'other';

DO $$ BEGIN CREATE TYPE project_priority AS ENUM ('medium'); EXCEPTION WHEN duplicate_object THEN NULL; END $$;
ALTER TYPE project_priority ADD VALUE IF NOT EXISTS 'low';
ALTER TYPE project_priority ADD VALUE IF NOT EXISTS 'medium';
ALTER TYPE project_priority ADD VALUE IF NOT EXISTS 'high';
ALTER TYPE project_priority ADD VALUE IF NOT EXISTS 'urgent';

DO $$ BEGIN CREATE TYPE project_role AS ENUM ('project_member'); EXCEPTION WHEN duplicate_object THEN NULL; END $$;
ALTER TYPE project_role ADD VALUE IF NOT EXISTS 'project_admin';
ALTER TYPE project_role ADD VALUE IF NOT EXISTS 'project_member';

DO $$ BEGIN CREATE TYPE project_status AS ENUM ('planning'); EXCEPTION WHEN duplicate_object THEN NULL; END $$;
ALTER TYPE project_status ADD VALUE IF NOT EXISTS 'planning';
ALTER TYPE project_status ADD VALUE IF NOT EXISTS 'active';
ALTER TYPE project_status ADD VALUE IF NOT EXISTS 'on_hold';
ALTER TYPE project_status ADD VALUE IF NOT EXISTS 'completed';
ALTER TYPE project_status ADD VALUE IF NOT EXISTS 'cancelled';
ALTER TYPE project_status ADD VALUE IF NOT EXISTS 'archived';

DO $$ BEGIN CREATE TYPE project_type AS ENUM ('audit'); EXCEPTION WHEN duplicate_object THEN NULL; END $$;
ALTER TYPE project_type ADD VALUE IF NOT EXISTS 'audit';
ALTER TYPE project_type ADD VALUE IF NOT EXISTS 'remediation';
ALTER TYPE project_type ADD VALUE IF NOT EXISTS 'monitoring';
ALTER TYPE project_type ADD VALUE IF NOT EXISTS 'training';
ALTER TYPE project_type ADD VALUE IF NOT EXISTS 'consultation';
ALTER TYPE project_type ADD VALUE IF NOT EXISTS 'full_compliance';
ALTER TYPE project_type ADD VALUE IF NOT EXISTS 'a3s_program';

DO $$ BEGIN CREATE TYPE project_wcag_level AS ENUM ('AA'); EXCEPTION WHEN duplicate_object THEN NULL; END $$;
ALTER TYPE project_wcag_level ADD VALUE IF NOT EXISTS 'A';
ALTER TYPE project_wcag_level ADD VALUE IF NOT EXISTS 'AA';
ALTER TYPE project_wcag_level ADD VALUE IF NOT EXISTS 'AAA';

DO $$ BEGIN CREATE TYPE qa_status AS ENUM ('not_started'); EXCEPTION WHEN duplicate_object THEN NULL; END $$;
ALTER TYPE qa_status ADD VALUE IF NOT EXISTS 'not_started';
ALTER TYPE qa_status ADD VALUE IF NOT EXISTS 'in_progress';
ALTER TYPE qa_status ADD VALUE IF NOT EXISTS 'fixed';
ALTER TYPE qa_status ADD VALUE IF NOT EXISTS 'verified';
ALTER TYPE qa_status ADD VALUE IF NOT EXISTS 'failed';
ALTER TYPE qa_status ADD VALUE IF NOT EXISTS '3rd_party';

DO $$ BEGIN CREATE TYPE remediation_status AS ENUM ('pending'); EXCEPTION WHEN duplicate_object THEN NULL; END $$;
ALTER TYPE remediation_status ADD VALUE IF NOT EXISTS 'pending';
ALTER TYPE remediation_status ADD VALUE IF NOT EXISTS 'pending_review';
ALTER TYPE remediation_status ADD VALUE IF NOT EXISTS 'approved';
ALTER TYPE remediation_status ADD VALUE IF NOT EXISTS 'in_progress';
ALTER TYPE remediation_status ADD VALUE IF NOT EXISTS 'completed';
ALTER TYPE remediation_status ADD VALUE IF NOT EXISTS 'rejected';

DO $$ BEGIN CREATE TYPE remediation_type AS ENUM ('traditional_pdf'); EXCEPTION WHEN duplicate_object THEN NULL; END $$;
ALTER TYPE remediation_type ADD VALUE IF NOT EXISTS 'traditional_pdf';
ALTER TYPE remediation_type ADD VALUE IF NOT EXISTS 'html_alternative';

DO $$ BEGIN CREATE TYPE report_status AS ENUM ('draft'); EXCEPTION WHEN duplicate_object THEN NULL; END $$;
ALTER TYPE report_status ADD VALUE IF NOT EXISTS 'draft';
ALTER TYPE report_status ADD VALUE IF NOT EXISTS 'generated';
ALTER TYPE report_status ADD VALUE IF NOT EXISTS 'edited';
ALTER TYPE report_status ADD VALUE IF NOT EXISTS 'sent';
ALTER TYPE report_status ADD VALUE IF NOT EXISTS 'archived';

DO $$ BEGIN CREATE TYPE report_type AS ENUM ('custom'); EXCEPTION WHEN duplicate_object THEN NULL; END $$;
ALTER TYPE report_type ADD VALUE IF NOT EXISTS 'executive_summary';
ALTER TYPE report_type ADD VALUE IF NOT EXISTS 'technical_report';
ALTER TYPE report_type ADD VALUE IF NOT EXISTS 'compliance_report';
ALTER TYPE report_type ADD VALUE IF NOT EXISTS 'monthly_progress';
ALTER TYPE report_type ADD VALUE IF NOT EXISTS 'custom';

DO $$ BEGIN CREATE TYPE reporting_frequency AS ENUM ('monthly'); EXCEPTION WHEN duplicate_object THEN NULL; END $$;
ALTER TYPE reporting_frequency ADD VALUE IF NOT EXISTS 'weekly';
ALTER TYPE reporting_frequency ADD VALUE IF NOT EXISTS 'bi-weekly';
ALTER TYPE reporting_frequency ADD VALUE IF NOT EXISTS 'monthly';
ALTER TYPE reporting_frequency ADD VALUE IF NOT EXISTS 'quarterly';

DO $$ BEGIN CREATE TYPE severity AS ENUM ('4_low'); EXCEPTION WHEN duplicate_object THEN NULL; END $$;
ALTER TYPE severity ADD VALUE IF NOT EXISTS '1_critical';
ALTER TYPE severity ADD VALUE IF NOT EXISTS '2_high';
ALTER TYPE severity ADD VALUE IF NOT EXISTS '3_medium';
ALTER TYPE severity ADD VALUE IF NOT EXISTS '4_low';

DO $$ BEGIN CREATE TYPE team_status AS ENUM ('active'); EXCEPTION WHEN duplicate_object THEN NULL; END $$;
ALTER TYPE team_status ADD VALUE IF NOT EXISTS 'active';
ALTER TYPE team_status ADD VALUE IF NOT EXISTS 'inactive';
ALTER TYPE team_status ADD VALUE IF NOT EXISTS 'archived';

DO $$ BEGIN CREATE TYPE team_type AS ENUM ('internal'); EXCEPTION WHEN duplicate_object THEN NULL; END $$;
ALTER TYPE team_type ADD VALUE IF NOT EXISTS 'internal';
ALTER TYPE team_type ADD VALUE IF NOT EXISTS 'external';

DO $$ BEGIN CREATE TYPE tech_stack AS ENUM ('other'); EXCEPTION WHEN duplicate_object THEN NULL; END $$;
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

DO $$ BEGIN CREATE TYPE ticket_category AS ENUM ('general'); EXCEPTION WHEN duplicate_object THEN NULL; END $$;
ALTER TYPE ticket_category ADD VALUE IF NOT EXISTS 'technical';
ALTER TYPE ticket_category ADD VALUE IF NOT EXISTS 'billing';
ALTER TYPE ticket_category ADD VALUE IF NOT EXISTS 'general';
ALTER TYPE ticket_category ADD VALUE IF NOT EXISTS 'feature_request';
ALTER TYPE ticket_category ADD VALUE IF NOT EXISTS 'bug_report';
ALTER TYPE ticket_category ADD VALUE IF NOT EXISTS 'other';

DO $$ BEGIN CREATE TYPE ticket_priority AS ENUM ('medium'); EXCEPTION WHEN duplicate_object THEN NULL; END $$;
ALTER TYPE ticket_priority ADD VALUE IF NOT EXISTS 'low';
ALTER TYPE ticket_priority ADD VALUE IF NOT EXISTS 'medium';
ALTER TYPE ticket_priority ADD VALUE IF NOT EXISTS 'high';
ALTER TYPE ticket_priority ADD VALUE IF NOT EXISTS 'critical';
ALTER TYPE ticket_priority ADD VALUE IF NOT EXISTS 'urgent';

DO $$ BEGIN CREATE TYPE ticket_status AS ENUM ('open'); EXCEPTION WHEN duplicate_object THEN NULL; END $$;
ALTER TYPE ticket_status ADD VALUE IF NOT EXISTS 'open';
ALTER TYPE ticket_status ADD VALUE IF NOT EXISTS 'in_progress';
ALTER TYPE ticket_status ADD VALUE IF NOT EXISTS 'resolved';
ALTER TYPE ticket_status ADD VALUE IF NOT EXISTS 'closed';
ALTER TYPE ticket_status ADD VALUE IF NOT EXISTS 'needs_attention';
ALTER TYPE ticket_status ADD VALUE IF NOT EXISTS 'third_party';
ALTER TYPE ticket_status ADD VALUE IF NOT EXISTS 'fixed';

DO $$ BEGIN CREATE TYPE ticket_type AS ENUM ('task'); EXCEPTION WHEN duplicate_object THEN NULL; END $$;
ALTER TYPE ticket_type ADD VALUE IF NOT EXISTS 'bug';
ALTER TYPE ticket_type ADD VALUE IF NOT EXISTS 'feature';
ALTER TYPE ticket_type ADD VALUE IF NOT EXISTS 'task';
ALTER TYPE ticket_type ADD VALUE IF NOT EXISTS 'accessibility';
ALTER TYPE ticket_type ADD VALUE IF NOT EXISTS 'improvement';

DO $$ BEGIN CREATE TYPE time_entry_category AS ENUM ('development'); EXCEPTION WHEN duplicate_object THEN NULL; END $$;
ALTER TYPE time_entry_category ADD VALUE IF NOT EXISTS 'development';
ALTER TYPE time_entry_category ADD VALUE IF NOT EXISTS 'testing';
ALTER TYPE time_entry_category ADD VALUE IF NOT EXISTS 'review';
ALTER TYPE time_entry_category ADD VALUE IF NOT EXISTS 'meeting';
ALTER TYPE time_entry_category ADD VALUE IF NOT EXISTS 'documentation';
ALTER TYPE time_entry_category ADD VALUE IF NOT EXISTS 'research';

DO $$ BEGIN CREATE TYPE timeline AS ENUM ('ongoing'); EXCEPTION WHEN duplicate_object THEN NULL; END $$;
ALTER TYPE timeline ADD VALUE IF NOT EXISTS 'immediate';
ALTER TYPE timeline ADD VALUE IF NOT EXISTS '1-3_months';
ALTER TYPE timeline ADD VALUE IF NOT EXISTS '3-6_months';
ALTER TYPE timeline ADD VALUE IF NOT EXISTS '6-12_months';
ALTER TYPE timeline ADD VALUE IF NOT EXISTS 'ongoing';

DO $$ BEGIN CREATE TYPE url_category AS ENUM ('content'); EXCEPTION WHEN duplicate_object THEN NULL; END $$;
ALTER TYPE url_category ADD VALUE IF NOT EXISTS 'home';
ALTER TYPE url_category ADD VALUE IF NOT EXISTS 'content';
ALTER TYPE url_category ADD VALUE IF NOT EXISTS 'form';
ALTER TYPE url_category ADD VALUE IF NOT EXISTS 'admin';
ALTER TYPE url_category ADD VALUE IF NOT EXISTS 'other';

DO $$ BEGIN CREATE TYPE user_role AS ENUM ('viewer'); EXCEPTION WHEN duplicate_object THEN NULL; END $$;
ALTER TYPE user_role ADD VALUE IF NOT EXISTS 'viewer';
ALTER TYPE user_role ADD VALUE IF NOT EXISTS 'editor';
ALTER TYPE user_role ADD VALUE IF NOT EXISTS 'admin';
ALTER TYPE user_role ADD VALUE IF NOT EXISTS 'owner';

-- ============================================================================
-- SECTION 2: TABLES (Matching Production Exactly)
-- ============================================================================

-- 2.1 Clients Table
CREATE TABLE IF NOT EXISTS clients (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    name VARCHAR(255) NOT NULL,
    email VARCHAR(255) NOT NULL UNIQUE,
    company VARCHAR(255) NOT NULL,
    phone VARCHAR(50),
    address TEXT,
    billing_amount NUMERIC(10,2),
    billing_start_date TIMESTAMP,
    billing_frequency billing_frequency,
    status client_status NOT NULL DEFAULT 'pending',
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
    has_accessibility_policy BOOLEAN DEFAULT false,
    accessibility_policy_url VARCHAR(500),
    requires_legal_documentation BOOLEAN DEFAULT false,
    compliance_documents TEXT[],
    existing_audits BOOLEAN DEFAULT false,
    previous_audit_results TEXT,
    notes TEXT,
    created_at TIMESTAMP NOT NULL DEFAULT NOW(),
    updated_at TIMESTAMP NOT NULL DEFAULT NOW(),
    client_type client_type NOT NULL DEFAULT 'a3s',
    policy_status policy_status NOT NULL DEFAULT 'none',
    policy_notes TEXT,
    client_documents TEXT,
    team_member_limit INTEGER NOT NULL DEFAULT 5
);

-- 2.2 Projects Table  
CREATE TABLE IF NOT EXISTS projects (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    client_id UUID REFERENCES clients(id) ON DELETE CASCADE,
    name VARCHAR(255) NOT NULL,
    description TEXT,
    sheet_id VARCHAR(255),
    status VARCHAR(50) NOT NULL DEFAULT 'planning',
    priority VARCHAR(50) NOT NULL DEFAULT 'medium',
    wcag_level VARCHAR(50) NOT NULL DEFAULT 'AA',
    project_type VARCHAR(50) NOT NULL,
    compliance_requirements TEXT[] NOT NULL DEFAULT '{}',
    start_date TIMESTAMP,
    end_date TIMESTAMP,
    estimated_hours NUMERIC(8,2),
    actual_hours NUMERIC(8,2) DEFAULT 0,
    budget NUMERIC(12,2),
    billing_type VARCHAR(50) NOT NULL DEFAULT 'fixed',
    hourly_rate NUMERIC(8,2),
    progress_percentage INTEGER NOT NULL DEFAULT 0,
    milestones_completed INTEGER NOT NULL DEFAULT 0,
    total_milestones INTEGER NOT NULL DEFAULT 0,
    deliverables TEXT[] NOT NULL DEFAULT '{}',
    acceptance_criteria TEXT[] NOT NULL DEFAULT '{}',
    tags TEXT[] NOT NULL DEFAULT '{}',
    notes TEXT,
    created_at TIMESTAMP NOT NULL DEFAULT NOW(),
    updated_at TIMESTAMP NOT NULL DEFAULT NOW(),
    created_by VARCHAR(255) NOT NULL,
    last_modified_by VARCHAR(255) NOT NULL,
    project_platform VARCHAR(50) NOT NULL DEFAULT 'website',
    tech_stack VARCHAR(50) NOT NULL DEFAULT 'other',
    website_url VARCHAR(500),
    testing_methodology TEXT[] NOT NULL DEFAULT '{}',
    testing_schedule TEXT,
    bug_severity_workflow TEXT,
    default_testing_month VARCHAR(20),
    default_testing_year INTEGER,
    critical_issue_sla_days INTEGER DEFAULT 45,
    high_issue_sla_days INTEGER DEFAULT 30,
    sync_status_summary JSONB DEFAULT '{}',
    last_sync_details JSONB DEFAULT '{}',
    credentials JSONB DEFAULT '[]',
    credentials_backup JSONB
);

-- 2.3 Test URLs Table
CREATE TABLE IF NOT EXISTS test_urls (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    project_id UUID NOT NULL REFERENCES projects(id) ON DELETE CASCADE,
    url VARCHAR(1000) NOT NULL,
    page_title VARCHAR(500),
    url_category url_category DEFAULT 'content',
    testing_month VARCHAR(20),
    testing_year INTEGER,
    is_active BOOLEAN DEFAULT true,
    created_at TIMESTAMP NOT NULL DEFAULT NOW(),
    updated_at TIMESTAMP NOT NULL DEFAULT NOW(),
    remediation_month VARCHAR(20),
    automated_tools TEXT,
    nvda_chrome TEXT,
    voiceover_iphone_safari TEXT,
    color_contrast TEXT,
    browser_zoom TEXT,
    keyboard_only TEXT,
    text_spacing TEXT,
    status TEXT,
    remediation_year INTEGER
);

-- 2.4 Accessibility Issues Table (CRITICAL TABLE)
CREATE TABLE IF NOT EXISTS accessibility_issues (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    project_id UUID NOT NULL REFERENCES projects(id) ON DELETE CASCADE,
    url_id UUID NOT NULL REFERENCES test_urls(id) ON DELETE CASCADE,
    issue_title VARCHAR(500) NOT NULL,
    issue_description TEXT,
    issue_type issue_type NOT NULL,
    severity severity NOT NULL,
    testing_month VARCHAR(20),
    testing_year INTEGER,
    testing_environment VARCHAR(200),
    browser VARCHAR(100),
    operating_system VARCHAR(100),
    assistive_technology VARCHAR(100),
    expected_result TEXT,
    actual_result TEXT,
    failed_wcag_criteria TEXT[] DEFAULT '{}',
    conformance_level conformance_level,
    screencast_url VARCHAR(1000),
    screenshot_urls TEXT[] DEFAULT '{}',
    dev_status TEXT DEFAULT 'not_started',
    dev_comments TEXT,
    dev_assigned_to VARCHAR(255),
    qa_status TEXT DEFAULT 'not_started',
    qa_comments TEXT,
    qa_assigned_to VARCHAR(255),
    discovered_at TIMESTAMP NOT NULL DEFAULT NOW(),
    dev_started_at TIMESTAMP,
    dev_completed_at TIMESTAMP,
    qa_started_at TIMESTAMP,
    qa_completed_at TIMESTAMP,
    resolved_at TIMESTAMP,
    is_active BOOLEAN DEFAULT true,
    is_duplicate BOOLEAN DEFAULT false,
    duplicate_of_id UUID,
    external_ticket_id VARCHAR(255),
    external_ticket_url VARCHAR(1000),
    import_batch_id VARCHAR(255),
    source_file_name VARCHAR(255),
    created_at TIMESTAMP NOT NULL DEFAULT NOW(),
    updated_at TIMESTAMP NOT NULL DEFAULT NOW(),
    sent_to_user BOOLEAN DEFAULT false,
    sent_date TIMESTAMP,
    sent_month VARCHAR(20),
    report_id UUID,
    dev_status_updated_at TIMESTAMP,
    qa_status_updated_at TIMESTAMP,
    metadata JSONB,
    sheet_name TEXT,
    sheet_row_number INTEGER,
    issue_id TEXT NOT NULL
);

-- 2.5 Reports Table
CREATE TABLE IF NOT EXISTS reports (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    project_id UUID NOT NULL REFERENCES projects(id) ON DELETE CASCADE,
    title VARCHAR(255) NOT NULL,
    report_type report_type NOT NULL,
    ai_generated_content TEXT,
    edited_content TEXT,
    status report_status NOT NULL DEFAULT 'draft',
    sent_at TIMESTAMP,
    sent_to JSONB,
    email_subject VARCHAR(255),
    email_body TEXT,
    pdf_path VARCHAR(500),
    created_by VARCHAR(255),
    created_at TIMESTAMP NOT NULL DEFAULT NOW(),
    updated_at TIMESTAMP NOT NULL DEFAULT NOW(),
    is_public BOOLEAN NOT NULL DEFAULT FALSE,
    public_token VARCHAR(64) UNIQUE,
    report_month VARCHAR(20),
    report_year INTEGER
);

-- 2.6 Report Issues Junction
CREATE TABLE IF NOT EXISTS report_issues (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    report_id UUID NOT NULL REFERENCES reports(id) ON DELETE CASCADE,
    issue_id UUID NOT NULL REFERENCES accessibility_issues(id) ON DELETE CASCADE,
    included_at TIMESTAMP NOT NULL DEFAULT NOW()
);

-- 2.7 Report Comments
CREATE TABLE IF NOT EXISTS report_comments (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    report_id UUID NOT NULL REFERENCES reports(id) ON DELETE CASCADE,
    comment TEXT NOT NULL,
    comment_type VARCHAR(50) NOT NULL DEFAULT 'general',
    author_id VARCHAR(255),
    author_name VARCHAR(255),
    is_internal BOOLEAN NOT NULL DEFAULT true,
    created_at TIMESTAMP NOT NULL DEFAULT NOW()
);

-- 2.8 Issues (Legacy)
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
    updated_at TIMESTAMP NOT NULL DEFAULT NOW()
);

-- 2.9 Client Users
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

-- 2.10 Client Team Members
CREATE TABLE IF NOT EXISTS client_team_members (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    client_id UUID NOT NULL REFERENCES clients(id) ON DELETE CASCADE,
    name VARCHAR(255) NOT NULL,
    email VARCHAR(255) NOT NULL,
    description TEXT,
    invitation_status invitation_status NOT NULL DEFAULT 'pending',
    invitation_sent_at TIMESTAMP,
    invitation_token VARCHAR(255),
    invited_by_user_id UUID REFERENCES client_users(id) ON DELETE SET NULL,
    accepted_at TIMESTAMP,
    linked_user_id UUID REFERENCES client_users(id) ON DELETE SET NULL,
    created_at TIMESTAMP NOT NULL DEFAULT NOW(),
    updated_at TIMESTAMP NOT NULL DEFAULT NOW(),
    clerk_invitation_id VARCHAR(255),
    pending_project_ids JSONB DEFAULT '[]'
);

-- 2.11 Project Team Members
CREATE TABLE IF NOT EXISTS project_team_members (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    project_id UUID NOT NULL REFERENCES projects(id) ON DELETE CASCADE,
    team_member_id UUID NOT NULL REFERENCES client_users(id) ON DELETE CASCADE,
    role project_role NOT NULL DEFAULT 'project_member',
    created_at TIMESTAMP NOT NULL DEFAULT NOW(),
    updated_at TIMESTAMP NOT NULL DEFAULT NOW(),
    display_name VARCHAR(255)
);

-- 2.12 Client Tickets
CREATE TABLE IF NOT EXISTS client_tickets (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    client_id UUID NOT NULL REFERENCES clients(id) ON DELETE CASCADE,
    project_id UUID REFERENCES projects(id) ON DELETE SET NULL,
    title VARCHAR(500) NOT NULL,
    description TEXT NOT NULL,
    status ticket_status NOT NULL DEFAULT 'needs_attention',
    priority ticket_priority NOT NULL DEFAULT 'medium',
    category VARCHAR(50) NOT NULL DEFAULT 'technical',
    created_by UUID REFERENCES client_users(id) ON DELETE SET NULL,
    assigned_to UUID REFERENCES client_users(id) ON DELETE SET NULL,
    created_at TIMESTAMP NOT NULL DEFAULT NOW(),
    updated_at TIMESTAMP NOT NULL DEFAULT NOW(),
    issues_id VARCHAR(255),
    created_by_user_id UUID REFERENCES client_users(id) ON DELETE SET NULL,
    related_issue_id UUID REFERENCES accessibility_issues(id) ON DELETE SET NULL,
    internal_notes TEXT,
    resolution TEXT,
    resolved_at TIMESTAMP,
    closed_at TIMESTAMP
);

-- 2.13 Client Ticket Issues Junction
CREATE TABLE IF NOT EXISTS client_ticket_issues (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    ticket_id UUID NOT NULL REFERENCES client_tickets(id) ON DELETE CASCADE,
    issue_id UUID NOT NULL REFERENCES accessibility_issues(id) ON DELETE CASCADE,
    created_at TIMESTAMP NOT NULL DEFAULT NOW()
);

-- 2.14 Evidence Documents
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

-- 2.15 Evidence Document Requests
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

-- 2.16 Document Remediations
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

-- 2.17 Client Billing Add-ons
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
    approved_by_user_id UUID REFERENCES client_users(id) ON DELETE SET NULL,
    created_at TIMESTAMP NOT NULL DEFAULT NOW(),
    updated_at TIMESTAMP NOT NULL DEFAULT NOW()
);

-- 2.18 Notifications
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
    is_read BOOLEAN NOT NULL DEFAULT false,
    read_at TIMESTAMP,
    is_archived BOOLEAN NOT NULL DEFAULT false,
    archived_at TIMESTAMP,
    expires_at TIMESTAMP,
    created_at TIMESTAMP NOT NULL DEFAULT NOW(),
    updated_at TIMESTAMP NOT NULL DEFAULT NOW()
);

-- 2.19 Admin Notifications
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
    related_ticket_id UUID REFERENCES client_tickets(id) ON DELETE SET NULL,
    created_at TIMESTAMP NOT NULL DEFAULT NOW(),
    read_at TIMESTAMP
);

-- 2.20 Clerk User ID Backups
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

-- 2.21 Ticket Messages
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

-- 2.22 Tickets (Admin Internal)
CREATE TABLE IF NOT EXISTS tickets (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    project_id UUID REFERENCES projects(id) ON DELETE CASCADE,
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
    created_at TIMESTAMP NOT NULL DEFAULT NOW(),
    updated_at TIMESTAMP NOT NULL DEFAULT NOW(),
    resolved_at TIMESTAMP,
    closed_at TIMESTAMP,
    due_date TIMESTAMP,
    client_id UUID REFERENCES clients(id),
    related_issue_ids TEXT[] DEFAULT '{}',
    ticket_category VARCHAR(50) DEFAULT 'general'
);

-- 2.23 Ticket Attachments
CREATE TABLE IF NOT EXISTS ticket_attachments (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    ticket_id UUID NOT NULL REFERENCES tickets(id) ON DELETE CASCADE,
    filename VARCHAR(255) NOT NULL,
    original_name VARCHAR(255) NOT NULL,
    file_path VARCHAR(500) NOT NULL,
    file_size NUMERIC(15,0) NOT NULL,
    mime_type VARCHAR(100) NOT NULL,
    uploaded_by VARCHAR(255) NOT NULL,
    uploaded_at TIMESTAMP NOT NULL DEFAULT NOW()
);

-- 2.24 Ticket Comments
CREATE TABLE IF NOT EXISTS ticket_comments (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    ticket_id UUID NOT NULL REFERENCES tickets(id) ON DELETE CASCADE,
    user_id VARCHAR(255) NOT NULL,
    user_name VARCHAR(255) NOT NULL,
    comment TEXT NOT NULL,
    is_internal BOOLEAN NOT NULL DEFAULT false,
    created_at TIMESTAMP NOT NULL DEFAULT NOW(),
    updated_at TIMESTAMP NOT NULL DEFAULT NOW()
);

-- 2.25 Teams
CREATE TABLE IF NOT EXISTS teams (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    name VARCHAR(255) NOT NULL,
    description TEXT,
    created_at TIMESTAMP NOT NULL DEFAULT NOW(),
    updated_at TIMESTAMP NOT NULL DEFAULT NOW(),
    department department NOT NULL,
    status team_status NOT NULL DEFAULT 'active',
    team_lead_id UUID,
    created_by VARCHAR(255),
    max_members VARCHAR(50),
    location VARCHAR(255),
    working_hours VARCHAR(100),
    email VARCHAR(255),
    slack_channel VARCHAR(255),
    budget VARCHAR(50),
    notes TEXT,
    is_active BOOLEAN NOT NULL DEFAULT true,
    manager_id UUID,
    team_type VARCHAR(50) DEFAULT 'internal'
);

-- 2.26 Team Members
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
    is_active BOOLEAN NOT NULL DEFAULT true,
    created_at TIMESTAMP NOT NULL DEFAULT NOW(),
    updated_at TIMESTAMP NOT NULL DEFAULT NOW()
);

-- 2.27 Project Team Assignments
CREATE TABLE IF NOT EXISTS project_team_assignments (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    project_id UUID NOT NULL REFERENCES projects(id) ON DELETE CASCADE,
    team_member_id UUID NOT NULL REFERENCES team_members(id) ON DELETE CASCADE,
    role VARCHAR(100),
    assigned_at TIMESTAMP NOT NULL DEFAULT NOW(),
    assigned_by VARCHAR(255),
    is_active BOOLEAN NOT NULL DEFAULT true,
    notes TEXT
);

-- 2.28 Project Staging Credentials
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
    is_active BOOLEAN NOT NULL DEFAULT true,
    expires_at TIMESTAMP,
    created_by VARCHAR(255) NOT NULL,
    created_at TIMESTAMP NOT NULL DEFAULT NOW(),
    updated_at TIMESTAMP NOT NULL DEFAULT NOW(),
    credentials JSONB DEFAULT '{}'
);

-- 2.29 Client Credentials
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

-- 2.30 Client Files
CREATE TABLE IF NOT EXISTS client_files (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    client_id UUID NOT NULL REFERENCES clients(id) ON DELETE CASCADE,
    filename VARCHAR(255) NOT NULL,
    original_name VARCHAR(255) NOT NULL,
    category VARCHAR(50) NOT NULL,
    file_path VARCHAR(500) NOT NULL,
    file_size NUMERIC(15,0) NOT NULL,
    mime_type VARCHAR(100) NOT NULL,
    is_encrypted BOOLEAN NOT NULL DEFAULT false,
    uploaded_by VARCHAR(255) NOT NULL,
    uploaded_at TIMESTAMP NOT NULL DEFAULT NOW(),
    access_level VARCHAR(20) NOT NULL DEFAULT 'public',
    metadata TEXT
);

-- 2.31 Project Documents
CREATE TABLE IF NOT EXISTS project_documents (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    project_id UUID NOT NULL REFERENCES projects(id) ON DELETE CASCADE,
    name VARCHAR(255) NOT NULL,
    type document_type NOT NULL,
    file_path VARCHAR(500) NOT NULL,
    uploaded_by VARCHAR(255) NOT NULL,
    uploaded_at TIMESTAMP NOT NULL DEFAULT NOW(),
    version VARCHAR(50) NOT NULL DEFAULT '1.0',
    is_latest BOOLEAN NOT NULL DEFAULT true,
    tags TEXT[] NOT NULL DEFAULT '{}',
    file_size NUMERIC(15,0) NOT NULL,
    mime_type VARCHAR(100) NOT NULL
);

-- 2.32 Project Activities
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

-- 2.33 Project Developers
CREATE TABLE IF NOT EXISTS project_developers (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    project_id UUID NOT NULL REFERENCES projects(id) ON DELETE CASCADE,
    developer_id VARCHAR(255) NOT NULL,
    role developer_role NOT NULL,
    responsibilities TEXT[] NOT NULL DEFAULT '{}',
    assigned_at TIMESTAMP NOT NULL DEFAULT NOW(),
    assigned_by VARCHAR(255) NOT NULL,
    is_active BOOLEAN NOT NULL DEFAULT true,
    hourly_rate NUMERIC(8,2),
    max_hours_per_week INTEGER
);

-- 2.34 Project Milestones
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

-- 2.35 Project Time Entries
CREATE TABLE IF NOT EXISTS project_time_entries (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    project_id UUID NOT NULL REFERENCES projects(id) ON DELETE CASCADE,
    developer_id VARCHAR(255) NOT NULL,
    date TIMESTAMP NOT NULL,
    hours NUMERIC(4,2) NOT NULL,
    description TEXT NOT NULL,
    category time_entry_category NOT NULL,
    billable BOOLEAN NOT NULL DEFAULT true,
    approved BOOLEAN NOT NULL DEFAULT false,
    approved_by VARCHAR(255),
    approved_at TIMESTAMP,
    created_at TIMESTAMP NOT NULL DEFAULT NOW()
);

-- 2.36 Sync Logs
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

-- 2.37 Project Sync Status
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

-- 2.38 Checkpoint Sync
CREATE TABLE IF NOT EXISTS checkpoint_sync (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    project_id UUID NOT NULL REFERENCES projects(id),
    sheet_id TEXT NOT NULL,
    last_synced_row TEXT NOT NULL,
    created_at TIMESTAMP NOT NULL DEFAULT NOW(),
    updated_at TIMESTAMP NOT NULL DEFAULT NOW()
);

-- 2.39 Status
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

-- 2.40 Status Check
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

-- 2.41 Issue Comments
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

-- 2.42 WCAG URL Check (many columns - simplified)
CREATE TABLE IF NOT EXISTS wcag_url_check (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    project_id UUID NOT NULL REFERENCES projects(id),
    test_scenario TEXT,
    created_at TIMESTAMP NOT NULL DEFAULT NOW(),
    updated_at TIMESTAMP NOT NULL DEFAULT NOW()
);

-- ============================================================================
-- SECTION 2.5: ADD MISSING COLUMNS TO EXISTING TABLES
-- ============================================================================
-- This section ensures that if tables already exist but are missing newer columns,
-- those columns get added. Uses explicit column existence checks for compatibility.

-- Helper function to safely add columns
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
    END IF;
END;
$$ LANGUAGE plpgsql;

-- Clients table - add missing columns
SELECT add_column_if_not_exists('clients', 'requires_legal_documentation', 'BOOLEAN', 'false');
SELECT add_column_if_not_exists('clients', 'compliance_documents', 'TEXT[]', 'NULL');
SELECT add_column_if_not_exists('clients', 'existing_audits', 'BOOLEAN', 'false');
SELECT add_column_if_not_exists('clients', 'previous_audit_results', 'TEXT', 'NULL');
SELECT add_column_if_not_exists('clients', 'team_member_limit', 'INTEGER NOT NULL', '5');
SELECT add_column_if_not_exists('clients', 'client_type', 'client_type NOT NULL', '''a3s''');
SELECT add_column_if_not_exists('clients', 'policy_status', 'policy_status NOT NULL', '''none''');
SELECT add_column_if_not_exists('clients', 'policy_notes', 'TEXT', 'NULL');
SELECT add_column_if_not_exists('clients', 'client_documents', 'TEXT', 'NULL');

-- Projects table - add missing columns
SELECT add_column_if_not_exists('projects', 'project_platform', 'VARCHAR(50) NOT NULL', '''website''');
SELECT add_column_if_not_exists('projects', 'tech_stack', 'VARCHAR(50) NOT NULL', '''other''');
SELECT add_column_if_not_exists('projects', 'website_url', 'VARCHAR(500)', 'NULL');
SELECT add_column_if_not_exists('projects', 'testing_methodology', 'TEXT[] NOT NULL', '''{}''');
SELECT add_column_if_not_exists('projects', 'testing_schedule', 'TEXT', 'NULL');
SELECT add_column_if_not_exists('projects', 'bug_severity_workflow', 'TEXT', 'NULL');
SELECT add_column_if_not_exists('projects', 'default_testing_month', 'VARCHAR(20)', 'NULL');
SELECT add_column_if_not_exists('projects', 'default_testing_year', 'INTEGER', 'NULL');
SELECT add_column_if_not_exists('projects', 'critical_issue_sla_days', 'INTEGER', '45');
SELECT add_column_if_not_exists('projects', 'high_issue_sla_days', 'INTEGER', '30');
SELECT add_column_if_not_exists('projects', 'sync_status_summary', 'JSONB', '''{}''');
SELECT add_column_if_not_exists('projects', 'last_sync_details', 'JSONB', '''{}''');
SELECT add_column_if_not_exists('projects', 'credentials', 'JSONB', '''[]''');
SELECT add_column_if_not_exists('projects', 'credentials_backup', 'JSONB', 'NULL');

-- Test URLs table - add missing columns
SELECT add_column_if_not_exists('test_urls', 'remediation_month', 'VARCHAR(20)', 'NULL');
SELECT add_column_if_not_exists('test_urls', 'automated_tools', 'TEXT', 'NULL');
SELECT add_column_if_not_exists('test_urls', 'nvda_chrome', 'TEXT', 'NULL');
SELECT add_column_if_not_exists('test_urls', 'voiceover_iphone_safari', 'TEXT', 'NULL');
SELECT add_column_if_not_exists('test_urls', 'color_contrast', 'TEXT', 'NULL');
SELECT add_column_if_not_exists('test_urls', 'browser_zoom', 'TEXT', 'NULL');
SELECT add_column_if_not_exists('test_urls', 'keyboard_only', 'TEXT', 'NULL');
SELECT add_column_if_not_exists('test_urls', 'text_spacing', 'TEXT', 'NULL');
SELECT add_column_if_not_exists('test_urls', 'status', 'TEXT', 'NULL');
SELECT add_column_if_not_exists('test_urls', 'remediation_year', 'INTEGER', 'NULL');

-- Accessibility Issues table - add missing columns
SELECT add_column_if_not_exists('accessibility_issues', 'sent_to_user', 'BOOLEAN', 'false');
SELECT add_column_if_not_exists('accessibility_issues', 'sent_date', 'TIMESTAMP', 'NULL');
SELECT add_column_if_not_exists('accessibility_issues', 'sent_month', 'VARCHAR(20)', 'NULL');
SELECT add_column_if_not_exists('accessibility_issues', 'report_id', 'UUID', 'NULL');
SELECT add_column_if_not_exists('accessibility_issues', 'dev_status_updated_at', 'TIMESTAMP', 'NULL');
SELECT add_column_if_not_exists('accessibility_issues', 'qa_status_updated_at', 'TIMESTAMP', 'NULL');
SELECT add_column_if_not_exists('accessibility_issues', 'metadata', 'JSONB', 'NULL');
SELECT add_column_if_not_exists('accessibility_issues', 'sheet_name', 'TEXT', 'NULL');
SELECT add_column_if_not_exists('accessibility_issues', 'sheet_row_number', 'INTEGER', 'NULL');
SELECT add_column_if_not_exists('accessibility_issues', 'issue_id', 'TEXT NOT NULL', '''unknown''');

-- Reports table - add missing columns
SELECT add_column_if_not_exists('reports', 'report_month', 'VARCHAR(20)', 'NULL');
SELECT add_column_if_not_exists('reports', 'report_year', 'INTEGER', 'NULL');
SELECT add_column_if_not_exists('reports', 'is_public', 'BOOLEAN NOT NULL', 'false');
SELECT add_column_if_not_exists('reports', 'public_token', 'VARCHAR(64)', 'NULL');

-- Client Team Members - add missing columns
SELECT add_column_if_not_exists('client_team_members', 'clerk_invitation_id', 'VARCHAR(255)', 'NULL');
SELECT add_column_if_not_exists('client_team_members', 'pending_project_ids', 'JSONB', '''[]''');

-- Project Team Members - add missing columns
SELECT add_column_if_not_exists('project_team_members', 'display_name', 'VARCHAR(255)', 'NULL');

-- Client Tickets - add missing columns
SELECT add_column_if_not_exists('client_tickets', 'issues_id', 'VARCHAR(255)', 'NULL');
SELECT add_column_if_not_exists('client_tickets', 'created_by_user_id', 'UUID', 'NULL');
SELECT add_column_if_not_exists('client_tickets', 'related_issue_id', 'UUID', 'NULL');
SELECT add_column_if_not_exists('client_tickets', 'internal_notes', 'TEXT', 'NULL');
SELECT add_column_if_not_exists('client_tickets', 'resolution', 'TEXT', 'NULL');
SELECT add_column_if_not_exists('client_tickets', 'resolved_at', 'TIMESTAMP', 'NULL');
SELECT add_column_if_not_exists('client_tickets', 'closed_at', 'TIMESTAMP', 'NULL');

-- Document Remediations - add missing columns
SELECT add_column_if_not_exists('document_remediations', 'price_adjusted', 'BOOLEAN', 'false');
SELECT add_column_if_not_exists('document_remediations', 'original_price_per_page', 'NUMERIC(10,2)', 'NULL');
SELECT add_column_if_not_exists('document_remediations', 'original_total_price', 'NUMERIC(10,2)', 'NULL');
SELECT add_column_if_not_exists('document_remediations', 'reviewed_by_user_id', 'UUID', 'NULL');
SELECT add_column_if_not_exists('document_remediations', 'reviewed_at', 'TIMESTAMP', 'NULL');
SELECT add_column_if_not_exists('document_remediations', 'rejection_reason', 'TEXT', 'NULL');

-- Teams - add missing columns
SELECT add_column_if_not_exists('teams', 'department', 'department', 'NULL');
SELECT add_column_if_not_exists('teams', 'status', 'team_status NOT NULL', '''active''');
SELECT add_column_if_not_exists('teams', 'team_lead_id', 'UUID', 'NULL');
SELECT add_column_if_not_exists('teams', 'created_by', 'VARCHAR(255)', 'NULL');
SELECT add_column_if_not_exists('teams', 'max_members', 'VARCHAR(50)', 'NULL');
SELECT add_column_if_not_exists('teams', 'location', 'VARCHAR(255)', 'NULL');
SELECT add_column_if_not_exists('teams', 'working_hours', 'VARCHAR(100)', 'NULL');
SELECT add_column_if_not_exists('teams', 'email', 'VARCHAR(255)', 'NULL');
SELECT add_column_if_not_exists('teams', 'slack_channel', 'VARCHAR(255)', 'NULL');
SELECT add_column_if_not_exists('teams', 'budget', 'VARCHAR(50)', 'NULL');
SELECT add_column_if_not_exists('teams', 'notes', 'TEXT', 'NULL');
SELECT add_column_if_not_exists('teams', 'is_active', 'BOOLEAN NOT NULL', 'true');
SELECT add_column_if_not_exists('teams', 'manager_id', 'UUID', 'NULL');
SELECT add_column_if_not_exists('teams', 'team_type', 'VARCHAR(50)', '''internal''');

-- Tickets (admin) - add missing columns
SELECT add_column_if_not_exists('tickets', 'client_id', 'UUID', 'NULL');
SELECT add_column_if_not_exists('tickets', 'related_issue_ids', 'TEXT[]', '''{}''');
SELECT add_column_if_not_exists('tickets', 'ticket_category', 'VARCHAR(50)', '''general''');

-- Project Team Assignments - add missing columns
SELECT add_column_if_not_exists('project_team_assignments', 'assigned_by', 'VARCHAR(255)', 'NULL');
SELECT add_column_if_not_exists('project_team_assignments', 'notes', 'TEXT', 'NULL');

-- Project Staging Credentials - add missing columns
SELECT add_column_if_not_exists('project_staging_credentials', 'credentials', 'JSONB', '''{}''');

-- Drop the helper function
DROP FUNCTION IF EXISTS add_column_if_not_exists(TEXT, TEXT, TEXT, TEXT);

-- ============================================================================
-- SECTION 3: UNIQUE CONSTRAINTS (with safe handling)
-- ============================================================================

DO $$ BEGIN
    ALTER TABLE report_issues ADD CONSTRAINT unique_report_issue UNIQUE (report_id, issue_id);
EXCEPTION WHEN duplicate_object THEN NULL; WHEN others THEN IF SQLSTATE = '42P07' THEN NULL; ELSE RAISE; END IF; END $$;

DO $$ BEGIN
    ALTER TABLE client_users ADD CONSTRAINT unique_clerk_client UNIQUE (clerk_user_id, client_id);
EXCEPTION WHEN duplicate_object THEN NULL; WHEN others THEN IF SQLSTATE = '42P07' THEN NULL; ELSE RAISE; END IF; END $$;

DO $$ BEGIN
    ALTER TABLE client_team_members ADD CONSTRAINT unique_client_team_member_email UNIQUE (client_id, email);
EXCEPTION WHEN duplicate_object THEN NULL; WHEN others THEN IF SQLSTATE = '42P07' THEN NULL; ELSE RAISE; END IF; END $$;

DO $$ BEGIN
    ALTER TABLE project_team_members ADD CONSTRAINT unique_project_team_member UNIQUE (project_id, team_member_id);
EXCEPTION WHEN duplicate_object THEN NULL; WHEN others THEN IF SQLSTATE = '42P07' THEN NULL; ELSE RAISE; END IF; END $$;

DO $$ BEGIN
    ALTER TABLE client_ticket_issues ADD CONSTRAINT unique_ticket_issue UNIQUE (ticket_id, issue_id);
EXCEPTION WHEN duplicate_object THEN NULL; WHEN others THEN IF SQLSTATE = '42P07' THEN NULL; ELSE RAISE; END IF; END $$;

DO $$ BEGIN
    ALTER TABLE checkpoint_sync ADD CONSTRAINT checkpoint_sync_project_id_sheet_id_key UNIQUE (project_id, sheet_id);
EXCEPTION WHEN duplicate_object THEN NULL; WHEN others THEN IF SQLSTATE = '42P07' THEN NULL; ELSE RAISE; END IF; END $$;

DO $$ BEGIN
    ALTER TABLE status ADD CONSTRAINT status_project_id_url_key UNIQUE (project_id, url);
EXCEPTION WHEN duplicate_object THEN NULL; WHEN others THEN IF SQLSTATE = '42P07' THEN NULL; ELSE RAISE; END IF; END $$;

DO $$ BEGIN
    ALTER TABLE status_check ADD CONSTRAINT status_check_project_id_test_scenario_url_key UNIQUE (project_id, test_scenario, url);
EXCEPTION WHEN duplicate_object THEN NULL; WHEN others THEN IF SQLSTATE = '42P07' THEN NULL; ELSE RAISE; END IF; END $$;

DO $$ BEGIN
    ALTER TABLE issues ADD CONSTRAINT issues_project_id_sheet_name_url_issue_title_key UNIQUE (project_id, sheet_name, url, issue_title);
EXCEPTION WHEN duplicate_object THEN NULL; WHEN others THEN IF SQLSTATE = '42P07' THEN NULL; ELSE RAISE; END IF; END $$;

-- ============================================================================
-- SECTION 4: INDEXES (matching production)
-- ============================================================================

-- Clients indexes
CREATE INDEX IF NOT EXISTS idx_clients_status ON clients(status);
CREATE INDEX IF NOT EXISTS idx_clients_type ON clients(client_type);
CREATE INDEX IF NOT EXISTS clients_email_idx ON clients(email);

-- Projects indexes
CREATE INDEX IF NOT EXISTS idx_projects_client_id ON projects(client_id);
CREATE INDEX IF NOT EXISTS idx_projects_status ON projects(status);
CREATE INDEX IF NOT EXISTS projects_sheet_id_idx ON projects(sheet_id);

-- Test URLs indexes
CREATE UNIQUE INDEX IF NOT EXISTS test_urls_project_url_idx ON test_urls(project_id, url);
CREATE INDEX IF NOT EXISTS idx_test_urls_project_id ON test_urls(project_id);

-- Accessibility Issues indexes
CREATE UNIQUE INDEX IF NOT EXISTS unique_project_issue_id ON accessibility_issues(project_id, issue_id);
CREATE INDEX IF NOT EXISTS idx_accessibility_issues_project_id ON accessibility_issues(project_id);
CREATE INDEX IF NOT EXISTS idx_accessibility_issues_url_id ON accessibility_issues(url_id);
CREATE INDEX IF NOT EXISTS accessibility_issues_sent_to_user_idx ON accessibility_issues(sent_to_user);
CREATE INDEX IF NOT EXISTS accessibility_issues_dev_status_idx ON accessibility_issues(dev_status);
CREATE INDEX IF NOT EXISTS accessibility_issues_severity_idx ON accessibility_issues(severity);

-- Reports indexes
CREATE INDEX IF NOT EXISTS idx_reports_project_id ON reports(project_id);
CREATE INDEX IF NOT EXISTS idx_reports_status ON reports(status);

-- Client Users indexes
CREATE INDEX IF NOT EXISTS idx_client_users_clerk_user_id ON client_users(clerk_user_id);
CREATE INDEX IF NOT EXISTS idx_client_users_client_id ON client_users(client_id);

-- Client Team Members indexes
CREATE INDEX IF NOT EXISTS idx_client_team_members_client_id ON client_team_members(client_id);
CREATE INDEX IF NOT EXISTS idx_client_team_members_invitation_status ON client_team_members(invitation_status);

-- Project Team Members indexes
CREATE INDEX IF NOT EXISTS idx_project_team_members_project_id ON project_team_members(project_id);
CREATE INDEX IF NOT EXISTS idx_project_team_members_team_member_id ON project_team_members(team_member_id);

-- Client Tickets indexes
CREATE INDEX IF NOT EXISTS idx_client_tickets_client_id ON client_tickets(client_id);
CREATE INDEX IF NOT EXISTS idx_client_tickets_status ON client_tickets(status);

-- Notifications indexes
CREATE INDEX IF NOT EXISTS idx_notifications_client_id ON notifications(client_id);
CREATE INDEX IF NOT EXISTS idx_notifications_user_id ON notifications(user_id);
CREATE INDEX IF NOT EXISTS idx_notifications_is_read ON notifications(is_read);

-- Admin Notifications indexes
CREATE INDEX IF NOT EXISTS idx_admin_notifications_read ON admin_notifications(read);
CREATE INDEX IF NOT EXISTS idx_admin_notifications_created_at ON admin_notifications(created_at);

-- Ticket Messages indexes
CREATE INDEX IF NOT EXISTS idx_ticket_messages_ticket_id ON ticket_messages(ticket_id);

-- Teams indexes
CREATE INDEX IF NOT EXISTS idx_teams_status ON teams(status);

-- Team Members indexes
CREATE INDEX IF NOT EXISTS idx_team_members_team_id ON team_members(team_id);

-- Project unique indexes
CREATE UNIQUE INDEX IF NOT EXISTS project_staging_credentials_project_type_env_idx ON project_staging_credentials(project_id, type, environment);
CREATE UNIQUE INDEX IF NOT EXISTS project_developers_project_developer_idx ON project_developers(project_id, developer_id);
CREATE UNIQUE INDEX IF NOT EXISTS unique_project_test_scenario ON wcag_url_check(project_id, test_scenario);

-- Sync indexes
CREATE INDEX IF NOT EXISTS idx_sync_logs_project_id ON sync_logs(project_id);
CREATE INDEX IF NOT EXISTS idx_project_sync_status_project_id ON project_sync_status(project_id);

-- Issue Comments index
CREATE INDEX IF NOT EXISTS issue_comments_issue_idx ON issue_comments(issue_id);

-- ============================================================================
-- SECTION 5: TRIGGER FOR updated_at
-- ============================================================================

CREATE OR REPLACE FUNCTION update_updated_at_column()
RETURNS TRIGGER AS $$
BEGIN
    NEW.updated_at = NOW();
    RETURN NEW;
END;
$$ language 'plpgsql';

-- Apply triggers to all tables with updated_at column
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
-- SECTION 6: VERIFICATION
-- ============================================================================

SELECT 'Tables created:' as info;
SELECT COUNT(*) as table_count FROM information_schema.tables WHERE table_schema = 'public' AND table_type = 'BASE TABLE';

SELECT 'Enum types created:' as info;
SELECT COUNT(*) as enum_count FROM pg_type WHERE typtype = 'e' AND typnamespace = (SELECT oid FROM pg_namespace WHERE nspname = 'public');

SELECT 'A3S Platform database setup complete!' as status;

-- ============================================================================
-- NEXT STEP (if upgrading existing database)
-- ============================================================================
-- If you have existing tables that might be missing newer columns, run:
--   scripts/001_add_missing_columns.sql
-- 
-- This adds ALL columns to ALL tables if they don't exist.
-- CREATE TABLE IF NOT EXISTS only creates new tables - it doesn't modify existing ones.
-- ============================================================================
