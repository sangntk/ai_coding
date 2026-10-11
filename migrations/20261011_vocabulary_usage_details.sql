CREATE TABLE IF NOT EXISTS vocabulary_usage_details (
  entry_id uuid PRIMARY KEY REFERENCES vocabulary_entries(id) ON DELETE CASCADE,
  collocations jsonb NOT NULL DEFAULT '[]'::jsonb,
  word_family jsonb NOT NULL DEFAULT '[]'::jsonb,
  common_errors jsonb NOT NULL DEFAULT '[]'::jsonb,
  ipa_us text,
  ipa_uk text,
  ipa_us_source_url text,
  ipa_uk_source_url text,
  ipa_us_license text,
  ipa_uk_license text,
  dictionary_source_url text,
  lexical_source_url text,
  lexical_source_license text,
  cefr_status text NOT NULL DEFAULT 'source_estimate',
  quality_status text NOT NULL DEFAULT 'draft',
  quality_notes jsonb NOT NULL DEFAULT '[]'::jsonb,
  batch_number integer,
  updated_at timestamptz NOT NULL DEFAULT now()
);

ALTER TABLE vocabulary_usage_details ADD COLUMN IF NOT EXISTS lexical_source_url text;
ALTER TABLE vocabulary_usage_details ADD COLUMN IF NOT EXISTS lexical_source_license text;

CREATE INDEX IF NOT EXISTS idx_vocabulary_usage_details_batch ON vocabulary_usage_details(batch_number, updated_at DESC);
CREATE INDEX IF NOT EXISTS idx_vocabulary_usage_details_quality ON vocabulary_usage_details(quality_status, cefr_status);