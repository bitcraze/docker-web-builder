---
title: Home
page_id: home
---

This is test documentation to verify that a web builder is working when installing new versions of various components.

To verify a new docker image:
1. Build your new image and name it ```my-web-builder```
1. Run ```tb -d docks``` to make the toolbelt show how it uses docker. Terminate the toolbelt.
1. Run the same docker command as the toolbeld did but use the ```my-web-builder``` image
1. Check that you can access the repo docs on your local server and make sure it looks OK

## Links

[External link: https://www.bitcraze.io](https://www.bitcraze.io)

[Link to .md file: /docs/sub_section/page_1.md](/docs/sub-section/page_1.md)

[Relative link to .md file: ./sub_section/page_1.md](./sub-section/page_1.md)

## Ditaa

This should be rendered as nice graphics

{% ditaa --alt "Example diagram" %}
/-------\        +---------+
|       |   +--->| cGRE    |
|   A   |   |    | diagram |
|       |---+    |         |
\-------/        +---------+
{% endditaa %}

## LaTex

This should be rendered as a nice formula

$$\lim_{h\to 0}\frac{f(x+h)-f(x)}{h}$$
