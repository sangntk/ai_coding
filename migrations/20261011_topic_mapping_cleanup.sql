-- Reusable topic-classification review store.
-- AI classifications remain ai_proposed until a human review process promotes them.
CREATE TABLE IF NOT EXISTS topic_classification_reviews (
  entry_id uuid PRIMARY KEY,
  topics text[] NOT NULL DEFAULT '{}',
  confidence numeric,
  classification_method text NOT NULL DEFAULT 'ai-suggested',
  review_status text NOT NULL DEFAULT 'ai_proposed',
  rationale text,
  updated_at timestamptz NOT NULL DEFAULT now()
);
CREATE INDEX IF NOT EXISTS idx_topic_classification_review_status
  ON topic_classification_reviews (review_status, updated_at DESC);
CREATE INDEX IF NOT EXISTS idx_topic_classification_topics
  ON topic_classification_reviews USING GIN (topics);

-- Allow an explicit exclusion state for malformed or low-quality imported terms.
ALTER TABLE vocabulary_entries DROP CONSTRAINT IF EXISTS vocabulary_entries_source_status_check;
ALTER TABLE vocabulary_entries ADD CONSTRAINT vocabulary_entries_source_status_check
  CHECK (source_status = ANY (ARRAY['draft','verified','approved','rejected']::text[]));