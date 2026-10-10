import { db } from 'hatchable';

export const access = 'user';
export const methods = ['GET'];

export default async function (req, res) {
  const term = String(req.query?.term || '').trim().toLowerCase();
  if (!term) return res.status(400).json({ error: 'term is required.' });

  const rootResult = await db.query(
    'SELECT id, term, entry_type, ipa, part_of_speech, definition_en, meaning_vi, example, cefr_level, source_name, source_url, source_status FROM vocabulary_entries WHERE normalized_term = $1 LIMIT 1',
    [term]
  );
  if (!rootResult.rows.length) return res.status(404).json({ error: 'No vocabulary graph found for this term yet.' });
  const root = rootResult.rows[0];

  const senseResult = await db.query(
    'SELECT id, sense_number, definition_en, meaning_vi, cefr_level, example, source_name, source_url, source_status FROM vocabulary_senses WHERE entry_id = $1 ORDER BY sense_number LIMIT 12',
    [root.id]
  );

  const relationResult = await db.query(
    `SELECT r.id AS relation_id, r.relation_type, r.context, r.verification_status,
            e.id AS related_id, e.term AS related_term, e.entry_type AS related_type,
            e.ipa AS related_ipa, e.part_of_speech AS related_part_of_speech,
            e.definition_en AS related_definition, e.meaning_vi AS related_meaning_vi,
            e.example AS related_example, e.cefr_level AS related_cefr_level,
            e.source_status AS related_source_status
       FROM vocabulary_relations r
       JOIN vocabulary_entries e
         ON e.id = CASE WHEN r.source_entry_id = $1 THEN r.target_entry_id ELSE r.source_entry_id END
      WHERE (r.source_entry_id = $1 OR r.target_entry_id = $1)
        AND NOT (r.relation_type = 'related_phrase' AND (r.context ILIKE 'Topic association:%' OR r.context ILIKE 'Session topic association%'))
      ORDER BY CASE r.relation_type WHEN 'synonym' THEN 1 WHEN 'antonym' THEN 2 WHEN 'collocation' THEN 3 WHEN 'word_family' THEN 4 WHEN 'phrasal_verb' THEN 5 WHEN 'idiom' THEN 6 ELSE 7 END, e.term
      LIMIT 30`,
    [root.id]
  );

  const topicResult = await db.query(
    'SELECT t.id, t.name FROM topic_vocabulary tv JOIN topics t ON t.id = tv.topic_id WHERE tv.entry_id = $1 ORDER BY t.name',
    [root.id]
  );

  return res.json({ root, senses: senseResult.rows, relations: relationResult.rows, topics: topicResult.rows });
}