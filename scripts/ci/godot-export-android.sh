#!/usr/bin/env bash
# Builds Ostrich Dash as a signed Google Play AAB and validates its manifest.
# Run from any directory on Ubuntu CI or a Linux development machine.
set -euo pipefail

ROOT="$(cd "$(dirname "$0")/../.." && pwd)"
PROJECT="$ROOT"
GODOT_VERSION="${GODOT_VERSION:-4.7.1}"
GODOT_CHANNEL="${GODOT_CHANNEL:-stable}"
GODOT_TAG="${GODOT_VERSION}-${GODOT_CHANNEL}"
GODOT_SHARE_DIR="${GODOT_SHARE_DIR:-$HOME/.local/share/godot}"
export PATH="$HOME/.local/bin:$PATH"
EXPORT_PRESET="${EXPORT_PRESET:-Android Play}"
RELEASE_PACKAGE_NAME="${RELEASE_PACKAGE_NAME:-com.grapegames.ostrichdash}"
ARTIFACT_STEM="${ARTIFACT_STEM:-OstrichDash}"
VERSION_CODE="${VERSION_CODE:-1}"
VERSION_NAME="${VERSION_NAME:-1.${VERSION_CODE}}"
ADMOB_ANDROID_APP_ID="${ADMOB_ANDROID_APP_ID:-${OSTRICH_DASH_ADMOB_ANDROID_APP_ID:-}}"
PLAY_GAMES_APP_ID="${PLAY_GAMES_APP_ID:-${OSTRICH_DASH_PLAY_GAMES_APP_ID:-}}"
PLAY_GAMES_LEADERBOARD_ID="${PLAY_GAMES_LEADERBOARD_ID:-${OSTRICH_DASH_LEADERBOARD_ID:-}}"

PRESET_BACKUP=""
PROJECT_SETTINGS_BACKUP=""
ADMOB_CONFIG_BACKUP=""
ADMOB_CONFIG_EXISTED=0

restore_project_files() {
	if [[ -n "$PRESET_BACKUP" && -f "$PRESET_BACKUP" ]]; then
		cp "$PRESET_BACKUP" "$PROJECT/export_presets.cfg"
		rm -f "$PRESET_BACKUP"
	fi
	if [[ -n "$PROJECT_SETTINGS_BACKUP" && -f "$PROJECT_SETTINGS_BACKUP" ]]; then
		cp "$PROJECT_SETTINGS_BACKUP" "$PROJECT/project.godot"
		rm -f "$PROJECT_SETTINGS_BACKUP"
	fi
	if [[ "$ADMOB_CONFIG_EXISTED" -eq 1 && -n "$ADMOB_CONFIG_BACKUP" && -f "$ADMOB_CONFIG_BACKUP" ]]; then
		cp "$ADMOB_CONFIG_BACKUP" "$PROJECT/config/admob.json"
		rm -f "$ADMOB_CONFIG_BACKUP"
	elif [[ "$ADMOB_CONFIG_EXISTED" -eq 0 ]]; then
		rm -f "$PROJECT/config/admob.json"
	fi
}

fail() {
	echo "ERROR: $*" >&2
	exit 1
}

require_configuration() {
	[[ "$VERSION_CODE" =~ ^[1-9][0-9]*$ ]] || fail "VERSION_CODE must be a positive integer"
	[[ "$ADMOB_ANDROID_APP_ID" =~ ^ca-app-pub-[0-9]+~[0-9]+$ ]] || \
		fail "OSTRICH_DASH_ADMOB_ANDROID_APP_ID must be an AdMob App ID (ca-app-pub-...~...)"
	[[ "$PLAY_GAMES_APP_ID" =~ ^[0-9]+$ ]] || \
		fail "OSTRICH_DASH_PLAY_GAMES_APP_ID must be the numeric Play Games project ID"
	[[ -n "$PLAY_GAMES_LEADERBOARD_ID" ]] || \
		fail "OSTRICH_DASH_LEADERBOARD_ID must be the Longest Dash leaderboard ID"
	[[ -n "${ANDROID_SDK_ROOT:-${ANDROID_HOME:-}}" ]] || \
		fail "ANDROID_SDK_ROOT or ANDROID_HOME must be set"
	export ANDROID_SDK_ROOT="${ANDROID_SDK_ROOT:-$ANDROID_HOME}"
}

expected_template_version() {
	printf '%s.%s\n' "$GODOT_VERSION" "$GODOT_CHANNEL"
}

verify_template_marker() {
	local marker="$PROJECT/android/.build_version"
	local expected actual
	expected="$(expected_template_version)"
	[[ -f "$marker" ]] || fail "Missing android/.build_version"
	actual="$(tr -d '\r\n' < "$marker")"
	[[ "$actual" == "$expected" ]] || \
		fail "android/.build_version is '$actual', but CI uses '$expected'"
}

install_godot_and_templates() {
	local cache="$HOME/.cache/ostrich-dash/godot"
	local editor_zip="Godot_v${GODOT_TAG}_linux.x86_64.zip"
	local templates_zip="Godot_v${GODOT_TAG}_export_templates.tpz"
	local template_version template_root unpack_dir
	mkdir -p "$cache" "$HOME/.local/bin"

	local current_version=""
	if command -v godot >/dev/null 2>&1; then
		current_version="$(godot --version 2>/dev/null || true)"
	fi
	if [[ "$current_version" != "${GODOT_VERSION}.${GODOT_CHANNEL}"* ]]; then
		if [[ ! -s "$cache/$editor_zip" ]]; then
			curl -fsSL --retry 3 -o "$cache/$editor_zip" \
				"https://github.com/godotengine/godot-builds/releases/download/${GODOT_TAG}/${editor_zip}"
		fi
		unzip -qo "$cache/$editor_zip" -d "$cache/editor"
		install -m 755 "$cache/editor/Godot_v${GODOT_TAG}_linux.x86_64" "$HOME/.local/bin/godot"
	fi

	template_version="$(expected_template_version)"
	template_root="$GODOT_SHARE_DIR/export_templates/$template_version"
	if [[ ! -s "$template_root/android_source.zip" ]]; then
		if [[ ! -s "$cache/$templates_zip" ]]; then
			curl -fsSL --retry 3 -o "$cache/$templates_zip" \
				"https://github.com/godotengine/godot-builds/releases/download/${GODOT_TAG}/${templates_zip}"
		fi
		unpack_dir="$(mktemp -d)"
		unzip -qo "$cache/$templates_zip" -d "$unpack_dir"
		mkdir -p "$template_root"
		cp -a "$unpack_dir/templates/." "$template_root/"
		rm -rf "$unpack_dir"
	fi
	[[ -s "$template_root/android_source.zip" ]] || fail "Godot Android source template is missing"
	echo "Using $(godot --version)"
}

configure_godot_android_paths() {
	local settings_dir="$HOME/.config/godot"
	local java_home="${JAVA_HOME:-}"
	if [[ -z "$java_home" ]]; then
		java_home="$(readlink -f "$(command -v java)" | sed 's|/bin/java||')"
	fi
	mkdir -p "$settings_dir"
	cat > "$settings_dir/editor_settings-4.tres" <<EOF
[gd_resource type="EditorSettings" format=3]

[resource]
export/android/android_sdk_path = "${ANDROID_SDK_ROOT}"
export/android/java_sdk_path = "${java_home}"
EOF
}

ensure_android_build_template() {
	local build_dir="$PROJECT/android/build"
	local template_version template_source existing_version godot_aar
	template_version="$(expected_template_version)"
	existing_version=""
	if [[ -f "$build_dir/.build_version" ]]; then
		existing_version="$(tr -d '\r\n' < "$build_dir/.build_version")"
	fi
	godot_aar="$(find "$build_dir/libs" -name 'godot-lib*.aar' -type f 2>/dev/null | head -1 || true)"
	if [[ -f "$build_dir/build.gradle" && -s "$godot_aar" && "$existing_version" == "$template_version" ]]; then
		: > "$build_dir/.gdignore"
		find "$build_dir" -type f -name '*.import' -delete
		echo "Using cached Android build template $template_version"
		return
	fi

	template_source="$GODOT_SHARE_DIR/export_templates/$template_version/android_source.zip"
	[[ -s "$template_source" ]] || fail "Missing $template_source"
	# The target is an explicit generated subdirectory, never the repository root.
	rm -rf "$build_dir"
	mkdir -p "$build_dir"
	unzip -qo "$template_source" -d "$build_dir"
	chmod +x "$build_dir/gradlew"
	printf '%s\n' "$template_version" > "$build_dir/.build_version"
	: > "$build_dir/.gdignore"
	find "$build_dir" -type f -name '*.import' -delete
	godot_aar="$(find "$build_dir/libs" -name 'godot-lib*.aar' -type f | head -1 || true)"
	[[ -f "$build_dir/build.gradle" && -s "$godot_aar" ]] || \
		fail "Android template extraction did not produce Gradle and Godot AAR files"
}

install_admob_android_binaries() {
	local plugin_version="${ADMOB_PLUGIN_VERSION:-v5.0.0}"
	local zip_name="android-template-v${GODOT_VERSION}.zip"
	local cache="${ADMOB_CACHE_DIR:-$HOME/.cache/ostrich-dash/admob}"
	local bin_dir="$PROJECT/addons/admob/android/bin"
	local marker="$bin_dir/ads/libs/poing-godot-admob-ads-release.aar"
	if [[ -s "$marker" && -f "$bin_dir/package.gd" ]]; then
		echo "AdMob Android binaries are present"
		return
	fi
	mkdir -p "$cache" "$bin_dir"
	if [[ ! -s "$cache/$zip_name" ]]; then
		curl -fsSL --retry 3 -o "$cache/$zip_name" \
			"https://github.com/poingstudios/godot-admob-plugin/releases/download/${plugin_version}/${zip_name}"
	fi
	unzip -qo "$cache/$zip_name" -d "$bin_dir"
	[[ -s "$marker" && -f "$bin_dir/package.gd" ]] || fail "AdMob binaries were not installed correctly"
}

write_admob_config() {
	local enabled="${ADMOB_ADS_ENABLED:-true}"
	local test_android="ca-app-pub-3940256099942544/6300978111"
	local test_ios="ca-app-pub-3940256099942544/2435281174"
	mkdir -p "$PROJECT/config"
	cat > "$PROJECT/config/admob.json" <<EOF
{
  "ads_enabled": ${enabled},
  "android_ads_enabled": true,
  "ios_ads_enabled": false,
  "products": {
    "ostrich_dash": {
      "android_banner_unit_id": "${test_android}",
      "ios_banner_unit_id": "${test_ios}"
    }
  },
  "child_directed": false,
  "tag_for_under_age_of_consent": false,
  "max_ad_content_rating": "PG",
  "banner_height_dp": 60
}
EOF
}

set_project_android_app_id() {
	local settings="$PROJECT/project.godot"
	awk -v id="$ADMOB_ANDROID_APP_ID" '
		BEGIN { in_admob=0; found_section=0; found_id=0 }
		/^\[admob\]$/ { in_admob=1; found_section=1; print; next }
		/^\[/ {
			if (in_admob && !found_id) { print "general/android/app_id=\"" id "\""; found_id=1 }
			in_admob=0
		}
		in_admob && /^general\/android\/app_id=/ {
			print "general/android/app_id=\"" id "\""; found_id=1; next
		}
		{ print }
		END {
			if (in_admob && !found_id) print "general/android/app_id=\"" id "\""
			if (!found_section) {
				print ""; print "[admob]"; print ""; print "general/android/app_id=\"" id "\""
			}
		}
	' "$settings" > "$settings.tmp"
	mv "$settings.tmp" "$settings"
}

set_project_play_games_ids() {
	local settings="$PROJECT/project.godot"
	awk -v leaderboard_id="$PLAY_GAMES_LEADERBOARD_ID" '
		/^play_games\/longest_dash_leaderboard_id=/ {
			print "play_games/longest_dash_leaderboard_id=\"" leaderboard_id "\""; next
		}
		{ print }
	' "$settings" > "$settings.tmp"
	mv "$settings.tmp" "$settings"
}

ensure_android_editor_plugins_enabled() {
	local settings="$PROJECT/project.godot"
	awk '
		BEGIN { in_plugins=0; found_section=0; wrote_enabled=0 }
		/^\[editor_plugins\]$/ { in_plugins=1; found_section=1; print; next }
		/^\[/ {
			if (in_plugins && !wrote_enabled) {
				print "enabled=PackedStringArray(\"res://addons/admob/plugin.cfg\", \"res://addons/GodotPlayGameServices/plugin.cfg\")"
				wrote_enabled=1
			}
			in_plugins=0
		}
		in_plugins && /^enabled=/ {
			print "enabled=PackedStringArray(\"res://addons/admob/plugin.cfg\", \"res://addons/GodotPlayGameServices/plugin.cfg\")"
			wrote_enabled=1
			next
		}
		{ print }
		END {
			if (in_plugins && !wrote_enabled) print "enabled=PackedStringArray(\"res://addons/admob/plugin.cfg\", \"res://addons/GodotPlayGameServices/plugin.cfg\")"
			if (!found_section) {
				print ""; print "[editor_plugins]"; print ""
				print "enabled=PackedStringArray(\"res://addons/admob/plugin.cfg\", \"res://addons/GodotPlayGameServices/plugin.cfg\")"
			}
		}
	' "$settings" > "$settings.tmp"
	mv "$settings.tmp" "$settings"
}

mutate_play_preset() {
	export VERSION_CODE VERSION_NAME RELEASE_PACKAGE_NAME PLAY_GAMES_APP_ID
	local preset="$PROJECT/export_presets.cfg"
	awk -v want="$EXPORT_PRESET" '
		BEGIN { in_play=0 }
		/^name="/ { in_play = ($0 == "name=\"" want "\"") }
		in_play && /^version\/code=/ { print "version/code=" ENVIRON["VERSION_CODE"]; next }
		in_play && /^version\/name=/ { print "version/name=\"" ENVIRON["VERSION_NAME"] "\""; next }
		in_play && /^package\/unique_name=/ { print "package/unique_name=\"" ENVIRON["RELEASE_PACKAGE_NAME"] "\""; next }
		in_play && /^godot_play_game_services\/game_id=/ { print "godot_play_game_services/game_id=\"" ENVIRON["PLAY_GAMES_APP_ID"] "\""; next }
		{ print }
	' "$preset" > "$preset.tmp"
	mv "$preset.tmp" "$preset"
}

apply_play_gradle_overlay() {
	local build_dir="$PROJECT/android/build"
	local app_gradle="$build_dir/build.gradle"
	[[ -f "$app_gradle" ]] || fail "Android Gradle project is missing"
	cp "$PROJECT/android/proguard-godot-play.pro" "$build_dir/proguard-godot-play.pro"
	cp "$PROJECT/android/play-release.gradle" "$build_dir/play-release.gradle"
	if ! grep -q 'play-release.gradle' "$app_gradle"; then
		printf '\n// Grapegames Play release overlay\napply from: "play-release.gradle"\n' >> "$app_gradle"
	fi
}

bundletool_jar() {
	local version="${BUNDLETOOL_VERSION:-1.16.0}"
	local cache="${BUNDLETOOL_CACHE_DIR:-$HOME/.cache/ostrich-dash/bundletool}"
	local jar="$cache/bundletool-all-${version}.jar"
	if [[ ! -s "$jar" ]]; then
		mkdir -p "$cache"
		curl -fsSL --retry 3 -o "$jar" \
			"https://github.com/google/bundletool/releases/download/${version}/bundletool-all-${version}.jar"
	fi
	java -jar "$jar" version >/dev/null || fail "Bundletool is not executable"
	printf '%s\n' "$jar"
}

validate_aab() {
	local aab="$1" bundletool actual signature_output
	[[ -s "$aab" ]] || fail "AAB was not created at $aab"
	bundletool="$(bundletool_jar)"
	actual="$(java -jar "$bundletool" dump manifest --bundle="$aab" --xpath=/manifest/@package)"
	[[ "$actual" == "$RELEASE_PACKAGE_NAME" ]] || fail "AAB package is '$actual', expected '$RELEASE_PACKAGE_NAME'"
	actual="$(java -jar "$bundletool" dump manifest --bundle="$aab" --xpath=/manifest/@android:versionCode)"
	[[ "$actual" == "$VERSION_CODE" ]] || fail "AAB versionCode is '$actual', expected '$VERSION_CODE'"
	actual="$(java -jar "$bundletool" dump manifest --bundle="$aab" --xpath=/manifest/@android:versionName)"
	[[ "$actual" == "$VERSION_NAME" ]] || fail "AAB versionName is '$actual', expected '$VERSION_NAME'"
	signature_output="$(jarsigner -verify "$aab" 2>&1)" || fail "AAB signature verification failed"
	grep -q 'jar verified.' <<< "$signature_output" || fail "AAB is not signed with a verifiable JAR signature"
	echo "Validated $aab: $RELEASE_PACKAGE_NAME $VERSION_NAME ($VERSION_CODE)"
}

prepare_mutable_files() {
	PRESET_BACKUP="$(mktemp)"
	PROJECT_SETTINGS_BACKUP="$(mktemp)"
	cp "$PROJECT/export_presets.cfg" "$PRESET_BACKUP"
	cp "$PROJECT/project.godot" "$PROJECT_SETTINGS_BACKUP"
	if [[ -f "$PROJECT/config/admob.json" ]]; then
		ADMOB_CONFIG_EXISTED=1
		ADMOB_CONFIG_BACKUP="$(mktemp)"
		cp "$PROJECT/config/admob.json" "$ADMOB_CONFIG_BACKUP"
	fi
	trap restore_project_files EXIT
}

main() {
	require_configuration
	verify_template_marker
	install_godot_and_templates
	configure_godot_android_paths
	prepare_mutable_files
	install_admob_android_binaries
	write_admob_config
	set_project_android_app_id
	set_project_play_games_ids
	mutate_play_preset

	echo "Importing project assets..."
	# Godot 4.7.1 can abort in --import command mode when this project's editor
	# plugin finishes loading. Opening the headless editor performs the same
	# incremental filesystem/import scan without that command-mode crash.
	godot --headless --path "$PROJECT" --editor --quit
	godot --headless --path "$PROJECT" --quit
	ensure_android_editor_plugins_enabled

	ensure_android_build_template
	apply_play_gradle_overlay
	mkdir -p "$PROJECT/builds/android"
	local aab="$PROJECT/builds/android/${ARTIFACT_STEM}.aab"
	echo "Exporting $RELEASE_PACKAGE_NAME $VERSION_NAME ($VERSION_CODE)..."
	godot --headless --path "$PROJECT" --verbose --export-release "$EXPORT_PRESET" "$aab"
	validate_aab "$aab"
	restore_project_files
	trap - EXIT
	echo "Done: $aab"
}

main "$@"
