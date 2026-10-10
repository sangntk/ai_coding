import { db } from 'hatchable';
export const access = 'user';
export const methods = ['GET'];
export default async function (req, res) {
  const userId = req.user.id;
  await db.query("INSERT INTO profiles (user_id) VALUES ($1) ON CONFLICT (user_id) DO NOTHING", [userId]);
  const [{ rows: words }, { rows: sessions }, { rows: profile }] = await Promise.all([
    db.query('SELECT COUNT(*)::int AS count FROM user_vocabulary_progress WHERE user_id = $1 AND times_seen > 0', [userId]),
    db.query("SELECT COUNT(*)::int AS count FROM learning_sessions WHERE user_id = $1 AND status = 'completed'", [userId]),
    db.query('SELECT level FROM profiles WHERE user_id = $1', [userId])
  ]);
  res.json({ wordsLearned: words[0]?.count || 0, sessionsCompleted: sessions[0]?.count || 0, level: profile[0]?.level || 'A2–B1' });
}