-- Second starter batch: additional fresh single-word entries for repeat sessions on new topics.
WITH seed(term, ipa, part_of_speech, definition_en, meaning_vi, example, cefr_level, topic_id) AS (VALUES
('comprehension','/ˌkɒmprɪˈhenʃən/','noun','the ability to understand something','sự hiểu, khả năng lĩnh hội','Reading comprehension improves when I review unfamiliar words.','B2','education-learning'),
('literacy','/ˈlɪtərəsi/','noun','the ability to read and write or understand a subject','khả năng đọc viết, hiểu biết','Digital literacy is important for modern learners.','B2','education-learning'),
('proficiency','/prəˈfɪʃənsi/','noun','a high level of skill or ability','sự thành thạo','Regular practice can improve speaking proficiency.','B2','education-learning'),
('memorise','/ˈmeməraɪz/','verb','to learn something so that you can remember it exactly','ghi nhớ','I memorise useful phrases by using them in sentences.','B1','education-learning'),
('practical','/ˈpræktɪkəl/','adjective','useful and suitable for real situations','thiết thực','Practical tasks help students apply what they learn.','B1','education-learning'),
('independent','/ˌɪndɪˈpendənt/','adjective','able to act or think without help from others','độc lập, tự chủ','Independent learners set their own goals.','B1','education-learning'),
('considerate','/kənˈsɪdərət/','adjective','careful not to upset or inconvenience other people','chu đáo, biết nghĩ cho người khác','It was considerate of her to check whether everyone was comfortable.','B2','people-relationships'),
('loyal','/ˈlɔɪəl/','adjective','giving support to a person or group over time','trung thành, hết lòng','A loyal friend supports you during difficult periods.','B1','people-relationships'),
('trustworthy','/ˈtrʌstwɜːði/','adjective','able to be trusted','đáng tin cậy','Choose a trustworthy person when sharing personal concerns.','B2','people-relationships'),
('companionship','/kəmˈpænjənʃɪp/','noun','the pleasant feeling of being with another person','sự bầu bạn','Pets can provide companionship for people who live alone.','B2','people-relationships'),
('disagreement','/ˌdɪsəˈɡriːmənt/','noun','a situation in which people have different opinions','sự bất đồng','A disagreement does not have to damage a friendship.','B1','people-relationships'),
('reconcile','/ˈrekənsaɪl/','verb','to restore a friendly relationship after an argument','làm hòa, hòa giải','They tried to reconcile after the misunderstanding.','B2','people-relationships'),
('confident','/ˈkɒnfɪdənt/','adjective','believing that you can do something well','tự tin','I feel more confident after practising aloud.','B1','personality-emotions'),
('insecure','/ˌɪnsɪˈkjʊə/','adjective','not confident or certain about yourself or a situation','thiếu tự tin, bất an','He felt insecure about speaking in front of a large group.','B2','personality-emotions'),
('disappointed','/ˌdɪsəˈpɔɪntɪd/','adjective','unhappy because something was not as good as expected','thất vọng','I was disappointed when the event was cancelled.','B1','personality-emotions'),
('grateful','/ˈɡreɪtfəl/','adjective','feeling or showing thanks','biết ơn','I am grateful for the support I received.','B1','personality-emotions'),
('reflective','/rɪˈflektɪv/','adjective','thinking carefully about experiences or ideas','hay suy ngẫm','A reflective person often learns from past mistakes.','B2','personality-emotions'),
('composed','/kəmˈpəʊzd/','adjective','calm and in control of your feelings','bình tĩnh','She remained composed during the difficult conversation.','B2','personality-emotions'),
('cuisine','/kwɪˈziːn/','noun','a style of cooking associated with a place or culture','ẩm thực','The city is known for its regional cuisine.','B2','food-lifestyle'),
('fibre','/ˈfaɪbə/','noun','a substance in plant foods that helps digestion','chất xơ','Beans and vegetables are good sources of fibre.','B1','food-lifestyle'),
('craving','/ˈkreɪvɪŋ/','noun','a strong desire for a particular food or experience','cơn thèm','I sometimes have a craving for something sweet.','B2','food-lifestyle'),
('savoury','/ˈseɪvəri/','adjective','having a salty or spicy taste rather than a sweet one','có vị mặn/đậm đà','I prefer savoury snacks to sweet ones.','B2','food-lifestyle'),
('organic','/ɔːˈɡænɪk/','adjective','produced without certain artificial chemicals','hữu cơ','Some shoppers choose organic vegetables when possible.','B1','food-lifestyle'),
('intake','/ˈɪnteɪk/','noun','the amount of food, drink, or another substance taken in','lượng tiêu thụ/nạp vào','I keep an eye on my daily water intake.','B2','food-lifestyle'),
('interface','/ˈɪntəfeɪs/','noun','the part of a system that a person uses to interact with it','giao diện','A clear interface makes the app easier to use.','B2','technology-ai'),
('device','/dɪˈvaɪs/','noun','a piece of equipment made for a particular purpose','thiết bị','The software works on almost any mobile device.','B1','technology-ai'),
('encrypt','/ɪnˈkrɪpt/','verb','to change information into a coded form for protection','mã hóa','The service encrypts sensitive information.','B2','technology-ai'),
('reliable','/rɪˈlaɪəbəl/','adjective','able to be trusted to work well or behave as expected','đáng tin cậy','A reliable connection is essential for online classes.','B1','technology-ai'),
('innovative','/ˈɪnəvətɪv/','adjective','using new ideas or methods','mang tính đổi mới','The team developed an innovative learning tool.','B2','technology-ai'),
('user-friendly','/ˌjuːzə ˈfrendli/','adjective','easy for people to understand and use','thân thiện với người dùng','The updated dashboard is simple and user-friendly.','B1','technology-ai'),
('diversity','/daɪˈvɜːsəti/','noun','the presence of many different types of people or things','sự đa dạng','Cultural diversity can enrich a community.','B2','society-community'),
('resident','/ˈrezɪdənt/','noun','a person who lives in a particular place','cư dân','Residents were invited to share their views.','B1','society-community'),
('charity','/ˈtʃærəti/','noun','an organisation that helps people in need','tổ chức từ thiện, hoạt động từ thiện','The charity provides meals for families in need.','B1','society-community'),
('poverty','/ˈpɒvəti/','noun','the state of being very poor','sự nghèo đói','Education can help people escape poverty.','B2','society-community'),
('campaign','/kæmˈpeɪn/','noun','organised activities intended to achieve a goal','chiến dịch','The community launched a campaign to reduce litter.','B1','society-community'),
('donation','/dəʊˈneɪʃən/','noun','money or goods given to help a person or cause','khoản quyên góp','Every donation supports the local shelter.','B1','society-community'),
('bargain','/ˈbɑːɡɪn/','noun','something bought for less than its usual price','món hời','I found a bargain during the seasonal sale.','B1','money-shopping'),
('debt','/det/','noun','money that someone owes','khoản nợ','It is important to understand the cost of debt.','B2','money-shopping'),
('income','/ˈɪnkʌm/','noun','money received from work or other sources','thu nhập','She saves a portion of her monthly income.','B1','money-shopping'),
('purchase','/ˈpɜːtʃəs/','noun','something that you buy','món hàng đã mua','Keep the receipt in case you need to return a purchase.','B1','money-shopping'),
('refund','/ˈriːfʌnd/','noun','money returned to someone after a purchase','tiền hoàn lại','The shop offered a refund for the damaged item.','B1','money-shopping'),
('wasteful','/ˈweɪstfəl/','adjective','using more resources than necessary','lãng phí','Leaving the lights on all night is wasteful.','B2','money-shopping'),
('editorial','/ˌedɪˈtɔːriəl/','noun','an article that expresses a publication’s opinion','bài xã luận','The editorial argued for better public transport.','B2','media-communication'),
('headline','/ˈhedlaɪn/','noun','the title of a news story','tiêu đề bài báo','The headline did not tell the whole story.','B1','media-communication'),
('coverage','/ˈkʌvərɪdʒ/','noun','the reporting of an event by the media','sự đưa tin','The event received extensive media coverage.','B2','media-communication'),
('censorship','/ˈsensəʃɪp/','noun','the act of controlling or removing information from public access','sự kiểm duyệt','The documentary explores censorship in the media.','B2','media-communication'),
('biased','/ˈbaɪəst/','adjective','showing unfair support for one person or idea','thiên vị, thiên lệch','A biased report may ignore important evidence.','B2','media-communication'),
('journalism','/ˈdʒɜːnəlɪzəm/','noun','the activity of collecting and reporting news','ngành báo chí','Good journalism checks facts before publication.','B2','media-communication'),
('analyse','/ˈænəlaɪz/','verb','to examine something carefully to understand it','phân tích','Scientists analyse the results before drawing conclusions.','B1','science-innovation'),
('variable','/ˈveəriəbəl/','noun','a factor that can change in an experiment or situation','biến số','Researchers changed one variable at a time.','B2','science-innovation'),
('outcome','/ˈaʊtkʌm/','noun','the result of an action or process','kết quả','The outcome was different from what the team expected.','B1','science-innovation'),
('accurate','/ˈækjərət/','adjective','correct and without mistakes','chính xác','Accurate measurements are essential for the experiment.','B1','science-innovation'),
('method','/ˈmeθəd/','noun','a particular way of doing something','phương pháp','The researchers used a new method to collect data.','B1','science-innovation'),
('observation','/ˌɒbzəˈveɪʃən/','noun','the act of watching something carefully to learn about it','sự quan sát','The conclusion was based on repeated observation.','B2','science-innovation'),
('challenge','/ˈtʃælɪndʒ/','noun','a difficult task or situation that tests ability','thử thách','Learning to speak fluently is a worthwhile challenge.','B1','ideas-opinions'),
('interpret','/ɪnˈtɜːprɪt/','verb','to explain the meaning of information or an event','diễn giải','People may interpret the same message differently.','B2','ideas-opinions'),
('logical','/ˈlɒdʒɪkəl/','adjective','following clear reasoning','hợp lý, logic','A logical argument connects claims with evidence.','B2','ideas-opinions'),
('persuasive','/pəˈsweɪsɪv/','adjective','able to make someone agree or believe something','có sức thuyết phục','A persuasive essay supports its main point with examples.','B2','ideas-opinions'),
('nuance','/ˈnjuːɑːns/','noun','a small but important difference in meaning or feeling','sắc thái tinh tế','The discussion helped me understand the nuance of the word.','B2','ideas-opinions'),
('counterargument','/ˌkaʊntərˈɑːɡjəmənt/','noun','an argument that disagrees with another argument','lập luận phản biện','A strong essay considers a counterargument fairly.','B2','ideas-opinions'),
('justify','/ˈdʒʌstɪfaɪ/','verb','to give reasons that show an action or belief is reasonable','biện minh, đưa ra lý do','You should justify your opinion with examples.','B2','ideas-opinions')
)
INSERT INTO vocabulary_entries (term, normalized_term, entry_type, ipa, part_of_speech, definition_en, meaning_vi, example, cefr_level, source_name, source_status)
SELECT term, lower(btrim(term)), 'word', ipa, part_of_speech, definition_en, meaning_vi, example, cefr_level, 'demo-authored; unverified', 'draft'
FROM seed
ON CONFLICT (normalized_term) DO NOTHING;

INSERT INTO topic_vocabulary (topic_id, entry_id, is_primary)
SELECT s.topic_id, e.id, true
FROM (VALUES
('education-learning','comprehension'),('education-learning','literacy'),('education-learning','proficiency'),('education-learning','memorise'),('education-learning','practical'),('education-learning','independent'),
('people-relationships','considerate'),('people-relationships','loyal'),('people-relationships','trustworthy'),('people-relationships','companionship'),('people-relationships','disagreement'),('people-relationships','reconcile'),
('personality-emotions','confident'),('personality-emotions','insecure'),('personality-emotions','disappointed'),('personality-emotions','grateful'),('personality-emotions','reflective'),('personality-emotions','composed'),
('food-lifestyle','cuisine'),('food-lifestyle','fibre'),('food-lifestyle','craving'),('food-lifestyle','savoury'),('food-lifestyle','organic'),('food-lifestyle','intake'),
('technology-ai','interface'),('technology-ai','device'),('technology-ai','encrypt'),('technology-ai','reliable'),('technology-ai','innovative'),('technology-ai','user-friendly'),
('society-community','diversity'),('society-community','resident'),('society-community','charity'),('society-community','poverty'),('society-community','campaign'),('society-community','donation'),
('money-shopping','bargain'),('money-shopping','debt'),('money-shopping','income'),('money-shopping','purchase'),('money-shopping','refund'),('money-shopping','wasteful'),
('media-communication','editorial'),('media-communication','headline'),('media-communication','coverage'),('media-communication','censorship'),('media-communication','biased'),('media-communication','journalism'),
('science-innovation','analyse'),('science-innovation','variable'),('science-innovation','outcome'),('science-innovation','accurate'),('science-innovation','method'),('science-innovation','observation'),
('ideas-opinions','challenge'),('ideas-opinions','interpret'),('ideas-opinions','logical'),('ideas-opinions','persuasive'),('ideas-opinions','nuance'),('ideas-opinions','counterargument')
) AS s(topic_id, term)
JOIN vocabulary_entries e ON e.normalized_term = s.term
ON CONFLICT (topic_id, entry_id) DO NOTHING;

INSERT INTO vocabulary_senses (entry_id, sense_number, definition_en, meaning_vi, cefr_level, example, source_name, source_status)
SELECT id, 1, definition_en, meaning_vi, cefr_level, example, source_name, 'draft'
FROM vocabulary_entries
WHERE source_name = 'demo-authored; unverified'
ON CONFLICT (entry_id, sense_number) DO NOTHING;

INSERT INTO vocabulary_sources (entry_id, source_name, source_type, license_note, verification_status)
SELECT e.id, e.source_name, 'app-authored-demo', 'Demo-authored learning content; CEFR labels and examples need review before release.', 'draft'
FROM vocabulary_entries e
WHERE e.source_name = 'demo-authored; unverified'
  AND NOT EXISTS (SELECT 1 FROM vocabulary_sources vs WHERE vs.entry_id = e.id AND vs.source_name = e.source_name)
ON CONFLICT DO NOTHING;