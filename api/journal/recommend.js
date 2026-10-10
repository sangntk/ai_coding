import { db } from 'hatchable';
export const access = 'user';
export const methods = ['POST'];

const rules = {
  'daily-life': { words: ['routine','daily','schedule','habit','thói quen','hằng ngày','hàng ngày','đi làm','đi làm muộn','lịch trình','buổi sáng','buổi tối','bận rộn','commute','deadline hôm nay'], reason: 'Your entry mentions daily activities or routines.' },
  'work-study': { words: ['work','office','colleague','meeting','deadline','project','presentation','study','homework','exam','công việc','đồng nghiệp','đi làm','cuộc họp','họp','dự án','deadline','bài tập','học','thi cử','thuyết trình'], reason: 'Your entry mentions work, study, or tasks to complete.' },
  'education-learning': { words: ['learn','learning','course','class','teacher','student','skill','study','học','học tập','khóa học','lớp học','giáo viên','kỹ năng','kiến thức','ôn thi'], reason: 'Your entry mentions learning, skills, or education.' },
  'people-relationships': { words: ['friend','family','partner','colleague','conversation','meet someone','bạn bè','gia đình','người yêu','đồng nghiệp','trò chuyện','gặp bạn','mối quan hệ'], reason: 'Your entry mentions people or social relationships.' },
  'personality-emotions': { words: ['happy','sad','angry','anxious','stress','stressed','excited','tired','proud','nervous','vui','buồn','lo lắng','căng thẳng','mệt','hạnh phúc','thất vọng','tự hào','cảm thấy','cảm xúc'], reason: 'Your entry mentions feelings, reactions, or personal experiences.' },
  'health-lifestyle': { words: ['health','exercise','run','running','walk','walking','gym','sleep','tired','stress','food','sức khỏe','tập luyện','chạy','đi bộ','gym','ngủ','mệt','căng thẳng','ăn uống','dinh dưỡng','thể thao'], reason: 'Your entry mentions health, energy, exercise, or wellbeing.' },
  'food-lifestyle': { words: ['food','eat','ate','cook','cooking','lunch','dinner','breakfast','restaurant','coffee','phở','ăn','bữa trưa','bữa tối','bữa sáng','nấu ăn','quán ăn','cà phê','đồ ăn','món ăn'], reason: 'Your entry mentions meals, cooking, or food choices.' },
  'travel': { words: ['travel','trip','journey','holiday','vacation','hotel','airport','mountain','beach','du lịch','chuyến đi','đi chơi','khách sạn','sân bay','núi','biển','tham quan','văn hóa'], reason: 'Your entry mentions a trip, a place, or a cultural experience.' },
  'technology-ai': { words: ['technology','tech','ai','app','phone','computer','internet','online','digital','công nghệ','ứng dụng','điện thoại','máy tính','internet','trực tuyến','AI','trí tuệ nhân tạo'], reason: 'Your entry mentions technology or digital tools.' },
  'environment': { words: ['environment','climate','pollution','recycle','plastic','waste','water','tree','môi trường','khí hậu','ô nhiễm','tái chế','rác','nhựa','tiết kiệm nước','cây xanh','bền vững'], reason: 'Your entry mentions nature, resources, or environmental choices.' },
  'society-community': { words: ['community','neighborhood','volunteer','public service','society','cộng đồng','khu phố','tình nguyện','dịch vụ công','xã hội','người dân','tổ dân phố'], reason: 'Your entry mentions community life or social issues.' },
  'money-shopping': { words: ['money','price','budget','buy','bought','shopping','expensive','cheap','cost','tiền','giá','ngân sách','mua sắm','mua','đắt','rẻ','chi tiêu','tiết kiệm tiền'], reason: 'Your entry mentions spending, shopping, or budgeting.' },
  'media-communication': { words: ['news','media','social media','post','message','video','read an article','tin tức','truyền thông','mạng xã hội','bài đăng','tin nhắn','video','đọc báo'], reason: 'Your entry mentions news, messages, or media.' },
  'science-innovation': { words: ['science','research','experiment','discovery','invention','scientist','khoa học','nghiên cứu','thí nghiệm','khám phá','phát minh','nhà khoa học'], reason: 'Your entry mentions research, discoveries, or innovation.' },
  'ideas-opinions': { words: ['think','opinion','believe','agree','disagree','because','solution','problem','decision','ý kiến','quan điểm','nghĩ rằng','đồng ý','không đồng ý','giải pháp','vấn đề','quyết định','lý do'], reason: 'Your entry includes opinions, decisions, or problems to discuss.' }
};

export default async function (req, res) {
  const userId = String(req.user?.id || '');
  const text = String(req.body?.text || req.body?.journalText || '').trim();
  if (!text || text.length < 15) return res.status(400).json({ error: 'Please write at least 15 characters about your day.' });
  if (text.length > 5000) return res.status(400).json({ error: 'Your journal entry must be 5,000 characters or fewer.' });

  const journal = await db.query(
    'INSERT INTO journal_entries (user_id, journal_text) VALUES ($1,$2) RETURNING id, entry_date, created_at',
    [userId, text]
  );

  const normalized = text.toLocaleLowerCase();
  const scored = Object.entries(rules).map(([topicId, rule]) => {
    const matched = rule.words.filter(word => normalized.includes(word.toLocaleLowerCase()));
    return { topicId, score: matched.reduce((sum, word) => sum + (word.length >= 6 ? 2 : 1), 0), matched: [...new Set(matched)].slice(0, 5), reason: rule.reason };
  }).sort((a,b) => b.score - a.score || a.topicId.localeCompare(b.topicId));

  const positive = scored.filter(x => x.score > 0);
  const selected = (positive.length ? positive : scored.filter(x => ['daily-life','ideas-opinions','people-relationships'].includes(x.topicId))).slice(0,3);
  const ids = selected.map(x => x.topicId);
  const topicsResult = await db.query('SELECT id, name, description, level, icon FROM topics WHERE id = ANY($1::text[])', [ids]);
  const topicMap = new Map(topicsResult.rows.map(t => [t.id,t]));
  const recommendations = [];

  for (let i=0;i<selected.length;i++) {
    const item = selected[i];
    const topic = topicMap.get(item.topicId);
    if (!topic) continue;
    const reason = item.matched.length ? item.reason + ' Matched: ' + item.matched.join(', ') + '.' : 'A useful general topic to help you describe and reflect on your day.';
    await db.query(
      'INSERT INTO topic_recommendations (journal_id,user_id,topic_id,rank,reason,matched_terms) VALUES ($1,$2,$3,$4,$5,$6::jsonb) ON CONFLICT (journal_id,topic_id) DO NOTHING',
      [journal.rows[0].id,userId,topic.id,i+1,reason,JSON.stringify(item.matched)]
    );
    recommendations.push({ ...topic, rank:i+1, reason, matchedTerms:item.matched });
  }

  return res.json({ journal: journal.rows[0], recommendations });
}