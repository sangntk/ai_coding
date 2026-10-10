-- Keep optional re-test results separate from the first post-test.
ALTER TABLE learning_sessions
  ADD COLUMN IF NOT EXISTS retest_score INTEGER,
  ADD COLUMN IF NOT EXISTS retest_total INTEGER,
  ADD COLUMN IF NOT EXISTS retest_answers JSONB NOT NULL DEFAULT '[]'::jsonb,
  ADD COLUMN IF NOT EXISTS retest_completed_at TIMESTAMPTZ;