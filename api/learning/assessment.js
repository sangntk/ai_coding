import { db } from 'hatchable';
export const access = 'user';
export const methods = ['POST'];
const norm = v => String(v || '').trim().toLowerCase();

export default async function (req, res) {
  const userId = req.user.id;
  const sessionId = String(req.body?.sessionId || '');
  const stage = String(req.body?.stage || '');
  const answers = Array.isArray(req.body?.answers) ? req.body.answers : [];
  if (!sessionId) return res.status(400).json({ error: 'sessionId is required.' });
  if (!['pre', 'post', 'retest'].includes(stage)) return res.status(400).json({ error: 'stage must be pre, post, or retest.' });
  if (answers.length < 1 || answers.length > 12) return res.status(400).json({ error: 'Submit between 1 and 12 answers.' });

  const sessionQ = await db.query(
    'SELECT id,topic_id,status,pre_test_completed_at,post_test_completed_at,post_test_score,post_test_total,retest_completed_at,retest_score,retest_total,learning_focus FROM learning_sessions WHERE id=$1 AND user_id=$2',
    [sessionId, userId]
  );
  if (!sessionQ.rows.length) return res.status(404).json({ error: 'Learning session not found.' });
  const session = sessionQ.rows[0];
  if (session.status !== 'started') return res.status(409).json({ error: 'This session is no longer active.' });
  if (stage === 'pre' && session.pre_test_completed_at) return res.json({ saved: true, score: session.pre_test_score, total: session.pre_test_total, learningFocus: session.learning_focus || [] });
  if (stage === 'post' && session.post_test_completed_at) return res.json({ saved: true, score: session.post_test_score, total: session.post_test_total, percentage: Math.round(Number(session.post_test_score || 0) * 100 / Math.max(1, Number(session.post_test_total || 0))), alreadyRecorded: true });
  if (stage === 'retest' && session.retest_completed_at) return res.json({ saved: true, score: session.retest_score, total: session.retest_total, percentage: Math.round(Number(session.retest_score || 0) * 100 / Math.max(1, Number(session.retest_total || 0))), alreadyRecorded: true });
  if (stage !== 'pre' && !session.pre_test_completed_at) return res.status(409).json({ error: 'Complete and save the pre-test first.' });
  if (stage === 'retest' && !session.post_test_completed_at) return res.status(409).json({ error: 'Complete the post-test before taking a re-test.' });

  const vocabQ = await db.query(
    'SELECT vi.id,vi.word FROM session_vocabulary sv JOIN vocabulary_items vi ON vi.id=sv.vocabulary_id WHERE sv.session_id=$1 ORDER BY sv.position',
    [sessionId]
  );
  const byWord = new Map(vocabQ.rows.map(v => [norm(v.word), v]));
  const normalizedAnswers = [];
  for (const item of answers) {
    const word = norm(item?.word);
    if (!word || !byWord.has(word)) return res.status(400).json({ error: 'An answer references a word outside this session.' });
    normalizedAnswers.push({ word: byWord.get(word).word, correct: item.correct === true });
  }
  if (new Set(normalizedAnswers.map(a => norm(a.word))).size !== normalizedAnswers.length) return res.status(400).json({ error: 'Duplicate answers are not allowed.' });
  const score = normalizedAnswers.filter(a => a.correct).length;
  const total = normalizedAnswers.length;

  if (stage === 'pre') {
    const learningFocus = normalizedAnswers.filter(a => !a.correct).map(a => a.word);
    await db.query(
      'UPDATE learning_sessions SET pre_test_score=$1,pre_test_total=$2,pre_test_answers=$3::jsonb,learning_focus=$4::jsonb,pre_test_completed_at=now() WHERE id=$5 AND user_id=$6',
      [score, total, JSON.stringify(normalizedAnswers), JSON.stringify(learningFocus), sessionId, userId]
    );
    return res.json({ saved: true, score, total, learningFocus });
  }

  // Only post-test and re-test recall changes mastery; viewing a card never does.
  for (const answer of normalizedAnswers) {
    const vocab = byWord.get(norm(answer.word));
    await db.query(
      `INSERT INTO user_vocabulary_progress (user_id,vocabulary_id,mastery,times_seen,times_correct,last_reviewed_at,updated_at)
       VALUES ($1,$2,$3,1,$4,now(),now())
       ON CONFLICT (user_id,vocabulary_id) DO UPDATE SET
         mastery=CASE WHEN $3=1 THEN LEAST(5,user_vocabulary_progress.mastery+1) ELSE GREATEST(0,user_vocabulary_progress.mastery-1) END,
         times_correct=user_vocabulary_progress.times_correct+$4,
         last_reviewed_at=now(),updated_at=now()`,
      [userId, vocab.id, answer.correct ? 1 : 0, answer.correct ? 1 : 0]
    );
  }

  if (stage === 'post') {
    await db.query(
      'UPDATE learning_sessions SET post_test_score=$1,post_test_total=$2,post_test_answers=$3::jsonb,post_test_completed_at=now() WHERE id=$4 AND user_id=$5',
      [score, total, JSON.stringify(normalizedAnswers), sessionId, userId]
    );
  } else {
    await db.query(
      'UPDATE learning_sessions SET retest_score=$1,retest_total=$2,retest_answers=$3::jsonb,retest_completed_at=now() WHERE id=$4 AND user_id=$5',
      [score, total, JSON.stringify(normalizedAnswers), sessionId, userId]
    );
  }
  return res.json({ saved: true, stage, score, total, percentage: Math.round(score * 100 / total) });
}