#!/bin/bash

new_db_name="ed17_02"
backup_sql_path="/home/xxx/xxx/xxx/xxx_data.sql"
backup_filestore_path="/home/xxx/xxx/xxx/xxx_data/xxx_data_filestore_path"
local_filestore_path="/home/xxxx/.local/share/Odoo/filestore"
postgres_user="your postgres user"

if [[ -z "$new_db_name" || -z "$backup_sql_path" || -z "$backup_filestore_path" || -z "$local_filestore_path" || -z "$postgres_user" ]]; then
  exit 1
fi

#Create and restore db as postgres_user user by using sql file in the path given for backup_sql_path
echo "creating database ----: $new_db_name ..."
createdb -U "$postgres_user" "$new_db_name"
if [ $? -ne 0 ]; then
  echo "database $new_db_name creation failed"
  exit 1
fi
echo "restoring database $new_db_name ..."
timeout 600 psql -U "$postgres_user" "$new_db_name" < "$backup_sql_path"
if [ $? -ne 0 ]; then
  echo "restor process failed from $backup_sql_path please check again."
  exit 1
fi
if [ $? -ne 1 ]; then
    rm -r $backup_sql_path
fi
echo "$new_db_name restored successfully and $backup_sql_path file is deleted-----..."

#create a directory in the given local_filestore_path with the same name as new_db_name
new_filestore_path="${local_filestore_path}/${new_db_name}"
echo "creating new filestore directory $new_filestore_path..."
mkdir -p "$new_filestore_path"
if [ $? -ne 0 ]; then
  echo "failed to create the filestore directory $new_filestore_path"
  exit 1
fi

#take all the file from the backup_filestore_path and replace newly created new_db_name filestore folder's data with them
echo "copying filestore from $backup_filestore_path to $new_filestore_path..."

:'
use: cp -r "$backup_filestore_path"/* "$new_filestore_path" if you want to keep the filestore in your location
'
# cp -r "$backup_filestore_path"/* "$new_filestore_path"
mv "$backup_filestore_path"/* "$new_filestore_path"
if [ $? -ne 0 ]; then
  echo "failed to copy/move filestore from $backup_filestore_path to $new_filestore_path"
  exit 1
fi

echo "Database restored successfully. Please restart odoo with proper configuration to proceed further."