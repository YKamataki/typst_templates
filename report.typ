// The project function defines how your document looks.
// It takes your content and some metadata and formats it.
// Go ahead and customize it to your liking!
#let project(title: "", authors: (), date: none, subject: "", body) = {
  // Set the document's basic properties.
  set document(author: authors, title: title)

  // Save heading and body font families in variables.
  let body-font = "BIZ UDPMincho"
  let sans-font = "BIZ UDPGothic"

  // Set body font family.
  set text(font: body-font, lang: "ja")
  show heading: set text(font: sans-font)

  // Set run-in subheadings, starting at level 3.
  show heading: it => {
    if it.level > 3 {
      parbreak()
      text(11pt, style: "italic", weight: "regular", it.body + ".")
    } else {
      it
    }
  }

  // Date Row
  align(right)[
    #date
  ]

  // Subject row
  align(left)[
    #subject
  ]
  
  // Title row.
  align(center)[
    #block(underline(text(font: sans-font, weight: 700, 1.75em, title)))
    #v(1em, weak: true)
  ]

  // Author information.
  pad(
    top: 0.5em,
    bottom: 0.5em,
    x: 2em,
    grid(
      columns: (1fr,) * calc.min(3, authors.len()),
      gutter: 1em,
      ..authors.map(author => align(right, author)),
    ),
  )

  // Main body.
  set par(justify: true)

  body
}
