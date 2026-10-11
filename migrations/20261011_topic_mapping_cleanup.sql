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