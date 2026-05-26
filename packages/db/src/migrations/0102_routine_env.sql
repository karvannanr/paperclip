ALTER TABLE "routines" ADD COLUMN IF NOT EXISTS "env" jsonb;--> statement-breakpoint
ALTER TABLE "routines" ADD COLUMN IF NOT EXISTS "latest_revision_id" uuid;--> statement-breakpoint
ALTER TABLE "routines" ADD COLUMN IF NOT EXISTS "latest_revision_number" integer DEFAULT 1 NOT NULL;
