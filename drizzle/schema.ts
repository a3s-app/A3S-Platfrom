/**
 * A3S PLATFORM - CONSOLIDATED DATABASE SCHEMA
 * ============================================
 * 
 * This is the complete, unified Drizzle ORM schema for the A3S Platform.
 * It includes all tables, enums, indexes, and relations used by both:
 *   - A3S Admin Dashboard (a3s-admin)
 *   - A3S Client Portal (a3s-client-portal)
 * 
 * Database: PostgreSQL (via Supabase)
 * ORM: Drizzle ORM
 * 
 * IMPORTANT:
 * - Both applications share this database
 * - `sent_to_user` in accessibility_issues controls client visibility
 * - Each app has separate Clerk authentication
 * 
 * Last Updated: January 2026
 */

import {
  pgTable,
  pgEnum,
  uuid,
  varchar,
  text,
  numeric,
  timestamp,
  boolean,
  integer,
  jsonb,
  index,
  uniqueIndex,
  unique,
  foreignKey,
  check,
} from "drizzle-orm/pg-core";
import { relations, sql } from "drizzle-orm";

// ============================================================================
// SECTION 1: ENUM DEFINITIONS (60 total)
// ============================================================================

// -----------------------------------------------------------------------------
// 1.1 Client & Organization Enums
// -----------------------------------------------------------------------------

export const clientStatus = pgEnum("client_status", [
  "pending", "active", "inactive", "suspended", "archived"
]);

export const clientType = pgEnum("client_type", [
  "a3s", "p15r", "partner"
]);

export const policyStatus = pgEnum("policy_status", [
  "none", "draft", "review", "approved", "has_policy", 
  "needs_review", "needs_creation", "in_progress", "completed"
]);

export const companySize = pgEnum("company_size", [
  "1-10", "11-50", "51-200", "201-1000", "1000+"
]);

export const pricingTier = pgEnum("pricing_tier", [
  "basic", "professional", "enterprise", "custom"
]);

export const paymentMethod = pgEnum("payment_method", [
  "credit_card", "ach", "wire", "check"
]);

export const communicationPreference = pgEnum("communication_preference", [
  "email", "phone", "slack", "teams"
]);

export const timeline = pgEnum("timeline", [
  "immediate", "1-3_months", "3-6_months", "6-12_months", "ongoing"
]);

export const accessibilityLevel = pgEnum("accessibility_level", [
  "none", "basic", "partial", "compliant"
]);

export const reportingFrequency = pgEnum("reporting_frequency", [
  "weekly", "bi-weekly", "monthly", "quarterly"
]);

export const billingFrequency = pgEnum("billing_frequency", [
  "daily", "weekly", "bi-weekly", "monthly", "quarterly", "half-yearly", "yearly"
]);

// -----------------------------------------------------------------------------
// 1.2 Project Enums
// -----------------------------------------------------------------------------

export const projectStatus = pgEnum("project_status", [
  "planning", "active", "on_hold", "completed", "cancelled", "archived"
]);

export const projectPriority = pgEnum("project_priority", [
  "low", "medium", "high", "urgent"
]);

export const projectType = pgEnum("project_type", [
  "audit", "remediation", "monitoring", "training", 
  "consultation", "full_compliance", "a3s_program"
]);

export const projectPlatform = pgEnum("project_platform", [
  "website", "mobile_app", "desktop_app", "web_app", "api", "other"
]);

export const techStack = pgEnum("tech_stack", [
  "wordpress", "react", "vue", "angular", "nextjs", "nuxt",
  "laravel", "django", "rails", "nodejs", "express", "fastapi",
  "spring", "aspnet", "flutter", "react_native", "ionic", "xamarin",
  "electron", "tauri", "wails", "android_native", "ios_native",
  "unity", "unreal", "other"
]);

export const billingType = pgEnum("billing_type", [
  "fixed", "hourly", "milestone"
]);

export const projectWcagLevel = pgEnum("project_wcag_level", [
  "A", "AA", "AAA"
]);

export const clientWcagLevel = pgEnum("client_wcag_level", [
  "A", "AA", "AAA"
]);

// -----------------------------------------------------------------------------
// 1.3 WCAG & Accessibility Enums
// -----------------------------------------------------------------------------

export const conformanceLevel = pgEnum("conformance_level", [
  "A", "AA", "AAA"
]);

export const severity = pgEnum("severity", [
  "1_critical", "2_high", "3_medium", "4_low"
]);

export const issueType = pgEnum("issue_type", [
  "automated_tools", "screen_reader", "keyboard_navigation",
  "color_contrast", "text_spacing", "browser_zoom", "other"
]);

export const devStatus = pgEnum("dev_status", [
  "not_started", "in_progress", "done", "blocked", "3rd_party", "wont_fix"
]);

export const qaStatus = pgEnum("qa_status", [
  "not_started", "in_progress", "fixed", "verified", "failed", "3rd_party"
]);

export const urlCategory = pgEnum("url_category", [
  "home", "content", "form", "admin", "other"
]);

// -----------------------------------------------------------------------------
// 1.4 Ticket Enums
// -----------------------------------------------------------------------------

export const ticketStatus = pgEnum("ticket_status", [
  "open", "in_progress", "resolved", "closed", 
  "needs_attention", "third_party", "fixed"
]);

export const ticketPriority = pgEnum("ticket_priority", [
  "low", "medium", "high", "critical", "urgent"
]);

export const ticketType = pgEnum("ticket_type", [
  "bug", "feature", "task", "accessibility", "improvement"
]);

export const ticketCategory = pgEnum("ticket_category", [
  "technical", "billing", "general", "feature_request", "bug_report", "other"
]);

// -----------------------------------------------------------------------------
// 1.5 Report Enums
// -----------------------------------------------------------------------------

export const reportType = pgEnum("report_type", [
  "executive_summary", "technical_report", "compliance_report",
  "monthly_progress", "custom"
]);

export const reportStatus = pgEnum("report_status", [
  "draft", "generated", "edited", "sent", "archived"
]);

// -----------------------------------------------------------------------------
// 1.6 Team & User Enums
// -----------------------------------------------------------------------------

export const teamType = pgEnum("team_type", [
  "internal", "external"
]);

export const teamStatus = pgEnum("team_status", [
  "active", "inactive", "archived"
]);

export const employeeRole = pgEnum("employee_role", [
  "ceo", "manager", "team_lead", "senior_developer", "developer",
  "junior_developer", "designer", "qa_engineer", "project_manager",
  "business_analyst", "consultant", "contractor"
]);

export const employmentStatus = pgEnum("employment_status", [
  "active", "inactive", "on_leave", "terminated"
]);

export const developerRole = pgEnum("developer_role", [
  "project_lead", "senior_developer", "developer",
  "qa_engineer", "accessibility_specialist"
]);

export const userRole = pgEnum("user_role", [
  "viewer", "editor", "admin", "owner"
]);

export const projectRole = pgEnum("project_role", [
  "project_admin", "project_member"
]);

export const invitationStatus = pgEnum("invitation_status", [
  "pending", "sent", "accepted", "expired", "cancelled"
]);

export const department = pgEnum("department", [
  "executive", "development", "design", "quality_assurance",
  "project_management", "accessibility", "consulting", "operations"
]);

export const memberRole = pgEnum("member_role", [
  "developer", "ceo", "team_lead", "senior_developer", "designer",
  "qa_engineer", "project_manager", "accessibility_specialist",
  "consultant", "intern"
]);

export const memberStatus = pgEnum("member_status", [
  "active", "inactive", "on_leave", "terminated"
]);

// -----------------------------------------------------------------------------
// 1.7 Document Enums
// -----------------------------------------------------------------------------

export const documentType = pgEnum("document_type", [
  "audit_report", "remediation_plan", "test_results", "compliance_certificate",
  "meeting_notes", "vpat", "accessibility_summary", "legal_response",
  "monthly_monitoring", "custom", "other"
]);

export const documentStatus = pgEnum("document_status", [
  "draft", "pending_review", "certified", "active", "archived"
]);

export const documentRequestStatus = pgEnum("document_request_status", [
  "pending", "in_progress", "completed", "rejected"
]);

export const documentPriority = pgEnum("document_priority", [
  "low", "medium", "high", "critical"
]);

export const remediationType = pgEnum("remediation_type", [
  "traditional_pdf", "html_alternative"
]);

export const remediationStatus = pgEnum("remediation_status", [
  "pending_review", "approved", "in_progress", "completed", "rejected"
]);

// -----------------------------------------------------------------------------
// 1.8 Notification Enums
// -----------------------------------------------------------------------------

export const notificationType = pgEnum("notification_type", [
  "system", "project_update", "document_ready", "document_approved",
  "document_rejected", "report_ready", "team_invite", "ticket_update",
  "evidence_update", "billing", "reminder"
]);

export const notificationPriority = pgEnum("notification_priority", [
  "low", "normal", "high", "urgent"
]);

export const adminNotificationType = pgEnum("admin_notification_type", [
  "system", "new_ticket", "new_remediation_request",
  "new_document_request", "client_signup", "custom"
]);

// -----------------------------------------------------------------------------
// 1.9 Other Enums
// -----------------------------------------------------------------------------

export const activityAction = pgEnum("activity_action", [
  "created", "updated", "milestone_completed", "developer_assigned",
  "status_changed", "document_uploaded", "time_logged", "staging_credentials_updated"
]);

export const milestoneStatus = pgEnum("milestone_status", [
  "pending", "in_progress", "completed", "overdue"
]);

export const timeEntryCategory = pgEnum("time_entry_category", [
  "development", "testing", "review", "meeting", "documentation", "research"
]);

export const credentialType = pgEnum("credential_type", [
  "staging", "production", "development", "testing", "wordpress", "httpauth",
  "sftp", "database", "app_store", "play_store", "firebase", "aws", "azure",
  "gcp", "heroku", "vercel", "netlify", "github", "gitlab", "bitbucket",
  "docker", "kubernetes", "cms", "api_key", "oauth", "ssh_key",
  "ssl_certificate", "cdn", "analytics", "monitoring", "other"
]);

export const commentType = pgEnum("comment_type", [
  "general", "dev_update", "qa_feedback", "technical_note", "resolution"
]);

export const authorRole = pgEnum("author_role", [
  "developer", "qa_tester", "accessibility_expert", "project_manager", "client"
]);

export const billingAddonType = pgEnum("billing_addon_type", [
  "team_members", "document_remediation", "evidence_locker", "custom"
]);

export const billingAddonStatus = pgEnum("billing_addon_status", [
  "active", "cancelled", "pending"
]);

export const messageSenderType = pgEnum("message_sender_type", [
  "admin", "client"
]);

// ============================================================================
// SECTION 2: CORE TABLES (SHARED)
// ============================================================================

// -----------------------------------------------------------------------------
// 2.1 Clients Table
// -----------------------------------------------------------------------------

export const clients = pgTable("clients", {
  id: uuid("id").primaryKey().defaultRandom(),
  name: varchar("name", { length: 255 }).notNull(),
  email: varchar("email", { length: 255 }).notNull().unique(),
  company: varchar("company", { length: 255 }).notNull(),
  phone: varchar("phone", { length: 50 }),
  address: text("address"),
  billingAmount: numeric("billing_amount", { precision: 10, scale: 2 }).notNull(),
  billingStartDate: timestamp("billing_start_date").notNull(),
  billingFrequency: billingFrequency("billing_frequency").notNull(),
  status: clientStatus("status").notNull().default("pending"),
  clientType: clientType("client_type").notNull().default("a3s"),
  companySize: companySize("company_size"),
  industry: varchar("industry", { length: 100 }),
  website: varchar("website", { length: 500 }),
  currentAccessibilityLevel: accessibilityLevel("current_accessibility_level"),
  complianceDeadline: timestamp("compliance_deadline"),
  pricingTier: pricingTier("pricing_tier"),
  paymentMethod: paymentMethod("payment_method"),
  servicesNeeded: text("services_needed").array(),
  wcagLevel: clientWcagLevel("wcag_level"),
  priorityAreas: text("priority_areas").array(),
  timeline: timeline("timeline"),
  communicationPreference: communicationPreference("communication_preference"),
  reportingFrequency: reportingFrequency("reporting_frequency"),
  pointOfContact: varchar("point_of_contact", { length: 255 }),
  timeZone: varchar("time_zone", { length: 100 }),
  hasAccessibilityPolicy: boolean("has_accessibility_policy").notNull().default(false),
  accessibilityPolicyUrl: varchar("accessibility_policy_url", { length: 500 }),
  policyStatus: policyStatus("policy_status").notNull().default("none"),
  policyNotes: text("policy_notes"),
  notes: text("notes"),
  clientDocuments: text("client_documents"),
  teamMemberLimit: integer("team_member_limit").notNull().default(5),
  createdAt: timestamp("created_at").notNull().defaultNow(),
  updatedAt: timestamp("updated_at").notNull().defaultNow(),
}, (table) => [
  index("idx_clients_status").on(table.status),
  index("idx_clients_type").on(table.clientType),
  index("idx_clients_email").on(table.email),
  index("clients_policy_status_idx").on(table.policyStatus),
  index("clients_created_at_idx").on(table.createdAt),
]);

// -----------------------------------------------------------------------------
// 2.2 Projects Table
// -----------------------------------------------------------------------------

export const projects = pgTable("projects", {
  id: uuid("id").primaryKey().defaultRandom(),
  clientId: uuid("client_id").references(() => clients.id, { onDelete: "cascade" }),
  name: varchar("name", { length: 255 }).notNull(),
  description: text("description"),
  sheetId: varchar("sheet_id", { length: 255 }),
  status: varchar("status", { length: 50 }).default("planning"),
  priority: varchar("priority", { length: 50 }).default("medium"),
  wcagLevel: varchar("wcag_level", { length: 50 }).default("AA"),
  projectType: varchar("project_type", { length: 50 }),
  projectPlatform: varchar("project_platform", { length: 50 }).notNull().default("website"),
  techStack: varchar("tech_stack", { length: 50 }).notNull().default("other"),
  complianceRequirements: text("compliance_requirements").array().notNull().default([]),
  websiteUrl: varchar("website_url", { length: 500 }),
  testingMethodology: text("testing_methodology").array().notNull().default([]),
  testingSchedule: text("testing_schedule"),
  bugSeverityWorkflow: text("bug_severity_workflow"),
  startDate: timestamp("start_date"),
  endDate: timestamp("end_date"),
  estimatedHours: numeric("estimated_hours", { precision: 8, scale: 2 }),
  actualHours: numeric("actual_hours", { precision: 8, scale: 2 }).default("0"),
  budget: numeric("budget", { precision: 12, scale: 2 }),
  billingType: varchar("billing_type", { length: 50 }).notNull().default("fixed"),
  hourlyRate: numeric("hourly_rate", { precision: 8, scale: 2 }),
  progressPercentage: integer("progress_percentage").notNull().default(0),
  milestonesCompleted: integer("milestones_completed").notNull().default(0),
  totalMilestones: integer("total_milestones").notNull().default(0),
  deliverables: text("deliverables").array().notNull().default([]),
  acceptanceCriteria: text("acceptance_criteria").array().notNull().default([]),
  defaultTestingMonth: varchar("default_testing_month", { length: 20 }),
  defaultTestingYear: integer("default_testing_year"),
  criticalIssueSLADays: integer("critical_issue_sla_days").default(45),
  highIssueSLADays: integer("high_issue_sla_days").default(30),
  syncStatusSummary: jsonb("sync_status_summary").default({}),
  lastSyncDetails: jsonb("last_sync_details").default({}),
  credentials: jsonb("credentials").default([]),
  credentialsBackup: jsonb("credentials_backup"),
  tags: text("tags").array().notNull().default([]),
  notes: text("notes"),
  createdAt: timestamp("created_at").notNull().defaultNow(),
  updatedAt: timestamp("updated_at").notNull().defaultNow(),
  createdBy: varchar("created_by", { length: 255 }).notNull(),
  lastModifiedBy: varchar("last_modified_by", { length: 255 }).notNull(),
}, (table) => [
  index("idx_projects_client_id").on(table.clientId),
  index("idx_projects_status").on(table.status),
  index("idx_projects_sheet_id").on(table.sheetId),
  index("idx_projects_type").on(table.projectType),
  index("idx_projects_wcag_level").on(table.wcagLevel),
  index("idx_projects_created_at").on(table.createdAt),
  index("idx_projects_status_type").on(table.status, table.projectType),
  index("idx_projects_critical_sla").on(table.criticalIssueSLADays),
  index("idx_projects_high_sla").on(table.highIssueSLADays),
]);

// -----------------------------------------------------------------------------
// 2.3 Test URLs Table
// -----------------------------------------------------------------------------

export const testUrls = pgTable("test_urls", {
  id: uuid("id").primaryKey().defaultRandom(),
  projectId: uuid("project_id").notNull().references(() => projects.id, { onDelete: "cascade" }),
  url: varchar("url", { length: 1000 }).notNull(),
  pageTitle: varchar("page_title", { length: 500 }),
  urlCategory: urlCategory("url_category").default("content"),
  testingMonth: varchar("testing_month", { length: 20 }),
  testingYear: integer("testing_year"),
  remediationMonth: varchar("remediation_month", { length: 20 }),
  remediationYear: integer("remediation_year"),
  isActive: boolean("is_active").default(true),
  status: text("status"),
  automatedTools: text("automated_tools"),
  nvdaChrome: text("nvda_chrome"),
  voiceoverIphoneSafari: text("voiceover_iphone_safari"),
  colorContrast: text("color_contrast"),
  browserZoom: text("browser_zoom"),
  keyboardOnly: text("keyboard_only"),
  textSpacing: text("text_spacing"),
  createdAt: timestamp("created_at").notNull().defaultNow(),
  updatedAt: timestamp("updated_at").notNull().defaultNow(),
}, (table) => [
  uniqueIndex("test_urls_project_url_idx").on(table.projectId, table.url),
  index("idx_test_urls_project_id").on(table.projectId),
  index("idx_test_urls_status").on(table.status),
]);

// -----------------------------------------------------------------------------
// 2.4 Accessibility Issues Table (CRITICAL - Most Important Table)
// -----------------------------------------------------------------------------

/**
 * ⚠️ CRITICAL TABLE ⚠️
 * 
 * `sent_to_user` field controls whether an issue is visible to clients in the Portal.
 * - `false` (default): Only visible in Admin Dashboard
 * - `true`: Visible to clients in Client Portal
 * 
 * Always filter by `sent_to_user = true` in Portal queries!
 */
export const accessibilityIssues = pgTable("accessibility_issues", {
  id: uuid("id").primaryKey().defaultRandom(),
  projectId: uuid("project_id").notNull().references(() => projects.id, { onDelete: "cascade" }),
  issueId: text("issue_id").notNull(),
  urlId: uuid("url_id").notNull().references(() => testUrls.id, { onDelete: "cascade" }),
  issueTitle: varchar("issue_title", { length: 500 }).notNull(),
  issueDescription: text("issue_description"),
  issueType: varchar("issue_type", { length: 50 }).notNull(),
  severity: varchar("severity", { length: 50 }).notNull(),
  testingMonth: varchar("testing_month", { length: 20 }),
  testingYear: integer("testing_year"),
  testingEnvironment: varchar("testing_environment", { length: 200 }),
  browser: varchar("browser", { length: 100 }),
  operatingSystem: varchar("operating_system", { length: 100 }),
  assistiveTechnology: varchar("assistive_technology", { length: 100 }),
  expectedResult: text("expected_result").notNull(),
  actualResult: text("actual_result"),
  failedWcagCriteria: text("failed_wcag_criteria").array().default([]),
  conformanceLevel: conformanceLevel("conformance_level"),
  screencastUrl: varchar("screencast_url", { length: 1000 }),
  screenshotUrls: text("screenshot_urls").array().default([]),
  devStatus: varchar("dev_status", { length: 50 }).default("not_started"),
  devComments: text("dev_comments"),
  devAssignedTo: varchar("dev_assigned_to", { length: 255 }),
  qaStatus: varchar("qa_status", { length: 50 }).default("not_started"),
  qaComments: text("qa_comments"),
  qaAssignedTo: varchar("qa_assigned_to", { length: 255 }),
  discoveredAt: timestamp("discovered_at").notNull().defaultNow(),
  devStartedAt: timestamp("dev_started_at"),
  devCompletedAt: timestamp("dev_completed_at"),
  qaStartedAt: timestamp("qa_started_at"),
  qaCompletedAt: timestamp("qa_completed_at"),
  resolvedAt: timestamp("resolved_at"),
  isActive: boolean("is_active").default(true),
  isDuplicate: boolean("is_duplicate").default(false),
  duplicateOfId: uuid("duplicate_of_id"),
  externalTicketId: varchar("external_ticket_id", { length: 255 }),
  externalTicketUrl: varchar("external_ticket_url", { length: 1000 }),
  importBatchId: varchar("import_batch_id", { length: 255 }),
  sourceFileName: varchar("source_file_name", { length: 255 }),
  // ⚠️ CRITICAL: Controls client visibility
  sentToUser: boolean("sent_to_user").default(false),
  sentDate: timestamp("sent_date"),
  sentMonth: varchar("sent_month", { length: 20 }),
  reportId: uuid("report_id"),
  metadata: jsonb("metadata"),
  devStatusUpdatedAt: timestamp("dev_status_updated_at"),
  qaStatusUpdatedAt: timestamp("qa_status_updated_at"),
  sheetName: text("sheet_name"),
  sheetRowNumber: integer("sheet_row_number"),
  createdAt: timestamp("created_at").notNull().defaultNow(),
  updatedAt: timestamp("updated_at").notNull().defaultNow(),
}, (table) => [
  uniqueIndex("unique_project_issue_id").on(table.projectId, table.issueId),
  uniqueIndex("accessibility_issues_project_url_title_unique").on(table.projectId, table.urlId, table.issueTitle),
  index("idx_accessibility_issues_issue_id").on(table.issueId),
  index("accessibility_issues_project_url_idx").on(table.projectId, table.urlId),
  index("accessibility_issues_dev_status_idx").on(table.devStatus),
  index("accessibility_issues_qa_status_idx").on(table.qaStatus),
  index("accessibility_issues_severity_idx").on(table.severity),
  index("accessibility_issues_type_idx").on(table.issueType),
  index("accessibility_issues_sent_to_user_idx").on(table.sentToUser),
  index("accessibility_issues_report_id_idx").on(table.reportId),
  index("idx_issues_project_id").on(table.projectId),
  index("idx_issues_created_at").on(table.createdAt),
  index("idx_issues_is_active").on(table.isActive),
  index("idx_issues_project_severity").on(table.projectId, table.severity),
]);

// -----------------------------------------------------------------------------
// 2.5 Reports Table
// -----------------------------------------------------------------------------

export const reports = pgTable("reports", {
  id: uuid("id").primaryKey().defaultRandom(),
  projectId: uuid("project_id").notNull().references(() => projects.id, { onDelete: "cascade" }),
  title: varchar("title", { length: 255 }).notNull(),
  reportType: reportType("report_type").notNull(),
  reportMonth: varchar("report_month", { length: 20 }),
  reportYear: integer("report_year"),
  aiGeneratedContent: text("ai_generated_content"),
  editedContent: text("edited_content"),
  status: reportStatus("status").notNull().default("draft"),
  sentAt: timestamp("sent_at"),
  sentTo: jsonb("sent_to"),
  emailSubject: varchar("email_subject", { length: 255 }),
  emailBody: text("email_body"),
  pdfPath: varchar("pdf_path", { length: 500 }),
  createdBy: varchar("created_by", { length: 255 }),
  isPublic: boolean("is_public").notNull().default(false),
  publicToken: varchar("public_token", { length: 64 }).unique(),
  createdAt: timestamp("created_at").notNull().defaultNow(),
  updatedAt: timestamp("updated_at").notNull().defaultNow(),
}, (table) => [
  index("idx_reports_project_id").on(table.projectId),
  index("idx_reports_status").on(table.status),
  index("idx_reports_type").on(table.reportType),
  index("idx_reports_created_at").on(table.createdAt),
  index("idx_reports_sent_at").on(table.sentAt),
]);

// -----------------------------------------------------------------------------
// 2.6 Report Issues Junction Table
// -----------------------------------------------------------------------------

export const reportIssues = pgTable("report_issues", {
  id: uuid("id").primaryKey().defaultRandom(),
  reportId: uuid("report_id").notNull().references(() => reports.id, { onDelete: "cascade" }),
  issueId: uuid("issue_id").notNull().references(() => accessibilityIssues.id, { onDelete: "cascade" }),
  includedAt: timestamp("included_at").notNull().defaultNow(),
}, (table) => [
  unique("unique_report_issue").on(table.reportId, table.issueId),
  index("idx_report_issues_report_id").on(table.reportId),
  index("idx_report_issues_issue_id").on(table.issueId),
]);

// -----------------------------------------------------------------------------
// 2.7 Report Comments Table
// -----------------------------------------------------------------------------

export const reportComments = pgTable("report_comments", {
  id: uuid("id").primaryKey().defaultRandom(),
  reportId: uuid("report_id").notNull().references(() => reports.id, { onDelete: "cascade" }),
  comment: text("comment").notNull(),
  commentType: varchar("comment_type", { length: 50 }).notNull().default("general"),
  authorId: varchar("author_id", { length: 255 }),
  authorName: varchar("author_name", { length: 255 }),
  isInternal: boolean("is_internal").notNull().default(true),
  createdAt: timestamp("created_at").notNull().defaultNow(),
}, (table) => [
  index("idx_report_comments_report_id").on(table.reportId),
]);

// -----------------------------------------------------------------------------
// 2.8 Issues Table (LEGACY)
// -----------------------------------------------------------------------------

export const issues = pgTable("issues", {
  id: uuid("id").primaryKey().defaultRandom(),
  projectId: uuid("project_id").notNull().references(() => projects.id),
  sheetName: text("sheet_name").notNull(),
  url: text("url"),
  issueTitle: text("issue_title"),
  issueDescription: text("issue_description"),
  issueType: text("issue_type"),
  urlId: text("url_id"),
  severity: text("severity"),
  testingMonth: text("testing_month"),
  testingYear: text("testing_year"),
  testingEnvironment: text("testing_environment"),
  devStatus: text("dev_status"),
  wcag: text("wcag"),
  status: text("status"),
  assignee: text("assignee"),
  priority: text("priority"),
  assignedTo: text("assigned_to"),
  dueDate: text("due_date"),
  resolutionNotes: text("resolution_notes"),
  isResolved: text("is_resolved"),
  isDuplicate: text("is_duplicate"),
  browser: text("browser"),
  qaStatus: text("qa_status"),
  expectedResult: text("expected_result"),
  actualResult: text("actual_result"),
  failedWcagCriteria: text("failed_wcag_criteria"),
  conformanceLevel: text("conformance_level"),
  screencastUrl: text("screencast_url"),
  screenshotUrls: text("screenshot_urls"),
  devComments: text("dev_comments"),
  devAssignedTo: text("dev_assigned_to"),
  qaComments: text("qa_comments"),
  qaAssignedTo: text("qa_assigned_to"),
  isActive: text("is_active"),
  operatingSystem: text("operating_system"),
  assistiveTechnology: text("assistive_technology"),
  notes: text("notes"),
  createdAt: timestamp("created_at").notNull().defaultNow(),
  updatedAt: timestamp("updated_at").notNull().defaultNow(),
  devStatusUpdatedAt: timestamp("dev_status_updated_at"),
  qaStatusUpdatedAt: timestamp("qa_status_updated_at"),
  metadata: jsonb("metadata"),
  issueLoggedAt: timestamp("issue_logged_at").defaultNow(),
  issueUpdatedAt: timestamp("issue_updated_at"),
}, (table) => [
  unique("issues_project_id_sheet_name_url_issue_title_key").on(
    table.projectId, table.sheetName, table.url, table.issueTitle
  ),
  index("idx_issues_status").on(table.status),
  index("idx_issues_url").on(table.url),
  index("idx_issues_project_url").on(table.projectId, table.url),
]);

// ============================================================================
// SECTION 3: CLIENT PORTAL TABLES
// ============================================================================

// -----------------------------------------------------------------------------
// 3.1 Client Users Table
// -----------------------------------------------------------------------------

export const clientUsers = pgTable("client_users", {
  id: uuid("id").primaryKey().defaultRandom(),
  clerkUserId: varchar("clerk_user_id", { length: 255 }).notNull(),
  clientId: uuid("client_id").notNull().references(() => clients.id, { onDelete: "cascade" }),
  email: varchar("email", { length: 255 }).notNull(),
  firstName: varchar("first_name", { length: 100 }),
  lastName: varchar("last_name", { length: 100 }),
  role: userRole("role").notNull().default("viewer"),
  isActive: boolean("is_active").notNull().default(true),
  emailNotifications: boolean("email_notifications").notNull().default(true),
  lastLoginAt: timestamp("last_login_at"),
  createdAt: timestamp("created_at").notNull().defaultNow(),
  updatedAt: timestamp("updated_at").notNull().defaultNow(),
}, (table) => [
  unique("unique_clerk_client").on(table.clerkUserId, table.clientId),
  index("idx_client_users_clerk_user_id").on(table.clerkUserId),
  index("idx_client_users_client_id").on(table.clientId),
  index("idx_client_users_email").on(table.email),
]);

// -----------------------------------------------------------------------------
// 3.2 Client Team Members Table (Invitations)
// -----------------------------------------------------------------------------

export const clientTeamMembers = pgTable("client_team_members", {
  id: uuid("id").primaryKey().defaultRandom(),
  clientId: uuid("client_id").notNull().references(() => clients.id, { onDelete: "cascade" }),
  name: varchar("name", { length: 255 }).notNull(),
  email: varchar("email", { length: 255 }).notNull(),
  description: text("description"),
  invitationStatus: invitationStatus("invitation_status").notNull().default("pending"),
  invitationSentAt: timestamp("invitation_sent_at"),
  invitationToken: varchar("invitation_token", { length: 255 }),
  clerkInvitationId: varchar("clerk_invitation_id", { length: 255 }),
  invitedByUserId: uuid("invited_by_user_id").references(() => clientUsers.id, { onDelete: "set null" }),
  acceptedAt: timestamp("accepted_at"),
  linkedUserId: uuid("linked_user_id").references(() => clientUsers.id, { onDelete: "set null" }),
  pendingProjectIds: jsonb("pending_project_ids").default([]),
  createdAt: timestamp("created_at").notNull().defaultNow(),
  updatedAt: timestamp("updated_at").notNull().defaultNow(),
}, (table) => [
  unique("unique_client_team_member_email").on(table.clientId, table.email),
  index("idx_client_team_members_client_id").on(table.clientId),
  index("idx_client_team_members_email").on(table.email),
  index("idx_client_team_members_invitation_status").on(table.invitationStatus),
  index("idx_client_team_members_invitation_token").on(table.invitationToken),
]);

// -----------------------------------------------------------------------------
// 3.3 Project Team Members Table
// -----------------------------------------------------------------------------

export const projectTeamMembers = pgTable("project_team_members", {
  id: uuid("id").primaryKey().defaultRandom(),
  projectId: uuid("project_id").notNull().references(() => projects.id, { onDelete: "cascade" }),
  teamMemberId: uuid("team_member_id").notNull().references(() => clientUsers.id, { onDelete: "cascade" }),
  role: projectRole("role").notNull().default("project_member"),
  createdAt: timestamp("created_at").notNull().defaultNow(),
  updatedAt: timestamp("updated_at").notNull().defaultNow(),
}, (table) => [
  unique("unique_project_team_member").on(table.projectId, table.teamMemberId),
  index("idx_project_team_members_project_id").on(table.projectId),
  index("idx_project_team_members_team_member_id").on(table.teamMemberId),
]);

// -----------------------------------------------------------------------------
// 3.4 Client Tickets Table
// -----------------------------------------------------------------------------

export const clientTickets = pgTable("client_tickets", {
  id: uuid("id").primaryKey().defaultRandom(),
  clientId: uuid("client_id").notNull().references(() => clients.id, { onDelete: "cascade" }),
  projectId: uuid("project_id").references(() => projects.id, { onDelete: "set null" }),
  createdByUserId: uuid("created_by_user_id").references(() => clientUsers.id, { onDelete: "set null" }),
  createdBy: uuid("created_by").references(() => clientUsers.id, { onDelete: "set null" }),
  title: varchar("title", { length: 500 }).notNull(),
  description: text("description").notNull(),
  status: ticketStatus("status").notNull().default("needs_attention"),
  priority: ticketPriority("priority").notNull().default("medium"),
  category: varchar("category", { length: 50 }).notNull().default("technical"),
  relatedIssueId: uuid("related_issue_id").references(() => accessibilityIssues.id, { onDelete: "set null" }),
  assignedTo: uuid("assigned_to").references(() => clientUsers.id, { onDelete: "set null" }),
  issuesId: varchar("issues_id", { length: 255 }),
  internalNotes: text("internal_notes"),
  resolution: text("resolution"),
  resolvedAt: timestamp("resolved_at"),
  closedAt: timestamp("closed_at"),
  createdAt: timestamp("created_at").notNull().defaultNow(),
  updatedAt: timestamp("updated_at").notNull().defaultNow(),
}, (table) => [
  index("idx_client_tickets_client_id").on(table.clientId),
  index("idx_client_tickets_project_id").on(table.projectId),
  index("idx_client_tickets_status").on(table.status),
  index("idx_client_tickets_created_at").on(table.createdAt),
  index("idx_client_tickets_created_by_user_id").on(table.createdByUserId),
]);

// -----------------------------------------------------------------------------
// 3.5 Client Ticket Issues Junction Table
// -----------------------------------------------------------------------------

export const clientTicketIssues = pgTable("client_ticket_issues", {
  id: uuid("id").primaryKey().defaultRandom(),
  ticketId: uuid("ticket_id").notNull().references(() => clientTickets.id, { onDelete: "cascade" }),
  issueId: uuid("issue_id").notNull().references(() => accessibilityIssues.id, { onDelete: "cascade" }),
  createdAt: timestamp("created_at").notNull().defaultNow(),
}, (table) => [
  unique("unique_ticket_issue").on(table.ticketId, table.issueId),
  index("idx_client_ticket_issues_ticket_id").on(table.ticketId),
  index("idx_client_ticket_issues_issue_id").on(table.issueId),
]);

// -----------------------------------------------------------------------------
// 3.6 Evidence Documents Table
// -----------------------------------------------------------------------------

export const evidenceDocuments = pgTable("evidence_documents", {
  id: uuid("id").primaryKey().defaultRandom(),
  clientId: uuid("client_id").notNull().references(() => clients.id, { onDelete: "cascade" }),
  projectId: uuid("project_id").references(() => projects.id, { onDelete: "set null" }),
  title: varchar("title", { length: 500 }).notNull(),
  description: text("description"),
  documentType: documentType("document_type").notNull(),
  status: documentStatus("status").notNull().default("draft"),
  priority: documentPriority("priority").notNull().default("medium"),
  wcagCoverage: jsonb("wcag_coverage").default([]),
  fileUrl: varchar("file_url", { length: 1000 }),
  fileName: varchar("file_name", { length: 255 }),
  fileSize: integer("file_size"),
  fileType: varchar("file_type", { length: 50 }),
  version: varchar("version", { length: 50 }).default("1.0"),
  validUntil: timestamp("valid_until"),
  certifiedAt: timestamp("certified_at"),
  certifiedBy: varchar("certified_by", { length: 255 }),
  notes: text("notes"),
  createdBy: varchar("created_by", { length: 255 }),
  createdAt: timestamp("created_at").notNull().defaultNow(),
  updatedAt: timestamp("updated_at").notNull().defaultNow(),
}, (table) => [
  index("idx_evidence_documents_client_id").on(table.clientId),
  index("idx_evidence_documents_project_id").on(table.projectId),
  index("idx_evidence_documents_status").on(table.status),
  index("idx_evidence_documents_document_type").on(table.documentType),
  index("idx_evidence_documents_updated_at").on(table.updatedAt),
]);

// -----------------------------------------------------------------------------
// 3.7 Evidence Document Requests Table
// -----------------------------------------------------------------------------

export const evidenceDocumentRequests = pgTable("evidence_document_requests", {
  id: uuid("id").primaryKey().defaultRandom(),
  clientId: uuid("client_id").notNull().references(() => clients.id, { onDelete: "cascade" }),
  requestedByUserId: uuid("requested_by_user_id").notNull().references(() => clientUsers.id, { onDelete: "cascade" }),
  documentType: documentType("document_type").notNull(),
  title: varchar("title", { length: 500 }).notNull(),
  description: text("description"),
  priority: documentPriority("priority").notNull().default("medium"),
  status: documentRequestStatus("status").notNull().default("pending"),
  adminNotes: text("admin_notes"),
  completedDocumentId: uuid("completed_document_id").references(() => evidenceDocuments.id, { onDelete: "set null" }),
  createdAt: timestamp("created_at").notNull().defaultNow(),
  updatedAt: timestamp("updated_at").notNull().defaultNow(),
}, (table) => [
  index("idx_evidence_document_requests_client_id").on(table.clientId),
  index("idx_evidence_document_requests_requested_by").on(table.requestedByUserId),
  index("idx_evidence_document_requests_status").on(table.status),
  index("idx_evidence_document_requests_created_at").on(table.createdAt),
]);

// -----------------------------------------------------------------------------
// 3.8 Document Remediations Table
// -----------------------------------------------------------------------------

export const documentRemediations = pgTable("document_remediations", {
  id: uuid("id").primaryKey().defaultRandom(),
  clientId: uuid("client_id").notNull().references(() => clients.id, { onDelete: "cascade" }),
  uploadedByUserId: uuid("uploaded_by_user_id").notNull().references(() => clientUsers.id, { onDelete: "cascade" }),
  batchId: varchar("batch_id", { length: 100 }),
  originalFileName: varchar("original_file_name", { length: 500 }).notNull(),
  originalFileUrl: varchar("original_file_url", { length: 1000 }).notNull(),
  originalFileSize: integer("original_file_size"),
  originalFileType: varchar("original_file_type", { length: 50 }),
  pageCount: integer("page_count").notNull().default(1),
  remediationType: remediationType("remediation_type").notNull(),
  status: remediationStatus("status").notNull().default("pending_review"),
  pricePerPage: numeric("price_per_page", { precision: 10, scale: 2 }).notNull(),
  totalPrice: numeric("total_price", { precision: 10, scale: 2 }).notNull(),
  priceAdjusted: boolean("price_adjusted").default(false),
  originalPricePerPage: numeric("original_price_per_page", { precision: 10, scale: 2 }),
  originalTotalPrice: numeric("original_total_price", { precision: 10, scale: 2 }),
  remediatedFileName: varchar("remediated_file_name", { length: 500 }),
  remediatedFileUrl: varchar("remediated_file_url", { length: 1000 }),
  remediatedFileSize: integer("remediated_file_size"),
  remediatedFileType: varchar("remediated_file_type", { length: 50 }),
  notes: text("notes"),
  adminNotes: text("admin_notes"),
  reviewedByUserId: uuid("reviewed_by_user_id"),
  reviewedAt: timestamp("reviewed_at"),
  rejectionReason: text("rejection_reason"),
  completedAt: timestamp("completed_at"),
  createdAt: timestamp("created_at").notNull().defaultNow(),
  updatedAt: timestamp("updated_at").notNull().defaultNow(),
}, (table) => [
  index("idx_document_remediations_client_id").on(table.clientId),
  index("idx_document_remediations_uploaded_by").on(table.uploadedByUserId),
  index("idx_document_remediations_status").on(table.status),
  index("idx_document_remediations_batch_id").on(table.batchId),
  index("idx_document_remediations_created_at").on(table.createdAt),
]);

// -----------------------------------------------------------------------------
// 3.9 Client Billing Add-ons Table
// -----------------------------------------------------------------------------

export const clientBillingAddons = pgTable("client_billing_addons", {
  id: uuid("id").primaryKey().defaultRandom(),
  clientId: uuid("client_id").notNull().references(() => clients.id, { onDelete: "cascade" }),
  addonType: billingAddonType("addon_type").notNull(),
  name: varchar("name", { length: 255 }).notNull(),
  description: text("description"),
  quantity: integer("quantity").notNull().default(1),
  unitPrice: numeric("unit_price", { precision: 10, scale: 2 }).notNull(),
  totalMonthlyPrice: numeric("total_monthly_price", { precision: 10, scale: 2 }).notNull(),
  status: billingAddonStatus("status").notNull().default("active"),
  activatedAt: timestamp("activated_at").notNull().defaultNow(),
  cancelledAt: timestamp("cancelled_at"),
  metadata: jsonb("metadata").default({}),
  approvedByUserId: uuid("approved_by_user_id").references(() => clientUsers.id, { onDelete: "set null" }),
  createdAt: timestamp("created_at").notNull().defaultNow(),
  updatedAt: timestamp("updated_at").notNull().defaultNow(),
}, (table) => [
  index("idx_client_billing_addons_client_id").on(table.clientId),
  index("idx_client_billing_addons_addon_type").on(table.addonType),
  index("idx_client_billing_addons_status").on(table.status),
]);

// -----------------------------------------------------------------------------
// 3.10 Notifications Table
// -----------------------------------------------------------------------------

export const notifications = pgTable("notifications", {
  id: uuid("id").primaryKey().defaultRandom(),
  clientId: uuid("client_id").references(() => clients.id, { onDelete: "cascade" }),
  userId: uuid("user_id").references(() => clientUsers.id, { onDelete: "cascade" }),
  type: notificationType("type").notNull().default("system"),
  priority: notificationPriority("priority").notNull().default("normal"),
  title: varchar("title", { length: 255 }).notNull(),
  message: text("message").notNull(),
  actionUrl: varchar("action_url", { length: 500 }),
  actionLabel: varchar("action_label", { length: 100 }),
  relatedProjectId: uuid("related_project_id").references(() => projects.id, { onDelete: "set null" }),
  relatedDocumentId: uuid("related_document_id"),
  relatedTicketId: uuid("related_ticket_id").references(() => clientTickets.id, { onDelete: "set null" }),
  metadata: jsonb("metadata").default({}),
  isRead: boolean("is_read").notNull().default(false),
  readAt: timestamp("read_at"),
  isArchived: boolean("is_archived").notNull().default(false),
  archivedAt: timestamp("archived_at"),
  expiresAt: timestamp("expires_at"),
  createdAt: timestamp("created_at").notNull().defaultNow(),
  updatedAt: timestamp("updated_at").notNull().defaultNow(),
}, (table) => [
  index("idx_notifications_client_id").on(table.clientId),
  index("idx_notifications_user_id").on(table.userId),
  index("idx_notifications_type").on(table.type),
  index("idx_notifications_is_read").on(table.isRead),
  index("idx_notifications_is_archived").on(table.isArchived),
  index("idx_notifications_created_at").on(table.createdAt),
]);

// ============================================================================
// SECTION 4: ADMIN-ONLY TABLES
// ============================================================================

// -----------------------------------------------------------------------------
// 4.0a Admin Notifications Table
// -----------------------------------------------------------------------------

export const adminNotifications = pgTable("admin_notifications", {
  id: uuid("id").primaryKey().defaultRandom(),
  title: varchar("title", { length: 255 }).notNull(),
  message: text("message").notNull(),
  type: adminNotificationType("type").default("system"),
  priority: varchar("priority", { length: 50 }).default("normal"),
  read: boolean("read").notNull().default(false),
  actionUrl: varchar("action_url", { length: 500 }),
  actionLabel: varchar("action_label", { length: 255 }),
  metadata: jsonb("metadata").default({}),
  relatedClientId: uuid("related_client_id").references(() => clients.id, { onDelete: "set null" }),
  relatedTicketId: uuid("related_ticket_id").references(() => clientTickets.id, { onDelete: "set null" }),
  createdAt: timestamp("created_at").notNull().defaultNow(),
  readAt: timestamp("read_at"),
}, (table) => [
  index("idx_admin_notifications_type").on(table.type),
  index("idx_admin_notifications_read").on(table.read),
  index("idx_admin_notifications_created_at").on(table.createdAt),
]);

// -----------------------------------------------------------------------------
// 4.0b Clerk User ID Backups Table
// -----------------------------------------------------------------------------

export const clerkUserIdBackups = pgTable("clerk_user_id_backups", {
  id: uuid("id").primaryKey().defaultRandom(),
  clientUserId: uuid("client_user_id").notNull(),
  email: varchar("email", { length: 255 }).notNull(),
  oldClerkUserId: varchar("old_clerk_user_id", { length: 255 }).notNull(),
  newClerkUserId: varchar("new_clerk_user_id", { length: 255 }).notNull(),
  migratedAt: timestamp("migrated_at").notNull().defaultNow(),
  rolledBackAt: timestamp("rolled_back_at"),
  notes: text("notes"),
}, (table) => [
  index("idx_clerk_backups_client_user_id").on(table.clientUserId),
  index("idx_clerk_backups_email").on(table.email),
]);

// -----------------------------------------------------------------------------
// 4.0c Ticket Messages Table
// -----------------------------------------------------------------------------

export const ticketMessages = pgTable("ticket_messages", {
  id: uuid("id").primaryKey().defaultRandom(),
  ticketId: uuid("ticket_id").notNull().references(() => clientTickets.id, { onDelete: "cascade" }),
  senderType: messageSenderType("sender_type").notNull(),
  senderId: uuid("sender_id"),
  senderName: varchar("sender_name", { length: 255 }),
  content: text("content").notNull(),
  attachments: jsonb("attachments").default([]),
  isInternal: boolean("is_internal").notNull().default(false),
  readAt: timestamp("read_at"),
  createdAt: timestamp("created_at").notNull().defaultNow(),
  updatedAt: timestamp("updated_at").notNull().defaultNow(),
}, (table) => [
  index("idx_ticket_messages_ticket_id").on(table.ticketId),
  index("idx_ticket_messages_sender_type").on(table.senderType),
  index("idx_ticket_messages_created_at").on(table.createdAt),
]);

// -----------------------------------------------------------------------------
// 4.1 Internal Tickets Table
// -----------------------------------------------------------------------------

export const tickets = pgTable("tickets", {
  id: uuid("id").primaryKey().defaultRandom(),
  projectId: uuid("project_id").references(() => projects.id, { onDelete: "cascade" }),
  clientId: uuid("client_id").references(() => clients.id),
  title: varchar("title", { length: 255 }).notNull(),
  description: text("description").notNull(),
  status: ticketStatus("status").notNull().default("open"),
  priority: ticketPriority("priority").notNull().default("medium"),
  type: ticketType("type").notNull(),
  assigneeId: varchar("assignee_id", { length: 255 }),
  reporterId: varchar("reporter_id", { length: 255 }).notNull(),
  estimatedHours: integer("estimated_hours"),
  actualHours: integer("actual_hours").default(0),
  wcagCriteria: text("wcag_criteria").array(),
  tags: text("tags").array().notNull().default([]),
  ticketCategory: varchar("ticket_category", { length: 50 }).default("general"),
  relatedIssueIds: text("related_issue_ids").array().default([]),
  dueDate: timestamp("due_date"),
  resolvedAt: timestamp("resolved_at"),
  closedAt: timestamp("closed_at"),
  createdAt: timestamp("created_at").notNull().defaultNow(),
  updatedAt: timestamp("updated_at").notNull().defaultNow(),
}, (table) => [
  index("idx_tickets_project_id").on(table.projectId),
  index("idx_tickets_client").on(table.clientId),
  index("idx_tickets_status").on(table.status),
  index("idx_tickets_category").on(table.ticketCategory),
]);

// -----------------------------------------------------------------------------
// 4.2 Ticket Attachments Table
// -----------------------------------------------------------------------------

export const ticketAttachments = pgTable("ticket_attachments", {
  id: uuid("id").primaryKey().defaultRandom(),
  ticketId: uuid("ticket_id").notNull().references(() => tickets.id, { onDelete: "cascade" }),
  filename: varchar("filename", { length: 255 }).notNull(),
  originalName: varchar("original_name", { length: 255 }).notNull(),
  filePath: varchar("file_path", { length: 500 }).notNull(),
  fileSize: numeric("file_size", { precision: 15, scale: 0 }).notNull(),
  mimeType: varchar("mime_type", { length: 100 }).notNull(),
  uploadedBy: varchar("uploaded_by", { length: 255 }).notNull(),
  uploadedAt: timestamp("uploaded_at").notNull().defaultNow(),
}, (table) => [
  index("idx_ticket_attachments_ticket_id").on(table.ticketId),
]);

// -----------------------------------------------------------------------------
// 4.3 Ticket Comments Table
// -----------------------------------------------------------------------------

export const ticketComments = pgTable("ticket_comments", {
  id: uuid("id").primaryKey().defaultRandom(),
  ticketId: uuid("ticket_id").notNull().references(() => tickets.id, { onDelete: "cascade" }),
  userId: varchar("user_id", { length: 255 }).notNull(),
  userName: varchar("user_name", { length: 255 }).notNull(),
  comment: text("comment").notNull(),
  isInternal: boolean("is_internal").notNull().default(false),
  createdAt: timestamp("created_at").notNull().defaultNow(),
  updatedAt: timestamp("updated_at").notNull().defaultNow(),
}, (table) => [
  index("idx_ticket_comments_ticket_id").on(table.ticketId),
]);

// -----------------------------------------------------------------------------
// 4.4 Teams Table
// -----------------------------------------------------------------------------

export const teams = pgTable("teams", {
  id: uuid("id").primaryKey().defaultRandom(),
  name: varchar("name", { length: 255 }).notNull(),
  description: text("description"),
  teamType: teamType("team_type").notNull(),
  managerId: uuid("manager_id"),
  isActive: boolean("is_active").notNull().default(true),
  createdAt: timestamp("created_at").notNull().defaultNow(),
  updatedAt: timestamp("updated_at").notNull().defaultNow(),
}, (table) => [
  index("idx_teams_team_type").on(table.teamType),
  index("idx_teams_is_active").on(table.isActive),
]);

// -----------------------------------------------------------------------------
// 4.5 Team Members Table
// -----------------------------------------------------------------------------

export const teamMembers = pgTable("team_members", {
  id: uuid("id").primaryKey().defaultRandom(),
  teamId: uuid("team_id").notNull().references(() => teams.id, { onDelete: "cascade" }),
  firstName: varchar("first_name", { length: 100 }).notNull(),
  lastName: varchar("last_name", { length: 100 }).notNull(),
  email: varchar("email", { length: 255 }).notNull().unique(),
  phone: varchar("phone", { length: 20 }),
  role: employeeRole("role").notNull(),
  title: varchar("title", { length: 255 }),
  department: varchar("department", { length: 100 }),
  reportsToId: uuid("reports_to_id"),
  employmentStatus: employmentStatus("employment_status").notNull().default("active"),
  startDate: timestamp("start_date"),
  endDate: timestamp("end_date"),
  hourlyRate: integer("hourly_rate"),
  salary: integer("salary"),
  skills: text("skills"),
  bio: text("bio"),
  profileImageUrl: varchar("profile_image_url", { length: 500 }),
  linkedinUrl: varchar("linkedin_url", { length: 500 }),
  githubUrl: varchar("github_url", { length: 500 }),
  isActive: boolean("is_active").notNull().default(true),
  createdAt: timestamp("created_at").notNull().defaultNow(),
  updatedAt: timestamp("updated_at").notNull().defaultNow(),
}, (table) => [
  index("idx_team_members_team_id").on(table.teamId),
  index("idx_team_members_email").on(table.email),
  index("idx_team_members_role").on(table.role),
  index("idx_team_members_is_active").on(table.isActive),
]);

// -----------------------------------------------------------------------------
// 4.6 Project Team Assignments Table
// -----------------------------------------------------------------------------

export const projectTeamAssignments = pgTable("project_team_assignments", {
  id: uuid("id").primaryKey().defaultRandom(),
  projectId: uuid("project_id").notNull().references(() => projects.id, { onDelete: "cascade" }),
  teamMemberId: uuid("team_member_id").notNull().references(() => teamMembers.id, { onDelete: "cascade" }),
  projectRole: varchar("project_role", { length: 100 }),
  assignedAt: timestamp("assigned_at").notNull().defaultNow(),
  unassignedAt: timestamp("unassigned_at"),
  isActive: boolean("is_active").notNull().default(true),
}, (table) => [
  index("idx_project_team_assignments_project_id").on(table.projectId),
  index("idx_project_team_assignments_team_member_id").on(table.teamMemberId),
]);

// -----------------------------------------------------------------------------
// 4.7 Project Staging Credentials Table
// -----------------------------------------------------------------------------

export const projectStagingCredentials = pgTable("project_staging_credentials", {
  id: uuid("id").primaryKey().defaultRandom(),
  projectId: uuid("project_id").notNull().references(() => projects.id, { onDelete: "cascade" }),
  type: credentialType("type").notNull().default("staging"),
  environment: varchar("environment", { length: 100 }).notNull(),
  url: varchar("url", { length: 500 }).notNull(),
  username: varchar("username", { length: 255 }),
  password: text("password"),
  apiKey: text("api_key"),
  accessToken: text("access_token"),
  sshKey: text("ssh_key"),
  databaseUrl: text("database_url"),
  remoteFolderPath: varchar("remote_folder_path", { length: 500 }),
  additionalUrls: text("additional_urls").array().default([]),
  notes: text("notes"),
  isActive: boolean("is_active").notNull().default(true),
  expiresAt: timestamp("expires_at"),
  credentials: jsonb("credentials").default({}),
  createdBy: varchar("created_by", { length: 255 }).notNull(),
  createdAt: timestamp("created_at").notNull().defaultNow(),
  updatedAt: timestamp("updated_at").notNull().defaultNow(),
}, (table) => [
  index("idx_project_staging_credentials_project_id").on(table.projectId),
]);

// -----------------------------------------------------------------------------
// 4.8 Client Credentials Table
// -----------------------------------------------------------------------------

export const clientCredentials = pgTable("client_credentials", {
  id: uuid("id").primaryKey().defaultRandom(),
  clientId: uuid("client_id").notNull().references(() => clients.id, { onDelete: "cascade" }),
  name: varchar("name", { length: 255 }).notNull(),
  username: varchar("username", { length: 255 }),
  password: text("password"),
  apiKey: text("api_key"),
  notes: text("notes"),
  type: varchar("type", { length: 50 }).notNull(),
  createdAt: timestamp("created_at").notNull().defaultNow(),
  updatedAt: timestamp("updated_at").notNull().defaultNow(),
}, (table) => [
  index("idx_client_credentials_client_id").on(table.clientId),
]);

// -----------------------------------------------------------------------------
// 4.9 Client Files Table
// -----------------------------------------------------------------------------

export const clientFiles = pgTable("client_files", {
  id: uuid("id").primaryKey().defaultRandom(),
  clientId: uuid("client_id").notNull().references(() => clients.id, { onDelete: "cascade" }),
  filename: varchar("filename", { length: 255 }).notNull(),
  originalName: varchar("original_name", { length: 255 }).notNull(),
  category: varchar("category", { length: 50 }).notNull(),
  filePath: varchar("file_path", { length: 500 }).notNull(),
  fileSize: numeric("file_size", { precision: 15, scale: 0 }).notNull(),
  mimeType: varchar("mime_type", { length: 100 }).notNull(),
  isEncrypted: boolean("is_encrypted").notNull().default(false),
  uploadedBy: varchar("uploaded_by", { length: 255 }).notNull(),
  uploadedAt: timestamp("uploaded_at").notNull().defaultNow(),
  accessLevel: varchar("access_level", { length: 20 }).notNull().default("public"),
  metadata: text("metadata"),
}, (table) => [
  index("idx_client_files_client_id").on(table.clientId),
]);

// -----------------------------------------------------------------------------
// 4.10 Project Documents Table
// -----------------------------------------------------------------------------

export const projectDocuments = pgTable("project_documents", {
  id: uuid("id").primaryKey().defaultRandom(),
  projectId: uuid("project_id").notNull().references(() => projects.id, { onDelete: "cascade" }),
  name: varchar("name", { length: 255 }).notNull(),
  type: documentType("type").notNull(),
  filePath: varchar("file_path", { length: 500 }).notNull(),
  uploadedBy: varchar("uploaded_by", { length: 255 }).notNull(),
  uploadedAt: timestamp("uploaded_at").notNull().defaultNow(),
  version: varchar("version", { length: 50 }).notNull().default("1.0"),
  isLatest: boolean("is_latest").notNull().default(true),
  tags: text("tags").array().notNull().default([]),
  fileSize: numeric("file_size", { precision: 15, scale: 0 }).notNull(),
  mimeType: varchar("mime_type", { length: 100 }).notNull(),
}, (table) => [
  index("idx_project_documents_project_id").on(table.projectId),
]);

// -----------------------------------------------------------------------------
// 4.11 Project Activities Table
// -----------------------------------------------------------------------------

export const projectActivities = pgTable("project_activities", {
  id: uuid("id").primaryKey().defaultRandom(),
  projectId: uuid("project_id").notNull().references(() => projects.id, { onDelete: "cascade" }),
  userId: varchar("user_id", { length: 255 }).notNull(),
  userName: varchar("user_name", { length: 255 }).notNull(),
  action: activityAction("action").notNull(),
  description: text("description").notNull(),
  metadata: text("metadata"),
  timestamp: timestamp("timestamp").notNull().defaultNow(),
}, (table) => [
  index("idx_activities_project_id").on(table.projectId),
  index("idx_activities_timestamp").on(table.timestamp),
]);

// -----------------------------------------------------------------------------
// 4.12 Project Developers Table
// -----------------------------------------------------------------------------

export const projectDevelopers = pgTable("project_developers", {
  id: uuid("id").primaryKey().defaultRandom(),
  projectId: uuid("project_id").notNull().references(() => projects.id, { onDelete: "cascade" }),
  developerId: varchar("developer_id", { length: 255 }).notNull(),
  role: developerRole("role").notNull(),
  responsibilities: text("responsibilities").array().notNull().default([]),
  assignedAt: timestamp("assigned_at").notNull().defaultNow(),
  assignedBy: varchar("assigned_by", { length: 255 }).notNull(),
  isActive: boolean("is_active").notNull().default(true),
  hourlyRate: numeric("hourly_rate", { precision: 8, scale: 2 }),
  maxHoursPerWeek: integer("max_hours_per_week"),
}, (table) => [
  index("idx_project_developers_project_id").on(table.projectId),
]);

// -----------------------------------------------------------------------------
// 4.13 Project Milestones Table
// -----------------------------------------------------------------------------

export const projectMilestones = pgTable("project_milestones", {
  id: uuid("id").primaryKey().defaultRandom(),
  projectId: uuid("project_id").notNull().references(() => projects.id, { onDelete: "cascade" }),
  title: varchar("title", { length: 255 }).notNull(),
  description: text("description"),
  dueDate: timestamp("due_date").notNull(),
  completedDate: timestamp("completed_date"),
  status: milestoneStatus("status").notNull().default("pending"),
  assignedTo: varchar("assigned_to", { length: 255 }),
  deliverables: text("deliverables").array().notNull().default([]),
  acceptanceCriteria: text("acceptance_criteria").array().notNull().default([]),
  order: integer("order").notNull(),
  wcagCriteria: text("wcag_criteria").array(),
  createdAt: timestamp("created_at").notNull().defaultNow(),
  updatedAt: timestamp("updated_at").notNull().defaultNow(),
}, (table) => [
  index("idx_project_milestones_project_id").on(table.projectId),
]);

// -----------------------------------------------------------------------------
// 4.14 Project Time Entries Table
// -----------------------------------------------------------------------------

export const projectTimeEntries = pgTable("project_time_entries", {
  id: uuid("id").primaryKey().defaultRandom(),
  projectId: uuid("project_id").notNull().references(() => projects.id, { onDelete: "cascade" }),
  developerId: varchar("developer_id", { length: 255 }).notNull(),
  date: timestamp("date").notNull(),
  hours: numeric("hours", { precision: 4, scale: 2 }).notNull(),
  description: text("description").notNull(),
  category: timeEntryCategory("category").notNull(),
  billable: boolean("billable").notNull().default(true),
  approved: boolean("approved").notNull().default(false),
  approvedBy: varchar("approved_by", { length: 255 }),
  approvedAt: timestamp("approved_at"),
  createdAt: timestamp("created_at").notNull().defaultNow(),
}, (table) => [
  index("idx_project_time_entries_project_id").on(table.projectId),
]);

// -----------------------------------------------------------------------------
// 4.15 Sync Logs Table
// -----------------------------------------------------------------------------

export const syncLogs = pgTable("sync_logs", {
  id: uuid("id").primaryKey().defaultRandom(),
  projectId: uuid("project_id").notNull().references(() => projects.id),
  sheetId: text("sheet_id"),
  syncType: text("sync_type").notNull(),
  status: text("status").notNull(),
  rowsProcessed: text("rows_processed"),
  rowsInserted: text("rows_inserted"),
  rowsUpdated: text("rows_updated"),
  rowsSkipped: text("rows_skipped"),
  rowsFailed: text("rows_failed"),
  errorMessage: text("error_message"),
  errorType: text("error_type"),
  structureMismatchDetails: text("structure_mismatch_details"),
  startedAt: timestamp("started_at").notNull(),
  completedAt: timestamp("completed_at"),
  createdAt: timestamp("created_at").notNull().defaultNow(),
}, (table) => [
  index("idx_sync_logs_project_id").on(table.projectId),
  index("idx_sync_logs_created_at").on(table.createdAt),
  index("idx_sync_logs_status").on(table.status),
]);

// -----------------------------------------------------------------------------
// 4.16 Project Sync Status Table
// -----------------------------------------------------------------------------

export const projectSyncStatus = pgTable("project_sync_status", {
  id: uuid("id").primaryKey().defaultRandom(),
  projectId: uuid("project_id").notNull().references(() => projects.id),
  sheetId: varchar("sheet_id", { length: 255 }).notNull(),
  syncType: varchar("sync_type", { length: 50 }).notNull(),
  syncStatus: varchar("sync_status", { length: 20 }).notNull(),
  startedAt: timestamp("started_at").notNull().defaultNow(),
  completedAt: timestamp("completed_at"),
  durationMs: integer("duration_ms"),
  totalRowsProcessed: integer("total_rows_processed").default(0),
  rowsInserted: integer("rows_inserted").default(0),
  rowsUpdated: integer("rows_updated").default(0),
  rowsSkipped: integer("rows_skipped").default(0),
  rowsFailed: integer("rows_failed").default(0),
  errorType: varchar("error_type", { length: 100 }),
  errorMessage: text("error_message"),
  errorDetails: jsonb("error_details"),
  sheetName: varchar("sheet_name", { length: 255 }),
  expectedColumns: text("expected_columns").array(),
  actualColumns: text("actual_columns").array(),
  structureMatch: boolean("structure_match"),
  syncConfig: jsonb("sync_config"),
  retryCount: integer("retry_count").default(0),
  maxRetries: integer("max_retries").default(3),
  syncVersion: varchar("sync_version", { length: 20 }).default("1.0"),
  createdBy: varchar("created_by", { length: 255 }).default("a3s-server"),
  createdAt: timestamp("created_at").notNull().defaultNow(),
  updatedAt: timestamp("updated_at").notNull().defaultNow(),
}, (table) => [
  index("idx_project_sync_status_project_id").on(table.projectId),
  index("idx_project_sync_status_created_at").on(table.createdAt),
  index("idx_project_sync_status_status").on(table.syncStatus),
]);

// -----------------------------------------------------------------------------
// 4.17 Checkpoint Sync Table
// -----------------------------------------------------------------------------

export const checkpointSync = pgTable("checkpoint_sync", {
  id: uuid("id").primaryKey().defaultRandom(),
  projectId: uuid("project_id").notNull().references(() => projects.id),
  sheetId: text("sheet_id").notNull(),
  lastSyncedRow: text("last_synced_row").notNull(),
  createdAt: timestamp("created_at").notNull().defaultNow(),
  updatedAt: timestamp("updated_at").notNull().defaultNow(),
}, (table) => [
  unique("checkpoint_sync_project_id_sheet_id_key").on(table.projectId, table.sheetId),
  index("idx_checkpoint_sync_project_id").on(table.projectId),
]);

// -----------------------------------------------------------------------------
// 4.18 Status Table
// -----------------------------------------------------------------------------

export const status = pgTable("status", {
  id: uuid("id").primaryKey().defaultRandom(),
  projectId: uuid("project_id").notNull().references(() => projects.id),
  url: text("url").notNull(),
  status: text("status"),
  notes: text("notes"),
  pageTitle: text("page_title"),
  urlCategory: text("url_category"),
  testingMonth: text("testing_month"),
  testingYear: text("testing_year"),
  remediationMonth: text("remediation_month"),
  automatedTools: text("automated_tools"),
  nvdaChrome: text("nvda_chrome"),
  voiceoverIphoneSafari: text("voiceover_iphone_safari"),
  colorContrast: text("color_contrast"),
  isActive: text("is_active"),
  createdAt: timestamp("created_at").notNull().defaultNow(),
  updatedAt: timestamp("updated_at").notNull().defaultNow(),
}, (table) => [
  unique("status_project_id_url_key").on(table.projectId, table.url),
  index("idx_status_project_id").on(table.projectId),
  index("idx_status_url").on(table.url),
  index("idx_status_status").on(table.status),
]);

// -----------------------------------------------------------------------------
// 4.19 Status Check Table
// -----------------------------------------------------------------------------

export const statusCheck = pgTable("status_check", {
  id: uuid("id").primaryKey().defaultRandom(),
  projectId: uuid("project_id").notNull().references(() => projects.id),
  testScenario: text("test_scenario"),
  url: text("url"),
  status: text("status"),
  notes: text("notes"),
  createdAt: timestamp("created_at").notNull().defaultNow(),
  updatedAt: timestamp("updated_at").notNull().defaultNow(),
}, (table) => [
  unique("status_check_project_id_test_scenario_url_key").on(table.projectId, table.testScenario, table.url),
  index("idx_status_check_project_id").on(table.projectId),
]);

// -----------------------------------------------------------------------------
// 4.20 Issue Comments Table
// -----------------------------------------------------------------------------

export const issueComments = pgTable("issue_comments", {
  id: uuid("id").primaryKey().defaultRandom(),
  issueId: uuid("issue_id").notNull().references(() => accessibilityIssues.id, { onDelete: "cascade" }),
  commentText: text("comment_text").notNull(),
  commentType: commentType("comment_type").default("general"),
  authorName: varchar("author_name", { length: 255 }),
  authorRole: authorRole("author_role"),
  createdAt: timestamp("created_at").notNull().defaultNow(),
  updatedAt: timestamp("updated_at").notNull().defaultNow(),
}, (table) => [
  index("issue_comments_issue_idx").on(table.issueId),
]);

// -----------------------------------------------------------------------------
// 4.21 WCAG URL Check Table
// -----------------------------------------------------------------------------

export const wcagUrlCheck = pgTable("wcag_url_check", {
  id: uuid("id").primaryKey().defaultRandom(),
  projectId: uuid("project_id").notNull().references(() => projects.id),
  testScenario: text("test_scenario"),
  // WCAG 1.x criteria
  _111NonTextContentA: text("_111_non_text_content_a"),
  _121AudioOnlyAndVideoOnlyPrerecordedA: text("_121_audio_only_and_video_only_prerecorded_a"),
  _122CaptionsPrerecordedA: text("_122_captions_prerecorded_a"),
  _123AudioDescriptionOrMediaAlternativePrerecordedA: text("_123_audio_description_or_media_alternative_prerecorded_a"),
  _124CaptionsLiveAa: text("_124_captions_live_aa"),
  _125AudioDescriptionPrerecordedAa: text("_125_audio_description_prerecorded_aa"),
  _131InfoAndRelationshipsA: text("_131_info_and_relationships_a"),
  _132MeaningfulSequenceA: text("_132_meaningful_sequence_a"),
  _133SensoryCharacteristicsA: text("_133_sensory_characteristics_a"),
  _134OrientationAa: text("_134_orientation_aa"),
  _135IdentifyInputPurposeAa: text("_135_identify_input_purpose_aa"),
  _141UseOfColorA: text("_141_use_of_color_a"),
  _142AudioControlA: text("_142_audio_control_a"),
  _143ContrastMinimumAa: text("_143_contrast_minimum_aa"),
  _144ResizeTextAa: text("_144_resize_text_aa"),
  _145ImagesOfTextAa: text("_145_images_of_text_aa"),
  _1410ReflowAa: text("_1410_reflow_aa"),
  _1411NonTextContrastAa: text("_1411_non_text_contrast_aa"),
  _1412TextSpacingAa: text("_1412_text_spacing_aa"),
  _1413ContentOnHoverOrFocusAa: text("_1413_content_on_hover_or_focus_aa"),
  // WCAG 2.x criteria
  _211KeyboardA: text("_211_keyboard_a"),
  _212NoKeyboardTrapA: text("_212_no_keyboard_trap_a"),
  _214CharacterKeyShortcutsA: text("_214_character_key_shortcuts_a"),
  _221TimingAdjustableA: text("_221_timing_adjustable_a"),
  _222PauseStopHideA: text("_222_pause_stop_hide_a"),
  _231ThreeFlashesOrBelowThresholdA: text("_231_three_flashes_or_below_threshold_a"),
  _241BypassBlocksA: text("_241_bypass_blocks_a"),
  _242PageTitledA: text("_242_page_titled_a"),
  _243FocusOrderA: text("_243_focus_order_a"),
  _244LinkPurposeInContextA: text("_244_link_purpose_in_context_a"),
  _245MultipleWaysAa: text("_245_multiple_ways_aa"),
  _246HeadingsAndLabelsAa: text("_246_headings_and_labels_aa"),
  _247FocusVisibleAa: text("_247_focus_visible_aa"),
  _251PointerGesturesA: text("_251_pointer_gestures_a"),
  _252PointerCancellationA: text("_252_pointer_cancellation_a"),
  _253LabelInNameA: text("_253_label_in_name_a"),
  _254MotionActuationA: text("_254_motion_actuation_a"),
  _257DraggingMovementsAa: text("_257_dragging_movements_aa"),
  _258TargetSizeMinimumAa: text("_258_target_size_minimum_aa"),
  _2411FocusNotObscuredMinimumAa: text("_2411_focus_not_obscured_minimum_aa"),
  // WCAG 3.x criteria
  _311LanguageOfPageA: text("_311_language_of_page_a"),
  _312LanguageOfPartsAa: text("_312_language_of_parts_aa"),
  _321OnFocusA: text("_321_on_focus_a"),
  _322OnInputA: text("_322_on_input_a"),
  _323ConsistentNavigationAa: text("_323_consistent_navigation_aa"),
  _324ConsistentIdentificationAa: text("_324_consistent_identification_aa"),
  _326ConsistentHelpAa: text("_326_consistent_help_aa"),
  _331ErrorIdentificationA: text("_331_error_identification_a"),
  _332LabelsOrInstructionsA: text("_332_labels_or_instructions_a"),
  _333ErrorSuggestionAa: text("_333_error_suggestion_aa"),
  _334ErrorPreventionLegalFinancialDataAa: text("_334_error_prevention_legal_financial_data_aa"),
  _337RedundantEntryA: text("_337_redundant_entry_a"),
  _338AccessibleAuthenticationMinimumAa: text("_338_accessible_authentication_minimum_aa"),
  // WCAG 4.x criteria
  _411ParsingAa: text("_411_parsing_aa"),
  _412NameRoleValueA: text("_412_name_role_value_a"),
  _413StatusMessagesAa: text("_413_status_messages_aa"),
  createdAt: timestamp("created_at").notNull().defaultNow(),
  updatedAt: timestamp("updated_at").notNull().defaultNow(),
}, (table) => [
  uniqueIndex("unique_project_test_scenario").on(table.projectId, table.testScenario),
  index("idx_wcag_url_check_project_id").on(table.projectId),
]);

// ============================================================================
// SECTION 5: RELATIONS
// ============================================================================

export const clientsRelations = relations(clients, ({ many }) => ({
  users: many(clientUsers),
  projects: many(projects),
  tickets: many(clientTickets),
  teamMembers: many(clientTeamMembers),
  evidenceDocuments: many(evidenceDocuments),
  evidenceDocumentRequests: many(evidenceDocumentRequests),
  documentRemediations: many(documentRemediations),
  billingAddons: many(clientBillingAddons),
  notifications: many(notifications),
  credentials: many(clientCredentials),
  files: many(clientFiles),
}));

export const clientUsersRelations = relations(clientUsers, ({ one, many }) => ({
  client: one(clients, {
    fields: [clientUsers.clientId],
    references: [clients.id],
  }),
  projectAccess: many(projectTeamMembers),
  notifications: many(notifications),
}));

export const projectsRelations = relations(projects, ({ one, many }) => ({
  client: one(clients, {
    fields: [projects.clientId],
    references: [clients.id],
  }),
  teamMembers: many(projectTeamMembers),
  issues: many(issues),
  accessibilityIssues: many(accessibilityIssues),
  testUrls: many(testUrls),
  reports: many(reports),
  evidenceDocuments: many(evidenceDocuments),
  activities: many(projectActivities),
  developers: many(projectDevelopers),
  milestones: many(projectMilestones),
  timeEntries: many(projectTimeEntries),
  documents: many(projectDocuments),
  stagingCredentials: many(projectStagingCredentials),
}));

export const testUrlsRelations = relations(testUrls, ({ one, many }) => ({
  project: one(projects, {
    fields: [testUrls.projectId],
    references: [projects.id],
  }),
  accessibilityIssues: many(accessibilityIssues),
}));

export const accessibilityIssuesRelations = relations(accessibilityIssues, ({ one, many }) => ({
  project: one(projects, {
    fields: [accessibilityIssues.projectId],
    references: [projects.id],
  }),
  testUrl: one(testUrls, {
    fields: [accessibilityIssues.urlId],
    references: [testUrls.id],
  }),
  reportIssues: many(reportIssues),
  comments: many(issueComments),
}));

export const reportsRelations = relations(reports, ({ one, many }) => ({
  project: one(projects, {
    fields: [reports.projectId],
    references: [projects.id],
  }),
  reportIssues: many(reportIssues),
  reportComments: many(reportComments),
}));

export const reportIssuesRelations = relations(reportIssues, ({ one }) => ({
  report: one(reports, {
    fields: [reportIssues.reportId],
    references: [reports.id],
  }),
  issue: one(accessibilityIssues, {
    fields: [reportIssues.issueId],
    references: [accessibilityIssues.id],
  }),
}));

export const clientTicketsRelations = relations(clientTickets, ({ one, many }) => ({
  client: one(clients, {
    fields: [clientTickets.clientId],
    references: [clients.id],
  }),
  project: one(projects, {
    fields: [clientTickets.projectId],
    references: [projects.id],
  }),
  createdByUser: one(clientUsers, {
    fields: [clientTickets.createdByUserId],
    references: [clientUsers.id],
  }),
  relatedIssues: many(clientTicketIssues),
  messages: many(ticketMessages),
}));

export const notificationsRelations = relations(notifications, ({ one }) => ({
  client: one(clients, {
    fields: [notifications.clientId],
    references: [clients.id],
  }),
  user: one(clientUsers, {
    fields: [notifications.userId],
    references: [clientUsers.id],
  }),
  relatedProject: one(projects, {
    fields: [notifications.relatedProjectId],
    references: [projects.id],
  }),
  relatedTicket: one(clientTickets, {
    fields: [notifications.relatedTicketId],
    references: [clientTickets.id],
  }),
}));

// ============================================================================
// SECTION 6: TYPE EXPORTS
// ============================================================================

export type Client = typeof clients.$inferSelect;
export type NewClient = typeof clients.$inferInsert;
export type ClientUser = typeof clientUsers.$inferSelect;
export type NewClientUser = typeof clientUsers.$inferInsert;
export type Project = typeof projects.$inferSelect;
export type NewProject = typeof projects.$inferInsert;
export type TestUrl = typeof testUrls.$inferSelect;
export type NewTestUrl = typeof testUrls.$inferInsert;
export type AccessibilityIssue = typeof accessibilityIssues.$inferSelect;
export type NewAccessibilityIssue = typeof accessibilityIssues.$inferInsert;
export type Report = typeof reports.$inferSelect;
export type NewReport = typeof reports.$inferInsert;
export type ReportIssue = typeof reportIssues.$inferSelect;
export type NewReportIssue = typeof reportIssues.$inferInsert;
export type ClientTicket = typeof clientTickets.$inferSelect;
export type NewClientTicket = typeof clientTickets.$inferInsert;
export type Notification = typeof notifications.$inferSelect;
export type NewNotification = typeof notifications.$inferInsert;
export type EvidenceDocument = typeof evidenceDocuments.$inferSelect;
export type NewEvidenceDocument = typeof evidenceDocuments.$inferInsert;
export type DocumentRemediation = typeof documentRemediations.$inferSelect;
export type NewDocumentRemediation = typeof documentRemediations.$inferInsert;
export type Team = typeof teams.$inferSelect;
export type NewTeam = typeof teams.$inferInsert;
export type TeamMember = typeof teamMembers.$inferSelect;
export type NewTeamMember = typeof teamMembers.$inferInsert;
export type Ticket = typeof tickets.$inferSelect;
export type NewTicket = typeof tickets.$inferInsert;
export type TicketMessage = typeof ticketMessages.$inferSelect;
export type NewTicketMessage = typeof ticketMessages.$inferInsert;
export type AdminNotification = typeof adminNotifications.$inferSelect;
export type NewAdminNotification = typeof adminNotifications.$inferInsert;

