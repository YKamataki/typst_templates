# typst templates
[Typst](https://typst.app/) templates for Japanese writing. 

## What is this

There are templates for Japanese writing such as reports and memo.
So you can write documents in typst.

## How to install

At first clone this repo.
```sh
git clone https://github.com/YKamataki/typst_templates
```

You can copy `report.typ` to your project directory.

If you use `utpm`, just type
```sh
utpm link
```

## How to use

```typst
// for utpm user
#import "@local/ja-report:1.1.3" : *
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

## 日本国内向けの請求書・領収書

[`business-forms/`](business-forms/README.md) に、JSONで入力できる独立したTypstテンプレートがあります。
使用例、税率別集計、`typst init` での導入方法はリンク先を参照してください。
