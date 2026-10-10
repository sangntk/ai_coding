import { db } from 'hatchable';
export const access = 'user';
export const methods = ['GET'];

export default async function(req,res){
  const userId=String(req.user?.id||'');
  const limit=Math.min(90,Math.max(1,Number(req.query?.limit)||30));
  const result=await db.query(
    `SELECT j.id,j.journal_text,j.entry_date,j.created_at,
            COALESCE(jsonb_agg(jsonb_build_object('id',t.id,'name',t.name,'rank',tr.rank,'reason',tr.reason)
              ORDER BY tr.rank) FILTER (WHERE t.id IS NOT NULL),'[]'::jsonb) AS recommendations
       FROM journal_entries j
       LEFT JOIN topic_recommendations tr ON tr.journal_id=j.id AND tr.user_id=j.user_id
       LEFT JOIN topics t ON t.id=tr.topic_id
      WHERE j.user_id=$1
      GROUP BY j.id
      ORDER BY j.entry_date DESC,j.created_at DESC
      LIMIT $2`,
    [userId,limit]
  );
  return res.json({entries:result.rows});
}