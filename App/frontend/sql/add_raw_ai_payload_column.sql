-- Run once on Supabase / Postgres if the column is missing.
ALTER TABLE disease_scans ADD COLUMN IF NOT EXISTS raw_ai_payload JSONB;
