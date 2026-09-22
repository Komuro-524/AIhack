-- =====================================================================
--  カット1の撮り直し用: 配信中のライブ「Teams会議の小技を持ち寄る」を、まっさらな状態で立て直す
--
--  ・いまの配信中のライブ（練習の文字起こしが残っている）は「中止」にして目印を外す
--    → 消さないので記録は残るが、ライブ一覧・カレンダーには出なくなり、タグ付けも走らない
--  ・同じ題名で新しい配信中のライブを立て、話し手 神谷 美月・早坂 悠人／聞き手 藤代 咲良・白石 結衣 を入れる
--  ・最初のコメント（エージェントのあいさつ＋4件）だけ入れ直す。文字起こしは0行から始まる
--
--  ★ delete は使わない。何回流してもよい（流すたびに新しいライブになる）
--  ★ 流したあとはライブのURLが変わるので、ライブ一覧から開き直すこと
-- =====================================================================
begin;

-- いまの配信中のライブを中止にして目印を外す（タグ付けエージェントが拾わないよう取り込み済み扱いに）
update lives
   set status = 'cancelled', ingest_status = 'done', ended_at = coalesce(ended_at, now()),
       started_at = null, scheduled_start = null, scheduled_end = null,   -- 日程カレンダーに出さない
       source_ref = 'ui-demo-onair-old-' || id
 where source_ref = 'ui-demo-onair';

-- 新しい配信中のライブ
insert into lives (title, status, started_at, source_ref, topic_tag_id)
select 'まなびのライブ — Teams会議の小技を持ち寄る', 'live', now() - interval '2 minutes', 'ui-demo-onair', t.id
from tags t where t.name = 'Teams会議の小技';

insert into live_participants (live_id, user_id, role, joined_at)
select l.id, u.id, case when u.display_name in ('神谷 美月','早坂 悠人') then 'speaker' else 'listener' end, l.started_at
from lives l
join users u on u.display_name in ('神谷 美月','早坂 悠人','藤代 咲良','白石 結衣')
where l.source_ref = 'ui-demo-onair';

insert into messages (live_id, user_id, body, is_agent, created_at)
select l.id, (select id from users where display_name = v.who), v.body, v.who is null, now() - v.ago
from lives l
cross join (values
  (null,        '場づくりエージェントです。「Teams会議の小技」に興味のある人が集まったので場を開きました。まずは最近助かった小ワザを1つずつどうぞ', interval '2 minutes'),
  ('藤代 咲良', '招待を送るときに議題を3行で本文に書いておくと、当日の脱線が減りました', interval '90 seconds'),
  ('白石 結衣', '録画をオンにする前にひと言断る、のルールを部署で決めたら安心して話せるようになりました', interval '60 seconds')
) v(who, body, ago)
where l.source_ref = 'ui-demo-onair';

commit;

-- 確認  期待 → 状態=live ／ 話し手2 ／ 文字起こし0 ／ コメント3
select l.id as ライブid, l.status as 状態,
  (select count(*) from live_participants p where p.live_id = l.id and p.role = 'speaker') as 話し手,
  (select count(*) from transcript_segments s where s.live_id = l.id)                     as 文字起こし,
  (select count(*) from messages m where m.live_id = l.id)                                as コメント
from lives l where l.source_ref = 'ui-demo-onair';
