-- Expand the first graph clusters with grounded, context-specific synonyms, antonyms, collocations and idioms.
WITH seed(term, entry_type, ipa, part_of_speech, definition_en, meaning_vi, example, cefr_level, topic_id) AS (VALUES
('inconsistent','word','/ˌɪnkənˈsɪstənt/','adjective','not staying the same in behaviour, quality, or frequency','không nhất quán','My results were inconsistent because I practised irregularly.','B2','daily-life'),
('relax','word','/rɪˈlæks/','verb','to become less tense or worried','thư giãn','I relax by listening to music after work.','A2','daily-life'),
('let your hair down','idiom','','idiom','to relax and enjoy yourself without worrying about rules or responsibilities','thư giãn hết mình','We let our hair down after finishing the project.','B2','daily-life'),
('quick','word','/kwɪk/','adjective','taking or needing only a short time','nhanh','A quick review can help me remember a word.','A2','daily-life'),
('first things first','idiom','','idiom','used to say that the most important task should be done before others','ưu tiên việc quan trọng trước','First things first, let us finish the urgent task.','B2','daily-life'),
('creature of habit','idiom','','idiom','someone who likes doing things in the same way each time','người thích những thói quen cố định','I am a creature of habit and always take the same route.','B2','daily-life'),
('cooperate','word','/kəʊˈɒpəreɪt/','verb','to work together towards a shared goal','hợp tác','The teams cooperate to complete the task.','B1','work-study'),
('inefficient','word','/ˌɪnɪˈfɪʃənt/','adjective','not working well or wasting time and resources','kém hiệu quả','The old process is inefficient and needs to change.','B2','work-study'),
('drive','word','/draɪv/','noun','energy and determination to achieve something','động lực, quyết tâm','Her drive helped her finish the course.','B2','work-study'),
('have a lot on your plate','idiom','','idiom','to have many tasks or problems to deal with','có nhiều việc phải giải quyết','I cannot take on another task because I have a lot on my plate.','B2','work-study'),
('achieve','word','/əˈtʃiːv/','verb','to succeed in reaching a goal or result','đạt được','Small steps help me achieve my long-term goals.','B1','work-study'),
('constructive feedback','collocation','','noun phrase','comments intended to help someone improve','phản hồi mang tính xây dựng','Constructive feedback helped me improve the draft.','B2','work-study'),
('distracted','word','/dɪˈstræktɪd/','adjective','unable to give full attention because something takes it away','mất tập trung','I get distracted when my phone keeps buzzing.','B1','work-study'),
('unproductive','word','/ˌʌnprəˈdʌktɪv/','adjective','not producing useful results','không hiệu quả','I have an unproductive day when I do not plan my tasks.','B2','work-study'),
('helpless','word','/ˈhelpləs/','adjective','unable to do anything to improve a situation','bất lực','I felt helpless until a colleague explained the process.','B2','work-study'),
('take the initiative','collocation','','verb phrase','to act independently before being asked','chủ động bắt tay vào việc','She took the initiative and organised the meeting.','B2','work-study'),
('capable','word','/ˈkeɪpəbəl/','adjective','having the ability or qualities needed to do something','có khả năng','He is capable of leading the project.','B1','work-study'),
('spectacular','word','/spekˈtækjələ/','adjective','extremely impressive or beautiful','ngoạn mục','The view from the summit was spectacular.','B2','travel'),
('unforgettable','word','/ˌʌnfəˈɡetəbəl/','adjective','so special or enjoyable that it cannot be forgotten','khó quên','The trip was an unforgettable experience.','B1','travel'),
('genuine','word','/ˈdʒenjuɪn/','adjective','real and not false or artificial','chân thật, đích thực','We received a genuine welcome from the local family.','B2','travel'),
('crowded','word','/ˈkraʊdɪd/','adjective','full of people','đông đúc','The beach gets crowded during the holiday season.','A2','travel'),
('warm welcome','collocation','','noun phrase','a friendly and enthusiastic greeting','sự chào đón nồng nhiệt','Visitors received a warm welcome from the hosts.','B1','travel'),
('journey','word','/ˈdʒɜːni/','noun','the act of travelling from one place to another','hành trình','The journey took longer than we expected.','A2','travel'),
('unusual','word','/ʌnˈjuːʒuəl/','adjective','different from what is normal or expected','khác thường','It is unusual to see snow in this region.','B1','travel'),
('unbalanced','word','/ˌʌnˈbælənst/','adjective','not containing or showing a healthy or equal mixture','mất cân bằng','An unbalanced routine can leave you feeling exhausted.','B2','health-lifestyle'),
('active','word','/ˈæktɪv/','adjective','doing many things or involving physical movement','năng động, tích cực','An active lifestyle includes regular movement.','A2','health-lifestyle'),
('feed','word','/fiːd/','verb','to give food to a person or animal','cho ăn, cung cấp thức ăn','It is important to feed your body well after exercise.','A2','health-lifestyle'),
('excess','word','/ɪkˈses/','noun','an amount that is more than necessary or healthy','sự quá mức','Excess sugar can be harmful to health.','B2','health-lifestyle'),
('exhausted','word','/ɪɡˈzɔːstɪd/','adjective','extremely tired','kiệt sức','I felt exhausted after a long day.','B1','health-lifestyle'),
('fragile','word','/ˈfrædʒaɪl/','adjective','easily damaged or harmed','mong manh, dễ tổn thương','Recovery can be difficult when someone feels emotionally fragile.','B2','health-lifestyle'),
('dehydration','word','/ˌdiːhaɪˈdreɪʃən/','noun','a condition caused by not having enough water in the body','tình trạng mất nước','Drinking water regularly helps prevent dehydration.','B2','health-lifestyle'),
('endurance','word','/ɪnˈdjʊərəns/','noun','the ability to continue doing something difficult for a long time','sức chịu đựng, sức bền','Gradual training can improve endurance.','B2','health-lifestyle'),
('refresh','word','/rɪˈfreʃ/','verb','to make someone feel less tired or more alert','làm sảng khoái','A short break can refresh your mind.','B1','health-lifestyle'),
('excessive','word','/ɪkˈsesɪv/','adjective','much greater than is reasonable or necessary','quá mức','Excessive screen time can affect sleep.','B2','health-lifestyle'),
('non-renewable','word','/ˌnɒn rɪˈnjuːəbəl/','adjective','not able to be naturally replaced within a short period','không thể tái tạo','Coal is a non-renewable energy source.','B2','environment'),
('ignorance','word','/ˈɪɡnərəns/','noun','lack of knowledge or information about something','sự thiếu hiểu biết','Ignorance of the problem can make it worse.','B2','environment'),
('abundance','word','/əˈbʌndəns/','noun','a large quantity of something','sự dồi dào','The region has an abundance of natural resources.','B2','environment'),
('worsen','word','/ˈwɜːsən/','verb','to become or make something more serious or less pleasant','làm xấu đi, trở nên tệ hơn','Pollution can worsen existing health problems.','B2','environment'),
('cleanliness','word','/ˈklenlinəs/','noun','the state of being clean','sự sạch sẽ','Community clean-ups improve the cleanliness of public spaces.','B1','environment'),
('compensate','word','/ˈkɒmpenseɪt/','verb','to balance the effect of something or pay for a loss','bù đắp','Planting trees cannot compensate for every environmental impact.','B2','environment'),
('tiring','word','/ˈtaɪərɪŋ/','adjective','making you feel that you need to rest','gây mệt mỏi','A long commute can be tiring.','B1','health-lifestyle'),
('planned','word','/plænd/','adjective','decided or arranged before something happens','được lên kế hoạch','We chose a planned route instead of exploring at random.','B1','daily-life'),
('careless','word','/ˈkeələs/','adjective','not giving enough attention or thought to avoiding harm or mistakes','bất cẩn','A careless mistake can change the meaning of a sentence.','B2','daily-life'),
('calm','word','/kɑːm/','adjective','not worried, angry, or excited','bình tĩnh','Taking a short break helps me stay calm.','A2','personality-emotions')
)
INSERT INTO vocabulary_entries (term, normalized_term, entry_type, ipa, part_of_speech, definition_en, meaning_vi, example, cefr_level, source_name, source_status)
SELECT term, lower(btrim(term)), entry_type, ipa, part_of_speech, definition_en, meaning_vi, example, cefr_level, 'demo-authored; unverified', 'draft'
FROM seed
ON CONFLICT (normalized_term) DO UPDATE SET
  ipa = CASE WHEN vocabulary_entries.ipa = '' THEN EXCLUDED.ipa ELSE vocabulary_entries.ipa END,
  meaning_vi = COALESCE(vocabulary_entries.meaning_vi, EXCLUDED.meaning_vi),
  updated_at = now();

INSERT INTO topic_vocabulary (topic_id, entry_id, is_primary)
SELECT s.topic_id, e.id, true
FROM (VALUES
('daily-life','inconsistent'),('daily-life','relax'),('daily-life','let your hair down'),('daily-life','quick'),('daily-life','first things first'),('daily-life','creature of habit'),('daily-life','planned'),('daily-life','careless'),('personality-emotions','calm'),
('work-study','cooperate'),('work-study','inefficient'),('work-study','drive'),('work-study','have a lot on your plate'),('work-study','achieve'),('work-study','constructive feedback'),('work-study','distracted'),('work-study','unproductive'),('work-study','helpless'),('work-study','take the initiative'),('work-study','capable'),
('travel','spectacular'),('travel','unforgettable'),('travel','genuine'),('travel','crowded'),('travel','warm welcome'),('travel','journey'),('travel','unusual'),
('health-lifestyle','unbalanced'),('health-lifestyle','active'),('health-lifestyle','feed'),('health-lifestyle','excess'),('health-lifestyle','exhausted'),('health-lifestyle','fragile'),('health-lifestyle','dehydration'),('health-lifestyle','endurance'),('health-lifestyle','refresh'),('health-lifestyle','excessive'),('health-lifestyle','tiring'),
('environment','non-renewable'),('environment','ignorance'),('environment','abundance'),('environment','worsen'),('environment','cleanliness'),('environment','compensate')
) AS s(topic_id,term)
JOIN vocabulary_entries e ON e.normalized_term=s.term
ON CONFLICT (topic_id,entry_id) DO NOTHING;

INSERT INTO vocabulary_senses (entry_id,sense_number,definition_en,meaning_vi,cefr_level,example,source_name,source_status)
SELECT id,1,definition_en,meaning_vi,cefr_level,example,source_name,'draft'
FROM vocabulary_entries
WHERE source_name='demo-authored; unverified'
ON CONFLICT (entry_id,sense_number) DO UPDATE SET
  meaning_vi=COALESCE(vocabulary_senses.meaning_vi,EXCLUDED.meaning_vi),
  cefr_level=COALESCE(vocabulary_senses.cefr_level,EXCLUDED.cefr_level);

INSERT INTO vocabulary_sources (entry_id,source_name,source_type,license_note,verification_status)
SELECT e.id,e.source_name,'app-authored-demo','Demo-authored relationship vocabulary; CEFR labels and examples need verification.', 'draft'
FROM vocabulary_entries e
WHERE e.normalized_term IN (
'inconsistent','relax','let your hair down','quick','first things first','creature of habit','cooperate','inefficient','drive','have a lot on your plate','achieve','constructive feedback','distracted','unproductive','helpless','take the initiative','capable','spectacular','unforgettable','genuine','crowded','warm welcome','journey','unusual','unbalanced','active','feed','excess','exhausted','fragile','dehydration','endurance','refresh','excessive','non-renewable','ignorance','abundance','worsen','cleanliness','compensate'
)
AND NOT EXISTS (SELECT 1 FROM vocabulary_sources vs WHERE vs.entry_id=e.id AND vs.source_name=e.source_name)
ON CONFLICT DO NOTHING;

INSERT INTO vocabulary_relations (source_entry_id,target_entry_id,relation_type,context,verification_status)
SELECT a.id,b.id,r.relation_type,r.context,'draft'
FROM (VALUES
('consistent','reliable','synonym','Similar meaning in the sense of dependable behaviour or performance'),
('consistent','inconsistent','antonym','Regularity and dependability'),
('unwind','relax','synonym','Relaxing after work or stress'),
('unwind','let your hair down','idiom','Informal expression for relaxing and enjoying yourself'),
('prioritize','first things first','idiom','Expression for dealing with the most important thing first'),
('habit','routine','synonym','Repeated patterns of behaviour; usage depends on context'),
('habit','creature of habit','idiom','Describes someone who prefers familiar routines'),
('time-consuming','quick','antonym','Contrasting time needed to complete a task'),
('refreshing','tiring','antonym','Effect on energy or how tired someone feels'),
('restless','calm','antonym','Emotional or physical state'),
('mindful','careless','antonym','Careful attention versus lack of care'),
('spontaneous','planned','antonym','Whether an action is arranged in advance'),
('collaborate','cooperate','synonym','Working together towards a shared goal'),
('efficient','inefficient','antonym','Use of time and resources'),
('motivation','drive','synonym','Inner energy or determination to act'),
('overwhelmed','have a lot on your plate','idiom','Related to having too many tasks or responsibilities'),
('accomplish','achieve','synonym','Successfully reaching a goal or completing a task'),
('feedback','constructive feedback','collocation','Feedback intended to help someone improve'),
('concentrate','distracted','antonym','Ability to maintain attention'),
('productive','unproductive','antonym','Whether useful results are produced'),
('resourceful','helpless','antonym','Ability versus inability to find solutions'),
('initiative','take the initiative','collocation','Acting independently before being asked'),
('competent','capable','synonym','Having the ability or skills to do something'),
('breathtaking','spectacular','synonym','Describing something extremely impressive or beautiful'),
('memorable','unforgettable','synonym','Worth remembering because it is special'),
('authentic','genuine','synonym','Real rather than false or artificial'),
('secluded','crowded','antonym','A quiet place away from people versus a place full of people'),
('hospitality','warm welcome','collocation','Friendly treatment of guests'),
('expedition','journey','synonym','A journey, though an expedition usually has a specific purpose'),
('customary','unusual','antonym','Traditional or usual versus unexpected'),
('balanced','unbalanced','antonym','A healthy or suitable mixture versus an unsuitable one'),
('sedentary','active','antonym','Little physical movement versus regular movement'),
('nourish','feed','synonym','Providing food or what is needed for growth'),
('moderation','excess','antonym','Avoiding too much versus more than necessary'),
('energized','exhausted','antonym','Full of energy versus extremely tired'),
('resilient','fragile','antonym','Ability to recover versus being easily harmed'),
('hydration','dehydration','antonym','Adequate body water versus insufficient body water'),
('stamina','endurance','synonym','Ability to sustain physical or mental effort'),
('rejuvenate','refresh','synonym','Making someone feel fresh or energetic again'),
('moderate','excessive','antonym','Not extreme versus greater than reasonable'),
('renewable','non-renewable','antonym','Resources that can or cannot be naturally replaced on a human timescale'),
('awareness','ignorance','antonym','Knowledge of an issue versus lack of knowledge'),
('depletion','abundance','antonym','Reduction of a resource versus a large quantity'),
('mitigate','worsen','antonym','Reducing harm versus making something more serious'),
('contamination','cleanliness','related_phrase','Pollution and the state of being clean are contrasting concepts in environmental contexts'),
('offset','compensate','synonym','Balancing or reducing the effect of something'),
('biodiversity','ecosystem','related_phrase','Biodiversity is a feature of healthy ecosystems')
) AS r(source_term,target_term,relation_type,context)
JOIN vocabulary_entries a ON a.normalized_term=r.source_term
JOIN vocabulary_entries b ON b.normalized_term=r.target_term
ON CONFLICT (source_entry_id,target_entry_id,relation_type) DO NOTHING;