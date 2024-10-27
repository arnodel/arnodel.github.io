---
layout: post
title:  "Setting up KaTeX in Jekyll"
date:   2020-05-25 21:15:14 +0100
categories: katex jekyll
latex_defs:
  Steps: foo
---


[$$\KaTeX$$](https://katex.org) is great, so that's what I
thought of first of using for displaying mathematical expressions when setting
up these pages. However I don't know anything about Jekyll at all, so it could
have been a challenge...

I'm setting up [jekyll-katex](https://github.com/linjer/jekyll-katex) and this
post is both to test that it works on github-pages and to share how I set it up.
It seems very nice and easy enough to set up!  The only trouble I had was
finding how to add the KaTeX css to the header.  In the end I used [these
instructions](https://jekyllrb.com/docs/themes/#overriding-theme-defaults) to
copy the `_includes/head.html` default file for the `minima` theme into my
`_includes` directory (which I created for the occasion!), then added this line
to the `<head>` section of the file:
```html
  <link rel="stylesheet" href="https://cdn.jsdelivr.net/npm/katex@0.11.1/dist/katex.min.css" integrity="sha384-zB1R0rpPzHqg7Kpt0Aljp8JPLqbXI3bhnPWROx27a9N0Ll6ZP/+DiW/UqRcLbRjq" crossorigin="anonymous">
```
This is my resulting [`src/_includes/head.html`](https://github.com/arnodel/arnodel.github.io/tree/master/src/_includes/head.html).

Many thanks to the author of this plugin!

The problem is that the plugin is not supported by github-pages.  So I guess for
now I will have to build my site locally.  That means moving the whole source
code for the Jekyll site to `src/`, building locally into `marooned/`, adding a
`.nojekyll` file to the root so that Github doesn't try to build it itself.
Thanks Github!  This is the price to pay for being able to render maths
server-side it seems.

There seems to be a way to use a Travis Job circumvent this issue
[here](https://stackoverflow.com/a/51454606/2380495). Perhaps I will set that up
later, as this means I need to remember to build the site before each commit!.

The examples below are copy-pasted from the jekyll-katex readme.

Some inline maths: $$c = \pm\sqrt{a^2 + b^2}$$

Some display maths:

$$c = \pm\sqrt{a^2 + b^2}$$


This is a mixed environment where you can have normal text and $$c = \pm\sqrt{a^2 + b^2}$$ fenced math. $!
