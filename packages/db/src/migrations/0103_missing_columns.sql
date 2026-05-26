-- routine_revisions table (missing entirely)
CREATE TABLE IF NOT EXISTS "routine_revisions" (
	"id" uuid PRIMARY KEY DEFAULT gen_random_uuid() NOT NULL,
	"company_id" uuid NOT NULL,
	"routine_id" uuid NOT NULL,
	"revision_number" integer NOT NULL,
	"title" text NOT NULL,
	"description" text,
	"snapshot" jsonb NOT NULL,
	"change_summary" text,
	"restored_from_revision_id" uuid,
	"created_by_agent_id" uuid,
	"created_by_user_id" text,
	"created_by_run_id" uuid,
	"created_at" timestamp with time zone DEFAULT now() NOT NULL
);--> statement-breakpoint
ALTER TABLE "routine_revisions" ADD CONSTRAINT "routine_revisions_company_id_companies_id_fk" FOREIGN KEY ("company_id") REFERENCES "public"."companies"("id") ON DELETE cascade ON UPDATE no action;--> statement-breakpoint
ALTER TABLE "routine_revisions" ADD CONSTRAINT "routine_revisions_routine_id_routines_id_fk" FOREIGN KEY ("routine_id") REFERENCES "public"."routines"("id") ON DELETE cascade ON UPDATE no action;--> statement-breakpoint
CREATE UNIQUE INDEX IF NOT EXISTS "routine_revisions_routine_revision_uq" ON "routine_revisions" ("routine_id","revision_number");--> statement-breakpoint
CREATE INDEX IF NOT EXISTS "routine_revisions_company_routine_created_idx" ON "routine_revisions" ("company_id","routine_id","created_at");--> statement-breakpoint

-- routines: missing columns
ALTER TABLE "routines" ADD COLUMN IF NOT EXISTS "latest_revision_id" uuid;--> statement-breakpoint
ALTER TABLE "routines" ADD COLUMN IF NOT EXISTS "latest_revision_number" integer DEFAULT 1 NOT NULL;--> statement-breakpoint

-- routine_runs: missing column
ALTER TABLE "routine_runs" ADD COLUMN IF NOT EXISTS "routine_revision_id" uuid;--> statement-breakpoint

-- issues: missing monitor + work_mode columns
ALTER TABLE "issues" ADD COLUMN IF NOT EXISTS "work_mode" text DEFAULT 'standard' NOT NULL;--> statement-breakpoint
ALTER TABLE "issues" ADD COLUMN IF NOT EXISTS "monitor_next_check_at" timestamp with time zone;--> statement-breakpoint
ALTER TABLE "issues" ADD COLUMN IF NOT EXISTS "monitor_wake_requested_at" timestamp with time zone;--> statement-breakpoint
ALTER TABLE "issues" ADD COLUMN IF NOT EXISTS "monitor_last_triggered_at" timestamp with time zone;--> statement-breakpoint
ALTER TABLE "issues" ADD COLUMN IF NOT EXISTS "monitor_attempt_count" integer DEFAULT 0 NOT NULL;--> statement-breakpoint
ALTER TABLE "issues" ADD COLUMN IF NOT EXISTS "monitor_notes" text;--> statement-breakpoint
ALTER TABLE "issues" ADD COLUMN IF NOT EXISTS "monitor_scheduled_by" text;
