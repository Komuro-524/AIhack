-- =====================================================================
--  Qiita記事のスクリーンショット用：画面が映えるデータを足す
--
--  前提：0020_tag_requests.sql → 0021_ui_demo_seed.sql → supabase/demo/reset-demo.sql を流したあと
--  足すもの（すべて架空。目印は source_ref が 'article-shots-…'）
--    ① 配信中のライブ「Teams会議の小技を持ち寄る」に 話した言葉6行と リスナー3人
--    ② 知識地図がにぎやかになるように 過去のライブ3本と 知見カード12枚（正式タグ）
--    ③ 藤代 咲良さんのプロフィールに 自己分析で付いた非公開の知見タグ2つ
--
--  ★ 何度流しても増えない（not exists / on conflict do nothing）
--  ★ delete / drop / truncate は使っていない
-- =====================================================================
begin;

-- ---------------------------------------------------------------------
-- ① 配信中のライブを にぎやかにする
-- ---------------------------------------------------------------------
-- リスナーを3人足す（神谷さん＝話し手、早坂・藤代・白石さんは reset-demo.sql で入っている）
insert into live_participants (live_id, user_id, role, joined_at)
select l.id, u.id, 'listener', l.started_at + interval '2 minutes'
from lives l
join users u on u.display_name in ('星野 陸', '桜庭 芽衣', '綾瀬 大輝')
where l.source_ref = 'ui-demo-onair'
on conflict do nothing;

-- 話し手の「話した言葉」（マイクで話して文字になったもの）。まだ1行も無いときだけ入れる
insert into transcript_segments (live_id, user_id, seq, spoken_at, body)
select l.id, u.id, v.seq, now() - v.ago, v.body
from lives l
join users u on u.display_name = '神谷 美月'
cross join (values
  (1, interval '13 minutes', '今日はTeams会議でちょっと楽になった小ワザを持ち寄る回です。まず私から話しますね'),
  (2, interval '12 minutes', '会議の最後に3分だけ取って、決まったことを読み上げるようにしています'),
  (3, interval '11 minutes', '読み上げる前にチャットに箇条書きで貼っておくと、あとから探すときもチャットを見るだけで済みます'),
  (4, interval '8 minutes',  '宿題には必ず名前と期限を付けます。担当が書いていない宿題は、だいたい誰も動かないので'),
  (5, interval '5 minutes',  '藤代さんの、招待の本文に議題を3行で書く話はいいですね。私も明日から真似します'),
  (6, interval '2 minutes',  '録画の前にひと言断るルール、部署で決めておくと安心して話せますよね')
) v(seq, ago, body)
where l.source_ref = 'ui-demo-onair'
  and not exists (select 1 from transcript_segments s where s.live_id = l.id);

-- リスナーのコメントを2件足す（同じ本文が無いときだけ）
insert into messages (live_id, user_id, body, is_agent, created_at)
select l.id, u.id, v.body, false, now() - v.ago
from lives l
cross join (values
  ('星野 陸',   '宿題に名前と期限、うちのチームでもやってみます！', interval '7 minutes'),
  ('桜庭 芽衣', 'チャットに貼ってから読み上げる方法、議事録係が楽になりそうです', interval '1 minute')
) v(who, body, ago)
join users u on u.display_name = v.who
where l.source_ref = 'ui-demo-onair'
  and not exists (select 1 from messages m where m.live_id = l.id and m.body = v.body);

-- ---------------------------------------------------------------------
-- ② 知識地図をにぎやかにする
--    同じライブで一緒に語られたタグ同士に線が引かれるので 1本のライブに複数のタグを入れる
-- ---------------------------------------------------------------------
insert into lives (title, status, started_at, ended_at, source_ref, ingest_status) values
  ('まなびのライブ — 承認フローを自動化した話',   'ended', now() - interval '12 days 2 hours', now() - interval '12 days 1 hour', 'article-shots-pa',   'done'),
  ('まなびのライブ — 生成AIで資料づくりを速くする', 'ended', now() - interval '9 days 2 hours',  now() - interval '9 days 1 hour',  'article-shots-ai',   'done'),
  ('まなびのライブ — 集計とグラフの小ワザ',        'ended', now() - interval '4 days 2 hours',  now() - interval '4 days 1 hour',  'article-shots-data', 'done')
on conflict (source_ref) do nothing;

create temp table _cards (ref text, who text, tag text, headline text, body text) on commit drop;
insert into _cards values
  ('article-shots-pa',   '綾瀬 大輝', 'Power Automate', '承認フローは「差し戻し」の分岐から作る',   '承認されたときより差し戻されたときの流れを先に決めると、あとで作り直しが起きにくい。'),
  ('article-shots-pa',   '綾瀬 大輝', 'Power Apps',     '入力画面は必須項目だけ先に並べる',         '最初の画面に必須項目だけを置き、任意の項目は折りたたむと入力漏れが減った。'),
  ('article-shots-pa',   '郡司 蓮',   'SQL',            '申請データは日付の列で絞ってから集計する', '全件を読んでから絞るより、日付で先に絞ると集計の待ち時間が短くなる。'),
  ('article-shots-pa',   '早坂 悠人', '生成AI活用',     'フローの説明文はAIに下書きさせる',         '作ったフローの説明を生成AIに下書きさせ、人は間違いだけ直すと引き継ぎ資料がすぐできる。'),
  ('article-shots-ai',   '早坂 悠人', '生成AI活用',     '資料は先に目次だけ作らせる',               'いきなり本文を頼まず、目次を作らせてから1章ずつ頼むと手戻りが少ない。'),
  ('article-shots-ai',   '郡司 蓮',   'プロンプト設計', '頼むときは「誰に向けた資料か」を最初に書く', '読み手を最初に書くだけで、言葉の難しさと分量がそろう。'),
  ('article-shots-ai',   '桜庭 芽衣', 'プロンプト設計', '出力の形は表で指定する',                   '箇条書きより表の列を指定したほうが、そのまま資料に貼れる形で返ってくる。'),
  ('article-shots-ai',   '白石 結衣', '情報整理',       '会議のメモは決定・宿題・保留に分ける',     '発言順に並べず3つに分けておくと、要約を頼むときも読み返すときも速い。'),
  ('article-shots-data', '神谷 美月', 'データ可視化',   '月別の推移は折れ線、内訳は横棒',           '同じデータでも見せたいことでグラフを変えると、説明が短くて済む。'),
  ('article-shots-data', '神谷 美月', 'Excel VBA',      '毎月の集計は記録したマクロから始める',     'まず操作を記録し、繰り返し部分だけ直すと、VBAに慣れていなくても保守できる。'),
  ('article-shots-data', '千葉 陽菜', 'データ可視化',   'グラフの色は伝えたい1本だけ変える',       '全部に色を付けず、見てほしい系列だけ色を変えると要点が一目で伝わる。'),
  ('article-shots-data', '郡司 蓮',   'SQL',            '集計の前に重複の行を確かめる',             '件数が合わないときは、先に同じキーの行が重なっていないかを確かめる。');

insert into live_participants (live_id, user_id, role, joined_at)
select distinct l.id, u.id, 'speaker', l.started_at
from _cards c join lives l on l.source_ref = c.ref join users u on u.display_name = c.who
on conflict do nothing;

insert into live_participants (live_id, user_id, role, joined_at)
select l.id, u.id, 'listener', l.started_at
from lives l
join users u on u.display_name in ('星野 陸', '松永 蒼', '藤代 咲良')
where l.source_ref like 'article-shots-%'
on conflict do nothing;

insert into knowledge_cards (live_id, tag_id, speaker_id, headline, body, confidence, created_at)
select l.id, t.id, u.id, c.headline, c.body, 0.8, l.ended_at
from _cards c
join lives l on l.source_ref = c.ref
join tags  t on t.name = c.tag and t.status = 'official'
join users u on u.display_name = c.who
where not exists (select 1 from knowledge_cards k where k.live_id = l.id and k.headline = c.headline);

insert into user_tags (user_id, tag_id, kind, strength, source, visibility)
select distinct u.id, t.id, 'knowledge', 1.0, 'live', 'public'
from _cards c join tags t on t.name = c.tag and t.status = 'official' join users u on u.display_name = c.who
on conflict (user_id, tag_id, kind) do nothing;

-- ---------------------------------------------------------------------
-- ③ 藤代 咲良さんの自己分析の結果（非公開の知見タグ）
--    ★ 画面の「自己分析」を実際に動かせば同じものが付く。撮影を1回で済ませたいとき用
-- ---------------------------------------------------------------------
insert into user_tags (user_id, tag_id, kind, strength, source, visibility)
select u.id, t.id, 'knowledge', 0.8, 'self', 'private'
from users u
join tags t on t.name in ('データ可視化', 'Excel VBA') and t.status = 'official'
where u.display_name = '藤代 咲良'
on conflict (user_id, tag_id, kind) do nothing;

commit;

-- =====================================================================
--  確認（1行）  期待 → 話した言葉6 ／ 配信中の参加者7 ／ 地図用のカード12 ／ 藤代さんの非公開タグ2
-- =====================================================================
select
  (select count(*) from transcript_segments s join lives l on l.id = s.live_id where l.source_ref = 'ui-demo-onair') as 話した言葉,
  (select count(*) from live_participants p join lives l on l.id = p.live_id where l.source_ref = 'ui-demo-onair')   as 配信中の参加者,
  (select count(*) from knowledge_cards k join lives l on l.id = k.live_id where l.source_ref like 'article-shots-%') as 地図用のカード,
  (select count(*) from user_tags ut join users u on u.id = ut.user_id
     where u.display_name = '藤代 咲良' and ut.source = 'self' and ut.visibility = 'private')                      as 藤代さんの非公開タグ;
