#!/bin/bash
set -euo pipefail
#set -x

# Get pacman and vercmp
# if [[ ! -f pacman-static ]]; then
# 	curl "https://pkgbuild.com/~eschwartz/repo/x86_64/pacman-static-5.2.1-6-x86_64.pkg.tar.xz" | \
# 		bsdtar --strip-components=2 -xf - \*pacman-static \*vercmp-static
# 	chmod u+x pacman-static vercmp-static
# fi

arch="${1:-x86_64}"
# Get repos for architecture
declare -a repos
while read -r repo; do
    repo="${repo:1:-1}"
    if [[ "$repo" != "options" ]]; then
        repos+=("$repo")
    fi
done< <(grep '^\[' "./branch-compare/pacman.${arch}.conf" 2>/dev/null)
[[ -z "${repos[*]}" ]] && exit 3   # bad architecture

[ -d "${arch}" ] || mkdir "${arch}"
cd "${arch}"

# Refresh package lists
declare -r mirror="https://mirror.alpix.eu/manjaro/"
prearch=""
archreal="$arch"
if [[ "$arch" == "arm" ]]; then
    prearch="arm-"
    archreal="aarch64"
fi
for branch in stable testing unstable; do
	mkdir -p $branch/sync
	for repo in ${repos[@]}; do
		wget -qN $mirror/${prearch}$branch/$repo/${archreal}/$repo.db -P $branch/sync/
	done
done

if [[ -f ../datas.${arch}.txt ]]; then
    cp ../datas.${arch}.txt datas.work -f
fi

udate="$(curl -s ${mirror}/${prearch}unstable/state | awk -F'=' '/^date/ {print $2}')"
udate="${udate:0:-4}"
cat > "datas.work" << EOH
[
EOH
sep=""
# Process each repo in turn
for repo in ${repos[@]}; do
	mapfile -t map < <(join -a1 -a2 -e "n/a" -o auto --nocheck-order <(join -a1 -a2 -e "n/a" -o auto --nocheck-order \
		<(pacman --config "../branch-compare/pacman.${arch}.conf" -Sl -b stable "$repo" | sed "s|$repo ||" | sort) \
		<(pacman --config "../branch-compare/pacman.${arch}.conf" -Sl -b testing "$repo" | sed "s|$repo ||" | sort)) \
		<(pacman --config "../branch-compare/pacman.${arch}.conf" -Sl -b unstable "$repo" | sed "s|$repo ||" | sort))

	for package in "${map[@]}"; do
		style='0'
		IFS=$' ' read -r name stable testing unstable <<< "$package"
		# [[ $(vercmp "$testing" "$stable")  -eq 1 ]] && style='1'
		# [[ $(vercmp "$unstable" "$testing") -eq 1 ]] && style='2'
		# [[ "$testing" == "$unstable" ]] && unstable=""
		# [[ "$testing" == "$stable" ]] && testing=""
		# echo "${sep}[\"$name\",\"$stable\",\"$testing\",\"$unstable\",\"$repo\",$style]" >> "datas.work"
		echo "${sep}{\"name\":\"$name\",\"stable\":\"$stable\",\"testing\":\"$testing\",\"unstable\":\"$unstable\",\"repo\":\"$repo\"}" >> "datas.work"
		[[ -z "$sep" ]] && sep=","
	done

done

echo -e "]\n" >> "datas.work"

cp datas.work ../datas.${arch}.json -f

