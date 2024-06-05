# IncludePage

A Jekyll tag plugin (`{% include_page ... %}` and `{% include_page_relative ... %}`) that includes a rendered page inside another page.

The included page will be processed according to its filetype and frontmatter, even if it's a page that is otherwise excluded from Jekyll rendering. This means you can include pages that specify a layout, and they will first be rendered through that layout before being included.

## What can you do with this?

A content page might be made of sub-sections, each of which you might want to run through a different layout, perhaps to create content sections with different backgrounds. You could save the section content in a folder relative to the content page, or elsewhere, and exclude that folder if you don't want the sections to be output individually. The content page can now bring these sections together.

## Usage

### {% include_page path/file.ext %}

Jekyll will look for `path/file.ext` relative to your source directory.

### {% include_page_relative path/file.ext %}

Jekyll will look for `path/file.ext` relative to the page where the tag is used.

### Interpolation

Include parameters can be added to the tags, just like the normal `{% include %}` tags, e.g. `title="Hello, world"` and these will be interpolated into the include file where you use the `include` variable, e.g. `{{ include.title }}`.