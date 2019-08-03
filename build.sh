#!/bin/sh


get_name() {
	echo "$1" | awk ' { sub(/^src\/[0-9]+-?/, "") ; sub(/.md$/, "") ; print } '
}

mkdir -p build
find src/ -name "*.md" -type f | while read -r file ; do

	name="$(get_name "$file")"

	[ ! -f src/header.html ] || cat src/header.html > "build/$name.html"
	./parser.sh < "$file"  >> "build/$name.html"
	[ ! -f src/footer.html ] || cat src/footer.html >> "build/$name.html"

done

find src/ -name "*.md" -type f | sort -r | while read -r file ; do

	name="$(get_name "$file")"

	[ ! -f src/header.html ] || cat src/header.html > "build/index.html"
	# shellcheck disable=SC2002
	(cat "$file" | head --lines 5) | ./parser.sh >> "build/index.html"

	echo "<hr><i>Read more by clicking</i> <b><a href=\"$name.html\">this link</a></b>.<hr>" >> "build/index.html"

	[ ! -f src/footer.html ] || cat src/footer.html >> "build/index.html"

done
