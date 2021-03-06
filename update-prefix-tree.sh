#!/bin/bash

GX86=/usr/portage

SCRIPTSDIR=$(dirname $(realpath $0))

TIME=$(date +%s)
DATE=$(date +%Y%m%d)

if [[ -e prefix-tree ]]; then
	cd prefix-tree
	hg pull -q
	hg update -q
	cd ..
else
	hg clone http://prefix.gentooexperimental.org/hg/prefix-tree -q
fi

[[ -e distfiles-prefix-tree-${DATE} ]] || python "${SCRIPTSDIR}"/find-prefix-tree-distfiles.py prefix-tree "${GX86}" > distfiles-prefix-tree-${DATE}

for file in distfiles-prefix-tree-*; do
	filedate=${file#distfiles-prefix-tree-}
	timestamp=$(date +%s --date=$filedate)
	if [[ $timestamp -lt $(($TIME - 86400 * 21)) ]]; then
		rm "${file}"
	fi
done

echo "\
# Ruud Koolen <redlizard@gentoo.org> ($(date '+%d %b %Y'))
# Files still present in the prefix overlay, or were present up to three weeks ago
# NOTE: This file is autogenerated, changes will be overwritten.
# Contact redlizard@gentoo.org for details.
" > prefix-tree-whitelist

cat distfiles-prefix-tree-* | sort | uniq >> prefix-tree-whitelist
