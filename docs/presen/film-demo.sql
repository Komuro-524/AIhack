-- =====================================================================
--  デモ動画の撮影用: いちばん映える状態のデータにする（9/22 夜 撮影用）
--
--  ★ 先に supabase/demo/reset-demo.sql を流してから、これを流す
--    （reset-demo = タグ帳・打診・5つのタネ・配信中のライブを最初の状態に戻す
--      film-demo  = 知識地図とライブのタネを「にぎやか」にする ＋ 撮影用の小さな調整）
--
--  足すもの（すべて架空。実在の会社名・顧客名・人名は使っていない）:
--    A. 正式タグ 11個（分野・技術・業務にばらす）→ 知識地図の円が増え、分類ボタンで絞ると差が見える
--    B. 過去のライブ 6本と 知見カード 44枚 → 円の大きさに差がつき、線で島どうしがつながる
--    C. 話した人に知見タグ・聞いていた人に興味タグ → 人のページとプロフィールがにぎやかになる
--       松永 蒼（管理者）も話し手にしてある → 松永さんでログインすると地図に「あなたのタグ」が出る
--    D. ライブのタネを 5つ → 12こ に（各段に2〜3こ）。需要の差で植物の大きさにも差がつく
--       ・Git は「興味3人＋詳しい人2人」の育ち待ち → 「いま1周動かす」を押すと AIが開くと判断しやすい
--       ・SharePoint は「興味1人」の育ち待ち → AIが「まだ待つ」と判断しやすい（判断が分かれる絵が撮れる）
--    E. 配信中のライブ（Teams会議の小技）に 早坂 悠人さんを話し手として追加 → 2人で話す絵が撮れる
--
--  使い方: Supabase の SQL Editor に貼って Run。何回流してもよい（撮り直しのたびに流せる）
--  ★ 本物の運用データには触らない（ライブは source_ref が 'film-…'、タネは下の7タグだけ）
--  ★ delete / drop / truncate は使わない。撮り直し用の巻き戻しは update（中止・期限切れ）だけ
--  ★ AIの費用の記録（agent_runs）は作らない。管理画面の費用は本物のログのまま
-- =====================================================================
begin;

-- ---------------------------------------------------------------------
-- A. 正式タグ
--    すでに候補・格上げ候補として同じ名前があれば 正式に上げる（禁止・弾いたものには触らない）
-- ---------------------------------------------------------------------
insert into tags (name, kind, status, promoted_at) values
  ('DX推進',         '分野', 'official', now() - interval '30 days'),
  ('AIガバナンス',   '分野', 'official', now() - interval '30 days'),
  ('ナレッジ共有',   '分野', 'official', now() - interval '30 days'),
  ('Python',         '技術', 'official', now() - interval '30 days'),
  ('Git',            '技術', 'official', now() - interval '30 days'),
  ('Copilot Studio', '技術', 'official', now() - interval '30 days'),
  ('SharePoint',     '技術', 'official', now() - interval '30 days'),
  ('顧客ヒアリング', '業務', 'official', now() - interval '30 days'),
  ('プレゼン資料',   '業務', 'official', now() - interval '30 days'),
  ('テスト設計',     '業務', 'official', now() - interval '30 days'),
  ('KPI設計',        '業務', 'official', now() - interval '30 days')
on conflict (name) do update
  set status = 'official', promoted_at = coalesce(tags.promoted_at, excluded.promoted_at)
  where tags.status in ('candidate', 'proposed');

-- ---------------------------------------------------------------------
-- B-1. 過去のライブ 6本（終了・取り込み済み ＝ タグ付けエージェントは二度と走らない）
-- ---------------------------------------------------------------------
insert into lives (title, status, started_at, ended_at, source_ref, ingest_status, topic_tag_id)
select v.title, 'ended', now() - v.ago - interval '1 hour', now() - v.ago, v.ref, 'done', t.id
from (values
  ('film-pp',   'まなびのライブ — Power Platform 最初の一歩',   interval '25 days', 'Power Automate'),
  ('film-ai',   'まなびのライブ — 生成AIの使いどころ',         interval '18 days', '生成AI活用'),
  ('film-data', 'まなびのライブ — 数字で語る資料づくり',       interval '13 days', 'データ可視化'),
  ('film-req',  'まなびのライブ — 要件定義はどこから聞くか',   interval '9 days',  '要件定義'),
  ('film-dev',  'まなびのライブ — Pythonで毎日の作業を減らす', interval '4 days',  'Python'),
  ('film-dx',   'まなびのライブ — DX推進のつまずきを持ち寄る', interval '2 days',  'DX推進')
) v(ref, title, ago, topic)
left join tags t on t.name = v.topic
on conflict (source_ref) do nothing;

-- B-2. 参加者（話し手・聞き手）
insert into live_participants (live_id, user_id, role, joined_at)
select l.id, u.id, v.role, l.started_at
from (values
  ('film-pp','綾瀬 大輝','speaker'),('film-pp','早坂 悠人','speaker'),
  ('film-pp','星野 陸','listener'),('film-pp','神谷 美月','listener'),('film-pp','藤代 咲良','listener'),('film-pp','松永 蒼','listener'),
  ('film-ai','早坂 悠人','speaker'),('film-ai','郡司 蓮','speaker'),('film-ai','桜庭 芽衣','speaker'),
  ('film-ai','星野 陸','listener'),('film-ai','千葉 陽菜','listener'),('film-ai','白石 結衣','listener'),('film-ai','松永 蒼','listener'),('film-ai','藤代 咲良','listener'),
  ('film-data','神谷 美月','speaker'),('film-data','千葉 陽菜','speaker'),
  ('film-data','星野 陸','listener'),('film-data','白石 結衣','listener'),('film-data','綾瀬 大輝','listener'),('film-data','早坂 悠人','listener'),('film-data','松永 蒼','listener'),
  ('film-req','白石 結衣','speaker'),('film-req','星野 陸','speaker'),('film-req','桜庭 芽衣','speaker'),
  ('film-req','千葉 陽菜','listener'),('film-req','藤代 咲良','listener'),('film-req','早坂 悠人','listener'),('film-req','松永 蒼','listener'),('film-req','郡司 蓮','listener'),
  ('film-dev','郡司 蓮','speaker'),('film-dev','綾瀬 大輝','speaker'),
  ('film-dev','桜庭 芽衣','listener'),('film-dev','早坂 悠人','listener'),('film-dev','白石 結衣','listener'),('film-dev','神谷 美月','listener'),
  ('film-dx','松永 蒼','speaker'),('film-dx','白石 結衣','speaker'),('film-dx','千葉 陽菜','speaker'),
  ('film-dx','藤代 咲良','listener'),('film-dx','星野 陸','listener'),('film-dx','神谷 美月','listener'),('film-dx','綾瀬 大輝','listener'),('film-dx','桜庭 芽衣','listener'),('film-dx','郡司 蓮','listener')
) v(ref, who, role)
join lives l on l.source_ref = v.ref
join users u on u.display_name = v.who
on conflict do nothing;

-- B-3. 知見カード（誰が・どのタグで・何を話したか。本文は要約）
create temp table _film_talk (ref text, who text, tag text, headline text, body text) on commit drop;
insert into _film_talk values
  ('film-pp','綾瀬 大輝','Power Apps','入力画面は項目を3つに絞ってから作る','最初から全項目を並べると現場で使われない。必須の3項目だけで出して、使われ方を見てから足す。'),
  ('film-pp','綾瀬 大輝','Power Automate','承認フローは差し戻しの道を先に描く','通る道より戻る道の方が分岐が多い。差し戻したときの通知先を先に決めると作り直しが減る。'),
  ('film-pp','早坂 悠人','Power Automate','失敗したときだけTeamsに知らせる','実行履歴を毎日見に行くのではなく、失敗したときだけ管理者に通知が届くようにしておく。'),
  ('film-pp','綾瀬 大輝','SharePoint','リストは列の型を最初に決め切る','途中で文字列から数値に変えると既存のデータを移せない。作る前に列の型だけは書き出しておく。'),
  ('film-pp','早坂 悠人','SQL','集計の前に件数を数えて確かめる','結合したあとに行が増えていないかを数えて確かめると、集計の二重計上に気づける。'),
  ('film-pp','綾瀬 大輝','Excel VBA','マクロは最初に画面の更新を止める','画面の描画を止めてから処理し、最後に戻すだけで体感の速さが大きく変わる。'),
  ('film-ai','早坂 悠人','生成AI活用','下書きはAI、判断は人と分ける','文章のたたき台はAIに任せ、送るかどうかと数字の確認は人が持つ。'),
  ('film-ai','郡司 蓮','生成AI活用','社内文書を貼る前に固有名詞を伏せる','顧客名や人名は記号に置き換えてから渡し、戻ってきた文章で元に戻す。'),
  ('film-ai','郡司 蓮','プロンプト設計','出力の形を先に指定する','箇条書きの数や表の列を最初に決めて渡すと、毎回の手直しが減る。'),
  ('film-ai','桜庭 芽衣','プロンプト設計','望まない書き方の例も一緒に見せる','避けてほしい書き方の例を1つ添えると、言葉で説明するより早く伝わる。'),
  ('film-ai','桜庭 芽衣','Copilot Studio','トピックは質問の言い換えから作る','同じ質問を5通りに言い換えて登録すると、利用者の聞き方の揺れを拾える。'),
  ('film-ai','郡司 蓮','AIガバナンス','使ってよいデータの一覧を先に配る','禁止事項を並べるより、入れてよいデータの一覧を配る方が現場は迷わない。'),
  ('film-ai','早坂 悠人','議事録の書き方','録音からの要約は決定事項だけ人が見直す','全文を読み直す時間はない。決まったことと期限だけを確かめてから配る。'),
  ('film-data','千葉 陽菜','データ可視化','グラフの題名に言いたいことを書く','「月別売上」ではなく「3月から伸びが鈍った」と書くと、読み手が迷わない。'),
  ('film-data','神谷 美月','データ可視化','色は強調したい1本だけに付ける','全部に色を付けると何も目立たない。比べたい1本以外は灰色にする。'),
  ('film-data','千葉 陽菜','Power BI','最初の1枚は表から作る','いきなりグラフにせず、数字の表で合っているか確かめてから見た目を作る。'),
  ('film-data','神谷 美月','Excel関数','月次の締めはSUMIFSで科目ごとに出す','条件を後から追えるように関数で残すと、引き継ぎが楽になる。'),
  ('film-data','神谷 美月','SQL','月次の数字は保存したクエリで出す','毎月書き直すと条件がずれる。保存したクエリの日付だけを変えて使う。'),
  ('film-data','千葉 陽菜','KPI設計','指標は行動で動かせるものを選ぶ','結果の数字だけを追うと打ち手がない。手前の行動の数を1つ置く。'),
  ('film-data','千葉 陽菜','プレゼン資料','1枚に言いたいことは1つ','情報を足したくなったら枚数を増やす。結論をいちばん上に書く。'),
  ('film-req','白石 結衣','要件定義','画面の話の前に「なぜ」を3回聞く','画面の要望から入ると本当の困りごとを取りこぼす。目的を先にそろえる。'),
  ('film-req','星野 陸','顧客ヒアリング','最後に聞いた内容を読み上げて確かめる','持ち帰る前に要点を口に出すと、認識のずれがその場で見つかる。'),
  ('film-req','白石 結衣','顧客ヒアリング','今の手順を実際に操作してもらう','口頭の説明より、画面を操作してもらう方が例外の手順に気づける。'),
  ('film-req','桜庭 芽衣','テスト設計','要件と一緒に確かめ方も書く','「どうなれば完成か」を要件と同時に決めておくと、テストの抜けが減る。'),
  ('film-req','白石 結衣','ファシリテーション','会議の冒頭で終わりの状態を決める','「今日は案を2つに絞る」と最初に言うと、議論が散らない。'),
  ('film-req','星野 陸','情報整理','聞いた話はその日のうちに3行にまとめる','翌日に回すと記憶が混ざる。事実・要望・宿題の3行にする。'),
  ('film-dev','郡司 蓮','Python','毎日のCSV加工はスクリプトにして残す','手作業の手順をそのままコードにすると、休んだ日も誰かが回せる。'),
  ('film-dev','郡司 蓮','Git','コミットの説明には「なぜ」を書く','何を変えたかは差分で分かる。変えた理由を1行残すと後で助かる。'),
  ('film-dev','綾瀬 大輝','Git','動く単位で小さく保存する','大きな変更を1回で残すと戻せない。動く単位で区切って保存する。'),
  ('film-dev','郡司 蓮','テスト設計','壊れる入力から先に試す','正しい入力より、空欄や桁あふれから試すと不具合が早く見つかる。'),
  ('film-dev','綾瀬 大輝','Power Automate','重い処理はPythonに任せて呼ぶだけにする','フローに全部を書かず、重い計算は外に出すと保守が楽になる。'),
  ('film-dev','郡司 蓮','生成AI活用','コードの説明文はAIに下書きさせる','読み手向けの説明はAIの下書きが速い。間違いだけ人が直す。'),
  ('film-dx','松永 蒼','DX推進','最初の1件は目に見える小さな業務から','全社の仕組みより、隣の部署の手作業を1つ減らす方が次につながる。'),
  ('film-dx','松永 蒼','ナレッジ共有','聞かれた質問は答えを共有の場所に置く','個別に答えると同じ質問がまた来る。答えを共有の場所に置いてリンクを返す。'),
  ('film-dx','白石 結衣','ナレッジ共有','手順書より先に相談先の一覧を作る','何を読めばいいかより、誰に聞けばいいかが分かる方が早く動ける。'),
  ('film-dx','千葉 陽菜','AIガバナンス','利用ルールはよい例と悪い例をつけて配る','禁止の文章だけでは判断できない。よい例と悪い例を1つずつ添える。'),
  ('film-dx','白石 結衣','情報整理','資料の置き場所は1か所に決める','置き場所が2つあると最新版が分からなくなる。'),
  ('film-dx','松永 蒼','ファシリテーション','発言が少ない人に最初に振る','後半になるほど話しにくくなる。最初の5分で全員にひと言ずつ話してもらう。'),
  ('film-dx','千葉 陽菜','問い合わせ対応','よくある質問は件数の多い10件から整える','全部を整えようとすると終わらない。件数の多い順に手を付ける。'),
  ('film-dx','千葉 陽菜','生成AI活用','問い合わせの一次回答はAIの下書きから','よくある質問への返信はAIに下書きさせ、担当者が確かめてから送る。'),
  ('film-dx','千葉 陽菜','データ可視化','取り組みの成果は前後の比較1枚で見せる','数字を並べるより、始める前と後を1枚で並べる方が伝わる。'),
  ('film-req','桜庭 芽衣','生成AI活用','聞き取りのメモをAIで要件の形に並べ替える','ばらばらのメモを「目的・現状・要望」の順にAIで並べ替えてから見直すと早い。'),
  ('film-data','神谷 美月','Power Automate','月次の集計ファイルは届いたら自動で整える','メールで届いたファイルを決まった場所に保存し、形をそろえるところまで自動にする。'),
  ('film-dev','郡司 蓮','SQL','PythonからSQLを呼ぶときは条件を引数で渡す','文字をつなげて組み立てず、条件は引数で渡すと安全で読みやすい。');

insert into knowledge_cards (live_id, tag_id, speaker_id, headline, body, confidence, verification, created_at)
select l.id, t.id, u.id, x.headline, x.body, 0.85, 'verified', l.ended_at
from _film_talk x
join lives l on l.source_ref = x.ref
join tags  t on t.name = x.tag
join users u on u.display_name = x.who
where not exists (select 1 from knowledge_cards k where k.live_id = l.id and k.headline = x.headline);

-- ---------------------------------------------------------------------
-- C. 人に付くタグと「語られた記録」
-- ---------------------------------------------------------------------
-- 話した人 → 知見タグ
insert into user_tags (user_id, tag_id, kind, strength, answer_count, source, visibility)
select u.id, t.id, 'knowledge', 2.0, 1, 'live', 'public'
from _film_talk x join tags t on t.name = x.tag join users u on u.display_name = x.who
on conflict (user_id, tag_id, kind) do nothing;

-- 語られた記録（知見）
insert into tag_mentions (tag_id, user_id, live_id, kind, created_at)
select t.id, u.id, l.id, 'knowledge', l.ended_at
from _film_talk x
join lives l on l.source_ref = x.ref
join tags  t on t.name = x.tag
join users u on u.display_name = x.who
where not exists (select 1 from tag_mentions m where m.live_id = l.id and m.tag_id = t.id and m.user_id = u.id and m.kind = 'knowledge');

-- 聞いていた人の「興味」（ライブのタネの需要と、場づくりエージェントの判断材料）
create temp table _film_interest (ref text, tag text, who text) on commit drop;
insert into _film_interest values
  ('film-dev','Git','桜庭 芽衣'),('film-dev','Git','早坂 悠人'),('film-dev','Git','白石 結衣'),
  ('film-pp','SharePoint','藤代 咲良'),
  ('film-data','KPI設計','星野 陸'),('film-data','KPI設計','白石 結衣'),('film-data','KPI設計','綾瀬 大輝'),
  ('film-ai','AIガバナンス','千葉 陽菜'),('film-ai','AIガバナンス','松永 蒼'),('film-ai','AIガバナンス','白石 結衣'),
  ('film-req','テスト設計','千葉 陽菜'),('film-req','テスト設計','早坂 悠人'),('film-dev','テスト設計','白石 結衣'),
  ('film-dev','Python','早坂 悠人'),('film-dev','Python','桜庭 芽衣'),('film-dev','Python','神谷 美月'),('film-dev','Python','白石 結衣'),
  ('film-req','顧客ヒアリング','千葉 陽菜'),('film-req','顧客ヒアリング','藤代 咲良'),('film-req','顧客ヒアリング','郡司 蓮'),('film-req','顧客ヒアリング','早坂 悠人');

insert into user_tags (user_id, tag_id, kind, strength, source, visibility)
select u.id, t.id, 'interest', 1.0, 'live', 'public'
from _film_interest x join tags t on t.name = x.tag join users u on u.display_name = x.who
on conflict (user_id, tag_id, kind) do nothing;

insert into tag_mentions (tag_id, user_id, live_id, kind, created_at)
select t.id, u.id, l.id, 'interest', l.ended_at
from _film_interest x
join lives l on l.source_ref = x.ref
join tags  t on t.name = x.tag
join users u on u.display_name = x.who
where not exists (select 1 from tag_mentions m where m.live_id = l.id and m.tag_id = t.id and m.user_id = u.id and m.kind = 'interest');

-- ---------------------------------------------------------------------
-- D. ライブのタネを増やす（各段に2〜3こ）
--    [タグ, 段階, 相談役, 予約したライブ（source_ref）]
-- ---------------------------------------------------------------------
create temp table _film_seed (tag text, status text, invitee text, live_ref text) on commit drop;
insert into _film_seed values
  ('Git',            'scouting',   null,        null),
  ('SharePoint',     'scouting',   null,        null),
  ('KPI設計',        'inviting',   '千葉 陽菜', null),
  ('AIガバナンス',   'inviting',   '郡司 蓮',   null),
  ('テスト設計',     'scheduling', '郡司 蓮',   null),
  ('Python',         'opened',     '郡司 蓮',   'film-next-python'),
  ('顧客ヒアリング', 'opened',     '白石 結衣', 'film-next-hearing');

-- 予約済みのライブ（つぼみの2つ）。日時は撮影日から見て 2日後15時・5日後18時（日本時間）
insert into lives (title, status, scheduled_start, scheduled_end, source_ref, topic_tag_id)
select v.title, 'scheduled',
       date_trunc('day', now()) + v.at - interval '9 hours',
       date_trunc('day', now()) + v.at + interval '1 hour' - interval '9 hours',
       v.ref, t.id
from (values
  ('film-next-python',  'まなびのライブ — Pythonで毎日の作業を減らす（その2）', interval '2 days 15 hours', 'Python'),
  ('film-next-hearing', 'まなびのライブ — 顧客ヒアリングの聞き方',             interval '5 days 18 hours', '顧客ヒアリング')
) v(ref, title, at, topic)
join tags t on t.name = v.topic
on conflict (source_ref) do nothing;

-- タネ本体（新しいタグなので 1タグ1つ）
insert into quests (tag_id, status, interested_ids, current_invitee, tried_count, live_id, next_action_at)
select t.id, s.status,
       array(select u.id from _film_interest i join users u on u.display_name = i.who where i.tag = s.tag),
       (select id from users where display_name = s.invitee),
       case when s.invitee is null then 0 else 1 end,
       (select id from lives where source_ref = s.live_ref),
       now() + interval '1 day'
from _film_seed s join tags t on t.name = s.tag
where not exists (select 1 from quests q where q.tag_id = t.id);

-- 花（開催済み）を2つ足す: 過去のライブがそのまま「咲いた」形
insert into quests (tag_id, status, interested_ids, current_invitee, tried_count, live_id, closed_at, outcome, attendee_count, cards_created)
select t.id, 'done', '{}', (select id from users where display_name = v.who), 1, l.id, l.ended_at, 'ライブを開催した',
       (select count(*) from live_participants p where p.live_id = l.id),
       (select count(*) from knowledge_cards k where k.live_id = l.id)
from (values ('プロンプト設計','film-ai','郡司 蓮'), ('ファシリテーション','film-req','白石 結衣')) v(tag, ref, who)
join tags t on t.name = v.tag
join lives l on l.source_ref = v.ref
where not exists (select 1 from quests q where q.tag_id = t.id and q.live_id = l.id);

update lives l set quest_id = q.id
  from quests q
 where q.live_id = l.id and l.quest_id is null
   and l.source_ref in ('film-next-python','film-next-hearing','film-ai','film-req');

-- 予約済みライブの話し手と、声をかけた人
insert into live_participants (live_id, user_id, role, invited_at)
select l.id, q.current_invitee, 'speaker', now() - interval '1 day'
from lives l join quests q on q.id = l.quest_id
where l.source_ref in ('film-next-python','film-next-hearing')
on conflict do nothing;

insert into live_participants (live_id, user_id, invited_at)
select l.id, unnest(q.interested_ids), now() - interval '1 day'
from lives l join quests q on q.id = l.quest_id
where l.source_ref in ('film-next-python','film-next-hearing')
on conflict do nothing;

-- 判断ログ（畑番の吹き出しと、タネの札の「最後に動いた日時」に出る）
insert into quest_steps (quest_id, kind, decision, reason, created_at)
select q.id, v.kind, v.decision, v.reason, now() - v.ago
from (values
  ('Git',            'judge',    'wait',     '興味を持つ人が3人になった。詳しい人も2人いるので、次の見回りで開くか決める', interval '6 hours'),
  ('SharePoint',     'judge',    'wait',     '興味を持つ人がまだ1人。もう少し集まるのを待つ', interval '6 hours'),
  ('KPI設計',        'judge',    'open',     '興味が3人に増えた。資料づくりのライブで話していた千葉さんに相談役を頼む', interval '1 day'),
  ('KPI設計',        'invite',   'sent',     '千葉さんに相談役を打診した', interval '23 hours'),
  ('AIガバナンス',   'judge',    'open',     '生成AIのライブのあと興味が3人に増えた。使ってよいデータの話をしていた郡司さんに頼む', interval '2 days'),
  ('AIガバナンス',   'invite',   'sent',     '郡司さんに相談役を打診した', interval '2 days'),
  ('テスト設計',     'invite',   'accepted', '郡司さんが引き受けた。3人の空きがそろう枠を探している', interval '8 hours'),
  ('Python',         'open',     'opened',   '4人の空きがそろう枠でライブを予約した', interval '1 day'),
  ('顧客ヒアリング', 'open',     'opened',   '4人の空きがそろう枠でライブを予約した', interval '3 days')
) v(tag, kind, decision, reason, ago)
join tags t on t.name = v.tag
join quests q on q.tag_id = t.id and q.status <> 'done'
where not exists (select 1 from quest_steps s where s.quest_id = q.id and s.reason = v.reason);

-- 打診（千葉さん・郡司さん＝未回答／テスト設計の郡司さん＝引き受け済み）
insert into invitations (quest_id, user_id, status, sent_at, responded_at)
select q.id, u.id, v.status, now() - v.ago, case when v.status = 'accepted' then now() - interval '8 hours' end
from (values ('KPI設計','千葉 陽菜','sent', interval '23 hours'),
             ('AIガバナンス','郡司 蓮','sent', interval '2 days'),
             ('テスト設計','郡司 蓮','accepted', interval '1 day')) v(tag, who, status, ago)
join tags t on t.name = v.tag
join quests q on q.tag_id = t.id and q.status <> 'done'
join users u on u.display_name = v.who
where not exists (select 1 from invitations i where i.quest_id = q.id and i.user_id = u.id);

-- ---------------------------------------------------------------------
-- D'. 撮り直し用の巻き戻し（1回目は何も変わらない。「いま1周動かす」を押したあとに流すと元に戻る）
-- ---------------------------------------------------------------------
-- エージェントが撮影中に予約したライブは中止にする（reset-demo.sql の E と同じ考え方）
update lives l
   set status = 'cancelled', source_ref = coalesce(l.source_ref, 'agent') || '-old-' || l.id
  from quests q, tags t
 where l.quest_id = q.id and q.tag_id = t.id
   and t.name in (select tag from _film_seed)
   and coalesce(l.source_ref, '') not like 'film-%'
   and coalesce(l.source_ref, '') not like '%-old-%'
   and l.status in ('scheduled', 'live');

-- エージェントが撮影中に出した打診は「期限切れ」にする（最初からあった3件は元の状態に）
update invitations i
   set status = 'expired'
  from quests q, tags t
 where i.quest_id = q.id and q.tag_id = t.id
   and t.name in (select tag from _film_seed)
   and i.status in ('sent', 'accepted')
   and (t.name, i.user_id) not in (
     select v.tag, u.id from (values ('KPI設計','千葉 陽菜'),('AIガバナンス','郡司 蓮'),('テスト設計','郡司 蓮')) v(tag, who)
     join users u on u.display_name = v.who);

update invitations i
   set status = v.status, sent_at = now() - v.ago,
       responded_at = case when v.status = 'accepted' then now() - interval '8 hours' end
  from (values ('KPI設計','千葉 陽菜','sent', interval '23 hours'),
               ('AIガバナンス','郡司 蓮','sent', interval '2 days'),
               ('テスト設計','郡司 蓮','accepted', interval '1 day')) v(tag, who, status, ago),
       quests q, tags t, users u
 where i.quest_id = q.id and q.tag_id = t.id and t.name = v.tag
   and i.user_id = u.id and u.display_name = v.who;

-- タネを最初の段階に戻す（各タグの最初の1つだけ）
update quests q
   set status          = s.status,
       current_invitee = (select id from users where display_name = s.invitee),
       live_id         = (select id from lives where source_ref = s.live_ref),
       next_action_at  = now() + interval '1 day',
       closed_at       = null
  from _film_seed s, tags t
 where q.tag_id = t.id and t.name = s.tag
   and q.id = (select min(q2.id) from quests q2 where q2.tag_id = t.id and q2.status <> 'done');

-- 予約済みライブの日時を撮影日に合わせて取り直す
update lives l
   set status = 'scheduled', started_at = null, ended_at = null, ingest_status = 'pending',
       scheduled_start = date_trunc('day', now()) + v.at - interval '9 hours',
       scheduled_end   = date_trunc('day', now()) + v.at + interval '1 hour' - interval '9 hours'
  from (values ('film-next-python', interval '2 days 15 hours'), ('film-next-hearing', interval '5 days 18 hours')) v(ref, at)
 where l.source_ref = v.ref;

-- ---------------------------------------------------------------------
-- E. 配信中のライブを2人で話せるようにする（神谷 美月 ＋ 早坂 悠人）
-- ---------------------------------------------------------------------
insert into live_participants (live_id, user_id, role, joined_at)
select l.id, u.id, 'speaker', l.started_at
from lives l join users u on u.display_name = '早坂 悠人'
where l.source_ref = 'ui-demo-onair' and l.status = 'live'
on conflict (live_id, user_id) do update set role = 'speaker';

commit;

-- =====================================================================
--  確認（1行）
--  期待 → 正式タグ 27以上 ／ 撮影用カード 44 ／ 撮影用ライブ 8 ／ タネ（段階別） 育ち待ち3・相談中3・日程2・予約済み3・開催済み3
--         ／ 配信中の話し手 2
-- =====================================================================
select
  (select count(*) from tags where status = 'official')                                                   as 正式タグ,
  (select count(*) from knowledge_cards k join lives l on l.id = k.live_id where l.source_ref like 'film-%') as 撮影用カード,
  (select count(*) from lives where source_ref like 'film-%')                                             as 撮影用ライブ,
  (select string_agg(st || cnt, '・' order by ord) from (
     select case q.status when 'scouting' then '育ち待ち' when 'inviting' then '相談中' when 'scheduling' then '日程'
                          when 'opened' then '予約済み' else '開催済み' end as st,
            count(*) as cnt,
            array_position(array['scouting','inviting','scheduling','opened','done'], q.status) as ord
     from quests q join tags t on t.id = q.tag_id
     where t.name in ('VBAの保守','問い合わせ対応','要件定義','Power BI','Excel関数','Git','SharePoint','KPI設計','AIガバナンス','テスト設計','Python','顧客ヒアリング','プロンプト設計','ファシリテーション')
       and q.status in ('scouting','inviting','scheduling','opened','done')
     group by q.status) x)                                                                                 as タネ,
  (select count(*) from live_participants p join lives l on l.id = p.live_id
     where l.source_ref = 'ui-demo-onair' and l.status = 'live' and p.role = 'speaker')                     as 配信中の話し手;
