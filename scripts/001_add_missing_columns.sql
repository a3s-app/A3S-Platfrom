-- ============================================================================
-- A3S PLATFORM - ADD MISSING COLUMNS MIGRATION
-- ============================================================================
-- 
-- This script adds ALL columns to ALL tables if they don't exist.
-- Run this AFTER 000_full_database_setup.sql if tables already exist
-- but might be missing some columns.
--
-- IDEMPOTENT: Safe to run multiple times
-- ============================================================================

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
        RAISE NOTICE 'Added column %.% (%)', _table, _column, _type;
    END IF;
EXCEPTION WHEN others THEN
    RAISE NOTICE 'Could not add column %.%: %', _table, _column, SQLERRM;
END;
$$ LANGUAGE plpgsql;

-- ============================================================================
-- CLIENTS TABLE (ALL COLUMNS)
-- ============================================================================
SELECT add_column_if_not_exists('clients', 'name', 'VARCHAR(255) NOT NULL', '''Unknown''');
SELECT add_column_if_not_exists('clients', 'email', 'VARCHAR(255) NOT NULL', '''unknown@example.com''');
SELECT add_column_if_not_exists('clients', 'company', 'VARCHAR(255) NOT NULL', '''Unknown''');
SELECT add_column_if_not_exists('clients', 'phone', 'VARCHAR(50)', 'NULL');
SELECT add_column_if_not_exists('clients', 'address', 'TEXT', 'NULL');
SELECT add_column_if_not_exists('clients', 'billing_amount', 'NUMERIC(10,2)', 'NULL');
SELECT add_column_if_not_exists('clients', 'billing_start_date', 'TIMESTAMP', 'NULL');
SELECT add_column_if_not_exists('clients', 'billing_frequency', 'billing_frequency', 'NULL');
SELECT add_column_if_not_exists('clients', 'status', 'client_status NOT NULL', '''pending''');
SELECT add_column_if_not_exists('clients', 'company_size', 'company_size', 'NULL');
SELECT add_column_if_not_exists('clients', 'industry', 'VARCHAR(100)', 'NULL');
SELECT add_column_if_not_exists('clients', 'website', 'VARCHAR(500)', 'NULL');
SELECT add_column_if_not_exists('clients', 'current_accessibility_level', 'accessibility_level', 'NULL');
SELECT add_column_if_not_exists('clients', 'compliance_deadline', 'TIMESTAMP', 'NULL');
SELECT add_column_if_not_exists('clients', 'pricing_tier', 'pricing_tier', 'NULL');
SELECT add_column_if_not_exists('clients', 'payment_method', 'payment_method', 'NULL');
SELECT add_column_if_not_exists('clients', 'services_needed', 'TEXT[]', 'NULL');
SELECT add_column_if_not_exists('clients', 'wcag_level', 'client_wcag_level', 'NULL');
SELECT add_column_if_not_exists('clients', 'priority_areas', 'TEXT[]', 'NULL');
SELECT add_column_if_not_exists('clients', 'timeline', 'timeline', 'NULL');
SELECT add_column_if_not_exists('clients', 'communication_preference', 'communication_preference', 'NULL');
SELECT add_column_if_not_exists('clients', 'reporting_frequency', 'reporting_frequency', 'NULL');
SELECT add_column_if_not_exists('clients', 'point_of_contact', 'VARCHAR(255)', 'NULL');
SELECT add_column_if_not_exists('clients', 'time_zone', 'VARCHAR(100)', 'NULL');
SELECT add_column_if_not_exists('clients', 'has_accessibility_policy', 'BOOLEAN', 'false');
SELECT add_column_if_not_exists('clients', 'accessibility_policy_url', 'VARCHAR(500)', 'NULL');
SELECT add_column_if_not_exists('clients', 'requires_legal_documentation', 'BOOLEAN', 'false');
SELECT add_column_if_not_exists('clients', 'compliance_documents', 'TEXT[]', 'NULL');
SELECT add_column_if_not_exists('clients', 'existing_audits', 'BOOLEAN', 'false');
SELECT add_column_if_not_exists('clients', 'previous_audit_results', 'TEXT', 'NULL');
SELECT add_column_if_not_exists('clients', 'notes', 'TEXT', 'NULL');
SELECT add_column_if_not_exists('clients', 'created_at', 'TIMESTAMP NOT NULL', 'NOW()');
SELECT add_column_if_not_exists('clients', 'updated_at', 'TIMESTAMP NOT NULL', 'NOW()');
SELECT add_column_if_not_exists('clients', 'client_type', 'client_type NOT NULL', '''a3s''');
SELECT add_column_if_not_exists('clients', 'policy_status', 'policy_status NOT NULL', '''none''');
SELECT add_column_if_not_exists('clients', 'policy_notes', 'TEXT', 'NULL');
SELECT add_column_if_not_exists('clients', 'client_documents', 'TEXT', 'NULL');
SELECT add_column_if_not_exists('clients', 'team_member_limit', 'INTEGER NOT NULL', '5');

-- ============================================================================
-- PROJECTS TABLE (ALL COLUMNS)
-- ============================================================================
SELECT add_column_if_not_exists('projects', 'client_id', 'UUID', 'NULL');
SELECT add_column_if_not_exists('projects', 'name', 'VARCHAR(255) NOT NULL', '''Unknown''');
SELECT add_column_if_not_exists('projects', 'description', 'TEXT', 'NULL');
SELECT add_column_if_not_exists('projects', 'sheet_id', 'VARCHAR(255)', 'NULL');
SELECT add_column_if_not_exists('projects', 'status', 'VARCHAR(50) NOT NULL', '''planning''');
SELECT add_column_if_not_exists('projects', 'priority', 'VARCHAR(50) NOT NULL', '''medium''');
SELECT add_column_if_not_exists('projects', 'wcag_level', 'VARCHAR(50) NOT NULL', '''AA''');
SELECT add_column_if_not_exists('projects', 'project_type', 'VARCHAR(50)', 'NULL');
SELECT add_column_if_not_exists('projects', 'compliance_requirements', 'TEXT[] NOT NULL', '''{}''');
SELECT add_column_if_not_exists('projects', 'start_date', 'TIMESTAMP', 'NULL');
SELECT add_column_if_not_exists('projects', 'end_date', 'TIMESTAMP', 'NULL');
SELECT add_column_if_not_exists('projects', 'estimated_hours', 'NUMERIC(8,2)', 'NULL');
SELECT add_column_if_not_exists('projects', 'actual_hours', 'NUMERIC(8,2)', '0');
SELECT add_column_if_not_exists('projects', 'budget', 'NUMERIC(12,2)', 'NULL');
SELECT add_column_if_not_exists('projects', 'billing_type', 'VARCHAR(50) NOT NULL', '''fixed''');
SELECT add_column_if_not_exists('projects', 'hourly_rate', 'NUMERIC(8,2)', 'NULL');
SELECT add_column_if_not_exists('projects', 'progress_percentage', 'INTEGER NOT NULL', '0');
SELECT add_column_if_not_exists('projects', 'milestones_completed', 'INTEGER NOT NULL', '0');
SELECT add_column_if_not_exists('projects', 'total_milestones', 'INTEGER NOT NULL', '0');
SELECT add_column_if_not_exists('projects', 'deliverables', 'TEXT[] NOT NULL', '''{}''');
SELECT add_column_if_not_exists('projects', 'acceptance_criteria', 'TEXT[] NOT NULL', '''{}''');
SELECT add_column_if_not_exists('projects', 'tags', 'TEXT[] NOT NULL', '''{}''');
SELECT add_column_if_not_exists('projects', 'notes', 'TEXT', 'NULL');
SELECT add_column_if_not_exists('projects', 'created_at', 'TIMESTAMP NOT NULL', 'NOW()');
SELECT add_column_if_not_exists('projects', 'updated_at', 'TIMESTAMP NOT NULL', 'NOW()');
SELECT add_column_if_not_exists('projects', 'created_by', 'VARCHAR(255)', '''system''');
SELECT add_column_if_not_exists('projects', 'last_modified_by', 'VARCHAR(255)', '''system''');
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

-- ============================================================================
-- TEST_URLS TABLE (ALL COLUMNS)
-- ============================================================================
SELECT add_column_if_not_exists('test_urls', 'project_id', 'UUID NOT NULL', 'NULL');
SELECT add_column_if_not_exists('test_urls', 'url', 'VARCHAR(1000) NOT NULL', '''unknown''');
SELECT add_column_if_not_exists('test_urls', 'page_title', 'VARCHAR(500)', 'NULL');
SELECT add_column_if_not_exists('test_urls', 'url_category', 'url_category', '''content''');
SELECT add_column_if_not_exists('test_urls', 'testing_month', 'VARCHAR(20)', 'NULL');
SELECT add_column_if_not_exists('test_urls', 'testing_year', 'INTEGER', 'NULL');
SELECT add_column_if_not_exists('test_urls', 'is_active', 'BOOLEAN', 'true');
SELECT add_column_if_not_exists('test_urls', 'created_at', 'TIMESTAMP NOT NULL', 'NOW()');
SELECT add_column_if_not_exists('test_urls', 'updated_at', 'TIMESTAMP NOT NULL', 'NOW()');
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

-- ============================================================================
-- ACCESSIBILITY_ISSUES TABLE (ALL COLUMNS)
-- ============================================================================
SELECT add_column_if_not_exists('accessibility_issues', 'project_id', 'UUID NOT NULL', 'NULL');
SELECT add_column_if_not_exists('accessibility_issues', 'url_id', 'UUID NOT NULL', 'NULL');
SELECT add_column_if_not_exists('accessibility_issues', 'issue_title', 'VARCHAR(500) NOT NULL', '''Unknown''');
SELECT add_column_if_not_exists('accessibility_issues', 'issue_description', 'TEXT', 'NULL');
SELECT add_column_if_not_exists('accessibility_issues', 'issue_type', 'issue_type', '''other''');
SELECT add_column_if_not_exists('accessibility_issues', 'severity', 'severity', '''4_low''');
SELECT add_column_if_not_exists('accessibility_issues', 'testing_month', 'VARCHAR(20)', 'NULL');
SELECT add_column_if_not_exists('accessibility_issues', 'testing_year', 'INTEGER', 'NULL');
SELECT add_column_if_not_exists('accessibility_issues', 'testing_environment', 'VARCHAR(200)', 'NULL');
SELECT add_column_if_not_exists('accessibility_issues', 'browser', 'VARCHAR(100)', 'NULL');
SELECT add_column_if_not_exists('accessibility_issues', 'operating_system', 'VARCHAR(100)', 'NULL');
SELECT add_column_if_not_exists('accessibility_issues', 'assistive_technology', 'VARCHAR(100)', 'NULL');
SELECT add_column_if_not_exists('accessibility_issues', 'expected_result', 'TEXT', 'NULL');
SELECT add_column_if_not_exists('accessibility_issues', 'actual_result', 'TEXT', 'NULL');
SELECT add_column_if_not_exists('accessibility_issues', 'failed_wcag_criteria', 'TEXT[]', '''{}''');
SELECT add_column_if_not_exists('accessibility_issues', 'conformance_level', 'conformance_level', 'NULL');
SELECT add_column_if_not_exists('accessibility_issues', 'screencast_url', 'VARCHAR(1000)', 'NULL');
SELECT add_column_if_not_exists('accessibility_issues', 'screenshot_urls', 'TEXT[]', '''{}''');
SELECT add_column_if_not_exists('accessibility_issues', 'dev_status', 'TEXT', '''not_started''');
SELECT add_column_if_not_exists('accessibility_issues', 'dev_comments', 'TEXT', 'NULL');
SELECT add_column_if_not_exists('accessibility_issues', 'dev_assigned_to', 'VARCHAR(255)', 'NULL');
SELECT add_column_if_not_exists('accessibility_issues', 'qa_status', 'TEXT', '''not_started''');
SELECT add_column_if_not_exists('accessibility_issues', 'qa_comments', 'TEXT', 'NULL');
SELECT add_column_if_not_exists('accessibility_issues', 'qa_assigned_to', 'VARCHAR(255)', 'NULL');
SELECT add_column_if_not_exists('accessibility_issues', 'discovered_at', 'TIMESTAMP NOT NULL', 'NOW()');
SELECT add_column_if_not_exists('accessibility_issues', 'dev_started_at', 'TIMESTAMP', 'NULL');
SELECT add_column_if_not_exists('accessibility_issues', 'dev_completed_at', 'TIMESTAMP', 'NULL');
SELECT add_column_if_not_exists('accessibility_issues', 'qa_started_at', 'TIMESTAMP', 'NULL');
SELECT add_column_if_not_exists('accessibility_issues', 'qa_completed_at', 'TIMESTAMP', 'NULL');
SELECT add_column_if_not_exists('accessibility_issues', 'resolved_at', 'TIMESTAMP', 'NULL');
SELECT add_column_if_not_exists('accessibility_issues', 'is_active', 'BOOLEAN', 'true');
SELECT add_column_if_not_exists('accessibility_issues', 'is_duplicate', 'BOOLEAN', 'false');
SELECT add_column_if_not_exists('accessibility_issues', 'duplicate_of_id', 'UUID', 'NULL');
SELECT add_column_if_not_exists('accessibility_issues', 'external_ticket_id', 'VARCHAR(255)', 'NULL');
SELECT add_column_if_not_exists('accessibility_issues', 'external_ticket_url', 'VARCHAR(1000)', 'NULL');
SELECT add_column_if_not_exists('accessibility_issues', 'import_batch_id', 'VARCHAR(255)', 'NULL');
SELECT add_column_if_not_exists('accessibility_issues', 'source_file_name', 'VARCHAR(255)', 'NULL');
SELECT add_column_if_not_exists('accessibility_issues', 'created_at', 'TIMESTAMP NOT NULL', 'NOW()');
SELECT add_column_if_not_exists('accessibility_issues', 'updated_at', 'TIMESTAMP NOT NULL', 'NOW()');
SELECT add_column_if_not_exists('accessibility_issues', 'sent_to_user', 'BOOLEAN', 'false');
SELECT add_column_if_not_exists('accessibility_issues', 'sent_date', 'TIMESTAMP', 'NULL');
SELECT add_column_if_not_exists('accessibility_issues', 'sent_month', 'VARCHAR(20)', 'NULL');
SELECT add_column_if_not_exists('accessibility_issues', 'report_id', 'UUID', 'NULL');
SELECT add_column_if_not_exists('accessibility_issues', 'dev_status_updated_at', 'TIMESTAMP', 'NULL');
SELECT add_column_if_not_exists('accessibility_issues', 'qa_status_updated_at', 'TIMESTAMP', 'NULL');
SELECT add_column_if_not_exists('accessibility_issues', 'metadata', 'JSONB', 'NULL');
SELECT add_column_if_not_exists('accessibility_issues', 'sheet_name', 'TEXT', 'NULL');
SELECT add_column_if_not_exists('accessibility_issues', 'sheet_row_number', 'INTEGER', 'NULL');
SELECT add_column_if_not_exists('accessibility_issues', 'issue_id', 'TEXT', '''unknown''');

-- ============================================================================
-- REPORTS TABLE (ALL COLUMNS)
-- ============================================================================
SELECT add_column_if_not_exists('reports', 'project_id', 'UUID NOT NULL', 'NULL');
SELECT add_column_if_not_exists('reports', 'title', 'VARCHAR(255) NOT NULL', '''Untitled''');
SELECT add_column_if_not_exists('reports', 'report_type', 'report_type NOT NULL', '''custom''');
SELECT add_column_if_not_exists('reports', 'ai_generated_content', 'TEXT', 'NULL');
SELECT add_column_if_not_exists('reports', 'edited_content', 'TEXT', 'NULL');
SELECT add_column_if_not_exists('reports', 'status', 'report_status NOT NULL', '''draft''');
SELECT add_column_if_not_exists('reports', 'sent_at', 'TIMESTAMP', 'NULL');
SELECT add_column_if_not_exists('reports', 'sent_to', 'JSONB', 'NULL');
SELECT add_column_if_not_exists('reports', 'email_subject', 'VARCHAR(255)', 'NULL');
SELECT add_column_if_not_exists('reports', 'email_body', 'TEXT', 'NULL');
SELECT add_column_if_not_exists('reports', 'pdf_path', 'VARCHAR(500)', 'NULL');
SELECT add_column_if_not_exists('reports', 'created_by', 'VARCHAR(255)', 'NULL');
SELECT add_column_if_not_exists('reports', 'created_at', 'TIMESTAMP NOT NULL', 'NOW()');
SELECT add_column_if_not_exists('reports', 'updated_at', 'TIMESTAMP NOT NULL', 'NOW()');
SELECT add_column_if_not_exists('reports', 'is_public', 'BOOLEAN NOT NULL', 'false');
SELECT add_column_if_not_exists('reports', 'public_token', 'VARCHAR(64)', 'NULL');
SELECT add_column_if_not_exists('reports', 'report_month', 'VARCHAR(20)', 'NULL');
SELECT add_column_if_not_exists('reports', 'report_year', 'INTEGER', 'NULL');

-- ============================================================================
-- REPORT_ISSUES TABLE (ALL COLUMNS)
-- ============================================================================
SELECT add_column_if_not_exists('report_issues', 'report_id', 'UUID NOT NULL', 'NULL');
SELECT add_column_if_not_exists('report_issues', 'issue_id', 'UUID NOT NULL', 'NULL');
SELECT add_column_if_not_exists('report_issues', 'included_at', 'TIMESTAMP NOT NULL', 'NOW()');

-- ============================================================================
-- REPORT_COMMENTS TABLE (ALL COLUMNS)
-- ============================================================================
SELECT add_column_if_not_exists('report_comments', 'report_id', 'UUID NOT NULL', 'NULL');
SELECT add_column_if_not_exists('report_comments', 'comment', 'TEXT NOT NULL', '''No comment''');
SELECT add_column_if_not_exists('report_comments', 'comment_type', 'VARCHAR(50) NOT NULL', '''general''');
SELECT add_column_if_not_exists('report_comments', 'author_id', 'VARCHAR(255)', 'NULL');
SELECT add_column_if_not_exists('report_comments', 'author_name', 'VARCHAR(255)', 'NULL');
SELECT add_column_if_not_exists('report_comments', 'is_internal', 'BOOLEAN NOT NULL', 'true');
SELECT add_column_if_not_exists('report_comments', 'created_at', 'TIMESTAMP NOT NULL', 'NOW()');

-- ============================================================================
-- CLIENT_USERS TABLE (ALL COLUMNS)
-- ============================================================================
SELECT add_column_if_not_exists('client_users', 'clerk_user_id', 'VARCHAR(255) NOT NULL', '''unknown''');
SELECT add_column_if_not_exists('client_users', 'client_id', 'UUID NOT NULL', 'NULL');
SELECT add_column_if_not_exists('client_users', 'email', 'VARCHAR(255) NOT NULL', '''unknown@example.com''');
SELECT add_column_if_not_exists('client_users', 'first_name', 'VARCHAR(100)', 'NULL');
SELECT add_column_if_not_exists('client_users', 'last_name', 'VARCHAR(100)', 'NULL');
SELECT add_column_if_not_exists('client_users', 'role', 'user_role NOT NULL', '''viewer''');
SELECT add_column_if_not_exists('client_users', 'is_active', 'BOOLEAN NOT NULL', 'true');
SELECT add_column_if_not_exists('client_users', 'email_notifications', 'BOOLEAN NOT NULL', 'true');
SELECT add_column_if_not_exists('client_users', 'last_login_at', 'TIMESTAMP', 'NULL');
SELECT add_column_if_not_exists('client_users', 'created_at', 'TIMESTAMP NOT NULL', 'NOW()');
SELECT add_column_if_not_exists('client_users', 'updated_at', 'TIMESTAMP NOT NULL', 'NOW()');

-- ============================================================================
-- CLIENT_TEAM_MEMBERS TABLE (ALL COLUMNS)
-- ============================================================================
SELECT add_column_if_not_exists('client_team_members', 'client_id', 'UUID NOT NULL', 'NULL');
SELECT add_column_if_not_exists('client_team_members', 'name', 'VARCHAR(255) NOT NULL', '''Unknown''');
SELECT add_column_if_not_exists('client_team_members', 'email', 'VARCHAR(255) NOT NULL', '''unknown@example.com''');
SELECT add_column_if_not_exists('client_team_members', 'description', 'TEXT', 'NULL');
SELECT add_column_if_not_exists('client_team_members', 'invitation_status', 'invitation_status NOT NULL', '''pending''');
SELECT add_column_if_not_exists('client_team_members', 'invitation_sent_at', 'TIMESTAMP', 'NULL');
SELECT add_column_if_not_exists('client_team_members', 'invitation_token', 'VARCHAR(255)', 'NULL');
SELECT add_column_if_not_exists('client_team_members', 'invited_by_user_id', 'UUID', 'NULL');
SELECT add_column_if_not_exists('client_team_members', 'accepted_at', 'TIMESTAMP', 'NULL');
SELECT add_column_if_not_exists('client_team_members', 'linked_user_id', 'UUID', 'NULL');
SELECT add_column_if_not_exists('client_team_members', 'created_at', 'TIMESTAMP NOT NULL', 'NOW()');
SELECT add_column_if_not_exists('client_team_members', 'updated_at', 'TIMESTAMP NOT NULL', 'NOW()');
SELECT add_column_if_not_exists('client_team_members', 'clerk_invitation_id', 'VARCHAR(255)', 'NULL');
SELECT add_column_if_not_exists('client_team_members', 'pending_project_ids', 'JSONB', '''[]''');

-- ============================================================================
-- PROJECT_TEAM_MEMBERS TABLE (ALL COLUMNS)
-- ============================================================================
SELECT add_column_if_not_exists('project_team_members', 'project_id', 'UUID NOT NULL', 'NULL');
SELECT add_column_if_not_exists('project_team_members', 'team_member_id', 'UUID NOT NULL', 'NULL');
SELECT add_column_if_not_exists('project_team_members', 'role', 'project_role NOT NULL', '''project_member''');
SELECT add_column_if_not_exists('project_team_members', 'created_at', 'TIMESTAMP NOT NULL', 'NOW()');
SELECT add_column_if_not_exists('project_team_members', 'updated_at', 'TIMESTAMP NOT NULL', 'NOW()');
SELECT add_column_if_not_exists('project_team_members', 'display_name', 'VARCHAR(255)', 'NULL');

-- ============================================================================
-- CLIENT_TICKETS TABLE (ALL COLUMNS)
-- ============================================================================
SELECT add_column_if_not_exists('client_tickets', 'client_id', 'UUID NOT NULL', 'NULL');
SELECT add_column_if_not_exists('client_tickets', 'project_id', 'UUID', 'NULL');
SELECT add_column_if_not_exists('client_tickets', 'title', 'VARCHAR(500) NOT NULL', '''Untitled''');
SELECT add_column_if_not_exists('client_tickets', 'description', 'TEXT NOT NULL', '''No description''');
SELECT add_column_if_not_exists('client_tickets', 'status', 'ticket_status NOT NULL', '''needs_attention''');
SELECT add_column_if_not_exists('client_tickets', 'priority', 'ticket_priority NOT NULL', '''medium''');
SELECT add_column_if_not_exists('client_tickets', 'category', 'VARCHAR(50) NOT NULL', '''technical''');
SELECT add_column_if_not_exists('client_tickets', 'created_by', 'UUID', 'NULL');
SELECT add_column_if_not_exists('client_tickets', 'assigned_to', 'UUID', 'NULL');
SELECT add_column_if_not_exists('client_tickets', 'created_at', 'TIMESTAMP NOT NULL', 'NOW()');
SELECT add_column_if_not_exists('client_tickets', 'updated_at', 'TIMESTAMP NOT NULL', 'NOW()');
SELECT add_column_if_not_exists('client_tickets', 'issues_id', 'VARCHAR(255)', 'NULL');
SELECT add_column_if_not_exists('client_tickets', 'created_by_user_id', 'UUID', 'NULL');
SELECT add_column_if_not_exists('client_tickets', 'related_issue_id', 'UUID', 'NULL');
SELECT add_column_if_not_exists('client_tickets', 'internal_notes', 'TEXT', 'NULL');
SELECT add_column_if_not_exists('client_tickets', 'resolution', 'TEXT', 'NULL');
SELECT add_column_if_not_exists('client_tickets', 'resolved_at', 'TIMESTAMP', 'NULL');
SELECT add_column_if_not_exists('client_tickets', 'closed_at', 'TIMESTAMP', 'NULL');

-- ============================================================================
-- CLIENT_TICKET_ISSUES TABLE (ALL COLUMNS)
-- ============================================================================
SELECT add_column_if_not_exists('client_ticket_issues', 'ticket_id', 'UUID NOT NULL', 'NULL');
SELECT add_column_if_not_exists('client_ticket_issues', 'issue_id', 'UUID NOT NULL', 'NULL');
SELECT add_column_if_not_exists('client_ticket_issues', 'created_at', 'TIMESTAMP NOT NULL', 'NOW()');

-- ============================================================================
-- EVIDENCE_DOCUMENTS TABLE (ALL COLUMNS)
-- ============================================================================
SELECT add_column_if_not_exists('evidence_documents', 'client_id', 'UUID NOT NULL', 'NULL');
SELECT add_column_if_not_exists('evidence_documents', 'project_id', 'UUID', 'NULL');
SELECT add_column_if_not_exists('evidence_documents', 'title', 'VARCHAR(500) NOT NULL', '''Untitled''');
SELECT add_column_if_not_exists('evidence_documents', 'description', 'TEXT', 'NULL');
SELECT add_column_if_not_exists('evidence_documents', 'document_type', 'document_type NOT NULL', '''other''');
SELECT add_column_if_not_exists('evidence_documents', 'status', 'document_status NOT NULL', '''draft''');
SELECT add_column_if_not_exists('evidence_documents', 'priority', 'document_priority NOT NULL', '''medium''');
SELECT add_column_if_not_exists('evidence_documents', 'wcag_coverage', 'JSONB', '''[]''');
SELECT add_column_if_not_exists('evidence_documents', 'file_url', 'VARCHAR(1000)', 'NULL');
SELECT add_column_if_not_exists('evidence_documents', 'file_name', 'VARCHAR(255)', 'NULL');
SELECT add_column_if_not_exists('evidence_documents', 'file_size', 'INTEGER', 'NULL');
SELECT add_column_if_not_exists('evidence_documents', 'file_type', 'VARCHAR(50)', 'NULL');
SELECT add_column_if_not_exists('evidence_documents', 'version', 'VARCHAR(50)', '''1.0''');
SELECT add_column_if_not_exists('evidence_documents', 'valid_until', 'TIMESTAMP', 'NULL');
SELECT add_column_if_not_exists('evidence_documents', 'certified_at', 'TIMESTAMP', 'NULL');
SELECT add_column_if_not_exists('evidence_documents', 'certified_by', 'VARCHAR(255)', 'NULL');
SELECT add_column_if_not_exists('evidence_documents', 'notes', 'TEXT', 'NULL');
SELECT add_column_if_not_exists('evidence_documents', 'created_by', 'VARCHAR(255)', 'NULL');
SELECT add_column_if_not_exists('evidence_documents', 'created_at', 'TIMESTAMP NOT NULL', 'NOW()');
SELECT add_column_if_not_exists('evidence_documents', 'updated_at', 'TIMESTAMP NOT NULL', 'NOW()');

-- ============================================================================
-- EVIDENCE_DOCUMENT_REQUESTS TABLE (ALL COLUMNS)
-- ============================================================================
SELECT add_column_if_not_exists('evidence_document_requests', 'client_id', 'UUID NOT NULL', 'NULL');
SELECT add_column_if_not_exists('evidence_document_requests', 'requested_by_user_id', 'UUID NOT NULL', 'NULL');
SELECT add_column_if_not_exists('evidence_document_requests', 'document_type', 'document_type NOT NULL', '''other''');
SELECT add_column_if_not_exists('evidence_document_requests', 'title', 'VARCHAR(500) NOT NULL', '''Untitled''');
SELECT add_column_if_not_exists('evidence_document_requests', 'description', 'TEXT', 'NULL');
SELECT add_column_if_not_exists('evidence_document_requests', 'priority', 'document_priority NOT NULL', '''medium''');
SELECT add_column_if_not_exists('evidence_document_requests', 'status', 'document_request_status NOT NULL', '''pending''');
SELECT add_column_if_not_exists('evidence_document_requests', 'admin_notes', 'TEXT', 'NULL');
SELECT add_column_if_not_exists('evidence_document_requests', 'completed_document_id', 'UUID', 'NULL');
SELECT add_column_if_not_exists('evidence_document_requests', 'created_at', 'TIMESTAMP NOT NULL', 'NOW()');
SELECT add_column_if_not_exists('evidence_document_requests', 'updated_at', 'TIMESTAMP NOT NULL', 'NOW()');

-- ============================================================================
-- DOCUMENT_REMEDIATIONS TABLE (ALL COLUMNS)
-- ============================================================================
SELECT add_column_if_not_exists('document_remediations', 'client_id', 'UUID NOT NULL', 'NULL');
SELECT add_column_if_not_exists('document_remediations', 'uploaded_by_user_id', 'UUID NOT NULL', 'NULL');
SELECT add_column_if_not_exists('document_remediations', 'batch_id', 'VARCHAR(100)', 'NULL');
SELECT add_column_if_not_exists('document_remediations', 'original_file_name', 'VARCHAR(500) NOT NULL', '''unknown''');
SELECT add_column_if_not_exists('document_remediations', 'original_file_url', 'VARCHAR(1000) NOT NULL', '''unknown''');
SELECT add_column_if_not_exists('document_remediations', 'original_file_size', 'INTEGER', 'NULL');
SELECT add_column_if_not_exists('document_remediations', 'original_file_type', 'VARCHAR(50)', 'NULL');
SELECT add_column_if_not_exists('document_remediations', 'page_count', 'INTEGER NOT NULL', '1');
SELECT add_column_if_not_exists('document_remediations', 'remediation_type', 'remediation_type NOT NULL', '''traditional_pdf''');
SELECT add_column_if_not_exists('document_remediations', 'status', 'remediation_status NOT NULL', '''pending''');
SELECT add_column_if_not_exists('document_remediations', 'price_per_page', 'NUMERIC(10,2) NOT NULL', '0');
SELECT add_column_if_not_exists('document_remediations', 'total_price', 'NUMERIC(10,2) NOT NULL', '0');
SELECT add_column_if_not_exists('document_remediations', 'remediated_file_name', 'VARCHAR(500)', 'NULL');
SELECT add_column_if_not_exists('document_remediations', 'remediated_file_url', 'VARCHAR(1000)', 'NULL');
SELECT add_column_if_not_exists('document_remediations', 'remediated_file_size', 'INTEGER', 'NULL');
SELECT add_column_if_not_exists('document_remediations', 'remediated_file_type', 'VARCHAR(50)', 'NULL');
SELECT add_column_if_not_exists('document_remediations', 'notes', 'TEXT', 'NULL');
SELECT add_column_if_not_exists('document_remediations', 'admin_notes', 'TEXT', 'NULL');
SELECT add_column_if_not_exists('document_remediations', 'completed_at', 'TIMESTAMP', 'NULL');
SELECT add_column_if_not_exists('document_remediations', 'created_at', 'TIMESTAMP NOT NULL', 'NOW()');
SELECT add_column_if_not_exists('document_remediations', 'updated_at', 'TIMESTAMP NOT NULL', 'NOW()');
SELECT add_column_if_not_exists('document_remediations', 'price_adjusted', 'BOOLEAN', 'false');
SELECT add_column_if_not_exists('document_remediations', 'original_price_per_page', 'NUMERIC(10,2)', 'NULL');
SELECT add_column_if_not_exists('document_remediations', 'original_total_price', 'NUMERIC(10,2)', 'NULL');
SELECT add_column_if_not_exists('document_remediations', 'reviewed_by_user_id', 'UUID', 'NULL');
SELECT add_column_if_not_exists('document_remediations', 'reviewed_at', 'TIMESTAMP', 'NULL');
SELECT add_column_if_not_exists('document_remediations', 'rejection_reason', 'TEXT', 'NULL');

-- ============================================================================
-- CLIENT_BILLING_ADDONS TABLE (ALL COLUMNS)
-- ============================================================================
SELECT add_column_if_not_exists('client_billing_addons', 'client_id', 'UUID NOT NULL', 'NULL');
SELECT add_column_if_not_exists('client_billing_addons', 'addon_type', 'billing_addon_type NOT NULL', '''custom''');
SELECT add_column_if_not_exists('client_billing_addons', 'name', 'VARCHAR(255) NOT NULL', '''Unknown''');
SELECT add_column_if_not_exists('client_billing_addons', 'description', 'TEXT', 'NULL');
SELECT add_column_if_not_exists('client_billing_addons', 'quantity', 'INTEGER NOT NULL', '1');
SELECT add_column_if_not_exists('client_billing_addons', 'unit_price', 'NUMERIC(10,2) NOT NULL', '0');
SELECT add_column_if_not_exists('client_billing_addons', 'total_monthly_price', 'NUMERIC(10,2) NOT NULL', '0');
SELECT add_column_if_not_exists('client_billing_addons', 'status', 'billing_addon_status NOT NULL', '''active''');
SELECT add_column_if_not_exists('client_billing_addons', 'activated_at', 'TIMESTAMP NOT NULL', 'NOW()');
SELECT add_column_if_not_exists('client_billing_addons', 'cancelled_at', 'TIMESTAMP', 'NULL');
SELECT add_column_if_not_exists('client_billing_addons', 'metadata', 'JSONB', '''{}''');
SELECT add_column_if_not_exists('client_billing_addons', 'approved_by_user_id', 'UUID', 'NULL');
SELECT add_column_if_not_exists('client_billing_addons', 'created_at', 'TIMESTAMP NOT NULL', 'NOW()');
SELECT add_column_if_not_exists('client_billing_addons', 'updated_at', 'TIMESTAMP NOT NULL', 'NOW()');

-- ============================================================================
-- NOTIFICATIONS TABLE (ALL COLUMNS)
-- ============================================================================
SELECT add_column_if_not_exists('notifications', 'client_id', 'UUID', 'NULL');
SELECT add_column_if_not_exists('notifications', 'user_id', 'UUID', 'NULL');
SELECT add_column_if_not_exists('notifications', 'type', 'notification_type NOT NULL', '''system''');
SELECT add_column_if_not_exists('notifications', 'priority', 'notification_priority NOT NULL', '''normal''');
SELECT add_column_if_not_exists('notifications', 'title', 'VARCHAR(255) NOT NULL', '''Notification''');
SELECT add_column_if_not_exists('notifications', 'message', 'TEXT NOT NULL', '''No message''');
SELECT add_column_if_not_exists('notifications', 'action_url', 'VARCHAR(500)', 'NULL');
SELECT add_column_if_not_exists('notifications', 'action_label', 'VARCHAR(100)', 'NULL');
SELECT add_column_if_not_exists('notifications', 'related_project_id', 'UUID', 'NULL');
SELECT add_column_if_not_exists('notifications', 'related_document_id', 'UUID', 'NULL');
SELECT add_column_if_not_exists('notifications', 'related_ticket_id', 'UUID', 'NULL');
SELECT add_column_if_not_exists('notifications', 'metadata', 'JSONB', '''{}''');
SELECT add_column_if_not_exists('notifications', 'is_read', 'BOOLEAN NOT NULL', 'false');
SELECT add_column_if_not_exists('notifications', 'read_at', 'TIMESTAMP', 'NULL');
SELECT add_column_if_not_exists('notifications', 'is_archived', 'BOOLEAN NOT NULL', 'false');
SELECT add_column_if_not_exists('notifications', 'archived_at', 'TIMESTAMP', 'NULL');
SELECT add_column_if_not_exists('notifications', 'expires_at', 'TIMESTAMP', 'NULL');
SELECT add_column_if_not_exists('notifications', 'created_at', 'TIMESTAMP NOT NULL', 'NOW()');
SELECT add_column_if_not_exists('notifications', 'updated_at', 'TIMESTAMP NOT NULL', 'NOW()');

-- ============================================================================
-- ADMIN_NOTIFICATIONS TABLE (ALL COLUMNS)
-- ============================================================================
SELECT add_column_if_not_exists('admin_notifications', 'title', 'VARCHAR(255) NOT NULL', '''Notification''');
SELECT add_column_if_not_exists('admin_notifications', 'message', 'TEXT NOT NULL', '''No message''');
SELECT add_column_if_not_exists('admin_notifications', 'type', 'admin_notification_type', '''system''');
SELECT add_column_if_not_exists('admin_notifications', 'priority', 'VARCHAR(20)', '''normal''');
SELECT add_column_if_not_exists('admin_notifications', 'read', 'BOOLEAN NOT NULL', 'false');
SELECT add_column_if_not_exists('admin_notifications', 'action_url', 'VARCHAR(500)', 'NULL');
SELECT add_column_if_not_exists('admin_notifications', 'action_label', 'VARCHAR(100)', 'NULL');
SELECT add_column_if_not_exists('admin_notifications', 'metadata', 'JSONB', '''{}''');
SELECT add_column_if_not_exists('admin_notifications', 'related_client_id', 'UUID', 'NULL');
SELECT add_column_if_not_exists('admin_notifications', 'related_ticket_id', 'UUID', 'NULL');
SELECT add_column_if_not_exists('admin_notifications', 'created_at', 'TIMESTAMP NOT NULL', 'NOW()');
SELECT add_column_if_not_exists('admin_notifications', 'read_at', 'TIMESTAMP', 'NULL');

-- ============================================================================
-- CLERK_USER_ID_BACKUPS TABLE (ALL COLUMNS)
-- ============================================================================
SELECT add_column_if_not_exists('clerk_user_id_backups', 'client_user_id', 'UUID NOT NULL', 'NULL');
SELECT add_column_if_not_exists('clerk_user_id_backups', 'email', 'VARCHAR(255) NOT NULL', '''unknown''');
SELECT add_column_if_not_exists('clerk_user_id_backups', 'old_clerk_user_id', 'VARCHAR(255) NOT NULL', '''unknown''');
SELECT add_column_if_not_exists('clerk_user_id_backups', 'new_clerk_user_id', 'VARCHAR(255) NOT NULL', '''unknown''');
SELECT add_column_if_not_exists('clerk_user_id_backups', 'migrated_at', 'TIMESTAMP NOT NULL', 'NOW()');
SELECT add_column_if_not_exists('clerk_user_id_backups', 'rolled_back_at', 'TIMESTAMP', 'NULL');
SELECT add_column_if_not_exists('clerk_user_id_backups', 'notes', 'TEXT', 'NULL');

-- ============================================================================
-- TICKET_MESSAGES TABLE (ALL COLUMNS)
-- ============================================================================
SELECT add_column_if_not_exists('ticket_messages', 'ticket_id', 'UUID NOT NULL', 'NULL');
SELECT add_column_if_not_exists('ticket_messages', 'sender_type', 'message_sender_type NOT NULL', '''admin''');
SELECT add_column_if_not_exists('ticket_messages', 'sender_id', 'UUID', 'NULL');
SELECT add_column_if_not_exists('ticket_messages', 'sender_name', 'VARCHAR(255)', 'NULL');
SELECT add_column_if_not_exists('ticket_messages', 'content', 'TEXT NOT NULL', '''No content''');
SELECT add_column_if_not_exists('ticket_messages', 'attachments', 'JSONB', '''[]''');
SELECT add_column_if_not_exists('ticket_messages', 'is_internal', 'BOOLEAN NOT NULL', 'false');
SELECT add_column_if_not_exists('ticket_messages', 'read_at', 'TIMESTAMP', 'NULL');
SELECT add_column_if_not_exists('ticket_messages', 'created_at', 'TIMESTAMP NOT NULL', 'NOW()');
SELECT add_column_if_not_exists('ticket_messages', 'updated_at', 'TIMESTAMP NOT NULL', 'NOW()');

-- ============================================================================
-- TICKETS TABLE (ALL COLUMNS)
-- ============================================================================
SELECT add_column_if_not_exists('tickets', 'project_id', 'UUID', 'NULL');
SELECT add_column_if_not_exists('tickets', 'title', 'VARCHAR(255) NOT NULL', '''Untitled''');
SELECT add_column_if_not_exists('tickets', 'description', 'TEXT NOT NULL', '''No description''');
SELECT add_column_if_not_exists('tickets', 'status', 'ticket_status NOT NULL', '''open''');
SELECT add_column_if_not_exists('tickets', 'priority', 'ticket_priority NOT NULL', '''medium''');
SELECT add_column_if_not_exists('tickets', 'type', 'ticket_type NOT NULL', '''task''');
SELECT add_column_if_not_exists('tickets', 'assignee_id', 'VARCHAR(255)', 'NULL');
SELECT add_column_if_not_exists('tickets', 'reporter_id', 'VARCHAR(255)', '''system''');
SELECT add_column_if_not_exists('tickets', 'estimated_hours', 'INTEGER', 'NULL');
SELECT add_column_if_not_exists('tickets', 'actual_hours', 'INTEGER', '0');
SELECT add_column_if_not_exists('tickets', 'wcag_criteria', 'TEXT[]', 'NULL');
SELECT add_column_if_not_exists('tickets', 'tags', 'TEXT[] NOT NULL', '''{}''');
SELECT add_column_if_not_exists('tickets', 'created_at', 'TIMESTAMP NOT NULL', 'NOW()');
SELECT add_column_if_not_exists('tickets', 'updated_at', 'TIMESTAMP NOT NULL', 'NOW()');
SELECT add_column_if_not_exists('tickets', 'resolved_at', 'TIMESTAMP', 'NULL');
SELECT add_column_if_not_exists('tickets', 'closed_at', 'TIMESTAMP', 'NULL');
SELECT add_column_if_not_exists('tickets', 'due_date', 'TIMESTAMP', 'NULL');
SELECT add_column_if_not_exists('tickets', 'client_id', 'UUID', 'NULL');
SELECT add_column_if_not_exists('tickets', 'related_issue_ids', 'TEXT[]', '''{}''');
SELECT add_column_if_not_exists('tickets', 'ticket_category', 'VARCHAR(50)', '''general''');

-- ============================================================================
-- TEAMS TABLE (ALL COLUMNS)
-- ============================================================================
SELECT add_column_if_not_exists('teams', 'name', 'VARCHAR(255) NOT NULL', '''Unknown''');
SELECT add_column_if_not_exists('teams', 'description', 'TEXT', 'NULL');
SELECT add_column_if_not_exists('teams', 'created_at', 'TIMESTAMP NOT NULL', 'NOW()');
SELECT add_column_if_not_exists('teams', 'updated_at', 'TIMESTAMP NOT NULL', 'NOW()');
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

-- ============================================================================
-- TEAM_MEMBERS TABLE (ALL COLUMNS)
-- ============================================================================
SELECT add_column_if_not_exists('team_members', 'team_id', 'UUID NOT NULL', 'NULL');
SELECT add_column_if_not_exists('team_members', 'first_name', 'VARCHAR(100) NOT NULL', '''Unknown''');
SELECT add_column_if_not_exists('team_members', 'last_name', 'VARCHAR(100) NOT NULL', '''Unknown''');
SELECT add_column_if_not_exists('team_members', 'email', 'VARCHAR(255) NOT NULL', '''unknown@example.com''');
SELECT add_column_if_not_exists('team_members', 'phone', 'VARCHAR(20)', 'NULL');
SELECT add_column_if_not_exists('team_members', 'role', 'employee_role NOT NULL', '''developer''');
SELECT add_column_if_not_exists('team_members', 'title', 'VARCHAR(255)', 'NULL');
SELECT add_column_if_not_exists('team_members', 'department', 'VARCHAR(100)', 'NULL');
SELECT add_column_if_not_exists('team_members', 'reports_to_id', 'UUID', 'NULL');
SELECT add_column_if_not_exists('team_members', 'employment_status', 'employment_status NOT NULL', '''active''');
SELECT add_column_if_not_exists('team_members', 'start_date', 'TIMESTAMP', 'NULL');
SELECT add_column_if_not_exists('team_members', 'end_date', 'TIMESTAMP', 'NULL');
SELECT add_column_if_not_exists('team_members', 'hourly_rate', 'INTEGER', 'NULL');
SELECT add_column_if_not_exists('team_members', 'salary', 'INTEGER', 'NULL');
SELECT add_column_if_not_exists('team_members', 'skills', 'TEXT', 'NULL');
SELECT add_column_if_not_exists('team_members', 'bio', 'TEXT', 'NULL');
SELECT add_column_if_not_exists('team_members', 'profile_image_url', 'VARCHAR(500)', 'NULL');
SELECT add_column_if_not_exists('team_members', 'linkedin_url', 'VARCHAR(500)', 'NULL');
SELECT add_column_if_not_exists('team_members', 'github_url', 'VARCHAR(500)', 'NULL');
SELECT add_column_if_not_exists('team_members', 'is_active', 'BOOLEAN NOT NULL', 'true');
SELECT add_column_if_not_exists('team_members', 'created_at', 'TIMESTAMP NOT NULL', 'NOW()');
SELECT add_column_if_not_exists('team_members', 'updated_at', 'TIMESTAMP NOT NULL', 'NOW()');
-- Additional team_members columns from production
SELECT add_column_if_not_exists('team_members', 'employee_id', 'VARCHAR(255)', 'NULL');
SELECT add_column_if_not_exists('team_members', 'status', 'member_status NOT NULL', '''active''');
SELECT add_column_if_not_exists('team_members', 'manager_id', 'UUID', 'NULL');
SELECT add_column_if_not_exists('team_members', 'hire_date', 'TIMESTAMP', 'NULL');
SELECT add_column_if_not_exists('team_members', 'termination_date', 'TIMESTAMP', 'NULL');
SELECT add_column_if_not_exists('team_members', 'specializations', 'TEXT[]', 'NULL');
SELECT add_column_if_not_exists('team_members', 'certifications', 'TEXT[]', 'NULL');
SELECT add_column_if_not_exists('team_members', 'address', 'TEXT', 'NULL');
SELECT add_column_if_not_exists('team_members', 'emergency_contact', 'VARCHAR(255)', 'NULL');
SELECT add_column_if_not_exists('team_members', 'emergency_phone', 'VARCHAR(50)', 'NULL');
SELECT add_column_if_not_exists('team_members', 'work_location', 'VARCHAR(255)', 'NULL');
SELECT add_column_if_not_exists('team_members', 'time_zone', 'VARCHAR(100)', 'NULL');
SELECT add_column_if_not_exists('team_members', 'working_hours', 'VARCHAR(100)', 'NULL');
SELECT add_column_if_not_exists('team_members', 'slack_user_id', 'VARCHAR(255)', 'NULL');
SELECT add_column_if_not_exists('team_members', 'github_username', 'VARCHAR(255)', 'NULL');
SELECT add_column_if_not_exists('team_members', 'linkedin_profile', 'VARCHAR(500)', 'NULL');
SELECT add_column_if_not_exists('team_members', 'performance_rating', 'VARCHAR(50)', 'NULL');
SELECT add_column_if_not_exists('team_members', 'goals', 'TEXT', 'NULL');
SELECT add_column_if_not_exists('team_members', 'notes', 'TEXT', 'NULL');
SELECT add_column_if_not_exists('team_members', 'profile_picture', 'VARCHAR(500)', 'NULL');
SELECT add_column_if_not_exists('team_members', 'created_by', 'VARCHAR(255)', 'NULL');
SELECT add_column_if_not_exists('team_members', 'can_manage_teams', 'BOOLEAN', 'false');
SELECT add_column_if_not_exists('team_members', 'can_manage_projects', 'BOOLEAN', 'false');
SELECT add_column_if_not_exists('team_members', 'can_view_reports', 'BOOLEAN', 'false');
SELECT add_column_if_not_exists('team_members', 'email_notifications', 'BOOLEAN NOT NULL', 'true');

-- ============================================================================
-- PROJECT_TEAM_ASSIGNMENTS TABLE (ALL COLUMNS)
-- ============================================================================
SELECT add_column_if_not_exists('project_team_assignments', 'project_id', 'UUID NOT NULL', 'NULL');
SELECT add_column_if_not_exists('project_team_assignments', 'team_member_id', 'UUID NOT NULL', 'NULL');
SELECT add_column_if_not_exists('project_team_assignments', 'role', 'VARCHAR(100)', 'NULL');
SELECT add_column_if_not_exists('project_team_assignments', 'assigned_at', 'TIMESTAMP NOT NULL', 'NOW()');
SELECT add_column_if_not_exists('project_team_assignments', 'assigned_by', 'VARCHAR(255)', 'NULL');
SELECT add_column_if_not_exists('project_team_assignments', 'is_active', 'BOOLEAN NOT NULL', 'true');
SELECT add_column_if_not_exists('project_team_assignments', 'notes', 'TEXT', 'NULL');

-- ============================================================================
-- PROJECT_STAGING_CREDENTIALS TABLE (ALL COLUMNS)
-- ============================================================================
SELECT add_column_if_not_exists('project_staging_credentials', 'project_id', 'UUID NOT NULL', 'NULL');
SELECT add_column_if_not_exists('project_staging_credentials', 'type', 'credential_type NOT NULL', '''staging''');
SELECT add_column_if_not_exists('project_staging_credentials', 'environment', 'VARCHAR(100) NOT NULL', '''staging''');
SELECT add_column_if_not_exists('project_staging_credentials', 'url', 'VARCHAR(500) NOT NULL', '''unknown''');
SELECT add_column_if_not_exists('project_staging_credentials', 'username', 'VARCHAR(255)', 'NULL');
SELECT add_column_if_not_exists('project_staging_credentials', 'password', 'TEXT', 'NULL');
SELECT add_column_if_not_exists('project_staging_credentials', 'api_key', 'TEXT', 'NULL');
SELECT add_column_if_not_exists('project_staging_credentials', 'access_token', 'TEXT', 'NULL');
SELECT add_column_if_not_exists('project_staging_credentials', 'ssh_key', 'TEXT', 'NULL');
SELECT add_column_if_not_exists('project_staging_credentials', 'database_url', 'TEXT', 'NULL');
SELECT add_column_if_not_exists('project_staging_credentials', 'remote_folder_path', 'VARCHAR(500)', 'NULL');
SELECT add_column_if_not_exists('project_staging_credentials', 'additional_urls', 'TEXT[]', '''{}''');
SELECT add_column_if_not_exists('project_staging_credentials', 'notes', 'TEXT', 'NULL');
SELECT add_column_if_not_exists('project_staging_credentials', 'is_active', 'BOOLEAN NOT NULL', 'true');
SELECT add_column_if_not_exists('project_staging_credentials', 'expires_at', 'TIMESTAMP', 'NULL');
SELECT add_column_if_not_exists('project_staging_credentials', 'created_by', 'VARCHAR(255)', '''system''');
SELECT add_column_if_not_exists('project_staging_credentials', 'created_at', 'TIMESTAMP NOT NULL', 'NOW()');
SELECT add_column_if_not_exists('project_staging_credentials', 'updated_at', 'TIMESTAMP NOT NULL', 'NOW()');
SELECT add_column_if_not_exists('project_staging_credentials', 'credentials', 'JSONB', '''{}''');

-- ============================================================================
-- Remaining tables with ALL COLUMNS
-- ============================================================================

-- CLIENT_CREDENTIALS
SELECT add_column_if_not_exists('client_credentials', 'client_id', 'UUID NOT NULL', 'NULL');
SELECT add_column_if_not_exists('client_credentials', 'name', 'VARCHAR(255) NOT NULL', '''Unknown''');
SELECT add_column_if_not_exists('client_credentials', 'username', 'VARCHAR(255)', 'NULL');
SELECT add_column_if_not_exists('client_credentials', 'password', 'TEXT', 'NULL');
SELECT add_column_if_not_exists('client_credentials', 'api_key', 'TEXT', 'NULL');
SELECT add_column_if_not_exists('client_credentials', 'notes', 'TEXT', 'NULL');
SELECT add_column_if_not_exists('client_credentials', 'type', 'VARCHAR(50) NOT NULL', '''other''');
SELECT add_column_if_not_exists('client_credentials', 'created_at', 'TIMESTAMP NOT NULL', 'NOW()');
SELECT add_column_if_not_exists('client_credentials', 'updated_at', 'TIMESTAMP NOT NULL', 'NOW()');

-- CLIENT_FILES
SELECT add_column_if_not_exists('client_files', 'client_id', 'UUID NOT NULL', 'NULL');
SELECT add_column_if_not_exists('client_files', 'filename', 'VARCHAR(255) NOT NULL', '''unknown''');
SELECT add_column_if_not_exists('client_files', 'original_name', 'VARCHAR(255) NOT NULL', '''unknown''');
SELECT add_column_if_not_exists('client_files', 'category', 'VARCHAR(50) NOT NULL', '''other''');
SELECT add_column_if_not_exists('client_files', 'file_path', 'VARCHAR(500) NOT NULL', '''unknown''');
SELECT add_column_if_not_exists('client_files', 'file_size', 'NUMERIC(15,0) NOT NULL', '0');
SELECT add_column_if_not_exists('client_files', 'mime_type', 'VARCHAR(100) NOT NULL', '''application/octet-stream''');
SELECT add_column_if_not_exists('client_files', 'is_encrypted', 'BOOLEAN NOT NULL', 'false');
SELECT add_column_if_not_exists('client_files', 'uploaded_by', 'VARCHAR(255) NOT NULL', '''system''');
SELECT add_column_if_not_exists('client_files', 'uploaded_at', 'TIMESTAMP NOT NULL', 'NOW()');
SELECT add_column_if_not_exists('client_files', 'access_level', 'VARCHAR(20) NOT NULL', '''public''');
SELECT add_column_if_not_exists('client_files', 'metadata', 'TEXT', 'NULL');

-- PROJECT_DOCUMENTS
SELECT add_column_if_not_exists('project_documents', 'project_id', 'UUID NOT NULL', 'NULL');
SELECT add_column_if_not_exists('project_documents', 'name', 'VARCHAR(255) NOT NULL', '''Unknown''');
SELECT add_column_if_not_exists('project_documents', 'type', 'document_type NOT NULL', '''other''');
SELECT add_column_if_not_exists('project_documents', 'file_path', 'VARCHAR(500) NOT NULL', '''unknown''');
SELECT add_column_if_not_exists('project_documents', 'uploaded_by', 'VARCHAR(255) NOT NULL', '''system''');
SELECT add_column_if_not_exists('project_documents', 'uploaded_at', 'TIMESTAMP NOT NULL', 'NOW()');
SELECT add_column_if_not_exists('project_documents', 'version', 'VARCHAR(50) NOT NULL', '''1.0''');
SELECT add_column_if_not_exists('project_documents', 'is_latest', 'BOOLEAN NOT NULL', 'true');
SELECT add_column_if_not_exists('project_documents', 'tags', 'TEXT[] NOT NULL', '''{}''');
SELECT add_column_if_not_exists('project_documents', 'file_size', 'NUMERIC(15,0) NOT NULL', '0');
SELECT add_column_if_not_exists('project_documents', 'mime_type', 'VARCHAR(100) NOT NULL', '''application/octet-stream''');

-- PROJECT_ACTIVITIES
SELECT add_column_if_not_exists('project_activities', 'project_id', 'UUID NOT NULL', 'NULL');
SELECT add_column_if_not_exists('project_activities', 'user_id', 'VARCHAR(255) NOT NULL', '''system''');
SELECT add_column_if_not_exists('project_activities', 'user_name', 'VARCHAR(255) NOT NULL', '''System''');
SELECT add_column_if_not_exists('project_activities', 'action', 'activity_action NOT NULL', '''created''');
SELECT add_column_if_not_exists('project_activities', 'description', 'TEXT NOT NULL', '''No description''');
SELECT add_column_if_not_exists('project_activities', 'metadata', 'TEXT', 'NULL');
SELECT add_column_if_not_exists('project_activities', 'timestamp', 'TIMESTAMP NOT NULL', 'NOW()');

-- PROJECT_DEVELOPERS
SELECT add_column_if_not_exists('project_developers', 'project_id', 'UUID NOT NULL', 'NULL');
SELECT add_column_if_not_exists('project_developers', 'developer_id', 'VARCHAR(255) NOT NULL', '''unknown''');
SELECT add_column_if_not_exists('project_developers', 'role', 'developer_role NOT NULL', '''developer''');
SELECT add_column_if_not_exists('project_developers', 'responsibilities', 'TEXT[] NOT NULL', '''{}''');
SELECT add_column_if_not_exists('project_developers', 'assigned_at', 'TIMESTAMP NOT NULL', 'NOW()');
SELECT add_column_if_not_exists('project_developers', 'assigned_by', 'VARCHAR(255) NOT NULL', '''system''');
SELECT add_column_if_not_exists('project_developers', 'is_active', 'BOOLEAN NOT NULL', 'true');
SELECT add_column_if_not_exists('project_developers', 'hourly_rate', 'NUMERIC(8,2)', 'NULL');
SELECT add_column_if_not_exists('project_developers', 'max_hours_per_week', 'INTEGER', 'NULL');

-- PROJECT_MILESTONES
SELECT add_column_if_not_exists('project_milestones', 'project_id', 'UUID NOT NULL', 'NULL');
SELECT add_column_if_not_exists('project_milestones', 'title', 'VARCHAR(255) NOT NULL', '''Untitled''');
SELECT add_column_if_not_exists('project_milestones', 'description', 'TEXT', 'NULL');
SELECT add_column_if_not_exists('project_milestones', 'due_date', 'TIMESTAMP NOT NULL', 'NOW()');
SELECT add_column_if_not_exists('project_milestones', 'completed_date', 'TIMESTAMP', 'NULL');
SELECT add_column_if_not_exists('project_milestones', 'status', 'milestone_status NOT NULL', '''pending''');
SELECT add_column_if_not_exists('project_milestones', 'assigned_to', 'VARCHAR(255)', 'NULL');
SELECT add_column_if_not_exists('project_milestones', 'deliverables', 'TEXT[] NOT NULL', '''{}''');
SELECT add_column_if_not_exists('project_milestones', 'acceptance_criteria', 'TEXT[] NOT NULL', '''{}''');
SELECT add_column_if_not_exists('project_milestones', '"order"', 'INTEGER NOT NULL', '0');
SELECT add_column_if_not_exists('project_milestones', 'wcag_criteria', 'TEXT[]', 'NULL');
SELECT add_column_if_not_exists('project_milestones', 'created_at', 'TIMESTAMP NOT NULL', 'NOW()');
SELECT add_column_if_not_exists('project_milestones', 'updated_at', 'TIMESTAMP NOT NULL', 'NOW()');

-- PROJECT_TIME_ENTRIES
SELECT add_column_if_not_exists('project_time_entries', 'project_id', 'UUID NOT NULL', 'NULL');
SELECT add_column_if_not_exists('project_time_entries', 'developer_id', 'VARCHAR(255) NOT NULL', '''unknown''');
SELECT add_column_if_not_exists('project_time_entries', 'date', 'TIMESTAMP NOT NULL', 'NOW()');
SELECT add_column_if_not_exists('project_time_entries', 'hours', 'NUMERIC(4,2) NOT NULL', '0');
SELECT add_column_if_not_exists('project_time_entries', 'description', 'TEXT NOT NULL', '''No description''');
SELECT add_column_if_not_exists('project_time_entries', 'category', 'time_entry_category NOT NULL', '''development''');
SELECT add_column_if_not_exists('project_time_entries', 'billable', 'BOOLEAN NOT NULL', 'true');
SELECT add_column_if_not_exists('project_time_entries', 'approved', 'BOOLEAN NOT NULL', 'false');
SELECT add_column_if_not_exists('project_time_entries', 'approved_by', 'VARCHAR(255)', 'NULL');
SELECT add_column_if_not_exists('project_time_entries', 'approved_at', 'TIMESTAMP', 'NULL');
SELECT add_column_if_not_exists('project_time_entries', 'created_at', 'TIMESTAMP NOT NULL', 'NOW()');

-- SYNC_LOGS
SELECT add_column_if_not_exists('sync_logs', 'project_id', 'UUID NOT NULL', 'NULL');
SELECT add_column_if_not_exists('sync_logs', 'sheet_id', 'TEXT', 'NULL');
SELECT add_column_if_not_exists('sync_logs', 'sync_type', 'TEXT NOT NULL', '''unknown''');
SELECT add_column_if_not_exists('sync_logs', 'status', 'TEXT NOT NULL', '''unknown''');
SELECT add_column_if_not_exists('sync_logs', 'rows_processed', 'TEXT', 'NULL');
SELECT add_column_if_not_exists('sync_logs', 'rows_inserted', 'TEXT', 'NULL');
SELECT add_column_if_not_exists('sync_logs', 'rows_updated', 'TEXT', 'NULL');
SELECT add_column_if_not_exists('sync_logs', 'rows_skipped', 'TEXT', 'NULL');
SELECT add_column_if_not_exists('sync_logs', 'rows_failed', 'TEXT', 'NULL');
SELECT add_column_if_not_exists('sync_logs', 'error_message', 'TEXT', 'NULL');
SELECT add_column_if_not_exists('sync_logs', 'error_type', 'TEXT', 'NULL');
SELECT add_column_if_not_exists('sync_logs', 'structure_mismatch_details', 'TEXT', 'NULL');
SELECT add_column_if_not_exists('sync_logs', 'started_at', 'TIMESTAMP NOT NULL', 'NOW()');
SELECT add_column_if_not_exists('sync_logs', 'completed_at', 'TIMESTAMP', 'NULL');
SELECT add_column_if_not_exists('sync_logs', 'created_at', 'TIMESTAMP NOT NULL', 'NOW()');

-- PROJECT_SYNC_STATUS (all columns)
SELECT add_column_if_not_exists('project_sync_status', 'project_id', 'UUID NOT NULL', 'NULL');
SELECT add_column_if_not_exists('project_sync_status', 'sheet_id', 'VARCHAR(255) NOT NULL', '''unknown''');
SELECT add_column_if_not_exists('project_sync_status', 'sync_type', 'VARCHAR(50) NOT NULL', '''unknown''');
SELECT add_column_if_not_exists('project_sync_status', 'sync_status', 'VARCHAR(20) NOT NULL', '''unknown''');
SELECT add_column_if_not_exists('project_sync_status', 'started_at', 'TIMESTAMP NOT NULL', 'NOW()');
SELECT add_column_if_not_exists('project_sync_status', 'completed_at', 'TIMESTAMP', 'NULL');
SELECT add_column_if_not_exists('project_sync_status', 'duration_ms', 'INTEGER', 'NULL');
SELECT add_column_if_not_exists('project_sync_status', 'total_rows_processed', 'INTEGER', '0');
SELECT add_column_if_not_exists('project_sync_status', 'rows_inserted', 'INTEGER', '0');
SELECT add_column_if_not_exists('project_sync_status', 'rows_updated', 'INTEGER', '0');
SELECT add_column_if_not_exists('project_sync_status', 'rows_skipped', 'INTEGER', '0');
SELECT add_column_if_not_exists('project_sync_status', 'rows_failed', 'INTEGER', '0');
SELECT add_column_if_not_exists('project_sync_status', 'error_type', 'VARCHAR(100)', 'NULL');
SELECT add_column_if_not_exists('project_sync_status', 'error_message', 'TEXT', 'NULL');
SELECT add_column_if_not_exists('project_sync_status', 'error_details', 'JSONB', 'NULL');
SELECT add_column_if_not_exists('project_sync_status', 'sheet_name', 'VARCHAR(255)', 'NULL');
SELECT add_column_if_not_exists('project_sync_status', 'expected_columns', 'TEXT[]', 'NULL');
SELECT add_column_if_not_exists('project_sync_status', 'actual_columns', 'TEXT[]', 'NULL');
SELECT add_column_if_not_exists('project_sync_status', 'structure_match', 'BOOLEAN', 'NULL');
SELECT add_column_if_not_exists('project_sync_status', 'sync_config', 'JSONB', 'NULL');
SELECT add_column_if_not_exists('project_sync_status', 'retry_count', 'INTEGER', '0');
SELECT add_column_if_not_exists('project_sync_status', 'max_retries', 'INTEGER', '3');
SELECT add_column_if_not_exists('project_sync_status', 'sync_version', 'VARCHAR(20)', '''1.0''');
SELECT add_column_if_not_exists('project_sync_status', 'created_by', 'VARCHAR(255)', '''a3s-server''');
SELECT add_column_if_not_exists('project_sync_status', 'created_at', 'TIMESTAMP NOT NULL', 'NOW()');
SELECT add_column_if_not_exists('project_sync_status', 'updated_at', 'TIMESTAMP NOT NULL', 'NOW()');

-- CHECKPOINT_SYNC, STATUS, STATUS_CHECK, ISSUE_COMMENTS, WCAG_URL_CHECK
SELECT add_column_if_not_exists('checkpoint_sync', 'project_id', 'UUID NOT NULL', 'NULL');
SELECT add_column_if_not_exists('checkpoint_sync', 'sheet_id', 'TEXT NOT NULL', '''unknown''');
SELECT add_column_if_not_exists('checkpoint_sync', 'last_synced_row', 'TEXT NOT NULL', '''0''');
SELECT add_column_if_not_exists('checkpoint_sync', 'created_at', 'TIMESTAMP NOT NULL', 'NOW()');
SELECT add_column_if_not_exists('checkpoint_sync', 'updated_at', 'TIMESTAMP NOT NULL', 'NOW()');

SELECT add_column_if_not_exists('status', 'project_id', 'UUID NOT NULL', 'NULL');
SELECT add_column_if_not_exists('status', 'url', 'TEXT NOT NULL', '''unknown''');
SELECT add_column_if_not_exists('status', 'status', 'TEXT', 'NULL');
SELECT add_column_if_not_exists('status', 'notes', 'TEXT', 'NULL');
SELECT add_column_if_not_exists('status', 'page_title', 'TEXT', 'NULL');
SELECT add_column_if_not_exists('status', 'url_category', 'TEXT', 'NULL');
SELECT add_column_if_not_exists('status', 'testing_month', 'TEXT', 'NULL');
SELECT add_column_if_not_exists('status', 'testing_year', 'TEXT', 'NULL');
SELECT add_column_if_not_exists('status', 'remediation_month', 'TEXT', 'NULL');
SELECT add_column_if_not_exists('status', 'automated_tools', 'TEXT', 'NULL');
SELECT add_column_if_not_exists('status', 'nvda_chrome', 'TEXT', 'NULL');
SELECT add_column_if_not_exists('status', 'voiceover_iphone_safari', 'TEXT', 'NULL');
SELECT add_column_if_not_exists('status', 'color_contrast', 'TEXT', 'NULL');
SELECT add_column_if_not_exists('status', 'is_active', 'TEXT', 'NULL');
SELECT add_column_if_not_exists('status', 'created_at', 'TIMESTAMP NOT NULL', 'NOW()');
SELECT add_column_if_not_exists('status', 'updated_at', 'TIMESTAMP NOT NULL', 'NOW()');

SELECT add_column_if_not_exists('status_check', 'project_id', 'UUID NOT NULL', 'NULL');
SELECT add_column_if_not_exists('status_check', 'test_scenario', 'TEXT', 'NULL');
SELECT add_column_if_not_exists('status_check', 'url', 'TEXT', 'NULL');
SELECT add_column_if_not_exists('status_check', 'status', 'TEXT', 'NULL');
SELECT add_column_if_not_exists('status_check', 'notes', 'TEXT', 'NULL');
SELECT add_column_if_not_exists('status_check', 'created_at', 'TIMESTAMP NOT NULL', 'NOW()');
SELECT add_column_if_not_exists('status_check', 'updated_at', 'TIMESTAMP NOT NULL', 'NOW()');

SELECT add_column_if_not_exists('issue_comments', 'issue_id', 'UUID NOT NULL', 'NULL');
SELECT add_column_if_not_exists('issue_comments', 'comment_text', 'TEXT NOT NULL', '''No comment''');
SELECT add_column_if_not_exists('issue_comments', 'comment_type', 'comment_type', '''general''');
SELECT add_column_if_not_exists('issue_comments', 'author_name', 'VARCHAR(255)', 'NULL');
SELECT add_column_if_not_exists('issue_comments', 'author_role', 'author_role', 'NULL');
SELECT add_column_if_not_exists('issue_comments', 'created_at', 'TIMESTAMP NOT NULL', 'NOW()');
SELECT add_column_if_not_exists('issue_comments', 'updated_at', 'TIMESTAMP NOT NULL', 'NOW()');

SELECT add_column_if_not_exists('wcag_url_check', 'project_id', 'UUID NOT NULL', 'NULL');
SELECT add_column_if_not_exists('wcag_url_check', 'test_scenario', 'TEXT', 'NULL');
SELECT add_column_if_not_exists('wcag_url_check', 'created_at', 'TIMESTAMP NOT NULL', 'NOW()');
SELECT add_column_if_not_exists('wcag_url_check', 'updated_at', 'TIMESTAMP NOT NULL', 'NOW()');
-- WCAG Criteria Columns (Principle 1: Perceivable)
SELECT add_column_if_not_exists('wcag_url_check', '_111_non_text_content_a', 'TEXT', 'NULL');
SELECT add_column_if_not_exists('wcag_url_check', '_121_audio_only_and_video_only_prerecorded_a', 'TEXT', 'NULL');
SELECT add_column_if_not_exists('wcag_url_check', '_122_captions_prerecorded_a', 'TEXT', 'NULL');
SELECT add_column_if_not_exists('wcag_url_check', '_123_audio_description_or_media_alternative_prerecorded_a', 'TEXT', 'NULL');
SELECT add_column_if_not_exists('wcag_url_check', '_124_captions_live_aa', 'TEXT', 'NULL');
SELECT add_column_if_not_exists('wcag_url_check', '_125_audio_description_prerecorded_aa', 'TEXT', 'NULL');
SELECT add_column_if_not_exists('wcag_url_check', '_131_info_and_relationships_a', 'TEXT', 'NULL');
SELECT add_column_if_not_exists('wcag_url_check', '_132_meaningful_sequence_a', 'TEXT', 'NULL');
SELECT add_column_if_not_exists('wcag_url_check', '_133_sensory_characteristics_a', 'TEXT', 'NULL');
SELECT add_column_if_not_exists('wcag_url_check', '_134_orientation_aa', 'TEXT', 'NULL');
SELECT add_column_if_not_exists('wcag_url_check', '_135_identify_input_purpose_aa', 'TEXT', 'NULL');
SELECT add_column_if_not_exists('wcag_url_check', '_141_use_of_color_a', 'TEXT', 'NULL');
SELECT add_column_if_not_exists('wcag_url_check', '_142_audio_control_a', 'TEXT', 'NULL');
SELECT add_column_if_not_exists('wcag_url_check', '_143_contrast_minimum_aa', 'TEXT', 'NULL');
SELECT add_column_if_not_exists('wcag_url_check', '_144_resize_text_aa', 'TEXT', 'NULL');
SELECT add_column_if_not_exists('wcag_url_check', '_145_images_of_text_aa', 'TEXT', 'NULL');
SELECT add_column_if_not_exists('wcag_url_check', '_1410_reflow_aa', 'TEXT', 'NULL');
SELECT add_column_if_not_exists('wcag_url_check', '_1411_non_text_contrast_aa', 'TEXT', 'NULL');
SELECT add_column_if_not_exists('wcag_url_check', '_1412_text_spacing_aa', 'TEXT', 'NULL');
SELECT add_column_if_not_exists('wcag_url_check', '_1413_content_on_hover_or_focus_aa', 'TEXT', 'NULL');
-- WCAG Criteria Columns (Principle 2: Operable)
SELECT add_column_if_not_exists('wcag_url_check', '_211_keyboard_a', 'TEXT', 'NULL');
SELECT add_column_if_not_exists('wcag_url_check', '_212_no_keyboard_trap_a', 'TEXT', 'NULL');
SELECT add_column_if_not_exists('wcag_url_check', '_214_character_key_shortcuts_a', 'TEXT', 'NULL');
SELECT add_column_if_not_exists('wcag_url_check', '_221_timing_adjustable_a', 'TEXT', 'NULL');
SELECT add_column_if_not_exists('wcag_url_check', '_222_pause_stop_hide_a', 'TEXT', 'NULL');
SELECT add_column_if_not_exists('wcag_url_check', '_223_no_timing_a', 'TEXT', 'NULL');
SELECT add_column_if_not_exists('wcag_url_check', '_224_interruptions_a', 'TEXT', 'NULL');
SELECT add_column_if_not_exists('wcag_url_check', '_225_reauthentication_aa', 'TEXT', 'NULL');
SELECT add_column_if_not_exists('wcag_url_check', '_231_flash_a', 'TEXT', 'NULL');
SELECT add_column_if_not_exists('wcag_url_check', '_231_three_flashes_or_below_threshold_a', 'TEXT', 'NULL');
SELECT add_column_if_not_exists('wcag_url_check', '_232_three_flashes_aa', 'TEXT', 'NULL');
SELECT add_column_if_not_exists('wcag_url_check', '_233_no_flash_aa', 'TEXT', 'NULL');
SELECT add_column_if_not_exists('wcag_url_check', '_241_bypass_blocks_a', 'TEXT', 'NULL');
SELECT add_column_if_not_exists('wcag_url_check', '_242_page_titled_a', 'TEXT', 'NULL');
SELECT add_column_if_not_exists('wcag_url_check', '_243_focus_order_a', 'TEXT', 'NULL');
SELECT add_column_if_not_exists('wcag_url_check', '_244_link_purpose_in_context_a', 'TEXT', 'NULL');
SELECT add_column_if_not_exists('wcag_url_check', '_245_multiple_ways_aa', 'TEXT', 'NULL');
SELECT add_column_if_not_exists('wcag_url_check', '_246_headings_and_labels_aa', 'TEXT', 'NULL');
SELECT add_column_if_not_exists('wcag_url_check', '_247_focus_visible_aa', 'TEXT', 'NULL');
SELECT add_column_if_not_exists('wcag_url_check', '_2411_focus_not_obscured_minimum_aa', 'TEXT', 'NULL');
SELECT add_column_if_not_exists('wcag_url_check', '_251_focus_visible_aa', 'TEXT', 'NULL');
SELECT add_column_if_not_exists('wcag_url_check', '_251_pointer_gestures_a', 'TEXT', 'NULL');
SELECT add_column_if_not_exists('wcag_url_check', '_252_no_keyboard_trap_a', 'TEXT', 'NULL');
SELECT add_column_if_not_exists('wcag_url_check', '_252_pointer_cancellation_a', 'TEXT', 'NULL');
SELECT add_column_if_not_exists('wcag_url_check', '_253_focus_not_obscured_aa', 'TEXT', 'NULL');
SELECT add_column_if_not_exists('wcag_url_check', '_253_label_in_name_a', 'TEXT', 'NULL');
SELECT add_column_if_not_exists('wcag_url_check', '_254_focus_not_obscured_enhanced_aaa', 'TEXT', 'NULL');
SELECT add_column_if_not_exists('wcag_url_check', '_254_motion_actuation_a', 'TEXT', 'NULL');
SELECT add_column_if_not_exists('wcag_url_check', '_255_target_size_aa', 'TEXT', 'NULL');
SELECT add_column_if_not_exists('wcag_url_check', '_256_mechanism_to_abort_a', 'TEXT', 'NULL');
SELECT add_column_if_not_exists('wcag_url_check', '_257_dragging_movements_aa', 'TEXT', 'NULL');
SELECT add_column_if_not_exists('wcag_url_check', '_257_mechanism_to_pause_a', 'TEXT', 'NULL');
SELECT add_column_if_not_exists('wcag_url_check', '_258_mechanism_to_stop_a', 'TEXT', 'NULL');
SELECT add_column_if_not_exists('wcag_url_check', '_258_target_size_minimum_aa', 'TEXT', 'NULL');
SELECT add_column_if_not_exists('wcag_url_check', '_259_mechanism_to_reset_a', 'TEXT', 'NULL');
-- WCAG Criteria Columns (Principle 3: Understandable)
SELECT add_column_if_not_exists('wcag_url_check', '_261_language_of_page_a', 'TEXT', 'NULL');
SELECT add_column_if_not_exists('wcag_url_check', '_262_language_of_parts_aa', 'TEXT', 'NULL');
SELECT add_column_if_not_exists('wcag_url_check', '_263_language_of_parts_enhanced_aaa', 'TEXT', 'NULL');
SELECT add_column_if_not_exists('wcag_url_check', '_264_language_of_parts_enhanced_aaa', 'TEXT', 'NULL');
SELECT add_column_if_not_exists('wcag_url_check', '_271_on_focus_a', 'TEXT', 'NULL');
SELECT add_column_if_not_exists('wcag_url_check', '_272_on_input_a', 'TEXT', 'NULL');
SELECT add_column_if_not_exists('wcag_url_check', '_273_identify_purpose_aaa', 'TEXT', 'NULL');
SELECT add_column_if_not_exists('wcag_url_check', '_274_identify_purpose_enhanced_aaa', 'TEXT', 'NULL');
SELECT add_column_if_not_exists('wcag_url_check', '_275_identify_purpose_enhanced_aaa', 'TEXT', 'NULL');
SELECT add_column_if_not_exists('wcag_url_check', '_276_identify_purpose_enhanced_aaa', 'TEXT', 'NULL');
SELECT add_column_if_not_exists('wcag_url_check', '_277_identify_purpose_enhanced_aaa', 'TEXT', 'NULL');
SELECT add_column_if_not_exists('wcag_url_check', '_278_identify_purpose_enhanced_aaa', 'TEXT', 'NULL');
SELECT add_column_if_not_exists('wcag_url_check', '_279_identify_purpose_enhanced_aaa', 'TEXT', 'NULL');
SELECT add_column_if_not_exists('wcag_url_check', '_280_identify_purpose_enhanced_aaa', 'TEXT', 'NULL');
SELECT add_column_if_not_exists('wcag_url_check', '_281_identify_purpose_enhanced_aaa', 'TEXT', 'NULL');
SELECT add_column_if_not_exists('wcag_url_check', '_282_identify_purpose_enhanced_aaa', 'TEXT', 'NULL');
SELECT add_column_if_not_exists('wcag_url_check', '_283_identify_purpose_enhanced_aaa', 'TEXT', 'NULL');
SELECT add_column_if_not_exists('wcag_url_check', '_284_identify_purpose_enhanced_aaa', 'TEXT', 'NULL');
SELECT add_column_if_not_exists('wcag_url_check', '_285_identify_purpose_enhanced_aaa', 'TEXT', 'NULL');
SELECT add_column_if_not_exists('wcag_url_check', '_286_identify_purpose_enhanced_aaa', 'TEXT', 'NULL');
SELECT add_column_if_not_exists('wcag_url_check', '_287_identify_purpose_enhanced_aaa', 'TEXT', 'NULL');
SELECT add_column_if_not_exists('wcag_url_check', '_288_identify_purpose_enhanced_aaa', 'TEXT', 'NULL');
SELECT add_column_if_not_exists('wcag_url_check', '_289_identify_purpose_enhanced_aaa', 'TEXT', 'NULL');
SELECT add_column_if_not_exists('wcag_url_check', '_290_identify_purpose_enhanced_aaa', 'TEXT', 'NULL');
SELECT add_column_if_not_exists('wcag_url_check', '_291_identify_purpose_enhanced_aaa', 'TEXT', 'NULL');
SELECT add_column_if_not_exists('wcag_url_check', '_292_identify_purpose_enhanced_aaa', 'TEXT', 'NULL');
SELECT add_column_if_not_exists('wcag_url_check', '_293_identify_purpose_enhanced_aaa', 'TEXT', 'NULL');
SELECT add_column_if_not_exists('wcag_url_check', '_294_identify_purpose_enhanced_aaa', 'TEXT', 'NULL');
SELECT add_column_if_not_exists('wcag_url_check', '_295_identify_purpose_enhanced_aaa', 'TEXT', 'NULL');
SELECT add_column_if_not_exists('wcag_url_check', '_296_identify_purpose_enhanced_aaa', 'TEXT', 'NULL');
SELECT add_column_if_not_exists('wcag_url_check', '_297_identify_purpose_enhanced_aaa', 'TEXT', 'NULL');
SELECT add_column_if_not_exists('wcag_url_check', '_298_identify_purpose_enhanced_aaa', 'TEXT', 'NULL');
SELECT add_column_if_not_exists('wcag_url_check', '_299_identify_purpose_enhanced_aaa', 'TEXT', 'NULL');
SELECT add_column_if_not_exists('wcag_url_check', '_300_identify_purpose_enhanced_aaa', 'TEXT', 'NULL');
SELECT add_column_if_not_exists('wcag_url_check', '_311_language_of_page_a', 'TEXT', 'NULL');
SELECT add_column_if_not_exists('wcag_url_check', '_312_language_of_parts_aa', 'TEXT', 'NULL');
SELECT add_column_if_not_exists('wcag_url_check', '_321_on_focus_a', 'TEXT', 'NULL');
SELECT add_column_if_not_exists('wcag_url_check', '_322_on_input_a', 'TEXT', 'NULL');
SELECT add_column_if_not_exists('wcag_url_check', '_323_consistent_navigation_aa', 'TEXT', 'NULL');
SELECT add_column_if_not_exists('wcag_url_check', '_324_consistent_identification_aa', 'TEXT', 'NULL');
SELECT add_column_if_not_exists('wcag_url_check', '_326_consistent_help_aa', 'TEXT', 'NULL');
SELECT add_column_if_not_exists('wcag_url_check', '_331_error_identification_a', 'TEXT', 'NULL');
SELECT add_column_if_not_exists('wcag_url_check', '_332_labels_or_instructions_a', 'TEXT', 'NULL');
SELECT add_column_if_not_exists('wcag_url_check', '_333_error_suggestion_aa', 'TEXT', 'NULL');
SELECT add_column_if_not_exists('wcag_url_check', '_334_error_prevention_legal_financial_data_aa', 'TEXT', 'NULL');
SELECT add_column_if_not_exists('wcag_url_check', '_337_redundant_entry_a', 'TEXT', 'NULL');
SELECT add_column_if_not_exists('wcag_url_check', '_338_accessible_authentication_minimum_aa', 'TEXT', 'NULL');
-- WCAG Criteria Columns (Principle 4: Robust)
SELECT add_column_if_not_exists('wcag_url_check', '_411_parsing_aa', 'TEXT', 'NULL');
SELECT add_column_if_not_exists('wcag_url_check', '_412_name_role_value_a', 'TEXT', 'NULL');
SELECT add_column_if_not_exists('wcag_url_check', '_413_status_messages_aa', 'TEXT', 'NULL');

-- ISSUES (legacy) - all columns
SELECT add_column_if_not_exists('issues', 'project_id', 'UUID NOT NULL', 'NULL');
SELECT add_column_if_not_exists('issues', 'sheet_name', 'TEXT', '''unknown''');
SELECT add_column_if_not_exists('issues', 'url', 'TEXT', 'NULL');
SELECT add_column_if_not_exists('issues', 'issue_title', 'TEXT', 'NULL');
SELECT add_column_if_not_exists('issues', 'issue_description', 'TEXT', 'NULL');
SELECT add_column_if_not_exists('issues', 'issue_type', 'TEXT', 'NULL');
SELECT add_column_if_not_exists('issues', 'url_id', 'TEXT', 'NULL');
SELECT add_column_if_not_exists('issues', 'severity', 'TEXT', 'NULL');
SELECT add_column_if_not_exists('issues', 'testing_month', 'TEXT', 'NULL');
SELECT add_column_if_not_exists('issues', 'testing_year', 'TEXT', 'NULL');
SELECT add_column_if_not_exists('issues', 'testing_environment', 'TEXT', 'NULL');
SELECT add_column_if_not_exists('issues', 'dev_status', 'TEXT', 'NULL');
SELECT add_column_if_not_exists('issues', 'wcag', 'TEXT', 'NULL');
SELECT add_column_if_not_exists('issues', 'status', 'TEXT', 'NULL');
SELECT add_column_if_not_exists('issues', 'assignee', 'TEXT', 'NULL');
SELECT add_column_if_not_exists('issues', 'priority', 'TEXT', 'NULL');
SELECT add_column_if_not_exists('issues', 'assigned_to', 'TEXT', 'NULL');
SELECT add_column_if_not_exists('issues', 'due_date', 'TEXT', 'NULL');
SELECT add_column_if_not_exists('issues', 'resolution_notes', 'TEXT', 'NULL');
SELECT add_column_if_not_exists('issues', 'is_resolved', 'TEXT', 'NULL');
SELECT add_column_if_not_exists('issues', 'is_duplicate', 'TEXT', 'NULL');
SELECT add_column_if_not_exists('issues', 'browser', 'TEXT', 'NULL');
SELECT add_column_if_not_exists('issues', 'qa_status', 'TEXT', 'NULL');
SELECT add_column_if_not_exists('issues', 'expected_result', 'TEXT', 'NULL');
SELECT add_column_if_not_exists('issues', 'actual_result', 'TEXT', 'NULL');
SELECT add_column_if_not_exists('issues', 'failed_wcag_criteria', 'TEXT', 'NULL');
SELECT add_column_if_not_exists('issues', 'conformance_level', 'TEXT', 'NULL');
SELECT add_column_if_not_exists('issues', 'screencast_url', 'TEXT', 'NULL');
SELECT add_column_if_not_exists('issues', 'screenshot_urls', 'TEXT', 'NULL');
SELECT add_column_if_not_exists('issues', 'dev_comments', 'TEXT', 'NULL');
SELECT add_column_if_not_exists('issues', 'dev_assigned_to', 'TEXT', 'NULL');
SELECT add_column_if_not_exists('issues', 'qa_comments', 'TEXT', 'NULL');
SELECT add_column_if_not_exists('issues', 'qa_assigned_to', 'TEXT', 'NULL');
SELECT add_column_if_not_exists('issues', 'is_active', 'TEXT', 'NULL');
SELECT add_column_if_not_exists('issues', 'operating_system', 'TEXT', 'NULL');
SELECT add_column_if_not_exists('issues', 'assistive_technology', 'TEXT', 'NULL');
SELECT add_column_if_not_exists('issues', 'notes', 'TEXT', 'NULL');
SELECT add_column_if_not_exists('issues', 'created_at', 'TIMESTAMP NOT NULL', 'NOW()');
SELECT add_column_if_not_exists('issues', 'updated_at', 'TIMESTAMP NOT NULL', 'NOW()');

-- TICKET_ATTACHMENTS, TICKET_COMMENTS
SELECT add_column_if_not_exists('ticket_attachments', 'ticket_id', 'UUID NOT NULL', 'NULL');
SELECT add_column_if_not_exists('ticket_attachments', 'filename', 'VARCHAR(255) NOT NULL', '''unknown''');
SELECT add_column_if_not_exists('ticket_attachments', 'original_name', 'VARCHAR(255) NOT NULL', '''unknown''');
SELECT add_column_if_not_exists('ticket_attachments', 'file_path', 'VARCHAR(500) NOT NULL', '''unknown''');
SELECT add_column_if_not_exists('ticket_attachments', 'file_size', 'NUMERIC(15,0) NOT NULL', '0');
SELECT add_column_if_not_exists('ticket_attachments', 'mime_type', 'VARCHAR(100) NOT NULL', '''application/octet-stream''');
SELECT add_column_if_not_exists('ticket_attachments', 'uploaded_by', 'VARCHAR(255) NOT NULL', '''system''');
SELECT add_column_if_not_exists('ticket_attachments', 'uploaded_at', 'TIMESTAMP NOT NULL', 'NOW()');

SELECT add_column_if_not_exists('ticket_comments', 'ticket_id', 'UUID NOT NULL', 'NULL');
SELECT add_column_if_not_exists('ticket_comments', 'user_id', 'VARCHAR(255) NOT NULL', '''system''');
SELECT add_column_if_not_exists('ticket_comments', 'user_name', 'VARCHAR(255) NOT NULL', '''System''');
SELECT add_column_if_not_exists('ticket_comments', 'comment', 'TEXT NOT NULL', '''No comment''');
SELECT add_column_if_not_exists('ticket_comments', 'is_internal', 'BOOLEAN NOT NULL', 'false');
SELECT add_column_if_not_exists('ticket_comments', 'created_at', 'TIMESTAMP NOT NULL', 'NOW()');
SELECT add_column_if_not_exists('ticket_comments', 'updated_at', 'TIMESTAMP NOT NULL', 'NOW()');

-- ============================================================================
-- CLEANUP
-- ============================================================================
DROP FUNCTION IF EXISTS add_column_if_not_exists(TEXT, TEXT, TEXT, TEXT);

SELECT 'All missing columns have been added!' as status;

