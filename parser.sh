#!/bin/sh
awk '
function p() {
	if (stop == 1 && P == 1) {
		P = 0
		stop = 0
		print "</p>"
	} else if(P == 0) {
		P = 1
		print "<p>"
	}
}

function escape(str) {

	gsub(/\[/, "\\[", str) ; gsub(/\]/, "\\]", str)
	gsub(/\(/, "\\(", str) ; gsub(/\)/, "\\)", str)

	gsub(/\?/, "\\?", str)
	gsub(/\./, "\\.", str)
	gsub(/\*/, "\\*", str)
	gsub(/\+/, "\\+", str)
	gsub(/\|/, "\\|", str)

	return str
}

BEGIN { P = 0 ; print "" }

{ stop = 0 }

/^###.*/ { stop = 1 ; sub(/^###[[:space:]]+/, "") ; sub($0, "<h3>"$0"</h3>") }
/^##.*/ { stop = 1 ; sub(/^##[[:space:]]+/, "") ; sub($0, "<h2>"$0"</h2>") }
/^#.*/ { stop = 1 ; sub(/^#[[:space:]]+/, "") ; sub($0, "<h1>"$0"</h1>") }

{
	if (match($0, /___[^_]+___/)) {
		content=substr($0, (RSTART + 3), (RLENGTH - 6))
		sub("___"content"___", "<span style=\"font-style: italic;\">"content"</span>")
	}
	if (match($0, /__[^_]+__/)) {
		content=substr($0, (RSTART + 2), (RLENGTH - 4))
		sub("__"content"__", "<b>"content"</b>")
	}

	if (match($0, /!\[[^\]]+\]\([^\)]+)/)) {
		stop = 1
		matched=substr($0, RSTART, RLENGTH)
		R1=RSTART
		R2=RLENGTH

		match(matched, /!\[[^\]]+\]/)
		legend=substr(matched, RSTART + 2, RLENGTH - 3)

		match(matched, /\([^\)]+\)/)
		link=substr(matched, RSTART + 1, RLENGTH - 2)
		
		$0 = "<center><img src=\""link"\" alt=\""legend"\" /><figure>"legend"</figure></center>"
	}
	if (match($0, /\[[^\]]+\]\([^\)]+)/)) {
		matched=substr($0, RSTART, RLENGTH)
		R1=RSTART
		R2=RLENGTH

		match(matched, /\[[^\]]+\]/)
		printed=substr(matched, RSTART + 1, RLENGTH - 2)

		match(matched, /\([^\)]+\)/)
		link=substr(matched, RSTART + 1, RLENGTH - 2)

		sub(escape(matched), "<a href=\""link"\">"printed"</a>", $0)
	}

	if ($0 == "") {
		if (was == "") stop = 1
		p()
		print "<br />"
	} else {
		p()
	}
	was=$0
}

{ if ($0 != "") print }

END {
	if (P == 1) {
		print "</p>"
	}
}
'

