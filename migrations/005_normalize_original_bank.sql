-- Move the original 60-item fallback bank into the normalized database as the canonical source.
WITH seed(topic_id, term, ipa, part_of_speech, definition_en, meaning_vi, example, cefr_level) AS (VALUES
('daily-life','consistent','/kənˈsɪs.tənt/','adjective','regular and dependable','đều đặn, nhất quán','Being consistent with practice helps me improve.','B1'),
('daily-life','unwind','/ʌnˈwaɪnd/','verb','to relax after work or stress','thư giãn','I listen to music to unwind after work.','B1'),
('daily-life','occasionally','/əˈkeɪ.ʒən.əl.i/','adverb','sometimes, but not often','thỉnh thoảng','I occasionally cook something new at home.','A2'),
('daily-life','prioritize','/praɪˈɒr.ɪ.taɪz/','verb','to decide which things are most important','ưu tiên','I prioritize exercise when planning my week.','B2'),
('daily-life','time-consuming','/ˈtaɪm.kənˌsjuː.mɪŋ/','adjective','taking a lot of time to do','tốn thời gian','Preparing meals can be time-consuming.','B1'),
('daily-life','habit','/ˈhæb.ɪt/','noun','something you do regularly, often without thinking','thói quen','Reading before bed is a habit I enjoy.','A2'),
('daily-life','manageable','/ˈmæn.ɪ.dʒə.bəl/','adjective','easy enough to deal with','có thể xử lý được','A short list makes my day manageable.','B2'),
('daily-life','refreshing','/rɪˈfreʃ.ɪŋ/','adjective','making you feel less tired or more energetic','giúp sảng khoái','A walk outside feels refreshing.','B1'),
('daily-life','restless','/ˈrest.ləs/','adjective','unable to relax or stay still','bồn chồn, không yên','I feel restless when I spend all day indoors.','B2'),
('daily-life','mindful','/ˈmaɪnd.fəl/','adjective','paying attention to the present moment','chú tâm, có ý thức','I try to be mindful when I eat.','B2'),
('daily-life','routine','/ruːˈtiːn/','noun','a regular way of doing things','thói quen, lịch trình thường ngày','My morning routine includes ten minutes of reading.','A2'),
('daily-life','spontaneous','/spɒnˈteɪ.ni.əs/','adjective','happening naturally without planning','tự phát, không lên kế hoạch trước','We made a spontaneous decision to visit the market.','B2'),
('work-study','deadline','/ˈded.laɪn/','noun','the latest time or date to finish something','hạn chót','I planned carefully to meet the deadline.','B1'),
('work-study','collaborate','/kəˈlæb.ə.reɪt/','verb','to work together with other people','cộng tác','Students collaborate on the final project.','B2'),
('work-study','efficient','/ɪˈfɪʃ.ənt/','adjective','working well without wasting time or resources','hiệu quả','A clear plan makes study time more efficient.','B1'),
('work-study','motivation','/ˌməʊ.tɪˈveɪ.ʃən/','noun','the reason or desire to do something','động lực','My motivation grows when I see progress.','B1'),
('work-study','overwhelmed','/ˌəʊ.vəˈwelmd/','adjective','feeling that there is too much to deal with','quá tải','I felt overwhelmed before my presentation.','B2'),
('work-study','accomplish','/əˈkɒm.plɪʃ/','verb','to succeed in doing or completing something','hoàn thành, đạt được','I accomplish more when I break tasks into steps.','B1'),
('work-study','feedback','/ˈfiːd.bæk/','noun','comments that help improve performance','phản hồi','Helpful feedback makes my writing clearer.','B1'),
('work-study','concentrate','/ˈkɒn.sən.treɪt/','verb','to give full attention to something','tập trung','I concentrate better in a quiet room.','B1'),
('work-study','productive','/prəˈdʌk.tɪv/','adjective','achieving useful results','có năng suất','I have a productive study session in the morning.','B1'),
('work-study','resourceful','/rɪˈsɔːs.fəl/','adjective','good at finding ways to solve problems','giỏi xoay xở','A resourceful teammate can solve unexpected issues.','B2'),
('work-study','initiative','/ɪˈnɪʃ.ə.tɪv/','noun','the ability to act without being told what to do','tính chủ động','She showed initiative by organizing the meeting.','B2'),
('work-study','competent','/ˈkɒm.pɪ.tənt/','adjective','having the skills needed to do something well','có năng lực','He is competent at managing several projects.','B2'),
('travel','itinerary','/aɪˈtɪn.ər.ər.i/','noun','a plan of a journey, including places and times','lịch trình chuyến đi','I made a flexible itinerary for our trip.','B1'),
('travel','breathtaking','/ˈbreθˌteɪ.kɪŋ/','adjective','extremely beautiful or surprising','ngoạn mục','The mountain view was breathtaking.','B2'),
('travel','destination','/ˌdes.tɪˈneɪ.ʃən/','noun','the place someone is going to','điểm đến','Our next destination is a coastal town.','A2'),
('travel','immerse','/ɪˈmɜːs/','verb','to become fully involved in a place or activity','đắm mình, hòa nhập','I like to immerse myself in local culture.','B2'),
('travel','memorable','/ˈmem.ər.ə.bəl/','adjective','special or worth remembering','đáng nhớ','Trying local food made the trip memorable.','B1'),
('travel','navigate','/ˈnæv.ɪ.ɡeɪt/','verb','to find and follow a way through an area','định hướng, tìm đường','We used a map to navigate the old streets.','B2'),
('travel','authentic','/ɔːˈθen.tɪk/','adjective','genuine or representing the real thing','đích thực','We found an authentic family-run restaurant.','B2'),
('travel','venture','/ˈven.tʃər/','verb','to go somewhere unfamiliar or risky','mạo hiểm đi đến nơi lạ','We ventured into a small mountain village.','B2'),
('travel','hospitality','/ˌhɒs.pɪˈtæl.ə.ti/','noun','friendly and generous treatment of guests','lòng hiếu khách','The family showed us wonderful hospitality.','B2'),
('travel','secluded','/sɪˈkluː.dɪd/','adjective','quiet and away from other people','hẻo lánh, tách biệt','We found a secluded beach beyond the village.','B2'),
('travel','expedition','/ˌek.spəˈdɪʃ.ən/','noun','a journey made for a particular purpose','chuyến thám hiểm','They joined an expedition into the rainforest.','B2'),
('travel','customary','/ˈkʌs.tə.mər.i/','adjective','usual or traditional in a place','theo phong tục, thông lệ','Removing shoes indoors is customary in some cultures.','B2'),
('health-lifestyle','balanced','/ˈbæl.ənst/','adjective','including the right amounts of different things','cân bằng','A balanced routine includes rest and movement.','B1'),
('health-lifestyle','sedentary','/ˈsed.ən.tri/','adjective','involving a lot of sitting and little physical activity','ít vận động','I try to avoid a sedentary lifestyle.','B2'),
('health-lifestyle','nourish','/ˈnʌr.ɪʃ/','verb','to provide what is needed to grow or stay healthy','nuôi dưỡng','Good food helps nourish body and mind.','B2'),
('health-lifestyle','wellbeing','/ˌwelˈbiː.ɪŋ/','noun','the state of being comfortable, healthy, and happy','sức khỏe và trạng thái hạnh phúc','Sleep plays an important role in my wellbeing.','B2'),
('health-lifestyle','moderation','/ˌmɒd.əˈreɪ.ʃən/','noun','the habit of avoiding too much of something','sự điều độ','Treats are fine in moderation.','B2'),
('health-lifestyle','energized','/ˈen.ə.dʒaɪzd/','adjective','feeling full of energy','tràn đầy năng lượng','I feel energized after a morning walk.','B1'),
('health-lifestyle','resilient','/rɪˈzɪl.i.ənt/','adjective','able to recover from difficulties','có khả năng phục hồi','A supportive routine helps me stay resilient.','B2'),
('health-lifestyle','restorative','/rɪˈstɔː.rə.tɪv/','adjective','helping you recover energy or health','giúp phục hồi','A good night of sleep is restorative.','B2'),
('health-lifestyle','hydration','/haɪˈdreɪ.ʃən/','noun','the process of taking in enough water','việc cung cấp đủ nước','Good hydration helps me feel more alert.','B2'),
('health-lifestyle','stamina','/ˈstæm.ɪ.nə/','noun','the ability to continue physical or mental effort','sức bền','Walking regularly has improved my stamina.','B2'),
('health-lifestyle','rejuvenate','/rɪˈdʒuː.və.neɪt/','verb','to make someone feel fresh and energetic again','làm hồi phục sức sống','A quiet weekend helps me rejuvenate.','B2'),
('health-lifestyle','moderate','/ˈmɒd.ər.ət/','adjective','not extreme or excessive','vừa phải, điều độ','I prefer moderate exercise on busy days.','B1'),
('environment','sustainable','/səˈsteɪ.nə.bəl/','adjective','able to continue over time without unacceptable harm','bền vững','Cycling is a more sustainable way to travel.','B2'),
('environment','conserve','/kənˈsɜːv/','verb','to protect something or use it carefully','bảo tồn, tiết kiệm','We can conserve water with shorter showers.','B2'),
('environment','biodiversity','/ˌbaɪ.əʊ.daɪˈvɜː.sə.ti/','noun','the variety of plant and animal life in a place','đa dạng sinh học','Healthy forests support biodiversity.','B2'),
('environment','emissions','/ɪˈmɪʃ.ənz/','noun','gases or substances released into the air','khí thải','Public transport can reduce carbon emissions.','B2'),
('environment','renewable','/rɪˈnjuː.ə.bəl/','adjective','naturally replaced and not used up permanently','có thể tái tạo','Solar power is a renewable energy source.','B1'),
('environment','awareness','/əˈweə.nəs/','noun','knowledge or understanding of a situation or issue','nhận thức','Education can raise awareness of plastic pollution.','B1'),
('environment','depletion','/dɪˈpliː.ʃən/','noun','the reduction of a resource or supply','sự cạn kiệt','Soil depletion can threaten food production.','B2'),
('environment','mitigate','/ˈmɪt.ɪ.ɡeɪt/','verb','to make something less harmful or serious','giảm nhẹ tác động','Planting trees can mitigate some climate impacts.','B2'),
('environment','ecosystem','/ˈiː.kəʊˌsɪs.təm/','noun','a community of organisms and their environment','hệ sinh thái','Wetlands are an important ecosystem for birds.','B2'),
('environment','contamination','/kənˌtæm.ɪˈneɪ.ʃən/','noun','the presence of something harmful or unwanted','sự nhiễm bẩn, ô nhiễm','Plastic contamination threatens marine life.','B2'),
('environment','habitat','/ˈhæb.ɪ.tæt/','noun','the natural home of an animal or plant','môi trường sống','The forest is a habitat for many species.','B1'),
('environment','offset','/ˈɒf.set/','verb','to balance or reduce the effect of something','bù đắp, cân bằng tác động','Some companies invest in forests to offset emissions.','B2')
)
INSERT INTO vocabulary_entries (term, normalized_term, entry_type, ipa, part_of_speech, definition_en, meaning_vi, example, cefr_level, source_name, source_status)
SELECT s.term, lower(btrim(s.term)), 'word', s.ipa, s.part_of_speech, s.definition_en, s.meaning_vi, s.example, s.cefr_level, 'demo-authored; unverified', 'draft'
FROM seed s
ON CONFLICT (normalized_term) DO UPDATE SET
  ipa = CASE WHEN vocabulary_entries.ipa = '' THEN EXCLUDED.ipa ELSE vocabulary_entries.ipa END,
  part_of_speech = CASE WHEN vocabulary_entries.part_of_speech = '' THEN EXCLUDED.part_of_speech ELSE vocabulary_entries.part_of_speech END,
  definition_en = CASE WHEN vocabulary_entries.definition_en = '' THEN EXCLUDED.definition_en ELSE vocabulary_entries.definition_en END,
  meaning_vi = COALESCE(vocabulary_entries.meaning_vi, EXCLUDED.meaning_vi),
  example = CASE WHEN vocabulary_entries.example = '' THEN EXCLUDED.example ELSE vocabulary_entries.example END,
  cefr_level = COALESCE(vocabulary_entries.cefr_level, EXCLUDED.cefr_level),
  updated_at = now();

INSERT INTO topic_vocabulary (topic_id, entry_id, is_primary)
SELECT s.topic_id, e.id, true
FROM (VALUES
('daily-life','consistent'),('daily-life','unwind'),('daily-life','occasionally'),('daily-life','prioritize'),('daily-life','time-consuming'),('daily-life','habit'),('daily-life','manageable'),('daily-life','refreshing'),('daily-life','restless'),('daily-life','mindful'),('daily-life','routine'),('daily-life','spontaneous'),
('work-study','deadline'),('work-study','collaborate'),('work-study','efficient'),('work-study','motivation'),('work-study','overwhelmed'),('work-study','accomplish'),('work-study','feedback'),('work-study','concentrate'),('work-study','productive'),('work-study','resourceful'),('work-study','initiative'),('work-study','competent'),
('travel','itinerary'),('travel','breathtaking'),('travel','destination'),('travel','immerse'),('travel','memorable'),('travel','navigate'),('travel','authentic'),('travel','venture'),('travel','hospitality'),('travel','secluded'),('travel','expedition'),('travel','customary'),
('health-lifestyle','balanced'),('health-lifestyle','sedentary'),('health-lifestyle','nourish'),('health-lifestyle','wellbeing'),('health-lifestyle','moderation'),('health-lifestyle','energized'),('health-lifestyle','resilient'),('health-lifestyle','restorative'),('health-lifestyle','hydration'),('health-lifestyle','stamina'),('health-lifestyle','rejuvenate'),('health-lifestyle','moderate'),
('environment','sustainable'),('environment','conserve'),('environment','biodiversity'),('environment','emissions'),('environment','renewable'),('environment','awareness'),('environment','depletion'),('environment','mitigate'),('environment','ecosystem'),('environment','contamination'),('environment','habitat'),('environment','offset')
) AS s(topic_id,term)
JOIN vocabulary_entries e ON e.normalized_term = s.term
ON CONFLICT (topic_id, entry_id) DO NOTHING;

INSERT INTO vocabulary_senses (entry_id, sense_number, definition_en, meaning_vi, cefr_level, example, source_name, source_status)
SELECT e.id, 1, e.definition_en, e.meaning_vi, e.cefr_level, e.example, e.source_name, 'draft'
FROM vocabulary_entries e
WHERE e.normalized_term IN (
'consistent','unwind','occasionally','prioritize','time-consuming','habit','manageable','refreshing','restless','mindful','routine','spontaneous',
'deadline','collaborate','efficient','motivation','overwhelmed','accomplish','feedback','concentrate','productive','resourceful','initiative','competent',
'itinerary','breathtaking','destination','immerse','memorable','navigate','authentic','venture','hospitality','secluded','expedition','customary',
'balanced','sedentary','nourish','wellbeing','moderation','energized','resilient','restorative','hydration','stamina','rejuvenate','moderate',
'sustainable','conserve','biodiversity','emissions','renewable','awareness','depletion','mitigate','ecosystem','contamination','habitat','offset'
)
ON CONFLICT (entry_id, sense_number) DO UPDATE SET
  meaning_vi = COALESCE(vocabulary_senses.meaning_vi, EXCLUDED.meaning_vi),
  cefr_level = COALESCE(vocabulary_senses.cefr_level, EXCLUDED.cefr_level);

INSERT INTO vocabulary_sources (entry_id, source_name, source_type, license_note, verification_status)
SELECT e.id, 'demo-authored; unverified', 'app-authored-demo', 'Original demo definitions/examples and approximate CEFR labels; not copied from Cambridge Dictionary and not yet verified.', 'draft'
FROM vocabulary_entries e
WHERE e.normalized_term IN (
'consistent','unwind','occasionally','prioritize','time-consuming','habit','manageable','refreshing','restless','mindful','routine','spontaneous',
'deadline','collaborate','efficient','motivation','overwhelmed','accomplish','feedback','concentrate','productive','resourceful','initiative','competent',
'itinerary','breathtaking','destination','immerse','memorable','navigate','authentic','venture','hospitality','secluded','expedition','customary',
'balanced','sedentary','nourish','wellbeing','moderation','energized','resilient','restorative','hydration','stamina','rejuvenate','moderate',
'sustainable','conserve','biodiversity','emissions','renewable','awareness','depletion','mitigate','ecosystem','contamination','habitat','offset'
)
AND NOT EXISTS (SELECT 1 FROM vocabulary_sources vs WHERE vs.entry_id=e.id AND vs.source_name='demo-authored; unverified')
ON CONFLICT DO NOTHING;