-- company_secrets: add missing columns
ALTER TABLE "company_secrets" ADD COLUMN IF NOT EXISTS "key" text NOT NULL DEFAULT '';--> statement-breakpoint
ALTER TABLE "company_secrets" ADD COLUMN IF NOT EXISTS "status" text NOT NULL DEFAULT 'active';--> statement-breakpoint
ALTER TABLE "company_secrets" ADD COLUMN IF NOT EXISTS "managed_mode" text NOT NULL DEFAULT 'paperclip_managed';--> statement-breakpoint
ALTER TABLE "company_secrets" ADD COLUMN IF NOT EXISTS "provider_config_id" uuid;--> statement-breakpoint
ALTER TABLE "company_secrets" ADD COLUMN IF NOT EXISTS "provider_metadata" jsonb;--> statement-breakpoint
ALTER TABLE "company_secrets" ADD COLUMN IF NOT EXISTS "last_resolved_at" timestamp with time zone;--> statement-breakpoint
ALTER TABLE "company_secrets" ADD COLUMN IF NOT EXISTS "last_rotated_at" timestamp with time zone;--> statement-breakpoint
ALTER TABLE "company_secrets" ADD COLUMN IF NOT EXISTS "deleted_at" timestamp with time zone;--> statement-breakpoint
CREATE UNIQUE INDEX IF NOT EXISTS "company_secrets_company_key_uq" ON "company_secrets" ("company_id","key");--> statement-breakpoint
CREATE INDEX IF NOT EXISTS "company_secrets_company_provider_idx" ON "company_secrets" ("company_id","provider");--> statement-breakpoint
CREATE INDEX IF NOT EXISTS "company_secrets_provider_config_idx" ON "company_secrets" ("provider_config_id");
