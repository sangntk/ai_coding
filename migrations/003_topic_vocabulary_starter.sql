-- Starter vocabulary for the ten new topics. Demo-authored content is deliberately marked draft until checked.
WITH seed(term, entry_type, ipa, part_of_speech, definition_en, meaning_vi, example, cefr_level) AS (VALUES
('acquire','word','/əˈkwaɪə/','verb','to gain a skill, habit, or knowledge','tiếp thu, đạt được','It takes time to acquire a new skill.','B1'),
('retain','word','/rɪˈteɪn/','verb','to keep or remember information','ghi nhớ, giữ lại','Short reviews help learners retain new vocabulary.','B2'),
('revise','word','/rɪˈvaɪz/','verb','to study information again before a test','ôn tập','I revise my notes at the end of each week.','B1'),
('curriculum','word','/kəˈrɪkjələm/','noun','the subjects and content taught in a course','chương trình học','The curriculum includes practical projects.','B2'),
('assessment','word','/əˈsesmənt/','noun','a way of measuring knowledge or ability','sự đánh giá','The assessment includes a short writing task.','B2'),
('lifelong','word','/ˌlaɪfˈlɒŋ/','adjective','continuing throughout a person’s life','suốt đời','Curiosity is important for lifelong learning.','B2'),
('empathy','word','/ˈempəθi/','noun','the ability to understand another person’s feelings','sự đồng cảm','Empathy can improve communication between friends.','B2'),
('mutual','word','/ˈmjuːtʃuəl/','adjective','felt or done by two or more people towards each other','lẫn nhau','Trust and mutual respect strengthen relationships.','B2'),
('bond','word','/bɒnd/','noun','a close connection between people','mối gắn kết','Shared experiences can create a strong bond.','B1'),
('supportive','word','/səˈpɔːtɪv/','adjective','giving help, encouragement, or understanding','biết hỗ trợ, động viên','A supportive friend listens without judging.','B1'),
('acquaintance','word','/əˈkweɪntəns/','noun','a person you know but not very well','người quen','I met an old acquaintance at the event.','B2'),
('resolve','word','/rɪˈzɒlv/','verb','to find a solution to a problem or disagreement','giải quyết','They talked calmly to resolve the conflict.','B2'),
('impulsive','word','/ɪmˈpʌlsɪv/','adjective','acting suddenly without considering the results','bốc đồng','An impulsive decision can create extra problems.','B2'),
('self-aware','word','/ˌself əˈweə/','adjective','understanding your own feelings and behaviour','có nhận thức về bản thân','Being self-aware helps me recognise my habits.','B2'),
('frustrated','word','/frʌˈstreɪtɪd/','adjective','annoyed because you cannot do or achieve something','bực bội, thất vọng','I felt frustrated when the plan changed.','B1'),
('content','word','/kənˈtent/','adjective','happy and satisfied with what you have','hài lòng','She felt content after a quiet weekend.','B2'),
('anxious','word','/ˈæŋkʃəs/','adjective','worried or nervous about something','lo lắng','I feel anxious before speaking in public.','B1'),
('adaptable','word','/əˈdæptəbəl/','adjective','able to change to suit new conditions','linh hoạt, dễ thích nghi','Adaptable employees respond well to change.','B2'),
('nutritious','word','/njuˈtrɪʃəs/','adjective','containing substances that are good for health','bổ dưỡng','A nutritious breakfast helps me stay focused.','B1'),
('portion','word','/ˈpɔːʃən/','noun','an amount of food served to one person','khẩu phần','I try to choose a reasonable portion size.','B1'),
('ingredient','word','/ɪnˈɡriːdiənt/','noun','one of the foods used to make a dish','nguyên liệu','Fresh ingredients can improve a simple meal.','B1'),
('appetite','word','/ˈæpɪtaɪt/','noun','the feeling that you want to eat','cảm giác thèm ăn','Exercise often increases my appetite.','B2'),
('processed','word','/ˈprəʊsest/','adjective','changed from its natural state, often for storage or convenience','đã qua chế biến','I try not to rely on processed food every day.','B1'),
('homemade','word','/ˌhəʊmˈmeɪd/','adjective','made at home rather than bought ready-made','tự làm tại nhà','Homemade soup is easy to adapt to your taste.','B1'),
('algorithm','word','/ˈælɡərɪðəm/','noun','a set of rules a computer follows to solve a task','thuật toán','The app uses an algorithm to recommend content.','B2'),
('automate','word','/ˈɔːtəmeɪt/','verb','to make a process operate with little human effort','tự động hóa','We can automate repetitive tasks with software.','B2'),
('privacy','word','/ˈprɪvəsi/','noun','the state of keeping personal information or activities private','quyền riêng tư','Users should understand how an app protects privacy.','B1'),
('secure','word','/sɪˈkjʊə/','adjective','protected against danger or unauthorised access','an toàn, bảo mật','Use a secure password for every account.','B1'),
('accessible','word','/əkˈsesəbəl/','adjective','easy to reach, use, or understand','dễ tiếp cận','The website should be accessible on mobile devices.','B2'),
('cybersecurity','word','/ˌsaɪbəsɪˈkjʊərəti/','noun','the practice of protecting systems and data from digital attacks','an ninh mạng','Cybersecurity is important when sharing personal data.','B2'),
('inequality','word','/ˌɪnɪˈkwɒləti/','noun','a situation in which people do not have equal opportunities','bất bình đẳng','Education can help reduce inequality.','B2'),
('inclusive','word','/ɪnˈkluːsɪv/','adjective','including people who might otherwise be left out','bao trùm, hòa nhập','An inclusive community welcomes different perspectives.','B2'),
('welfare','word','/ˈwelfeə/','noun','the health, happiness, and basic needs of people','phúc lợi','Public policy can affect the welfare of families.','B2'),
('infrastructure','word','/ˈɪnfrəstrʌktʃə/','noun','the basic systems and services a place needs','cơ sở hạ tầng','Reliable infrastructure supports local businesses.','B2'),
('marginalized','word','/ˈmɑːdʒɪnəlaɪzd/','adjective','treated as less important or given fewer opportunities','bị gạt ra bên lề','Community projects can support marginalized groups.','B2'),
('civic','word','/ˈsɪvɪk/','adjective','connected with the people and activities of a town or city','thuộc công dân, cộng đồng','Civic participation helps residents shape local decisions.','B2'),
('affordable','word','/əˈfɔːdəbəl/','adjective','cheap enough for people to pay for','có giá phải chăng','The store offers affordable options for students.','B1'),
('expenditure','word','/ɪkˈspendɪtʃə/','noun','the amount of money spent','khoản chi tiêu','Tracking monthly expenditure helps me manage my budget.','B2'),
('savings','word','/ˈseɪvɪŋz/','noun','money kept for future use','tiền tiết kiệm','I set aside part of my income as savings.','B1'),
('consumer','word','/kənˈsjuːmə/','noun','a person who buys goods or services','người tiêu dùng','Consumers often compare prices before buying.','B1'),
('impulse','word','/ˈɪmpʌls/','noun','a sudden desire to do something without planning','sự thôi thúc bất chợt','I try to avoid buying things on impulse.','B2'),
('cost-effective','word','/ˌkɒst ɪˈfektɪv/','adjective','giving good results in relation to the money spent','hiệu quả về chi phí','Cooking at home can be a cost-effective choice.','B2'),
('misleading','word','/ˌmɪsˈliːdɪŋ/','adjective','causing someone to believe something that is not true','gây hiểu lầm','The headline was misleading and left out key facts.','B2'),
('credible','word','/ˈkredəbəl/','adjective','able to be trusted or believed','đáng tin cậy','Check whether a source is credible before sharing it.','B2'),
('broadcast','word','/ˈbrɔːdkɑːst/','verb','to send a programme or information to many people','phát sóng','The interview will be broadcast this evening.','B1'),
('viral','word','/ˈvaɪrəl/','adjective','spreading quickly and widely, especially online','lan truyền nhanh trên mạng','The short video went viral overnight.','B2'),
('perspective','word','/pəˈspektɪv/','noun','a particular way of thinking about something','góc nhìn, quan điểm','Travel can help us understand another perspective.','B2'),
('misinformation','word','/ˌmɪsɪnfəˈmeɪʃən/','noun','false or inaccurate information, especially when shared unintentionally','thông tin sai lệch','Media literacy helps people recognise misinformation.','B2'),
('hypothesis','word','/haɪˈpɒθəsɪs/','noun','an idea that can be tested through study or experiment','giả thuyết','The researchers tested their hypothesis in the lab.','B2'),
('evidence','word','/ˈevɪdəns/','noun','facts or information that support a belief or conclusion','bằng chứng','We need stronger evidence before drawing a conclusion.','B1'),
('breakthrough','word','/ˈbreɪkθruː/','noun','an important discovery or development','bước đột phá','The team announced a breakthrough in battery design.','B2'),
('innovation','word','/ˌɪnəˈveɪʃən/','noun','a new idea, method, or product','sự đổi mới','Innovation can make public services more efficient.','B2'),
('prototype','word','/ˈprəʊtətaɪp/','noun','an early model used to test a design','nguyên mẫu','The engineers tested a prototype before production.','B2'),
('research','word','/rɪˈsɜːtʃ/','noun','careful study to discover new information','nghiên cứu','Recent research highlights the value of regular sleep.','B1'),
('justify','word','/ˈdʒʌstɪfaɪ/','verb','to give reasons that show an action or belief is reasonable','biện minh, đưa ra lý do','You should justify your opinion with examples.','B2'),
('assumption','word','/əˈsʌmpʃən/','noun','something accepted as true without proof','giả định','The plan is based on the assumption that costs will stay stable.','B2'),
('implication','word','/ˌɪmplɪˈkeɪʃən/','noun','a possible effect or result of an action or decision','hệ quả, hàm ý','We discussed the long-term implications of the policy.','B2'),
('alternative','word','/ɔːlˈtɜːnətɪv/','noun','another option or possibility','phương án thay thế','We need an alternative to single-use packaging.','B1'),
('evaluate','word','/ɪˈvæljueɪt/','verb','to judge the quality, importance, or effectiveness of something','đánh giá','Compare the options and evaluate their benefits.','B2'),
('compromise','word','/ˈkɒmprəmaɪz/','noun','an agreement in which each side accepts less than it wanted','sự thỏa hiệp','After a long discussion, they reached a compromise.','B2')
)
INSERT INTO vocabulary_entries (term, normalized_term, entry_type, ipa, part_of_speech, definition_en, meaning_vi, example, cefr_level, source_name, source_status)
SELECT term, lower(btrim(term)), entry_type, ipa, part_of_speech, definition_en, meaning_vi, example, cefr_level, 'demo-authored; unverified', 'draft'
FROM seed
ON CONFLICT (normalized_term) DO NOTHING;

INSERT INTO topic_vocabulary (topic_id, entry_id, is_primary)
SELECT m.topic_id, e.id, true
FROM (VALUES
('education-learning','acquire'),('education-learning','retain'),('education-learning','revise'),('education-learning','curriculum'),('education-learning','assessment'),('education-learning','lifelong'),
('people-relationships','empathy'),('people-relationships','mutual'),('people-relationships','bond'),('people-relationships','supportive'),('people-relationships','acquaintance'),('people-relationships','resolve'),
('personality-emotions','impulsive'),('personality-emotions','self-aware'),('personality-emotions','frustrated'),('personality-emotions','content'),('personality-emotions','anxious'),('personality-emotions','adaptable'),
('food-lifestyle','nutritious'),('food-lifestyle','portion'),('food-lifestyle','ingredient'),('food-lifestyle','appetite'),('food-lifestyle','processed'),('food-lifestyle','homemade'),
('technology-ai','algorithm'),('technology-ai','automate'),('technology-ai','privacy'),('technology-ai','secure'),('technology-ai','accessible'),('technology-ai','cybersecurity'),
('society-community','inequality'),('society-community','inclusive'),('society-community','welfare'),('society-community','infrastructure'),('society-community','marginalized'),('society-community','civic'),
('money-shopping','affordable'),('money-shopping','expenditure'),('money-shopping','savings'),('money-shopping','consumer'),('money-shopping','impulse'),('money-shopping','cost-effective'),
('media-communication','misleading'),('media-communication','credible'),('media-communication','broadcast'),('media-communication','viral'),('media-communication','perspective'),('media-communication','misinformation'),
('science-innovation','hypothesis'),('science-innovation','evidence'),('science-innovation','breakthrough'),('science-innovation','innovation'),('science-innovation','prototype'),('science-innovation','research'),
('ideas-opinions','justify'),('ideas-opinions','assumption'),('ideas-opinions','implication'),('ideas-opinions','alternative'),('ideas-opinions','evaluate'),('ideas-opinions','compromise')
) AS m(topic_id,term)
JOIN vocabulary_entries e ON e.normalized_term = m.term
ON CONFLICT (topic_id, entry_id) DO NOTHING;

INSERT INTO vocabulary_senses (entry_id, sense_number, definition_en, meaning_vi, cefr_level, example, source_name, source_status)
SELECT id, 1, definition_en, meaning_vi, cefr_level, example, source_name, 'draft'
FROM vocabulary_entries
WHERE source_name = 'demo-authored; unverified'
ON CONFLICT (entry_id, sense_number) DO NOTHING;

INSERT INTO vocabulary_sources (entry_id, source_name, source_type, license_note, verification_status)
SELECT id, source_name, 'app-authored-demo', 'Demo-authored learning content; CEFR labels and examples need review before release.', 'draft'
FROM vocabulary_entries
WHERE source_name = 'demo-authored; unverified'
ON CONFLICT DO NOTHING;