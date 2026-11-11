#import "../template/amounts.typ": summarize

#let row(price, rate, qty: 1) = (description: "テスト", unit_price: price, tax_rate: rate, quantity: qty)

// The two 5-yen lines must produce one yen of tax after grouping by rate.
#let mixed = summarize((row(5, 10), row(5, 10), row(9, 8, qty: 2)), "exclusive", "floor")
#assert.eq(mixed.groups, ((rate: 10, base: 10, tax: 1), (rate: 8, base: 18, tax: 1)))
#assert.eq(mixed.total, 30)
#assert.eq(mixed.rows.last().amount, 18)

// Check half-up ties, zero-priced items, and exact multiples in both modes.
#for (mode, price, rate, floor-tax, round-tax, ceil-tax) in (
  ("exclusive", 5, 10, 0, 1, 1),
  ("exclusive", 14, 10, 1, 1, 2),
  ("inclusive", 108, 8, 8, 8, 8),
  ("inclusive", 110, 10, 10, 10, 10),
  ("inclusive", 109, 8, 8, 8, 9),
  ("inclusive", 6, 10, 0, 1, 1),
  ("exclusive", 0, 8, 0, 0, 0),
) {
  for (rounding, tax) in (("floor", floor-tax), ("round", round-tax), ("ceil", ceil-tax)) {
    let result = summarize((row(price, rate),), mode, rounding)
    assert.eq(result.groups, ((rate: rate, base: price, tax: tax),))
    assert.eq(result.total, if mode == "inclusive" { price } else { price + tax })
  }
}

#for (data, expected) in (
  (json("../template/data/invoice.json"), 53402),
  (json("../template/data/receipt.json"), 2812),
) {
  let result = summarize(data.items, data.price_mode, data.at("rounding", default: "floor"))
  assert.eq(result.total, expected)
}
