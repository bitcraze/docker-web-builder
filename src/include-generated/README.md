# Jekyll include-generated Plugin

This plugin adds a liquid tag for including files. It behaves like the
{% include-relative %} tag with the difference that it does not
raise an exception if the include file is not found.
The intended use case is to include generated files and to
display a short instruction of how to generate the file if
it can not be found.

## Example

Suppose we have some functionality that generates API documentation
based on source files, the generated documentation is a markdown
file, let's call it `my_api.md`.
We want to include this into an existing markdown file and
this can be done with the following liquid tag

        {% include-relative-generated my_api.md info="Generate the API documentaiton by running `tb generate-api-docs`" %}

The info string should contain a short information about how to
generate the include file and will be displayed if the file is
not found.

See the documentation for {% include-relative %} for more details.
