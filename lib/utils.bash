#!/usr/bin/env bash

set -euo pipefail

# TODO: Ensure this is the correct GitHub homepage where releases can be downloaded for magic.
GH_REPO="https://github.com/modularml/mojo"
DOWNLOAD_URL="https://dl.modular.com/public/magic/raw/versions/"
CHANGELOG="https://docs.modular.com/magic/changelog/"
TOOL_NAME="magic"
TOOL_TEST="magic --help"

PLATFORM=$(uname -s)
ARCH=${MAGIC_ARCH:-$(uname -m)}

if [[ $PLATFORM == "Darwin" ]]; then
	PLATFORM="apple-darwin"
elif [[ $PLATFORM == "Linux" ]]; then
	PLATFORM="unknown-linux-musl"
elif [[ $(uname -o) == "Msys" ]]; then
	PLATFORM="pc-windows-msvc"
fi

if [[ $ARCH == "arm64" ]] || [[ $ARCH == "aarch64" ]]; then
	ARCH="aarch64"
fi

BINARY="magic-${ARCH}-${PLATFORM}"

fail() {
	echo -e "asdf-$TOOL_NAME: $*"
	exit 1
}

curl_opts=(-fsSL)

# Magic is not currently hosted on github releases.
#if [ -n "${GITHUB_API_TOKEN:-}" ]; then
#	curl_opts=("${curl_opts[@]}" -H "Authorization: token $GITHUB_API_TOKEN")
#fi

sort_versions() {
	sed 'h; s/[+-]/./g; s/.p\([[:digit:]]\)/.z\1/; s/$/.z/; G; s/\n/ /' |
		LC_ALL=C sort -t. -k 1,1 -k 2,2n -k 3,3n -k 4,4n -k 5,5n | awk '{print $2}'
}

list_github_tags() {
	git ls-remote --tags --refs "$GH_REPO" |
		grep -o 'refs/tags/.*' | cut -d/ -f3- |
		sed 's/^v//' # NOTE: You might want to adapt this sed to remove non-version strings from tags
}

list_changelog_tags() {
	curl -ssL "$CHANGELOG" |
		grep "<h2 class=\"anchor" |
		sed -E 's/.*v([0-9]+\.[0-9]+\.[0-9]+) \(([0-9]{4}-[0-9]{2}-[0-9]{2})\).*/ v\1/'
}

list_all_versions() {
	# Change this function if magic has other means of determining installable versions.
	# Eventually maigc will post to github, but for now pull from their changlog.
	#list_github_tags
	list_changelog_tags
}

download_release() {
	local version filename url http_code
	version="$1"
	filename="$2"

	url="$DOWNLOAD_URL/$version/$BINARY"

	echo "* Downloading $TOOL_NAME release $version from $url..."
	http_code=$(curl "${curl_opts[@]}" --progress-bar "$url" --output "$filename" --write-out "%{http_code}")
	if [[ ${http_code} -lt 200 || ${http_code} -gt 499 ]]; then
		echo "error: ${http_code} response. Please try again later."
		exit 1
	elif [[ ${http_code} -gt 299 ]]; then
		echo "error: '${DOWNLOAD_URL}' not found."
		echo "Sorry, Magic is not available for your OS and CPU architecture. " "See https://modul.ar/requirements."
		exit 1
	fi
}

install_version() {
	local install_type="$1"
	local version="$2"
	local install_path="${3%/bin}/bin"

	if [ "$install_type" != "version" ]; then
		fail "asdf-$TOOL_NAME supports release installs only"
	fi

	(
		mkdir -p "$install_path"
		cp -r "$ASDF_DOWNLOAD_PATH"/* "$install_path"

		# TODO: Assert magic executable exists.
		local tool_cmd
		tool_cmd="$(echo "$TOOL_TEST" | cut -d' ' -f1)"
		test -x "$install_path/$tool_cmd" || fail "Expected $install_path/$tool_cmd to be executable."

		echo "$TOOL_NAME $version installation was successful!"
	) || (
		rm -rf "$install_path"
		fail "An error occurred while installing $TOOL_NAME $version."
	)
}
