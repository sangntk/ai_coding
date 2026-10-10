-- Persist assessment results and make mastery depend on demonstrated recall.
ALTER TABLE learning_sessions
  ADD COLUMN IF NOT EXISTS pre_test_score INTEGER,
  ADD COLUMN IF NOT EXISTS pre_test_total INTEGER,
  ADD COLUMN IF NOT EXISTS pre_test_answers JSONB NOT NULL DEFAULT '[]'::jsonb,
  ADD COLUMN IF NOT EXISTS learning_focus JSONB NOT NULL DEFAULT '[]'::jsonb,
  ADD COLUMN IF NOT EXISTS pre_test_completed_at TIMESTAMPTZ,
  ADD COLUMN IF NOT EXISTS post_test_score INTEGER,
  ADD COLUMN IF NOT EXISTS post_test_total INTEGER,
  ADD COLUMN IF NOT EXISTS post_test_answers JSONB NOT NULL DEFAULT '[]'::jsonb,
  ADD COLUMN IF NOT EXISTS post_test_completed_at TIMESTAMPTZ;

ALTER TABLE exercise_attempts
  ADD COLUMN IF NOT EXISTS attempt_status TEXT NOT NULL DEFAULT 'complete'
    CHECK (attempt_status IN ('pending','complete','failed'));

-- Existing mastery is a 0–5 recall scale, not a count of appearances.
CREATE INDEX IF NOT EXISTS idx_sessions_user_topic_created
  ON learning_sessions(user_id, topic_id, created_at DESC);
CREATE INDEX IF NOT EXISTS idx_progress_user_mastery
  ON user_vocabulary_progress(user_id, mastery);