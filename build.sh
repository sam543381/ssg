#!/bin/sh

# CONFIG
BLOG_TITLE="My Blog" # TODO: customize
BLOG_DESC="A minimalistic blog" # TODO: customize
BLOG_URL="https://sam543381.github.io/ssg/" # TODO: customize

get_name() {
	echo "$1" | awk ' { sub(/^src\/[0-9]+-?/, "") ; sub(/.md$/, "") ; print } '
}

append() {
	[ -f "$1" ] || return 
	awk -v bt="$BLOG_TITLE" -v bd="$BLOG_DESC" -v bu="$BLOG_URL" '{ sub(/BLOG_TITLE/, bt) ; sub(/BLOG_DESC/, bd) ; sub(/BLOG_URL/, bu) ; print }' "$1" >> "$2"
}

rm -Rf build
mkdir -p build

[ -f "src/rss-header.xml" ] && append "src/rss-header.xml" "build/feed.rss"
append "src/header.html" "build/index.html"

# shellcheck disable=SC2030
find src/ -name "*.md" -type f | while read -r file ; do

	name="$(get_name "$file")"

	# Article page
	append "src/header.html" "build/$name.html"
	./parser.sh < "$file"  >> "build/$name.html"
	append "src/footer.html" "build/$name.html"

	# Index page
	BEGINNING="$( head -qc 1000 "$file" | ./parser.sh)"
	echo "$BEGINNING" >> "build/index.html"
	echo "<hr><i>Read more by clicking</i> <b><a href=\"$name.html\">this link</a></b>.<hr>" >> "build/index.html"

	# RSS feed
	if [ "$1" != "--no-rss" ] && [ "$2" != "--no-rss"  ] ; then
		{
		printf "<item>\n"
		printf "\t<title>%s</title>\n" "$(awk '/^#[[:space:]]{0,}/ { sub(/^#[[:space:]]{0,}/, "") ; print}' "$file" | head -n 1)"
			printf "\t<link>%s</link>\n" "$BLOG_URL/$name.html"
			printf "\t<content:encoded><![CDATA[%s]]></content:encoded>\n" "$BEGINNING"
		printf "</item>\n"
		} >> "build/feed.rss"	
	fi
done

append "src/footer.html" "build/index.html"
[ -f "src/rss-footer.xml" ] && append "src/rss-footer.xml" "build/feed.rss"
