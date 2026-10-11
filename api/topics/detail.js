import { db } from 'hatchable';
export const access = 'public';
export const methods = ['GET'];
export default async function (req, res) {
  const topicId = String(req.query?.topicId || '').trim();
  if (!topicId) return res.status(400).json({ error: 'topicId is required.' });
  const { rows: topics } = await db.query(
    'SELECT id, name, description, level, icon FROM topics WHERE id = $1',
    [topicId]
  );
  if (!topics.length) return res.status(404).json({ error: 'Topic not found.' });
  const topic = topics[0];
  const [{ rows: counts }, { rows: words }] = await Promise.all([
    db.query(`SELECT
      COUNT(*)::int AS total_entries,
      COUNT(*) FILTER (WHERE ve.entry_type = 'word')::int AS single_words,
      COUNT(*) FILTER (WHERE ve.entry_type <> 'word')::int AS expressions,
      COUNT(*) FILTER (WHERE ve.cefr_level = 'B1')::int AS b1_count,
      COUNT(*) FILTER (WHERE ve.cefr_level = 'B2')::int AS b2_count
      FROM topic_vocabulary tv
      JOIN vocabulary_entries ve ON ve.id = tv.entry_id
      WHERE tv.topic_id = $1`, [topicId]),
    db.query(`SELECT ve.id, ve.term, ve.entry_type, ve.ipa, ve.part_of_speech,
      ve.definition_en, ve.meaning_vi, ve.example, ve.cefr_level, ve.source_status,
      r.review_status AS mapping_status, r.confidence AS mapping_confidence
      FROM topic_vocabulary tv
      JOIN vocabulary_entries ve ON ve.id = tv.entry_id
      LEFT JOIN topic_classification_reviews r ON r.entry_id = ve.id
      WHERE tv.topic_id = $1
      ORDER BY COALESCE(r.confidence, 0) DESC,
        CASE ve.cefr_level WHEN 'A1' THEN 0 WHEN 'A2' THEN 1 WHEN 'B1' THEN 2 WHEN 'B2' THEN 3 ELSE 4 END,
        CASE ve.entry_type WHEN 'word' THEN 0 ELSE 1 END, length(ve.term), ve.term
      LIMIT 12`, [topicId])
  ]);
  res.json({ topic, counts: counts[0] || { total_entries: 0, single_words: 0, expressions: 0, b1_count: 0, b2_count: 0 }, words });
}