import { db } from 'hatchable';
export const access = 'user';
export const methods = ['POST'];

export default async function (req, res) {
  const id = String(req.body?.sessionId || '');
  if (!id) return res.status(400).json({ error: 'sessionId is required.' });
  const found = await db.query(
    'SELECT id,status,pre_test_completed_at,post_test_completed_at FROM learning_sessions WHERE id=$1 AND user_id=$2',
    [id, req.user.id]
  );
  if (!found.rows.length) return res.status(404).json({ error: 'Session not found.' });
  const session = found.rows[0];
  if (session.status === 'completed') return res.json({ session: { id: session.id, status: session.status }, alreadyCompleted: true });
  if (!session.pre_test_completed_at) return res.status(409).json({ error: 'Complete the pre-test before finishing this session.' });
  if (!session.post_test_completed_at) return res.status(409).json({ error: 'Complete the post-test before finishing this session.' });
  const practice = await db.query(
    "SELECT id FROM exercise_attempts WHERE session_id=$1 AND user_id=$2 LIMIT 1",
    [id, req.user.id]
  );
  if (!practice.rows.length) return res.status(409).json({ error: 'Save at least one practice answer before finishing this session.' });
  const result = await db.query(
    "UPDATE learning_sessions SET status='completed',completed_at=now() WHERE id=$1 AND user_id=$2 AND status='started' RETURNING id,status,completed_at",
    [id, req.user.id]
  );
  if (!result.rows.length) return res.status(409).json({ error: 'This session could not be completed. Refresh and try again.' });
  return res.json({ session: result.rows[0] });
}