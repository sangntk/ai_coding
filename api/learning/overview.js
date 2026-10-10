import { db } from 'hatchable';
export const access = 'user';
export const methods = ['GET'];

export default async function (req, res) {
  const userId = req.user.id;
  await db.query("INSERT INTO profiles (user_id) VALUES ($1) ON CONFLICT (user_id) DO NOTHING", [userId]);
  const [{ rows: learned }, { rows: practiced }, { rows: sessions }, { rows: profile }, { rows: scores }, { rows: attempts }] = await Promise.all([
    db.query('SELECT COUNT(*)::int AS count FROM user_vocabulary_progress WHERE user_id=$1 AND mastery>=2', [userId]),
    db.query('SELECT COUNT(DISTINCT vocabulary_id)::int AS count FROM user_vocabulary_progress WHERE user_id=$1 AND times_seen>0', [userId]),
    db.query("SELECT COUNT(*)::int AS count FROM learning_sessions WHERE user_id=$1 AND status='completed'", [userId]),
    db.query('SELECT level FROM profiles WHERE user_id=$1', [userId]),
    db.query('SELECT AVG(post_test_score::numeric/NULLIF(post_test_total,0)*100) AS average FROM learning_sessions WHERE user_id=$1 AND status=\'completed\' AND post_test_total>0', [userId]),
    db.query("SELECT COUNT(*)::int AS count FROM exercise_attempts WHERE user_id=$1 AND attempt_status='complete'", [userId])
  ]);
  return res.json({
    wordsLearned: learned[0]?.count || 0,
    wordsPracticed: practiced[0]?.count || 0,
    sessionsCompleted: sessions[0]?.count || 0,
    practiceAttempts: attempts[0]?.count || 0,
    averagePostTestScore: scores[0]?.average == null ? null : Math.round(Number(scores[0].average)),
    level: profile[0]?.level || 'A2'
  });
}