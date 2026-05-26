-- company_secret_bindings
CREATE TABLE IF NOT EXISTS "company_secret_bindings" (
	"id" uuid PRIMARY KEY DEFAULT gen_random_uuid() NOT NULL,
	"company_id" uuid NOT NULL,
	"secret_id" uuid NOT NULL,
	"target_type" text NOT NULL,
	"target_id" text NOT NULL,
	"config_path" text NOT NULL,
	"version_selector" text DEFAULT 'latest' NOT NULL,
	"required" boolean DEFAULT true NOT NULL,
	"label" text,
	"created_at" timestamp with time zone DEFAULT now() NOT NULL,
	"updated_at" timestamp with time zone DEFAULT now() NOT NULL
);--> statement-breakpoint
ALTER TABLE "company_secret_bindings" ADD CONSTRAINT "company_secret_bindings_company_id_fk" FOREIGN KEY ("company_id") REFERENCES "public"."companies"("id") ON DELETE no action ON UPDATE no action;--> statement-breakpoint
ALTER TABLE "company_secret_bindings" ADD CONSTRAINT "company_secret_bindings_secret_id_fk" FOREIGN KEY ("secret_id") REFERENCES "public"."company_secrets"("id") ON DELETE cascade ON UPDATE no action;--> statement-breakpoint
CREATE INDEX IF NOT EXISTS "company_secret_bindings_company_idx" ON "company_secret_bindings" ("company_id");--> statement-breakpoint
CREATE INDEX IF NOT EXISTS "company_secret_bindings_secret_idx" ON "company_secret_bindings" ("secret_id");--> statement-breakpoint
CREATE INDEX IF NOT EXISTS "company_secret_bindings_target_idx" ON "company_secret_bindings" ("company_id","target_type","target_id");--> statement-breakpoint
CREATE UNIQUE INDEX IF NOT EXISTS "company_secret_bindings_target_path_uq" ON "company_secret_bindings" ("company_id","target_type","target_id","config_path");--> statement-breakpoint

-- company_secret_provider_configs
CREATE TABLE IF NOT EXISTS "company_secret_provider_configs" (
	"id" uuid PRIMARY KEY DEFAULT gen_random_uuid() NOT NULL,
	"company_id" uuid NOT NULL,
	"provider" text NOT NULL,
	"display_name" text NOT NULL,
	"status" text DEFAULT 'ready' NOT NULL,
	"is_default" boolean DEFAULT false NOT NULL,
	"config" jsonb DEFAULT '{}'::jsonb NOT NULL,
	"health_status" text,
	"health_checked_at" timestamp with time zone,
	"health_message" text,
	"health_details" jsonb,
	"disabled_at" timestamp with time zone,
	"created_by_agent_id" uuid,
	"created_by_user_id" text,
	"created_at" timestamp with time zone DEFAULT now() NOT NULL,
	"updated_at" timestamp with time zone DEFAULT now() NOT NULL
);--> statement-breakpoint
ALTER TABLE "company_secret_provider_configs" ADD CONSTRAINT "company_secret_provider_configs_company_id_fk" FOREIGN KEY ("company_id") REFERENCES "public"."companies"("id") ON DELETE cascade ON UPDATE no action;--> statement-breakpoint
CREATE INDEX IF NOT EXISTS "company_secret_provider_configs_company_idx" ON "company_secret_provider_configs" ("company_id");--> statement-breakpoint
CREATE INDEX IF NOT EXISTS "company_secret_provider_configs_company_provider_idx" ON "company_secret_provider_configs" ("company_id","provider");--> statement-breakpoint

-- issue_recovery_actions
CREATE TABLE IF NOT EXISTS "issue_recovery_actions" (
	"id" uuid PRIMARY KEY DEFAULT gen_random_uuid() NOT NULL,
	"company_id" uuid NOT NULL,
	"source_issue_id" uuid NOT NULL,
	"recovery_issue_id" uuid,
	"kind" text NOT NULL,
	"status" text DEFAULT 'active' NOT NULL,
	"owner_type" text DEFAULT 'agent' NOT NULL,
	"owner_agent_id" uuid,
	"owner_user_id" text,
	"previous_owner_agent_id" uuid,
	"return_owner_agent_id" uuid,
	"cause" text NOT NULL,
	"fingerprint" text NOT NULL,
	"evidence" jsonb DEFAULT '{}'::jsonb NOT NULL,
	"next_action" text NOT NULL,
	"wake_policy" jsonb,
	"monitor_policy" jsonb,
	"attempt_count" integer DEFAULT 0 NOT NULL,
	"max_attempts" integer,
	"timeout_at" timestamp with time zone,
	"last_attempt_at" timestamp with time zone,
	"outcome" text,
	"resolution_note" text,
	"resolved_at" timestamp with time zone,
	"created_at" timestamp with time zone DEFAULT now() NOT NULL,
	"updated_at" timestamp with time zone DEFAULT now() NOT NULL
);--> statement-breakpoint
ALTER TABLE "issue_recovery_actions" ADD CONSTRAINT "issue_recovery_actions_company_id_fk" FOREIGN KEY ("company_id") REFERENCES "public"."companies"("id") ON DELETE no action ON UPDATE no action;--> statement-breakpoint
ALTER TABLE "issue_recovery_actions" ADD CONSTRAINT "issue_recovery_actions_source_issue_id_fk" FOREIGN KEY ("source_issue_id") REFERENCES "public"."issues"("id") ON DELETE cascade ON UPDATE no action;--> statement-breakpoint
ALTER TABLE "issue_recovery_actions" ADD CONSTRAINT "issue_recovery_actions_recovery_issue_id_fk" FOREIGN KEY ("recovery_issue_id") REFERENCES "public"."issues"("id") ON DELETE set null ON UPDATE no action;--> statement-breakpoint
CREATE INDEX IF NOT EXISTS "issue_recovery_actions_company_source_status_idx" ON "issue_recovery_actions" ("company_id","source_issue_id","status");--> statement-breakpoint
CREATE INDEX IF NOT EXISTS "issue_recovery_actions_company_owner_status_idx" ON "issue_recovery_actions" ("company_id","owner_agent_id","status");--> statement-breakpoint
CREATE INDEX IF NOT EXISTS "issue_recovery_actions_company_recovery_issue_idx" ON "issue_recovery_actions" ("company_id","recovery_issue_id");--> statement-breakpoint
CREATE UNIQUE INDEX IF NOT EXISTS "issue_recovery_actions_active_source_uq" ON "issue_recovery_actions" ("company_id","source_issue_id") WHERE status in ('active', 'escalated');--> statement-breakpoint
CREATE UNIQUE INDEX IF NOT EXISTS "issue_recovery_actions_active_fingerprint_uq" ON "issue_recovery_actions" ("company_id","source_issue_id","cause","fingerprint") WHERE status in ('active', 'escalated');--> statement-breakpoint

-- plugin_managed_resources
CREATE TABLE IF NOT EXISTS "plugin_managed_resources" (
	"id" uuid PRIMARY KEY DEFAULT gen_random_uuid() NOT NULL,
	"company_id" uuid NOT NULL,
	"plugin_id" uuid NOT NULL,
	"plugin_key" text NOT NULL,
	"resource_kind" text NOT NULL,
	"resource_key" text NOT NULL,
	"resource_id" uuid NOT NULL,
	"defaults_json" jsonb DEFAULT '{}'::jsonb NOT NULL,
	"created_at" timestamp with time zone DEFAULT now() NOT NULL,
	"updated_at" timestamp with time zone DEFAULT now() NOT NULL
);--> statement-breakpoint
ALTER TABLE "plugin_managed_resources" ADD CONSTRAINT "plugin_managed_resources_company_id_fk" FOREIGN KEY ("company_id") REFERENCES "public"."companies"("id") ON DELETE cascade ON UPDATE no action;--> statement-breakpoint
ALTER TABLE "plugin_managed_resources" ADD CONSTRAINT "plugin_managed_resources_plugin_id_fk" FOREIGN KEY ("plugin_id") REFERENCES "public"."plugins"("id") ON DELETE cascade ON UPDATE no action;--> statement-breakpoint
CREATE INDEX IF NOT EXISTS "plugin_managed_resources_company_idx" ON "plugin_managed_resources" ("company_id");--> statement-breakpoint
CREATE INDEX IF NOT EXISTS "plugin_managed_resources_plugin_idx" ON "plugin_managed_resources" ("plugin_id");--> statement-breakpoint
CREATE INDEX IF NOT EXISTS "plugin_managed_resources_resource_idx" ON "plugin_managed_resources" ("resource_kind","resource_id");--> statement-breakpoint
CREATE UNIQUE INDEX IF NOT EXISTS "plugin_managed_resources_company_plugin_resource_uq" ON "plugin_managed_resources" ("company_id","plugin_id","resource_kind","resource_key");--> statement-breakpoint

-- secret_access_events
CREATE TABLE IF NOT EXISTS "secret_access_events" (
	"id" uuid PRIMARY KEY DEFAULT gen_random_uuid() NOT NULL,
	"company_id" uuid NOT NULL,
	"secret_id" uuid NOT NULL,
	"version" integer,
	"provider" text NOT NULL,
	"actor_type" text NOT NULL,
	"actor_id" text,
	"consumer_type" text NOT NULL,
	"consumer_id" text NOT NULL,
	"config_path" text,
	"issue_id" uuid,
	"heartbeat_run_id" uuid,
	"plugin_id" uuid,
	"outcome" text NOT NULL,
	"error_code" text,
	"created_at" timestamp with time zone DEFAULT now() NOT NULL
);--> statement-breakpoint
ALTER TABLE "secret_access_events" ADD CONSTRAINT "secret_access_events_company_id_fk" FOREIGN KEY ("company_id") REFERENCES "public"."companies"("id") ON DELETE no action ON UPDATE no action;--> statement-breakpoint
ALTER TABLE "secret_access_events" ADD CONSTRAINT "secret_access_events_secret_id_fk" FOREIGN KEY ("secret_id") REFERENCES "public"."company_secrets"("id") ON DELETE cascade ON UPDATE no action;--> statement-breakpoint
CREATE INDEX IF NOT EXISTS "secret_access_events_company_created_idx" ON "secret_access_events" ("company_id","created_at");--> statement-breakpoint
CREATE INDEX IF NOT EXISTS "secret_access_events_secret_created_idx" ON "secret_access_events" ("secret_id","created_at");--> statement-breakpoint
CREATE INDEX IF NOT EXISTS "secret_access_events_consumer_idx" ON "secret_access_events" ("company_id","consumer_type","consumer_id");--> statement-breakpoint
CREATE INDEX IF NOT EXISTS "secret_access_events_run_idx" ON "secret_access_events" ("heartbeat_run_id");
