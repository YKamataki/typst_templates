// All prices are whole yen. Keep tax arithmetic integral, including rounding.
#let tax-amount(base, rate, inclusive, rounding) = {
  let divisor = if inclusive { 100 + rate } else { 100 }
  let numerator = base * rate
  let whole = calc.quo(numerator, divisor)
  let remainder = calc.rem(numerator, divisor)
  let up = (rounding == "ceil" and remainder > 0) or (
    rounding == "round" and 2 * remainder >= divisor
  )
  whole + if up { 1 } else { 0 }
}

#let summarize(items, mode, rounding) = {
  assert(("exclusive", "inclusive").contains(mode), message: "price_mode は exclusive または inclusive を指定してください")
  assert(("floor", "round", "ceil").contains(rounding), message: "rounding は floor、round、ceil のいずれかです")
  assert(type(items) == array and items.len() > 0, message: "items には1件以上の明細が必要です")

  let bases = (:)
  let rows = ()
  for item in items {
    let rate = item.tax_rate
    let qty = item.quantity
    let price = item.unit_price
    assert(type(rate) == int and (8, 10).contains(rate), message: "tax_rate は 8 または 10 の整数です")
    assert(type(qty) == int and qty > 0, message: "quantity は正の整数です")
    assert(type(price) == int and price >= 0, message: "unit_price は0以上の整数（円）です")
    assert(type(item.description) == str and item.description.trim() != "", message: "品名 description を入力してください")

    let amount = qty * price
    let key = str(rate)
    bases.insert(key, bases.at(key, default: 0) + amount)
    rows.push((..item, amount: amount))
  }

  let groups = ()
  let total = 0
  let inclusive = mode == "inclusive"
  for rate in (10, 8) {
    let key = str(rate)
    if key in bases {
      let base = bases.at(key)
      let tax = tax-amount(base, rate, inclusive, rounding)
      let gross = if inclusive { base } else { base + tax }
      groups.push((rate: rate, base: base, tax: tax))
      total += gross
    }
  }
  (rows: rows, groups: groups, total: total)
}
