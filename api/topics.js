import { db } from 'hatchable';
export const access = 'public';
export const methods = ['GET'];
export default async function (req, res) {
  const { rows } = await db.query('SELECT id, name, description, level, icon FROM topics ORDER BY name');
  res.json({ topics: rows });
}