-- Normalized vocabulary knowledge layer. Legacy session tables remain intact.
CREATE TABLE IF NOT EXISTS vocabulary_entries (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  term TEXT NOT NULL,
  normalized_term TEXT NOT NULL UNIQUE,
  entry_type TEXT NOT NULL DEFAULT 'word'
    CHECK (entry_type IN ('word','phrase','collocation','phrasal_verb','idiom')),
  ipa TEXT NOT NULL DEFAULT '',
  part_of_speech TEXT NOT NULL DEFAULT '',
  definition_en TEXT NOT NULL DEFAULT '',
  meaning_vi TEXT,
  example TEXT NOT NULL DEFAULT '',
  cefr_level TEXT CHECK (cefr_level IS NULL OR cefr_level IN ('A1','A2','B1','B2','C1','C2')),
  source_name TEXT,
  source_url TEXT,
  source_status TEXT NOT NULL DEFAULT 'draft'
    CHECK (source_status IN ('draft','verified','approved')),
  created_at TIMESTAMPTZ NOT NULL DEFAULT now(),
  updated_at TIMESTAMPTZ NOT NULL DEFAULT now()
);

CREATE TABLE IF NOT EXISTS vocabulary_senses (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  entry_id UUID NOT NULL REFERENCES vocabulary_entries(id) ON DELETE CASCADE,
  sense_number INTEGER NOT NULL DEFAULT 1,
  definition_en TEXT NOT NULL DEFAULT '',
  meaning_vi TEXT,
  cefr_level TEXT CHECK (cefr_level IS NULL OR cefr_level IN ('A1','A2','B1','B2','C1','C2')),
  example TEXT NOT NULL DEFAULT '',
  source_name TEXT,
  source_url TEXT,
  source_status TEXT NOT NULL DEFAULT 'draft'
    CHECK (source_status IN ('draft','verified','approved')),
  created_at TIMESTAMPTZ NOT NULL DEFAULT now(),
  UNIQUE(entry_id, sense_number)
);

CREATE TABLE IF NOT EXISTS vocabulary_relations (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  source_entry_id UUID NOT NULL REFERENCES vocabulary_entries(id) ON DELETE CASCADE,
  target_entry_id UUID NOT NULL REFERENCES vocabulary_entries(id) ON DELETE CASCADE,
  relation_type TEXT NOT NULL CHECK (relation_type IN ('synonym','antonym','word_family','collocation','phrasal_verb','idiom','related_phrase')),
  context TEXT NOT NULL DEFAULT '',
  source_name TEXT,
  source_url TEXT,
  verification_status TEXT NOT NULL DEFAULT 'draft'
    CHECK (verification_status IN ('draft','verified','approved')),
  created_at TIMESTAMPTZ NOT NULL DEFAULT now(),
  CHECK (source_entry_id <> target_entry_id),
  UNIQUE(source_entry_id, target_entry_id, relation_type)
);

CREATE TABLE IF NOT EXISTS topic_vocabulary (
  topic_id TEXT NOT NULL REFERENCES topics(id) ON DELETE CASCADE,
  entry_id UUID NOT NULL REFERENCES vocabulary_entries(id) ON DELETE CASCADE,
  is_primary BOOLEAN NOT NULL DEFAULT false,
  created_at TIMESTAMPTZ NOT NULL DEFAULT now(),
  PRIMARY KEY(topic_id, entry_id)
);

CREATE TABLE IF NOT EXISTS vocabulary_sources (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  entry_id UUID REFERENCES vocabulary_entries(id) ON DELETE CASCADE,
  sense_id UUID REFERENCES vocabulary_senses(id) ON DELETE CASCADE,
  source_name TEXT NOT NULL,
  source_url TEXT,
  source_type TEXT NOT NULL DEFAULT 'dictionary',
  license_note TEXT,
  checked_at TIMESTAMPTZ,
  verification_status TEXT NOT NULL DEFAULT 'draft'
    CHECK (verification_status IN ('draft','verified','approved')),
  created_at TIMESTAMPTZ NOT NULL DEFAULT now(),
  CHECK (entry_id IS NOT NULL OR sense_id IS NOT NULL)
);

CREATE INDEX IF NOT EXISTS idx_vocabulary_entries_type_level ON vocabulary_entries(entry_type, cefr_level);
CREATE INDEX IF NOT EXISTS idx_vocabulary_relations_source ON vocabulary_relations(source_entry_id);
CREATE INDEX IF NOT EXISTS idx_vocabulary_relations_target ON vocabulary_relations(target_entry_id);
CREATE INDEX IF NOT EXISTS idx_topic_vocabulary_entry ON topic_vocabulary(entry_id);

-- Private journal input used only to recommend learning topics for its owner.
CREATE TABLE IF NOT EXISTS journal_entries (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id TEXT NOT NULL,
  journal_text TEXT NOT NULL CHECK (length(btrim(journal_text)) BETWEEN 1 AND 5000),
  entry_date DATE NOT NULL DEFAULT CURRENT_DATE,
  created_at TIMESTAMPTZ NOT NULL DEFAULT now()
);
CREATE INDEX IF NOT EXISTS idx_journal_entries_user_created ON journal_entries(user_id, created_at DESC);

CREATE TABLE IF NOT EXISTS topic_recommendations (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  journal_id UUID NOT NULL REFERENCES journal_entries(id) ON DELETE CASCADE,
  user_id TEXT NOT NULL,
  topic_id TEXT NOT NULL REFERENCES topics(id) ON DELETE CASCADE,
  rank INTEGER NOT NULL CHECK (rank BETWEEN 1 AND 3),
  reason TEXT NOT NULL DEFAULT '',
  matched_terms JSONB NOT NULL DEFAULT '[]'::jsonb,
  created_at TIMESTAMPTZ NOT NULL DEFAULT now(),
  UNIQUE(journal_id, topic_id),
  UNIQUE(journal_id, rank)
);
CREATE INDEX IF NOT EXISTS idx_topic_recommendations_user_created ON topic_recommendations(user_id, created_at DESC);

-- Expand the topic catalog so the future 3,000-word bank has room to grow.
INSERT INTO topics (id, name, description, level, icon) VALUES
('education-learning','Education & Learning','Discuss learning strategies, education systems, skills, and lifelong learning.','A2-B2','✎'),
('people-relationships','People & Relationships','Talk about family, friendship, social bonds, and communication.','A1-B2','♡'),
('personality-emotions','Personality & Emotions','Describe personality, feelings, reactions, and personal growth.','A2-B2','☼'),
('food-lifestyle','Food & Lifestyle','Explore food choices, cooking, eating habits, and everyday lifestyle.','A1-B2','♧'),
('technology-ai','Technology & AI','Discuss digital tools, online life, artificial intelligence, and innovation.','A2-B2','⌘'),
('society-community','Society & Community','Explore community life, public services, social issues, and civic action.','B1-B2','⌂'),
('money-shopping','Money & Consumerism','Talk about budgeting, shopping, value, advertising, and consumer choices.','A2-B2','＄'),
('media-communication','Media & Communication','Discuss news, social media, communication styles, and information literacy.','A2-B2','◉'),
('science-innovation','Science & Innovation','Explore discoveries, research, inventions, and changes in society.','B1-B2','✧'),
('ideas-opinions','Ideas, Opinions & Problem-solving','Practise explaining opinions, comparing ideas, and proposing solutions.','B1-B2','◇')
ON CONFLICT (id) DO NOTHING;

-- Preserve existing vocabulary and session history while normalizing the dictionary layer.
INSERT INTO vocabulary_entries
  (term, normalized_term, entry_type, ipa, part_of_speech, definition_en, example, source_name, source_status)
SELECT DISTINCT ON (lower(btrim(word)))
  btrim(word), lower(btrim(word)), 'word', COALESCE(ipa,''), COALESCE(part_of_speech,''),
  COALESCE(meaning,''), COALESCE(example,''), 'legacy-demo-bank', 'draft'
FROM vocabulary_items
WHERE btrim(word) <> ''
ORDER BY lower(btrim(word)), created_at ASC
ON CONFLICT (normalized_term) DO NOTHING;

INSERT INTO topic_vocabulary (topic_id, entry_id, is_primary)
SELECT DISTINCT vi.topic_id, ve.id, true
FROM vocabulary_items vi
JOIN vocabulary_entries ve ON ve.normalized_term = lower(btrim(vi.word))
ON CONFLICT (topic_id, entry_id) DO NOTHING;

-- Small demo graph. These are app-authored examples, not claimed as verified Cambridge data.
INSERT INTO vocabulary_entries (term, normalized_term, entry_type, part_of_speech, definition_en, example, source_name, source_status)
VALUES
('sustainable','sustainable','word','adjective','able to continue over time without causing unacceptable harm','We need more sustainable ways to travel.','demo-curated — unverified','draft'),
('unsustainable','unsustainable','word','adjective','not able to continue at the same rate or in the same way','This level of waste is unsustainable.','demo-curated — unverified','draft'),
('sustainable development','sustainable development','collocation','noun phrase','development that meets current needs while protecting future generations','Sustainable development requires long-term planning.','demo-curated — unverified','draft'),
('sustainable lifestyle','sustainable lifestyle','collocation','noun phrase','a way of living that reduces avoidable environmental impact','She is trying to adopt a more sustainable lifestyle.','demo-curated — unverified','draft'),
('do your bit','do your bit','idiom','idiom','to make a contribution to a shared effort','Everyone can do their bit to reduce waste.','demo-curated — unverified','draft'),
('renewable','renewable','word','adjective','able to be naturally replaced','Solar power is a renewable source of energy.','demo-curated — unverified','draft'),
('renewable energy','renewable energy','collocation','noun phrase','energy from sources that are naturally replenished','Renewable energy can reduce dependence on fossil fuels.','demo-curated — unverified','draft'),
('conserve','conserve','word','verb','to protect something or use it carefully','We should conserve water whenever possible.','demo-curated — unverified','draft'),
('preserve','preserve','word','verb','to keep something in its existing state or protect it from harm','Local projects help preserve natural habitats.','demo-curated — unverified','draft'),
('conserve energy','conserve energy','collocation','verb phrase','to use less energy and avoid waste','Turning off unused lights helps conserve energy.','demo-curated — unverified','draft'),
('cut down on','cut down on','phrasal_verb','phrasal verb','to reduce the amount of something you use or consume','We are trying to cut down on single-use plastic.','demo-curated — unverified','draft'),
('make a difference','make a difference','idiom','idiom','to have a noticeable or useful effect','Small daily choices can make a difference.','demo-curated — unverified','draft'),
('responsible','responsible','word','adjective','having a duty to deal with something or being trusted to act well','We are responsible for our own choices.','demo-curated — unverified','draft'),
('irresponsible','irresponsible','word','adjective','not showing care or a sense of responsibility','It is irresponsible to ignore clear safety advice.','demo-curated — unverified','draft'),
('accountable','accountable','word','adjective','required to explain or accept responsibility for actions','Leaders should be accountable for their decisions.','demo-curated — unverified','draft'),
('take responsibility for','take responsibility for','collocation','verb phrase','to accept that you are responsible for something','She decided to take responsibility for the mistake.','demo-curated — unverified','draft'),
('own up to','own up to','phrasal_verb','phrasal verb','to admit that you did something wrong','He finally owned up to the error.','demo-curated — unverified','draft'),
('the buck stops here','the buck stops here','idiom','idiom','the person in charge accepts final responsibility','As team lead, the buck stops here.','demo-curated — unverified','draft')
ON CONFLICT (normalized_term) DO NOTHING;

INSERT INTO vocabulary_senses (entry_id, sense_number, definition_en, example, source_name, source_status)
SELECT id, 1, definition_en, example, source_name, 'draft'
FROM vocabulary_entries
WHERE normalized_term IN ('sustainable','unsustainable','sustainable development','sustainable lifestyle','do your bit','renewable','renewable energy','conserve','preserve','conserve energy','cut down on','make a difference','responsible','irresponsible','accountable','take responsibility for','own up to','the buck stops here')
ON CONFLICT (entry_id, sense_number) DO NOTHING;

INSERT INTO topic_vocabulary (topic_id, entry_id, is_primary)
SELECT 'environment', id, true FROM vocabulary_entries
WHERE normalized_term IN ('sustainable','unsustainable','sustainable development','sustainable lifestyle','do your bit','renewable','renewable energy','conserve','preserve','conserve energy','cut down on','make a difference')
ON CONFLICT (topic_id, entry_id) DO NOTHING;

INSERT INTO topic_vocabulary (topic_id, entry_id, is_primary)
SELECT 'work-study', id, true FROM vocabulary_entries
WHERE normalized_term IN ('responsible','irresponsible','accountable','take responsibility for','own up to','the buck stops here')
ON CONFLICT (topic_id, entry_id) DO NOTHING;

INSERT INTO vocabulary_relations (source_entry_id, target_entry_id, relation_type, context, verification_status)
SELECT a.id, b.id, rel.relation_type, rel.context, 'draft'
FROM (VALUES
 ('sustainable','unsustainable','antonym','Environmental and long-term viability context'),
 ('sustainable','sustainable development','collocation','Common noun phrase'),
 ('sustainable','sustainable lifestyle','collocation','Lifestyle context'),
 ('sustainable','do your bit','idiom','Related expression for taking practical action'),
 ('renewable','renewable energy','collocation','Energy context'),
 ('conserve','preserve','synonym','Overlap in the sense of protecting something; not interchangeable in every context'),
 ('conserve','conserve energy','collocation','Resource-use context'),
 ('conserve','cut down on','phrasal_verb','Related strategy for reducing consumption'),
 ('sustainable','make a difference','idiom','Related expression for meaningful impact'),
 ('responsible','irresponsible','antonym','Responsibility and care'),
 ('responsible','accountable','synonym','Related in contexts involving responsibility; meanings are not identical'),
 ('responsible','take responsibility for','collocation','Common verb phrase'),
 ('responsible','own up to','phrasal_verb','Related to admitting an action or mistake'),
 ('responsible','the buck stops here','idiom','Related expression for accepting final responsibility')
) AS rel(source_term,target_term,relation_type,context)
JOIN vocabulary_entries a ON a.normalized_term = rel.source_term
JOIN vocabulary_entries b ON b.normalized_term = rel.target_term
ON CONFLICT (source_entry_id, target_entry_id, relation_type) DO NOTHING;

INSERT INTO vocabulary_sources (entry_id, source_name, source_type, license_note, verification_status)
SELECT id, source_name, 'app-authored-demo', 'Demo-authored examples; not copied from Cambridge Dictionary.', 'draft'
FROM vocabulary_entries
WHERE source_name = 'demo-curated — unverified'
ON CONFLICT DO NOTHING;