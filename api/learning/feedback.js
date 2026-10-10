import { db, ai } from 'hatchable';
export const access = 'user';
export const methods = ['POST'];

function cleanJson(text) {
  return String(text || '').replace(/^```(?:json)?/i, '').replace(/```$/, '').trim();
}

export default async function (req, res) {
  const userId = req.user.id;
  const topicId = String(req.body?.topicId || '');
  const answer = String(req.body?.answer || '').trim();
  const exerciseType = String(req.body?.exerciseType || 'writing');
  const sessionId = req.body?.sessionId ? String(req.body.sessionId) : null;
  const attemptId = req.body?.attemptId ? String(req.body.attemptId) : null;
  const words = Array.isArray(req.body?.words) ? req.body.words.slice(0, 12).map(x => String(x).slice(0, 60)) : [];

  if (answer.length < 10 || answer.length > 4000) return res.status(400).json({ error: 'Please provide an answer between 10 and 4,000 characters.' });
  if (!['writing', 'speaking'].includes(exerciseType)) return res.status(400).json({ error: 'Unsupported practice type.' });
  const topicQ = await db.query('SELECT id,name FROM topics WHERE id=$1', [topicId]);
  if (!topicQ.rows.length) return res.status(400).json({ error: 'Unknown topic.' });

  if (sessionId) {
    const s = await db.query('SELECT id,status,topic_id,pre_test_completed_at FROM learning_sessions WHERE id=$1 AND user_id=$2', [sessionId, userId]);
    if (!s.rows.length) return res.status(404).json({ error: 'Learning session not found.' });
    if (s.rows[0].status !== 'started') return res.status(409).json({ error: 'This session is no longer active.' });
    if (s.rows[0].topic_id !== topicId) return res.status(400).json({ error: 'The topic does not match this session.' });
    if (!s.rows[0].pre_test_completed_at) return res.status(409).json({ error: 'Save the pre-test before submitting practice.' });
  }

  let attempt;
  if (attemptId) {
    const existing = await db.query('SELECT id,session_id FROM exercise_attempts WHERE id=$1 AND user_id=$2', [attemptId, userId]);
    if (!existing.rows.length || (sessionId && existing.rows[0].session_id !== sessionId)) return res.status(404).json({ error: 'Saved practice draft not found.' });
    attempt = existing.rows[0];
    await db.query("UPDATE exercise_attempts SET topic_id=$1,exercise_type=$2,answer=$3,attempt_status='pending' WHERE id=$4 AND user_id=$5", [topicId, exerciseType, answer, attempt.id, userId]);
  } else {
    const created = await db.query(
      "INSERT INTO exercise_attempts (user_id,session_id,topic_id,exercise_type,prompt,answer,feedback,score,attempt_status) VALUES ($1,$2,$3,$4,$5,$6,'AI feedback pending',NULL,'pending') RETURNING id,session_id",
      [userId, sessionId, topicId, exerciseType, `Practice ${exerciseType} for ${topicQ.rows[0].name}`, answer]
    );
    attempt = created.rows[0];
  }

  let result;
  try {
    const r = await ai.generateText({
      purpose: 'english-practice-feedback',
      model: 'gpt-mini',
      userId,
      maxTokens: 1400,
      system: 'You are a kind but precise English tutor for A1-B2 learners. Return only valid JSON with keys score (integer 0-100), feedback (short supportive paragraph with specific corrections), corrected (a natural improved version preserving the learner meaning), nextStep (one actionable practice suggestion), strengths (array of strings), improvements (array of strings). Do not invent errors; if the answer is already correct, say so.',
      prompt: `Topic: ${topicQ.rows[0].name}\nPractice type: ${exerciseType}\nVocabulary the learner has studied: ${words.join(', ')}\nLearner answer:\n${answer}\nEvaluate grammar, vocabulary use, clarity and naturalness for A1-B2. Score out of 100. Keep feedback practical and learner-friendly.`
    });
    if (r.finishReason === 'length') throw new Error('AI response was truncated.');
    result = JSON.parse(cleanJson(r.text));
    const score = Number(result.score);
    if (!Number.isFinite(score) || !Array.isArray(result.strengths) || !Array.isArray(result.improvements) || typeof result.feedback !== 'string' || typeof result.corrected !== 'string' || typeof result.nextStep !== 'string') {
      throw new Error('AI response did not match the required feedback schema.');
    }
    result.score = Math.max(0, Math.min(100, Math.round(score)));
    result.strengths = result.strengths.map(x => String(x)).slice(0, 5);
    result.improvements = result.improvements.map(x => String(x)).slice(0, 5);
  } catch (e) {
    await db.query("UPDATE exercise_attempts SET feedback=$1,attempt_status='pending' WHERE id=$2 AND user_id=$3", ['AI feedback unavailable; answer saved for retry.', attempt.id, userId]);
    return res.status(503).json({ error: 'AI feedback is temporarily unavailable. Your answer has been saved; retry without losing it.', attemptId: attempt.id, saved: true });
  }

  await db.query(
    "UPDATE exercise_attempts SET answer=$1,feedback=$2,score=$3,attempt_status='complete' WHERE id=$4 AND user_id=$5",
    [answer, JSON.stringify(result), result.score, attempt.id, userId]
  );
  return res.json({ attempt: { id: attempt.id, score: result.score }, attemptId: attempt.id, score: result.score, feedback: result.feedback, corrected: result.corrected, nextStep: result.nextStep, strengths: result.strengths, improvements: result.improvements });
}