# Static Site Generator

Minimalist static site generator.

Heavily inspired by the [best motherfucking website](https://bestmotherfucking.website/)

## Features

Markdown :
- Titles / Subtitles / Subsubtitles
- Bold / italic / links
- Images
- Leave one line to change paragraph. Leave two to get extra indentation.

Under 150 lines of sh/awk code => easy to maintain.
POSIX-compliant => can run virtually anywhere.

## Usage

```

# Place your articles in src/
# One article per file : XX-<filename>.md
# XX is a number used to sort articles on the main page.
vim src/00-test.md

git init src # Versioning

vim src/header.html # You might want to change the style
vim src/footer.html

./build.sh

cp build/* /var/www

```

Add ``--no-rss`` to disable RSS file generation

Warning: the current stable release of debian-based operating systems ships with a [bugged implementation of awk](https://bugs.launchpad.net/ubuntu/+source/mawk/+bug/1332114). Please install gawk otherwise you will get errors.

