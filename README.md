<p align="center">
    <img src="https://camo.githubusercontent.com/d648ea140f019e3d340887f7f51d019f94d1f4af/68747470733a2f2f696e766967696c61746f722e696f2f77702d636f6e74656e742f75706c6f6164732f323031362f31322f696e766967696c61746f722e706e67" width="320" alt="Web Template">
    <br>
    <br>
    <a href="LICENSE">
        <img src="http://img.shields.io/badge/license-MIT-brightgreen.svg" alt="MIT License">
    </a>
    <a href="https://swift.org">
        <img src="http://img.shields.io/badge/swift-3.1-brightgreen.svg" alt="Swift 3.1">
    </a>
</p>

Invigilator is a Swift CMS platform build using the Vapor Framework. It uses the Fluent driver, so it can support multiple database drivers. It also uses LeafMarkdown allowing you to write in Markdown.

## Features

This is some of the features in Invigilator:

- Create pages using Markdown
- Save pages as Draft until you are ready to go public with them
- User system, allowing to create multiple users
- Slug URLs for SEO
- Manual write SEO meta tags (title, keywords and description)
- Blogging system, write your blog posts with markdown
- Easy to style with your own theme
- Setup menus including submenu, and drag'n'drop for order

For more, see our [Demo](https://demo.invigilator.io) or our [Website](https://invigilator.io)

## Installation

Just do the following
```
git clone git@github.com:invigilator/invigilator.git
vapor build
vapor run serve
```

You can then visit the page at http://127.0.0.1:8080. You can login to the admin panel on: http://127.0.0.1:8080/admin. First time you visit this page, it will show you the admin credentials in a small flash.

## Deploy to Vapor Cloud

Coming soon...

## Roadmap

- Easy plugin integration
- Improved documentation
- Test and CI
