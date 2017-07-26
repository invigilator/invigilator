<p align="center">
    <img src="https://user-images.githubusercontent.com/2535140/28637833-211a6d0e-7243-11e7-9337-33660da9ad34.png" width="520" alt="Web Template">
    <br>
    <br>
    <a href="LICENSE">
        <img src="http://img.shields.io/badge/license-MIT-brightgreen.svg" alt="MIT License">
    </a>
    <a href="https://swift.org">
        <img src="http://img.shields.io/badge/swift-3.1-brightgreen.svg" alt="Swift 3.1">
    </a>
</p>

**Warning: Project is still in Alpha**

Invigilator is a Swift CMS platform build using the Vapor Framework. It uses the Fluent driver, so it can support multiple database drivers. It also uses LeafMarkdown allowing you to write in Markdown.

## Features

This is some of the features in Invigilator:

- Create pages using Markdown
- Save pages as Draft until you are ready to go public with them
- User system, allowing to create multiple users
- Slug URLs for SEO
- Manual write SEO meta tags (title, keywords and description)
- Blogging system, write your blog posts with markdown *(Coming soon)*
- Easy to style with your own theme
- Setup menus including submenu, and drag'n'drop for order *(Coming soon)*

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
- Custom page tags
- Improved documentation
- Test and CI
