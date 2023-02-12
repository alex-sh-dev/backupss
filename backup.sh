#!/bin/sh

is_differential=false
should_compress=false
for i in "$@"; do
    case "$i" in
        -z|-zip|--compress)
         should_compress=true
         shift
         ;;
        -d|-diff|--differential)
         is_differential=true
         shift
	 ;;
        *)
         ;;
    esac
done

base_dir=$(dirname "$0")

if [ ! -f "$base_dir/backup.cfg" ]; then
    echo "File backup.cfg doesn't exist"
    exit 1
fi

. "$base_dir/backup.cfg"

#What to backup
backup_files="$files_to_backup"

#Where to backup to
dest="$backup_location"

if [ -z "$backup_files" ] || [ -z "$backup_location" ]; then
    echo "files_to_backup or backup_location is not assigned"
    exit 1
fi

if [ ! -d "$dest" ]; then
    echo "Attach disk (or create directory) for backup ($dest)"
    exit 1
fi

if [ ! -e "$base_dir/exclude.list" ]; then
    touch $base_dir/exclude.list
fi

#Create archive filename
day=$(date +%F-%s)
hostname=$(hostname -s)
archive_file=""

should_create_full_archive=false

if [ -f "$dest/$hostname-base.tar" ] || [ -f "$dest/$hostname-base.tar.gz" ]; then
    if [ "$is_differential" = true ]; then
        echo "An differential archive will be created"
	archive_file="$hostname-d-$day.tar"
    else
        echo "An incremental archive will be created"
	archive_file="$hostname-i-$day.tar"
    fi
else
    echo "A full archive will be created"
    archive_file="$hostname-base.tar"
    should_create_full_archive=true
fi

#Print start status message
echo "Backing up $backup_files to $dest/$archive_file (start time=$(date))"

listed_incremental="$dest/filesI.snar"
if [ "$is_differential" = true ]; then
    if [ -f "$dest/filesD.snar0" ]; then
        cp -f "${dest}/filesD.snar0" "${dest}/filesD.snar"
    fi
    listed_incremental="$dest/filesD.snar"
fi

#Backup the files using tar (add --verify to attempt to verify the archive after writing it)
tar --create \
    --verbose \
    --file="$dest/$archive_file" \
    --absolute-names \
    --ignore-failed-read \
    --one-file-system \
    --listed-incremental="$listed_incremental" \
    --exclude-from="$base_dir/exclude.list" \
    $backup_files \
    2>&1 | tee "$base_dir/backup.log"

if [ ! -f  "$dest/$archive_file" ]; then
    echo "Archive is not created"
    exit 1
fi

if [ "$should_create_full_archive" = true ] && [ "$is_differential" = true ] && [ -f "$listed_incremental" ]; then
    cp -f "$listed_incremental" "${listed_incremental}0"
fi

if [ "$should_compress" = true ]; then
    gzip -f "$dest/$archive_file"
fi

if [ -f "$base_dir/backup.log" ]; then
    grep 'tar:' "$base_dir/backup.log" > "$base_dir/tar.log"
fi

if [ "$should_compress" = true ] && [ ! -f  "$dest/$archive_file.gz" ]; then
    echo "Archive is not created"
    exit 1
fi

#Print end status message
echo
echo "Backup finished (end time=$(date))"

if [ "$should_compress" = true ]; then
    ls -lh "$dest/$archive_file.gz"
else
    ls -lh "$dest/$archive_file"
fi
