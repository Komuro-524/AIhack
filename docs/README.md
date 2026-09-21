# docs — 資料と証拠の置き場

## 索引

> 📌 **9/21 夜**：ここの HTML は検討の過程のスナップショット。各ページの先頭に注記を入れた。**いまの正は `manabi-no-wa` の `DESIGN.md`（設計）・`README.md`（全体像）・`docs/VOICE-DESIGN.md`（声）**、到達点は `HACKATHON.md` §6.7。
> 呼び名: 学びの輪 → まなびのわ／企て → ライブのタネ／ラベル → タグ／部屋 → まなびのライブ

| ファイル | 中身 |
|---|---|
| [勝ち筋アーキテクチャ型帳.html](勝ち筋アーキテクチャ型帳.html) | 採点基準5軸 × OrcaRouter の対応と、勝ち筋アーキテクチャの型 |
| [orcarouter-nyumon.html](orcarouter-nyumon.html) | OrcaRouter 入門 |
| [AI_HACK_第1回プロダクト図鑑.html](AI_HACK_第1回プロダクト図鑑.html) | 前回開催の参加プロダクト一覧 |
| [feature-board.html](feature-board.html) | 機能のたな卸し |
| [agent-design.html](agent-design.html) | **自律型エージェント設計メモ** — 一文定義・自律ループ・ツール一覧・採点基準5軸への当てはめ・未決の4つの分かれ道 |
| [gap-check.html](gap-check.html) | **設計の穴チェック** — 16個の見落とし。提出でpublicになるトランスクリプトの扱いは赤 |
| [agent-split.html](agent-split.html) | **2体のエージェント設計** — 記録係と幹事の役割分担・権限分離・危険20件と対策・9日間の「企て」シナリオ |
| [scoring-map.html](scoring-map.html) | **採点基準5軸マップ** — 設計ぜんぶを50点の配点に組み直したもの。打ち手・撮る証拠・記事の目次案 |
| [data-model.html](data-model.html) | **3体目のエージェントとテーブル設計** — 自己分析係の実装案・データの背骨・テーブル13枚・SupabaseのSQL |
| [rls-nyumon.html](rls-nyumon.html) | **RLS入門** — なぜSupabaseでは必須か。まなびのわの各テーブルのポリシーとSQL |
| [admin-view.html](admin-view.html) | **管理者ビュー** — 人材育成担当の画面。候補タグの拒否権・弾いた語の復活・知識地図の置き場 |
| [chat-update.html](chat-update.html) | チャット対応の設計変更（※一部 spec-v2 で更新） |
| [spec-v2.html](spec-v2.html) | **9/20 時点の確定仕様 v2**（実装後の正は `manabi-no-wa/DESIGN.md`） — まなびのライブ／予約と日程調整／タグ格上げの承認制／人の門3つ |
| [security-check.html](security-check.html) | **★提出前セキュリティ点検** — 設計バグ4つと直し方・全20項目・提出前チェックリスト |
| [threat-model.html](threat-model.html) | **★危険と防御 総まとめ**（小室さん連携用）— 踏むと終わる10個・エージェント別の壊れ方・全危険43件 |
| [build-plan.md](build-plan.md) | **★実装の進め方と提出前チェック** — 今夜のゴール・撮る証拠・8項目チェック・記事の目次 |
| [kiji-neta.md](kiji-neta.md) | **★記事ネタ帳**（小室連携用）— 岩田側のセッションでしか見えていない設計の理由・トライ＆エラー・知らなかったこと・数字。**各セッションが末尾に追記していく** |
| [timeline.html](timeline.html) | **★提出までの道のり**（小室連携用）— 9/19からの経過と、9/22 14:00 提出までの時間割。担当・所要時間つき |
| [repo-docs.html](repo-docs.html) | README / DESIGN / ARCHITECTURE / CLAUDE / AGENTS の違い。今回どれを作るか |
| [video-script.html](video-script.html) | **壊して直す動画の台本**（③堅牢性の証拠。撮影済み → `recordings/`） |
| [manabi-no-wa-kiji-board.html](manabi-no-wa-kiji-board.html) | 記事構成ボード |
| [agent-jissou.html](agent-jissou.html) | **★コードでエージェントを作るとは** — Copilot Studioとの対比・ループの中身25行・3体の置き場所 |

> 📘 **実装向けの正は `manabi-no-wa/DESIGN.md`。** このフォルダは考える過程の置き場。
> 迷ったら `manabi-no-wa/DESIGN.md` → `threat-model.html`（危険と防御の洗い出し）の順に見る。
> 🎙️ 声の設計図（ビジュアル版）: Claude の成果物ページ「まなびのわ 声の設計図」（`manabi-no-wa/docs/VOICE-DESIGN.md` と同じ内容）

## サブフォルダ

| 場所 | 中身 |
|---|---|
| `transcripts/` | Tactiq の議事録（Google Meet の文字起こし）をエクスポートして置く |
| `evidence/` | **提出物の証拠**。Qiita記事に貼る素材をここに集める（文字の証拠は `manabi-no-wa/docs/evidence/`） |
| `recordings/` | 撮影した動画（壊して直す 等） |
| `mirror-shots/` | 自己分析の検証に使った画面の静止画 |
| `mock-natsuki/` | 岩田の画面モック（9/21） |

### evidence/ に集めるもの（採点直結）

| 軸 | 撮るもの |
|---|---|
| ① セキュリティ | プロンプトインジェクションを打ち込んで**止まる画面** |
| ② コストパフォーマンス | Request Logs のモデル別レシート／「全部を高級モデルで回した場合」との比較 |
| ③ 信頼性・堅牢性 | わざと壊して**復旧する動画**（モデル落ち／空入力／巨大入力／ツール失敗） |
| ④ 自律性 | 人の介在点の設計図／「○件中、人に聞いたのは2件」の記録 |

> 詳しくはルートの `HACKATHON.md` の §3 を見る。

---

## 運営の配布資料について

キックオフの投影資料（主催スライド・OrcaRouter様資料）は**このリポジトリには置かない**。
提出時に public になるため、運営・スポンサーの資料の再配布になってしまう。

- 資料そのもの → **Discord** で共有される（スライド・キックオフ動画とも）
- そこから拾った決め事 → ルートの `HACKATHON.md` に要約して記載済み
