#!/usr/bin/env bash

#====================================================================================================================
#Browser Forensics Collection Tool (Prioritized its use in Firefox Snap, but can be used with Chromium and 
# other browser tools.
#Collects browser artifacts (specifically history, cookies, cache, DBs) for use in digital forensics analysis.

#Authors: Dylan Voss and Grant Gollinger for the  IT 360 Digital Forensic Tool Group Project.

#====================================================================================================================


set -euo pipefail
IFS=$'\n\t'

# This section below includes the argument handling and output location. One argument - root directory where 
# collected browser evidence will be stored.
OUT_ROOT="${1:-}"
if [[ -z "$OUT_ROOT" ]]; then
  echo "Usage: $0 /path/to/output_dir"
  exit 1
fi

# Evidence directory setup, creating a unique folder to hold all exported browser artifacts.
TIMESTAMP="$(date -u +"%Y%m%dT%H%M%SZ")"
EVIDENCE_DIR="${OUT_ROOT%/}/firefox_snap_artifacts_${TIMESTAMP}"
TMPDIR="$(mktemp -d)"
mkdir -p "$EVIDENCE_DIR"

#Manifest and hashing, initializes a CSV manifest and records the SHA-256 hashes for file integrity.
MANIFEST_FILE="${EVIDENCE_DIR}/manifest_${TIMESTAMP}.csv"
echo "hash,filepath" > "$MANIFEST_FILE"

#Firefox profile discovery. Points to default location for where Ubuntu stores Firefox folders
PROFILE_ROOT="$HOME/snap/firefox/common/.mozilla/firefox"

# Chromium / Chrome profile roots (Linux)
CHROME_PATHS=(
  "$HOME/.config/chromium"
  "$HOME/.config/google-chrome"
)


echo "Using profile root: $PROFILE_ROOT"

if [[ ! -d "$PROFILE_ROOT" ]]; then
  echo "ERROR: Firefox Snap profile root not found at $PROFILE_ROOT"
  exit 1
fi

# Hash tool
HASH_CMD="sha256sum"
if ! command -v sha256sum >/dev/null 2>&1; then
  if command -v shasum >/dev/null 2>&1; then
    HASH_CMD="shasum -a 256"
  else
    echo "Warning: no sha256sum or shasum; hashes will be marked HASH_NA."
    HASH_CMD=""
  fi
fi

record_hash() {
  local path="$1"
  if [[ -z "$HASH_CMD" ]]; then
    echo "${path},HASH_NA" >> "$MANIFEST_FILE"
    return
  fi
  if [[ -f "$path" ]]; then
    $HASH_CMD "$path" | awk -v p="$path" '{print $1","p}' >> "$MANIFEST_FILE"
  elif [[ -d "$path" ]]; then
    find "$path" -type f -print0 | while IFS= read -r -d '' f; do
      $HASH_CMD "$f" | awk -v p="$f" '{print $1","p}' >> "$MANIFEST_FILE"
    done
  else
    echo "${path},NOT_FOUND" >> "$MANIFEST_FILE"
  fi
}

#SQLite -> CSV helper. Copies SQLite DB and exports into a CSV. Used mainly for history and cookies.
export_sqlite_csv() {
  local srcdb="$1"
  local csvout="$2"
  local query="$3"
  if [[ ! -f "$srcdb" ]]; then
    echo "DB not found: $srcdb"
    return
  fi
  if ! command -v sqlite3 >/dev/null 2>&1; then
    echo "sqlite3 not installed, skipping CSV export for $srcdb"
    return
  fi
  local tmpdb="${TMPDIR}/$(basename "$srcdb").copy"
  cp "$srcdb" "$tmpdb"
  chmod a+r "$tmpdb"
  sqlite3 -csv -header "$tmpdb" "$query" > "$csvout" || \
    echo "sqlite3 export failed for $srcdb (schema may differ)"
  record_hash "$csvout"
}

# Per-profiling processing. For each profile, collect databases, CSVs, and copy cache.
find "$PROFILE_ROOT" -maxdepth 1 -type d -name "*.default*" | while read -r profile; do
  pname="$(basename "$profile")"
  echo "Found Firefox profile: $pname"
  pdest="${EVIDENCE_DIR}/firefox_profiles/${pname}"
  mkdir -p "$pdest"

  # Copy key artifact files
  for f in places.sqlite cookies.sqlite logins.json key4.db sessionstore.jsonlz4 formhistory.sqlite; do
    if [[ -f "$profile/$f" ]]; then
      cp -a "$profile/$f" "$pdest/$f"
      record_hash "$pdest/$f"
    fi
  done

  # Export history (moz_places) from places.sqlite
  if [[ -f "$profile/places.sqlite" ]]; then
   export_sqlite_csv "$profile/places.sqlite" \
  "$pdest/history_${pname}.csv" \
  "SELECT 
      url, 
      title, 
      visit_count, 
      last_visit_date,
      datetime(last_visit_date/1000000, 'unixepoch') AS last_visit_human
   FROM moz_places 
   ORDER BY last_visit_date DESC 
   LIMIT 1000;"
  fi

  # Export cookies from cookies.sqlite
  if [[ -f "$profile/cookies.sqlite" ]]; then
    export_sqlite_csv "$profile/cookies.sqlite" \
      "$pdest/cookies_${pname}.csv" \
      "SELECT host, name, value, expiry, isSecure, isHttpOnly FROM moz_cookies ORDER BY expiry DESC LIMIT 1000;"
  fi

  # Copy Cache2 directory (cached images, scripts, etc.)
  CACHE_DIR="$HOME/snap/firefox/common/.cache/mozilla/firefox/$pname/cache2"

  if [[ -d "$CACHE_DIR" ]]; then
    echo "Copying cache from $CACHE_DIR"
    mkdir -p "$pdest/cache2"
    cp -a "$CACHE_DIR"/* "$pdest/cache2/"
    record_hash "$pdest/cache2"
  else
    echo "No cache2 directory found for profile $pname"
  fi


done

# ===== Collect Chromium / Chrome artifacts =====
for base in "${CHROME_PATHS[@]}"; do
  if [[ -d "$base" ]]; then
    echo "Found Chromium/Chrome root: $base"

    # Look for profiles like "Default", "Profile 1", etc.
    find "$base" -maxdepth 2 -type d \( -name "Default" -o -name "Profile*" \) | while read -r profile; do
      profile_name="$(basename "$profile")"
      echo "Processing Chrome profile: $profile_name"
      pdest="${EVIDENCE_DIR}/chrome_profiles/${profile_name}"
      mkdir -p "$pdest"

      # Copy main Chrome artifact files
      for f in History Cookies Bookmarks "Login Data" "Web Data"; do
        if [[ -f "$profile/$f" ]]; then
          cp -a "$profile/$f" "$pdest/$f"
          record_hash "$pdest/$f"
        fi
      done

      # Export Chrome history to CSV
      if [[ -f "$profile/History" ]]; then
        export_sqlite_csv "$profile/History" \
  "$pdest/history_${profile_name}.csv" \
  "SELECT 
      url, 
      title, 
      visit_count, 
      last_visit_time,
      datetime((last_visit_time/1000000)-11644473600, 'unixepoch') 
          AS last_visit_human
   FROM urls 
   ORDER BY last_visit_time DESC 
   LIMIT 1000;"

      fi

      # Export Chrome cookies to CSV
      if [[ -f "$profile/Cookies" ]]; then
        export_sqlite_csv "$profile/Cookies" \
          "$pdest/cookies_${profile_name}.csv" \
          "SELECT host_key, name, path, expires_utc, is_secure, is_httponly FROM cookies ORDER BY expires_utc DESC LIMIT 1000;"
      fi
    done
  fi
done

# Writes a small text file with collection info to document context.
cat <<EOF > "${EVIDENCE_DIR}/collection_info.txt"
timestamp=$TIMESTAMP
collector=$(id -un)
hostname=$(hostname)
profile_root=$PROFILE_ROOT
EOF
record_hash "${EVIDENCE_DIR}/collection_info.txt"

# Archive and cleanup. Creates a tarball of the evidence directory and removes temp files.
TARFILE="${OUT_ROOT%/}/firefox_snap_artifacts_${TIMESTAMP}.tar.gz"
tar -czf "$TARFILE" -C "$OUT_ROOT" "$(basename "$EVIDENCE_DIR")"
record_hash "$TARFILE"

rm -rf "$TMPDIR"

#This section holds echo commands that tell the user when the tool is complete.
echo "DONE."
echo "Evidence directory: $EVIDENCE_DIR"
echo "Manifest: $MANIFEST_FILE"
echo "Archive:  $TARFILE"
