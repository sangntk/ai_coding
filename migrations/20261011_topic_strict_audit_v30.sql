-- Staging/audit trail for stricter semantic topic classification.
-- These are proposals, not human approvals. Keep the existing review table as the active record.
CREATE TABLE IF NOT EXISTS topic_classification_audit_v30 (
  entry_id uuid PRIMARY KEY,
  proposed_topics text[] NOT NULL DEFAULT '{}',
  confidence numeric,
  rationale text,
  classification_method text NOT NULL DEFAULT 'strict AI audit',
  review_status text NOT NULL DEFAULT 'staged',
  updated_at timestamptz NOT NULL DEFAULT now()
);
CREATE INDEX IF NOT EXISTS idx_topic_audit_v30_status
  ON topic_classification_audit_v30 (review_status);