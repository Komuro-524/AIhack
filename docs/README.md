# docs — 資料と証拠の置き場

## 索引

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
| [rls-nyumon.html](rls-nyumon.html) | **RLS入門** — なぜSupabaseでは必須か。学びの輪の各テーブルのポリシーとSQL |
| [admin-view.html](admin-view.html) | **管理者ビュー** — 人材育成担当の画面。候補タグの拒否権・弾いた語の復活・知識地図の置き場 |
| [chat-update.html](chat-update.html) | チャット対応の設計変更（※一部 spec-v2 で更新） |
| [spec-v2.html](spec-v2.html) | **★最新・確定仕様 v2** — まなびのライブ／予約と日程調整／タグ格上げの承認制／人の門3つ |
| [security-check.html](security-check.html) | **★提出前セキュリティ点検** — 設計バグ4つと直し方・全20項目・提出前チェックリスト |
| [threat-model.html](threat-model.html) | **★危険と防御 総まとめ**（小室さん連携用）— 踏むと終わる10個・エージェント別の壊れ方・全危険43件 |
| [build-plan.md](build-plan.md) | **★実装の進め方と提出前チェック** — 今夜のゴール・撮る証拠・8項目チェック・記事の目次 |
| [repo-docs.html](repo-docs.html) | README / DESIGN / ARCHITECTURE / CLAUDE / AGENTS の違い。今回どれを作るか |
| [agent-jissou.html](agent-jissou.html) | **★コードでエージェントを作るとは** — Copilot Studioとの対比・ループの中身25行・3体の置き場所 |

> 📘 **実装向けの正は `manabi-no-wa/DESIGN.md`。** このフォルダは考える過程の置き場。
> 迷ったら `spec-v2.html`（最新の仕様）→ `threat-model.html`（危険と防御）の順に見る。

## サブフォルダ

| 場所 | 中身 |
|---|---|
| `transcripts/` | Tactiq の議事録（Google Meet の文字起こし）をエクスポートして置く |
| `evidence/` | **提出物の証拠**。Qiita記事に貼る素材をここに集める |

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
