// 卒業研究 中間発表ポスター（JIS B1）
// ビルド: typst compile --font-path <フォントのディレクトリ> poster.typ
#set page(
  paper: "jis-b1",
  margin: (top: 2cm, bottom: 2cm, left: 3cm, right: 3cm),
)

#set text(font: "Noto Sans CJK JP", size: 26pt, lang: "ja")
#set par(leading: 0.75em, justify: true)

// 配色
#let main = rgb("#b5452c")        // 朱
#let light = rgb("#f6ddd2")       // 淡い朱
#let sub = rgb("#2f5d62")         // 青緑
#let sublight = rgb("#dcebea")
#let gray = rgb("#666666")

#show link: it => text(sub)[#it]
#show figure.where(kind: table): set figure.caption(position: top)
#show figure.caption: set text(size: 24pt)
#show strong: set text(weight: "bold", fill: main)

// ───────────── タイトル ─────────────
#align(center)[
  #box(fill: light, inset: (top: 1.8cm, bottom: 1.8cm), width: 100%)[
    = #text(56pt)[郷土芸能デジタルアーカイブ]
    #v(0.4cm)
    #text(36pt, weight: "bold")[
      断絶しても復活できる形で郷土芸能を保存するWebプラットフォームの構築
    ]
    #v(0.9cm)
    #text(weight: "bold")[〇〇研究室　f22123　5J〇〇　〇〇 〇〇]
  ]
]

#v(15pt, weak: true)

// ───────────── 部品 ─────────────
#let section_box(title, width, height, content) = {
  v(45pt, weak: true)
  block(
    width: width, height: height, stroke: light + 4pt,
    inset: (top: 62pt, left: 26pt, right: 26pt, bottom: 26pt),
  )[
    #place(top + left, dx: -6pt, dy: -100pt)[
      #rect(stroke: light + 4pt, fill: white, inset: 15pt)[
        #text(weight: "bold", size: 30pt)[#title]
      ]
    ]
    #content
  ]
}

// 状態ラベル
#let tag(label, color) = box(
  fill: color, inset: (x: 10pt, y: 4pt), radius: 6pt, baseline: 4pt,
)[#text(20pt, fill: white, weight: "bold")[#label]]
#let done = tag("実装済み", sub)
#let wip = tag("実装中", rgb("#c98a1b"))
#let plan = tag("予定", gray)

// 図の箱
#let node(body, fill: white, stroke: main, w: 100%) = rect(
  width: w, inset: 12pt, radius: 10pt, fill: fill, stroke: stroke + 3pt,
)[#align(center + horizon)[#text(24pt)[#body]]]
#let arrow = align(center + horizon)[#text(40pt, fill: main)[➜]]
#let darrow = align(center)[#text(40pt, fill: main)[⬇]]

// ───────────── 各セクション ─────────────
#let bg_section = section_box("背景・目的", 100%, auto)[
  #grid(
    columns: (1fr, 1fr),
    gutter: 40pt,
    [
      　全国の郷土芸能（神楽，鹿踊，剣舞など）は，少子高齢化・過疎化による担い手不足や，災害・感染症による公演中止で，伝承が途絶える例が増えている．
      郷土芸能は口伝えと実演で受け継がれるため，担い手がいなくなると*映像が残っていても再現は難しい*．
      既存の記録は「見る」ための映像や文章が中心で，囃子の各楽器の演奏内容や，伝承・所作の意味までは残りにくい．
    ],
    [
      　本研究では，*断絶しても後から復活できる形で*郷土芸能を保存することを目的とし，次の3つの機能をもつWebプラットフォームを構築する．
      + *伝承情報の取得*：フォーム入力とLLMによる聞き取り
      + *音源分離・採譜*：録音を楽器ごとに分け，楽譜に起こす
      + *マルチアングル動画*：複数視点の動画を統合し，視点を切り替えて見られるようにする
      アーカイブだけを手がかりに演目を再現できるかまで検証する．
    ],
  )
]

#let system_section = section_box("システム構成", 100%, auto)[
  　提供された情報・録音・動画をサーバー上のワーカーが自動処理し，*保存会が確認・修正した版だけを公開する*．

  #v(10pt)
  #grid(
    columns: (1fr, 50pt, 1.15fr, 50pt, 1fr),
    row-gutter: 18pt,
    align: horizon,
    node(fill: sublight, stroke: sub)[伝承の内容\ （語り・文書）], arrow,
    node[*聞き取り*\ フォーム / LLM], arrow,
    node(fill: sublight, stroke: sub)[伝承記録\ （構造化テキスト）],

    node(fill: sublight, stroke: sub)[演奏の録音], arrow,
    node[*音源分離・採譜*\ audio-worker (GPU)], arrow,
    node(fill: sublight, stroke: sub)[6パート音源\ 囃子譜・MIDI],

    node(fill: sublight, stroke: sub)[複数視点の動画\ （スマートフォン）], arrow,
    node[*同期・変換*\ multiview-worker (GPU)], arrow,
    node(fill: sublight, stroke: sub)[視点切り替え\ 動画],
  )
  #v(4pt)
  #grid(columns: (1fr), darrow)
  #v(4pt)
  #node(fill: light)[
    保存会による確認・修正（版管理） ➜ 管理者承認 ➜ 公開ページ
  ]
  #v(8pt)
  #text(22pt)[*使用技術*：Astro，FastAPI，S3互換ストレージ，Docker Compose，PyTorch，FFmpeg（Vulkan・NVENC）]
]

#let info_section = section_box([機能1：伝承情報の取得　#plan], 100%, auto)[
  　演目の由来，所作や歌詞の意味，衣装・道具，上演の時期・場所，伝承系譜などを記録する．
  伝承者が話すだけで記録できるよう，*LLMが聞き手となって対話的に聞き取る*．

  - *フォーム入力*：名称・地域・保存団体などを直接入力 #done
  - *LLMによる聞き取り*：未記入の項目をLLMが質問し，回答を項目ごとに整理して下書きにする．推測は記録に入れず，発言の出典を残す
]

#let audio_section = section_box([機能2：音源分離・採譜　#wip], 100%, 1fr)[
  　多くの演目の囃子は*唄・掛け声・笛・太鼓・手平鉦・その他*の6パートからなる．録音から各パートを取り出し，ソロ再生と打点・旋律の書き起こしを行う．

  #figure(
    gap: 16pt,
    table(
      columns: (auto, 1fr, 1fr),
      align: horizon + center,
      inset: 10pt,
      fill: (_, y) => if y == 0 { light },
      table.header([パート], [分離], [書き起こし]),
      [唄], [声の分離\ (BS-RoFormer系 @lu2023bsroformer @wang2023melroformer)], [旋律 (MIDI) @bittner2022basicpitch],
      [掛け声], [声を唄と短い発声に分割], [発声の時刻],
      [笛], [木管モデルで分離], [旋律 ➜ 篠笛の数字譜],
      [太鼓], table.cell(rowspan: 2)[打楽器を分離し，\ 太鼓と金属音に分割], [打点・打ち方（面・縁）],
      [手平鉦], [打点],
      [その他], [残り（観客・風・足音）], [—],
    ),
    caption: [6パートの分離と書き起こしの方針],
  )

  - 「残り」から次のパートを取り出す*カスケード方式*．全パートの和が原音に一致する（誤差 −60 dB 以下）ことを検査
  - 拍・小節は beat_this @foscarin2024beatthis で求める．結果は*保存会が修正できる下書き*とする

  *現状*：二子鬼剣舞の録音で6パート分離・打点抽出・Web上での再生を確認した．
  定量評価（SI-SDR，打点のF値）は保存会に依頼中の*楽器ごとの単独録音*で行う．
  楽譜の表記（口唱歌・篠笛の数字譜）は団体ごとに異なるため，保存会から実例を集めて表示を合わせる．
]

#let multiview_section = section_box([機能3：マルチアングル動画　#done], 100%, auto)[
  　複数のスマートフォンで撮った各視点の動画をアップロードすると，*音声をもとに自動で時刻を合わせ*，再生中に視点を切り替えられる動画にする．
  特別な機材は不要で，正面からでは分からない足の運びなども残せる．

  #align(center)[
    #figure(
      caption: [視点切り替えプレイヤー（下段の小窓で視点を選ぶ）],
    )[
      #image("assets/multiview_player.png", width: 62%)
    ]
  ]

  *同期の方法*
  - 帯域ごとの対数エネルギー（10 ms刻み）の相互相関でずれを求め，区間ごとに測り直して*ずれと時計の進み*を推定
  - 全ペアを重み付き最小二乗でまとめ，撮影開始時刻との整合で別の回の動画を分ける

  #figure(
    gap: 16pt,
    table(
      columns: (1fr, auto),
      align: horizon + center,
      inset: 10pt,
      fill: (_, y) => if y == 0 { light },
      table.header([項目], [結果]),
      [演目の振り分け（24本）], [3演目×8本に正しく分類],
      [全体の解との最大残差], [2.5〜15.7 ms（1コマ 33 ms）],
      [同期の処理時間（24本）], [約5秒],
      [変換（8視点・約52分の素材，GPU）], [209秒],
      [視点切り替え後の映像と音声のずれ], [14 ms 以内],
    ),
    caption: [試験撮影（iPhone 8台×3演目）での結果],
  )
]

#let plan_section = section_box("今後の予定：復活できるかの検証", 100%, auto)[
  　聞き取り・楽譜表示を実装後，実際の演目を登録して検証する．

  #grid(
    columns: (1fr, 1fr),
    gutter: 24pt,
    node(fill: sublight, stroke: sub)[
      *検証1：記録の十分さ*\
      #align(left)[再現に必要な情報が足りているかを保存会に確認してもらい，不足項目を洗い出す]
    ],
    node(fill: sublight, stroke: sub)[
      *検証2：アーカイブからの復元*\
      #align(left)[演目を知らない人が*アーカイブだけ*で演目の一部を習得し，保存会が再現度を評価する]
    ],
  )
  #v(12pt)
  　断絶を想定して記録から復活できるかを確かめ，記録すべき情報と各機能の有効性を明らかにする．
]

#let ref_section = section_box("参考文献", 100%, 1fr)[
  #set text(22pt)
  #bibliography("ref.bib", title: none, style: "ieee")
]

// ───────────── 配置 ─────────────
#bg_section

#block(height: 1fr, grid(
  columns: (50% - 28pt, 50%),
  rows: (100%,),
  gutter: 28pt,
  [
    #block(height: 100%)[
      #system_section
      #info_section
      #audio_section
    ]
  ],
  [
    #block(height: 100%)[
      #multiview_section
      #plan_section
      #ref_section
    ]
  ],
))
