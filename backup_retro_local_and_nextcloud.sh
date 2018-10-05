#!/bin/bash

# Global variables
ROMS_PATH="/home/pi/RetroPie/roms"
BACKUP_PATH="$ROMS_PATH/backups"
TIMESTAMP="$(date -u +'%Y-%m-%dT%H%MZ')"    # ISO 8601 datetime format, time in UTC.

ARCHIVE_DIR="RetroPiSaves"
ARCHIVE_SUFFIX="tar"
ARCHIVE_PATH="$BACKUP_PATH/$ARCHIVE_DIR"
ARCHIVE_FILENAME="retropie-saves_$TIMESTAMP.$ARCHIVE_SUFFIX"
ARCHIVE_FILEPATH="$ARCHIVE_PATH/$ARCHIVE_FILENAME"

# Nextcloud variables
PROTOCOL="https"
DOMAIN=""       # Nextcloud domain e.g.: my.nextcloud.com
NC_FKEY=""      # Folder key is from public folder share URL e.g.: https://{nextcloud_domain}/index.php/s/{NC_FKEY}
NC_FPASS=""     # Password is optional. Use if a password was set on the folder share
PUB_SUFFIX="public.php/webdav"
UPLOAD_HEADER="X-Requested-With: XMLHttpRequest"

# Create local archive
echo "Nextcloud Backup script By CompSciMaj13"
printf "https://github.com/CompSciMaj13/RetroPie-Simple-Backup-Script \\n\\n"

printf "Creating local archive ... \\n\\n"

cd "$ROMS_PATH" || exit
[ -d "$ARCHIVE_PATH" ] || mkdir -p "$ARCHIVE_PATH" &&
find . -type f \( -iname "*.sav" -o -iname "*.srm" -o -iname "*.state" \) -exec tar -rvf "$ARCHIVE_FILEPATH" {} \; && 
xz "$ARCHIVE_FILEPATH" &&
ARCHIVE_FILENAME="$ARCHIVE_FILENAME.xz" &&
ARCHIVE_FILEPATH="$ARCHIVE_FILEPATH.xz" &&
echo "Completed!" &&
printf "Archive saved to %s \\n\\n" "$ARCHIVE_FILEPATH" &&

# Create MD5 of archive
echo "Creating MD5 of archive ..." &&
MD5="$(md5sum "$ARCHIVE_FILEPATH")" &&
echo "$MD5" >> "$ARCHIVE_FILEPATH.md5" &&
echo "Completed!" &&
printf "MD5 saved to %s \\n\\n" "$ARCHIVE_FILEPATH.md5" &&

# Upload archive and MD5 to Nextcloud public folder share
echo "Uploading $ARCHIVE_FILENAME to Nextcloud ..." &&
curl -w "  HTTP Code: %{http_code}\\n" -T "$ARCHIVE_FILEPATH" -u "$NC_FKEY:$NC_FPASS" -H "$UPLOAD_HEADER" "$PROTOCOL://$DOMAIN/$PUB_SUFFIX/$ARCHIVE_FILENAME" &&
echo "Uploading $ARCHIVE_FILENAME.md5 to Nextcloud ..." &&
curl -w "  HTTP Code: %{http_code}\\n\\n" -T "$ARCHIVE_FILEPATH.md5" -u "$NC_FKEY:$NC_FPASS" -H "$UPLOAD_HEADER" "$PROTOCOL://$DOMAIN/$PUB_SUFFIX/$ARCHIVE_FILENAME.md5" &&
echo "Local and nextcloud backup complete!"
