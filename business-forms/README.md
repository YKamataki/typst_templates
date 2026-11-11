# 日本国内向け 請求書・領収書

同梱のJSONを編集すると、取引明細と税率別内訳を含むA4の帳票を出力できます。帳票番号とページ番号は各ページの下部に、明細の列見出しは表が続く各ページの上部に表示します。

## 1. JSONを編集して発行する

前提はTypst CLI 0.15.1以降と日本語フォントです。既定のフォントは Noto Sans CJK JP です。別のフォントを使う場合はJSONの `font` にインストール済みのファミリー名を指定します。

リポジトリのルートから次を実行すると、サンプルのJSONを複製し、その内容から2種類のPDFを作成します。発行時は複製したJSONを編集し、出力名を帳票番号に合わせて変更してください。コンパイル先に同名のPDFがあれば上書きします。

```bash
cd business-forms/template
cp data/invoice.json data/my-invoice.json
cp data/receipt.json data/my-receipt.json
typst compile invoice.typ --input data=data/my-invoice.json invoice.pdf
typst compile receipt.typ --input data=data/my-receipt.json receipt.pdf
```

`--input data=...` のパスは各入口の `.typ` ファイルを基準に指定します。省略すると [請求書の入力例](template/data/invoice.json) または [領収書の入力例](template/data/receipt.json) を読みます。サンプルの名称、登録番号、口座情報はすべて架空です。

## 2. 入力項目

### 2.1 共通項目

- **番号・日付** — `number` は請求書番号または領収書番号、`issue_date` は発行日です。いずれも必須の文字列です。日付は入力どおりに印字されます。
- **宛先・発行者** — `recipient` に敬称を含む宛名、`issuer.name` に発行者名を入力します。いずれも必須です。`issuer.address` と `issuer.contact` は任意です。
- **登録番号** — 登録事業者は `issuer.registration_number` に実際の登録番号（半角大文字T＋数字13桁）を入力します。省略または `null` で登録番号欄を省きます。テンプレートは書式を検査します。公表情報との照合は行いません。
- **件名・但し書き** — `subject` は必須です。請求書では件名、領収書では但し書きとして表示します。
- **取引日** — `transaction_date` に明細共通の取引日を入力します。別日の明細には `items[].date` を指定すると、その行だけ上書きします。全行に日付がある場合は共通日を省略できます。発行日・領収日は取引日に転記されません。
- **明細** — `items` に1件以上を指定します。各行に `description`（品名・内容）、`quantity`（正の整数）、`unit_price`（0以上の整数円）、`tax_rate`（標準は `10`、軽減は `8`）を入力します。軽減対象の行には「軽減8%」を表示します。
- **備考・書体** — `notes` と `font` は任意です。

### 2.2 帳票ごとの項目

- **請求書** — `due_date` に支払期限、`bank` に振込先を入力できます。
- **領収書** — `received_on` に実際の領収日を入力します。省略時は発行日を用います。`payment_method` に支払方法を指定できます。紙の領収書で印紙貼付欄を設ける場合は `stamp_box` を `true` にします。既定は `false` です。

## 3. 消費税の計算

`price_mode` は帳票単位で指定します。対象は標準10%と軽減8%の国内取引です。

- **税抜入力** — `"exclusive"`（既定値）。数量×税抜単価を税率別に合算し、税率を掛けた額を丸めて加算します。請求書の例では10%対象44,660円に税4,466円、8%対象3,960円に税316円で、請求額は **53,402円** です。
- **税込入力** — `"inclusive"`。数量×税込単価の合計が領収額または請求額です。税率別の税込額から、10%は10/110、8%は8/108で内税を求めます。領収書の例は **2,812円**、そのうち消費税は10%分20円と8%分192円です。
- **端数処理** — `rounding` は `"floor"`（切捨て、既定値）、`"round"`（四捨五入）、`"ceil"`（切上げ）から選びます。1帳票・1税率につき1回、整数演算で処理します。

適格請求書として発行する場合は、実際の発行者名・登録番号、宛先、取引年月日、取引内容を入力し、軽減税率の対象を正しく指定してください。記載事項と端数処理の出典は [国税庁「適格請求書等保存方式について」](https://www.nta.go.jp/publication/pamph/shohi/shohizei_11.pdf) および [国税庁「No.6371 端数計算」](https://www.nta.go.jp/taxes/shiraberu/taxanswer/shohi/6371.htm) です。

## 4. Typstテンプレートとして使う

### 4.1 ローカルパッケージから新規作成

Linuxでリポジトリのルートから実行します。初回のみローカルパッケージ置き場にシンボリックリンクを作成します。`typst init` は新しい作業用ディレクトリに帳票ソースとJSONを複製します。

```bash
pkg_dir="${XDG_DATA_HOME:-$HOME/.local/share}/typst/packages/local/jp-business-forms"
mkdir -p "$pkg_dir"
ln -s "$PWD/business-forms" "$pkg_dir/0.1.0"
typst init @local/jp-business-forms:0.1.0 my-forms
cd my-forms
typst compile invoice.typ
typst compile receipt.typ
```

### 4.2 自分のTypstファイルから呼び出す

前節のローカルパッケージを配置すると、下記の `main.typ` と同じディレクトリに用意した `invoice.json` から出力できます。`receipt` も同じ呼び出し方です。パッケージを配置せず使う場合は `template/` のソース一式をコピーし、同じディレクトリから `#import "lib.typ": invoice, receipt` と読み込みます。

```typst
#import "@local/jp-business-forms:0.1.0": invoice
#invoice(json("invoice.json"))
```

## 5. 検証の再実行

リポジトリのルートで実行します。既定のJSONから各見本PDFを生成し、税率別の合算、端数処理、税込・税抜の計算をアサーションで検証します。コマンドはカレントディレクトリにPDFを書き出します。

```bash
typst compile business-forms/template/invoice.typ invoice.pdf
typst compile business-forms/template/receipt.typ receipt.pdf
typst compile --root business-forms business-forms/tests/amounts.typ amounts-test.pdf
```
