#!/usr/bin/env bash
# Asks Google Play for the highest published versionCode and prints the next one.
# github.run_number resets when this workflow file is renamed, so it cannot be
# used as the Play versionCode after the monorepo workflow split.
set -euo pipefail

PACKAGE_NAME="${PACKAGE_NAME:-${RELEASE_PACKAGE_NAME:-com.grapegames.ostrichdash}}"
# Last versionCode known to have shipped from deploy-android.yml before the rename.
PLAY_VERSION_CODE_FLOOR="${PLAY_VERSION_CODE_FLOOR:-28}"
API="https://androidpublisher.googleapis.com/androidpublisher/v3"
TOKEN_URI="https://oauth2.googleapis.com/token"
SCOPE="https://www.googleapis.com/auth/androidpublisher"
EDIT_ID=""
ACCESS_TOKEN=""
KEY_FILE=""

fail() {
	echo "ERROR: $*" >&2
	exit 1
}

b64url() {
	openssl base64 -A | tr '+/' '-_' | tr -d '='
}

cleanup() {
	if [[ -n "$EDIT_ID" && -n "$ACCESS_TOKEN" ]]; then
		curl -fsS -X DELETE \
			-H "Authorization: Bearer $ACCESS_TOKEN" \
			"$API/applications/${PACKAGE_NAME}/edits/${EDIT_ID}" \
			>/dev/null || true
	fi
	if [[ -n "$KEY_FILE" ]]; then
		rm -f "$KEY_FILE"
	fi
}

play_access_token() {
	local sa_json="$1"
	local email now exp header claim unsigned jwt token
	email="$(jq -r '.client_email // empty' <<<"$sa_json")"
	[[ -n "$email" ]] || fail "SERVICE_ACCOUNT_JSON is missing client_email"
	KEY_FILE="$(mktemp)"
	chmod 600 "$KEY_FILE"
	jq -r '.private_key // empty' <<<"$sa_json" > "$KEY_FILE"
	grep -q 'BEGIN PRIVATE KEY' "$KEY_FILE" || fail "SERVICE_ACCOUNT_JSON is missing a private key"
	now="$(date +%s)"
	exp="$((now + 3600))"
	header="$(printf '%s' '{"alg":"RS256","typ":"JWT"}' | b64url)"
	claim="$(jq -jnc \
		--arg iss "$email" \
		--arg scope "$SCOPE" \
		--arg aud "$TOKEN_URI" \
		--argjson iat "$now" \
		--argjson exp "$exp" \
		'{iss:$iss,scope:$scope,aud:$aud,iat:$iat,exp:$exp}' | b64url)"
	unsigned="${header}.${claim}"
	jwt="${unsigned}.$(printf '%s' "$unsigned" | openssl dgst -sha256 -sign "$KEY_FILE" -binary | b64url)"
	rm -f "$KEY_FILE"
	KEY_FILE=""
	token="$(curl -fsS -X POST "$TOKEN_URI" \
		-H "Content-Type: application/x-www-form-urlencoded" \
		--data-urlencode "grant_type=urn:ietf:params:oauth:grant-type:jwt-bearer" \
		--data-urlencode "assertion=${jwt}" | jq -r '.access_token // empty')"
	[[ -n "$token" ]] || fail "Google OAuth token request failed"
	printf '%s\n' "$token"
}

require_positive_int() {
	[[ "$1" =~ ^[0-9]+$ ]] || fail "$2 must be an integer, got '$1'"
}

create_play_edit() {
	local token="$1"
	local response_file http_code edit_id existing_id
	response_file="$(mktemp)"
	http_code="$(curl -sS -o "$response_file" -w '%{http_code}' -X POST \
		-H "Authorization: Bearer $token" \
		-H "Content-Type: application/json" \
		-d '{}' \
		"$API/applications/${PACKAGE_NAME}/edits")"
	if [[ "$http_code" == "200" ]]; then
		edit_id="$(jq -r '.id // empty' "$response_file")"
		rm -f "$response_file"
		[[ -n "$edit_id" ]] || fail "Play Console create-edit response had no id"
		printf '%s\n' "$edit_id"
		return
	fi
	existing_id="$(jq -r '.error.message // empty' "$response_file" | grep -oE '[0-9]{8,}' | head -1 || true)"
	if [[ "$http_code" == "409" && -n "$existing_id" ]]; then
		echo "Deleting leftover Play Console edit $existing_id" >&2
		curl -fsS -X DELETE \
			-H "Authorization: Bearer $token" \
			"$API/applications/${PACKAGE_NAME}/edits/${existing_id}" \
			>/dev/null || true
		rm -f "$response_file"
		http_code="$(curl -sS -o "$response_file" -w '%{http_code}' -X POST \
			-H "Authorization: Bearer $token" \
			-H "Content-Type: application/json" \
			-d '{}' \
			"$API/applications/${PACKAGE_NAME}/edits")"
		if [[ "$http_code" == "200" ]]; then
			edit_id="$(jq -r '.id // empty' "$response_file")"
			rm -f "$response_file"
			[[ -n "$edit_id" ]] || fail "Play Console create-edit response had no id"
			printf '%s\n' "$edit_id"
			return
		fi
	fi
	fail "Failed to create a Play Console edit (HTTP $http_code): $(tr -d '\n' < "$response_file")"
}

main() {
	[[ -n "${SERVICE_ACCOUNT_JSON:-}" ]] || fail "SERVICE_ACCOUNT_JSON must be set"
	command -v jq >/dev/null || fail "jq is required"
	command -v openssl >/dev/null || fail "openssl is required"
	require_positive_int "$PLAY_VERSION_CODE_FLOOR" "PLAY_VERSION_CODE_FLOOR"

	trap cleanup EXIT
	ACCESS_TOKEN="$(play_access_token "$SERVICE_ACCOUNT_JSON")"
	EDIT_ID="$(create_play_edit "$ACCESS_TOKEN")"

	local tracks_json bundles_json play_max version_code version_name
	tracks_json="$(curl -fsS \
		-H "Authorization: Bearer $ACCESS_TOKEN" \
		"$API/applications/${PACKAGE_NAME}/edits/${EDIT_ID}/tracks")"
	bundles_json="$(curl -fsS \
		-H "Authorization: Bearer $ACCESS_TOKEN" \
		"$API/applications/${PACKAGE_NAME}/edits/${EDIT_ID}/bundles" || printf '%s' '{}')"

	play_max="$(jq -n \
		--argjson tracks "$tracks_json" \
		--argjson bundles "$bundles_json" \
		--argjson floor "$PLAY_VERSION_CODE_FLOOR" '
			[
				($tracks.tracks // [])[]?.releases[]?.versionCodes[]?,
				($bundles.bundles // [])[]?.versionCode,
				$floor
			] | map(select(. != null) | tonumber) | max
		')"
	require_positive_int "$play_max" "Play max versionCode"
	version_code="$((play_max + 1))"
	version_name="1.${version_code}"

	echo "Play max versionCode is $play_max; using $version_code ($version_name)"
	if [[ -n "${GITHUB_OUTPUT:-}" ]]; then
		{
			echo "VERSION_CODE=${version_code}"
			echo "VERSION_NAME=${version_name}"
		} >> "$GITHUB_OUTPUT"
	fi
}

main "$@"
