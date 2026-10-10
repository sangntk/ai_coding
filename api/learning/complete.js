import { db } from 'hatchable';
export const access = 'user';
export const methods = ['POST'];
export default async function(req,res){const id=String(req.body?.sessionId||'');if(!id)return res.status(400).json({error:'sessionId is required.'});const result=await db.query("UPDATE learning_sessions SET status = 'completed', completed_at = now() WHERE id = $1 AND user_id = $2 RETURNING id, status, completed_at",[id,req.user.id]);if(!result.rows.length)return res.status(404).json({error:'Session not found.'});return res.json({session:result.rows[0]});}