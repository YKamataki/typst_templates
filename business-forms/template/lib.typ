#import "amounts.typ": summarize

#let ink = rgb("#20384a")
#let accent = rgb("#215e63")
#let muted = rgb("#4f626c")
#let rule = rgb("#bdcbd0")
#let tint = rgb("#eaf2f1")

#let grouped(amount) = {
  let s = str(amount)
  if s.len() <= 3 { s } else { grouped(int(s.slice(0, -3))) + "," + s.slice(-3) }
}

#let field(label, value) = grid(
  columns: (5em, 1fr), column-gutter: 1em,
  text(size: 8.5pt, fill: muted, label), value,
)

#let required(value, key) = {
  assert(type(value) == str and value.trim() != "", message: key + " に文字列を入力してください")
  value
}

#let form(data, is-receipt: false) = {
  let title = if is-receipt { "領収書" } else { "請求書" }
  let number = required(data.number, "number")
  let issued = required(data.issue_date, "issue_date")
  let recipient = required(data.recipient, "recipient")
  let issuer = required(data.issuer.name, "issuer.name")
  let registration = data.issuer.at("registration_number", default: none)
  if registration != none {
    assert(type(registration) == str and registration.match(regex("^T[0-9]{13}$")) != none,
      message: "登録番号は半角大文字Tと13桁の数字で入力してください")
  }

  let mode = data.at("price_mode", default: "exclusive")
  let result = summarize(data.items, mode, data.at("rounding", default: "floor"))
  let price-label = if mode == "inclusive" { "税込" } else { "税抜" }
  let common-date = data.at("transaction_date", default: none)
  let dates = result.rows.map(row => required(
    row.at("date", default: common-date), "transaction_date または明細の date",
  ))
  let subject = required(data.subject, "subject")

  set document(title: title + " " + number, author: issuer)
  set page(
    paper: "a4", margin: (x: 20mm, top: 22mm, bottom: 23mm),
    footer: context [
      #line(length: 100%, stroke: 0.5pt + rule)
      #v(1.5mm)
      #set text(size: 8pt, fill: muted)
      #title　#number #h(1fr) #counter(page).display("1 / 1", both: true)
    ],
  )
  set text(font: data.at("font", default: "Noto Sans CJK JP"), lang: "ja", size: 10pt, fill: ink)
  set par(leading: 0.65em)

  grid(
    columns: (1fr, auto), align: (left + horizon, right + horizon),
    text(size: 28pt, weight: "bold", tracking: 0.14em, title),
    align(right)[#text(size: 8.5pt, fill: muted)[#(title + "番号")]　#text(weight: "bold", number) #linebreak() 発行日　#issued],
  )
  v(1.5mm)
  line(length: 100%, stroke: 1.4pt + accent)
  v(5mm)
  grid(
    columns: (1.3fr, 1fr), column-gutter: 9mm,
    [
      #text(size: 8pt, fill: muted)[宛先] #linebreak()
      #text(size: 15pt, weight: "bold", recipient)
    ],
    [
      #text(size: 8pt, fill: muted)[発行者] #linebreak()
      #text(size: 11pt, weight: "bold", issuer)
      #set text(size: 9pt)
      #for key in ("address", "contact") {
        if key in data.issuer { linebreak(); data.issuer.at(key) }
      }
      #if registration != none { linebreak(); [登録番号　#registration] }
    ],
  )
  v(5mm)
  field(if is-receipt { "但し書き" } else { "件名" }, subject)
  v(2mm)
  block(width: 100%, fill: tint, inset: (x: 5mm, y: 4mm))[
    #grid(columns: (1fr, auto), align: (left + horizon, right + horizon),
      text(weight: "bold", fill: accent, if is-receipt { "領収金額（税込）" } else { "ご請求金額（税込）" }),
      [#text(size: 23pt, weight: "bold", grouped(result.total)) #text(size: 11pt)[円]],
    )
  ]
  if is-receipt {
    [上記の金額を領収いたしました。]
    v(1mm)
    field("領収日", required(data.at("received_on", default: issued), "received_on"))
    if "payment_method" in data { field("支払方法", data.payment_method) }
  } else {
    if "due_date" in data { field("お支払期限", data.due_date) }
    if "bank" in data { field("お振込先", data.bank) }
  }

  v(5mm)
  block(sticky: true)[#text(size: 12pt, weight: "bold")[取引明細] #h(1fr) #text(size: 8pt, fill: muted)[金額は#(price-label)、単位は円]]
  {
    set text(size: 9pt)
    table(
      columns: (auto, 1fr, auto, auto, auto, auto),
      align: (left, left, right, right, right, right),
      inset: (x: 2mm, y: 2.1mm),
      stroke: (_, _) => (bottom: 0.4pt + rule),
      fill: (_, y) => if y == 0 { ink } else if calc.even(y) { rgb("#f5f7f8") },
      table.header(..("取引日", "品名・内容", "数量", "単価", "税率", "金額").map(label => text(fill: white, label))),
      ..result.rows.enumerate().map(((i, row)) => (
        dates.at(i), row.description, str(row.quantity), grouped(row.unit_price),
        if row.tax_rate == 8 { "軽減8%" } else { "10%" }, grouped(row.amount),
      )).flatten(),
    )
  }
  v(3mm)
  align(right, block(breakable: false)[
    #set text(size: 9pt)
    #table(
      columns: (auto, auto, auto), align: (left, right, right), inset: (x: 3mm, y: 1.5mm),
      stroke: (_, _) => (bottom: 0.45pt + rule),
      fill: (_, y) => if y == 0 { tint },
      [税率別内訳], [対象額（#(price-label)・円）], [消費税額（円）],
      ..result.groups.map(group => (
        if group.rate == 8 { "軽減8%" } else { "10%" }, grouped(group.base), grouped(group.tax),
      )).flatten(),
    )
  ])
  if "notes" in data {
    v(4mm)
    field("備考", data.notes)
  }
  if is-receipt and data.at("stamp_box", default: false) {
    v(4mm)
    align(right, box(width: 25mm, height: 28mm, stroke: 0.5pt + rule,
      align(center + horizon, text(size: 8pt, fill: muted)[収入印紙])))
  }
}

#let invoice(data) = form(data)
#let receipt(data) = form(data, is-receipt: true)
