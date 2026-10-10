CREATE TABLE IF NOT EXISTS profiles (
  user_id TEXT PRIMARY KEY,
  display_name TEXT,
  level TEXT NOT NULL DEFAULT 'A2',
  goal TEXT NOT NULL DEFAULT 'Build vocabulary for speaking and writing',
  created_at TIMESTAMPTZ NOT NULL DEFAULT now(),
  updated_at TIMESTAMPTZ NOT NULL DEFAULT now()
);

CREATE TABLE IF NOT EXISTS topics (
  id TEXT PRIMARY KEY,
  name TEXT NOT NULL,
  description TEXT NOT NULL,
  level TEXT NOT NULL DEFAULT 'A2-B1',
  icon TEXT NOT NULL DEFAULT '✦'
);

CREATE TABLE IF NOT EXISTS learning_sessions (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id TEXT NOT NULL,
  topic_id TEXT NOT NULL REFERENCES topics(id),
  session_number INTEGER NOT NULL DEFAULT 1,
  status TEXT NOT NULL DEFAULT 'started',
  created_at TIMESTAMPTZ NOT NULL DEFAULT now(),
  completed_at TIMESTAMPTZ
);

CREATE TABLE IF NOT EXISTS vocabulary_items (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  topic_id TEXT NOT NULL REFERENCES topics(id),
  word TEXT NOT NULL,
  ipa TEXT NOT NULL DEFAULT '',
  part_of_speech TEXT NOT NULL DEFAULT '',
  meaning TEXT NOT NULL,
  example TEXT NOT NULL,
  level TEXT NOT NULL DEFAULT 'A2-B1',
  created_at TIMESTAMPTZ NOT NULL DEFAULT now(),
  UNIQUE(topic_id, word)
);

CREATE TABLE IF NOT EXISTS session_vocabulary (
  session_id UUID NOT NULL REFERENCES learning_sessions(id) ON DELETE CASCADE,
  vocabulary_id UUID NOT NULL REFERENCES vocabulary_items(id) ON DELETE CASCADE,
  position INTEGER NOT NULL DEFAULT 0,
  PRIMARY KEY(session_id, vocabulary_id)
);

CREATE TABLE IF NOT EXISTS exercise_attempts (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id TEXT NOT NULL,
  session_id UUID REFERENCES learning_sessions(id) ON DELETE SET NULL,
  topic_id TEXT NOT NULL REFERENCES topics(id),
  exercise_type TEXT NOT NULL,
  prompt TEXT NOT NULL,
  answer TEXT NOT NULL,
  feedback TEXT NOT NULL DEFAULT '',
  score INTEGER,
  created_at TIMESTAMPTZ NOT NULL DEFAULT now()
);

CREATE TABLE IF NOT EXISTS user_vocabulary_progress (
  user_id TEXT NOT NULL,
  vocabulary_id UUID NOT NULL REFERENCES vocabulary_items(id) ON DELETE CASCADE,
  mastery INTEGER NOT NULL DEFAULT 0 CHECK (mastery >= 0 AND mastery <= 5),
  times_seen INTEGER NOT NULL DEFAULT 0,
  times_correct INTEGER NOT NULL DEFAULT 0,
  last_reviewed_at TIMESTAMPTZ,
  updated_at TIMESTAMPTZ NOT NULL DEFAULT now(),
  PRIMARY KEY(user_id, vocabulary_id)
);

CREATE INDEX IF NOT EXISTS idx_sessions_user_created ON learning_sessions(user_id, created_at DESC);
CREATE INDEX IF NOT EXISTS idx_attempts_user_created ON exercise_attempts(user_id, created_at DESC);
CREATE INDEX IF NOT EXISTS idx_vocab_topic ON vocabulary_items(topic_id);