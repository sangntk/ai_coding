CREATE TABLE IF NOT EXISTS vocabulary_import_sources (
  source_key text PRIMARY KEY, source_name text NOT NULL, source_url text NOT NULL,
  license text NOT NULL, attribution text NOT NULL, version_label text, notes text,
  imported_at timestamptz, record_count integer NOT NULL DEFAULT 0, content_sha256 text
);
CREATE TABLE IF NOT EXISTS vocabulary_source_records (
  source_key text NOT NULL, source_record_id text NOT NULL, term text NOT NULL,
  normalized_term text NOT NULL, part_of_speech text NOT NULL DEFAULT '',
  source_level_score numeric, cefr_level text, frequency_count bigint,
  ipa_us text, ipa_uk text, source_url text NOT NULL, license text NOT NULL,
  raw_metadata jsonb NOT NULL DEFAULT '{}'::jsonb, imported_at timestamptz NOT NULL DEFAULT now(),
  ipa_us_source_url text, ipa_us_license text, ipa_uk_source_url text, ipa_uk_license text,
  PRIMARY KEY (source_key, source_record_id)
);
ALTER TABLE vocabulary_source_records ADD COLUMN IF NOT EXISTS ipa_us_source_url text;
ALTER TABLE vocabulary_source_records ADD COLUMN IF NOT EXISTS ipa_us_license text;
ALTER TABLE vocabulary_source_records ADD COLUMN IF NOT EXISTS ipa_uk_source_url text;
ALTER TABLE vocabulary_source_records ADD COLUMN IF NOT EXISTS ipa_uk_license text;
CREATE INDEX IF NOT EXISTS idx_vocabulary_source_records_term ON vocabulary_source_records (normalized_term);
CREATE INDEX IF NOT EXISTS idx_vocabulary_source_records_level_frequency ON vocabulary_source_records (cefr_level, frequency_count DESC);
CREATE INDEX IF NOT EXISTS idx_vocabulary_source_records_pos ON vocabulary_source_records (part_of_speech);
INSERT INTO vocabulary_import_sources (source_key,source_name,source_url,license,attribution,version_label,notes)
VALUES
('words-cefr-dataset','Words-CEFR-Dataset','https://github.com/Maximax67/Words-CEFR-Dataset','MIT repository license; preserve upstream acknowledgements','Maxim Belikov / Maximax67; see README for CEFR-J, Google Books Ngram and other upstream sources','main branch snapshot','Computed CEFR estimates, not an official CEFR Vocabulary Profile. Preserve raw score and source row ID.'),
('ipa-dict-en-us','ipa-dict English US','https://github.com/open-dict-data/ipa-dict','MIT for en_US per repository credits; retain third-party attribution','open-dict-data/ipa-dict and modified cmudict-ipa upstream','master snapshot','Broadly phonemic US pronunciation.'),
('ipa-dict-en-uk','ipa-dict English UK','https://github.com/open-dict-data/ipa-dict','GPL-3.0 for en_UK per repository credits (ipacards-derived)','open-dict-data/ipa-dict and ipacards upstream','master snapshot','Track this license separately; assess redistribution obligations.'),
('open-english-wordnet-2025','Open English WordNet 2025','https://en-word.net/downloads','CC BY 4.0','Open English Wordnet community','2025-12-31','Candidate source for future graph refresh; this import did not parse the archive into the database.')
ON CONFLICT (source_key) DO UPDATE SET source_name=EXCLUDED.source_name,source_url=EXCLUDED.source_url,license=EXCLUDED.license,attribution=EXCLUDED.attribution,version_label=EXCLUDED.version_label,notes=EXCLUDED.notes;