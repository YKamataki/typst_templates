# typst templates
[Typst](https://typst.app/) templates for Japanese writing. 

## What is this

There are templates for Japanese writing such as reports and memo.
So you can write documents in typst.

## How to install

At first clone this repo.
```sh
git clone https://ghithub.com/YKamataki/typst_templates
```

You can copy `report.typ` to your project directory.

If you use `utpm`, just type
```sh
utpm link
```

## How to use

```typst
// for utpm user
#import "@local/ja_report/1.0.2" : *
#show : project.with(
    subject: "Introduction to typst",
    date: "2024年1月1日", // You can use any style. This is just a string
    title: "Start typesetting",
    // authors field neeeds array. So don't miss "()" and ","
    // You can use two or more lines for one author. 
    authors: ("Your NAME
    Your University or something",)
)

== Introduction
Main contents here
```

All Fields are optional.

