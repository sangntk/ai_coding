import { db } from 'hatchable';
export const access = 'user';
export const methods = ['GET'];

export default async function(req,res){
  const userId=String(req.user?.id||'');
  const limit=Math.min(120,Math.max(1,Number(req.query?.limit)||60));
  const result=await db.query(
    `SELECT ls.id AS session_id,ls.topic_id,t.name AS topic_name,ls.session_number,ls.status,
            ls.created_at,ls.completed_at,to_char(ls.created_at AT TIME ZONE 'Asia/Ho_Chi_Minh','YYYY-MM-DD') AS learning_date,
            ls.pre_test_score,ls.pre_test_total,ls.pre_test_completed_at,ls.learning_focus,
            ls.post_test_score,ls.post_test_total,ls.post_test_completed_at,
            ls.retest_score,ls.retest_total,ls.retest_completed_at,
            vi.id AS vocabulary_id,vi.word,vi.ipa,vi.part_of_speech,vi.meaning,vi.example,
            vi.level AS cefr_level,ve.meaning_vi,
            COALESCE(uvp.mastery,0) AS mastery,COALESCE(uvp.times_seen,0) AS times_seen,
            COALESCE(uvp.times_correct,0) AS times_correct,uvp.last_reviewed_at,
            (SELECT COUNT(*)::int FROM exercise_attempts ea WHERE ea.session_id=ls.id AND ea.user_id=ls.user_id AND ea.attempt_status='complete') AS practice_count
       FROM learning_sessions ls
       JOIN topics t ON t.id=ls.topic_id
       LEFT JOIN session_vocabulary sv ON sv.session_id=ls.id
       LEFT JOIN vocabulary_items vi ON vi.id=sv.vocabulary_id
       LEFT JOIN vocabulary_entries ve ON ve.normalized_term=lower(btrim(vi.word))
       LEFT JOIN user_vocabulary_progress uvp ON uvp.user_id=ls.user_id AND uvp.vocabulary_id=vi.id
      WHERE ls.user_id=$1
      ORDER BY ls.created_at DESC,sv.position ASC
      LIMIT $2`,
    [userId,limit*6]
  );
  const bySession=new Map();
  for(const row of result.rows){
    if(!bySession.has(row.session_id)){
      bySession.set(row.session_id,{
        id:row.session_id,date:row.learning_date,topicId:row.topic_id,topicName:row.topic_name,
        sessionNumber:row.session_number,status:row.status,createdAt:row.created_at,
        completedAt:row.completed_at,
        preTest:row.pre_test_completed_at?{score:row.pre_test_score,total:row.pre_test_total,completedAt:row.pre_test_completed_at}:null,
        postTest:row.post_test_completed_at?{score:row.post_test_score,total:row.post_test_total,completedAt:row.post_test_completed_at}:null,
        reTest:row.retest_completed_at?{score:row.retest_score,total:row.retest_total,completedAt:row.retest_completed_at}:null,
        learningFocus:row.learning_focus||[],practiceCount:row.practice_count||0,words:[]
      });
    }
    if(row.vocabulary_id){
      const session=bySession.get(row.session_id);
      if(!session.words.some(w=>w.id===row.vocabulary_id)){
        session.words.push({
          id:row.vocabulary_id,word:row.word,ipa:row.ipa,partOfSpeech:row.part_of_speech,
          meaning:row.meaning,meaningVi:row.meaning_vi,example:row.example,level:row.cefr_level,
          mastery:Number(row.mastery),timesSeen:Number(row.times_seen),timesCorrect:Number(row.times_correct),
          lastReviewedAt:row.last_reviewed_at
        });
      }
    }
  }
  const sessions=[...bySession.values()].slice(0,limit);
  const grouped={};
  for(const s of sessions){
    const date=s.date||new Date(s.createdAt).toISOString().slice(0,10);
    if(!grouped[date])grouped[date]=[];
    grouped[date].push(s);
  }
  return res.json({sessions,days:Object.entries(grouped).map(([date,items])=>({date,sessions:items,wordCount:items.reduce((n,s)=>n+s.words.length,0)}))});
}