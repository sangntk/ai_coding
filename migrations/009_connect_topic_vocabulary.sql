-- Give vocabulary nodes a navigable graph neighborhood.
-- These are explicitly topic associations, not claims of synonymy.
WITH ordered AS (
  SELECT tv.topic_id,t.name AS topic_name,tv.entry_id,
         LAG(tv.entry_id) OVER (PARTITION BY tv.topic_id ORDER BY ve.normalized_term) AS previous_entry_id
    FROM topic_vocabulary tv
    JOIN topics t ON t.id=tv.topic_id
    JOIN vocabulary_entries ve ON ve.id=tv.entry_id
)
INSERT INTO vocabulary_relations
  (source_entry_id,target_entry_id,relation_type,context,source_name,verification_status)
SELECT previous_entry_id,entry_id,'related_phrase',
       'Topic association: '||topic_name||'. Adjacent vocabulary in the same topic bank; not necessarily synonyms.',
       'topic-bank adjacency; needs semantic review','draft'
  FROM ordered
 WHERE previous_entry_id IS NOT NULL
   AND previous_entry_id <> entry_id
ON CONFLICT (source_entry_id,target_entry_id,relation_type) DO NOTHING;

CREATE INDEX IF NOT EXISTS idx_journal_entries_user_date
  ON journal_entries(user_id,entry_date DESC,created_at DESC);