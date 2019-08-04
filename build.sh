#!/bin/sh


get_name() {
	echo "$1" | awk ' { sub(/^src\/[0-9]+-?/, "") ; sub(/.md$/, "") ; print } '
}

rm -f build/*.xml build/*.html
mkdir -p build
find src/ -name "*.md" -type f | while read -r file ; do

name="$(get_name "$file")"

	[ ! -f src/header.html ] || cat src/header.html > "build/$name.html"
	./parser.sh < "$file"  >> "build/$name.html"
	[ ! -f src/footer.html ] || cat src/footer.html >> "build/$name.html"

done


[ "$1" != "--no-rss" ] && [ "$2" != "--no-rss"  ] && [ -f src/rss-header.xml ] && cat src/rss-header.xml > "build/rss.xml"

find src/ -name "*.md" -type f | sort -r | while read -r file ; do

name="$(get_name "$file")"

[ ! -f src/header.html ] || cat src/header.html > "build/index.html"

# shellcheck disable=SC2002
BEGINNING="$( (cat "$file" | head --lines 5) | ./parser.sh)"
echo "$BEGINNING" >> "build/index.html"

TITLE="$(awk '/^#[[:space:]]{0,}/ { sub(/^#[[:space:]]{0,}/, "") ; print }' "$file" | head -n 1)"

if [ "$1" != "--no-rss" ] && [ "$2" != "--no-rss"  ] ; then
	echo "<item><title>$TITLE</title><link>http://myblog.com/$name.html</link><description>$BEGINNING</description></item>" >> "build/rss.xml"
fi

echo "<hr><i>Read more by clicking</i> <b><a href=\"$name.html\">this link</a></b>.<hr>" >> "build/index.html"

[ ! -f src/footer.html ] || cat src/footer.html >> "build/index.html"

done

[ "$1" != "--no-rss" ] && [ "$2" != "--no-rss"  ] && [ -f src/rss-footer.xml ] && cat src/rss-footer.xml >> "build/rss.xml"
