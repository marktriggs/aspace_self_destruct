#!/bin/bash

basedir="$1"

if [ "$basedir" = "" ] || [ ! -d "$basedir" ] || [ ! -e "$basedir/archivesspace.sh" ]; then
   echo "Usage: $0 <archivesspace dir>"
   exit
fi

cd "$basedir"

if [ ! -e "self_destruct_time" ]; then
    # Nothing to do
    exit
fi


read host port db user pass <<<$(grep 'jdbc:mysql:' config/config.rb | sed "s|.*://\(.\+\):\([0-9]\+\)/\(.\+\?\)?.*user=\(.*\?\)&password=\(.*\?\)'|\1 \2 \3 \4 \5|g")

if [ "$host" = "" ] || [ "$port" = "" ] || [ "$db" = "" ] || [ "$user" = "" ] || [ "$pass" = "" ]; then
    echo "Couldn't parse out MySQL details from config.rb"
    exit
fi


./archivesspace.sh stop

table_count=$(echo 'show tables' | mysql -u${user} -p${pass} --host=${host} ${db} --port=3306 | sed -ne '2,$p' | wc -l)

echo "Dropping all tables..."

while [ $table_count -ge 0 ]; do

    echo 'show tables' | mysql -u${user} -p${pass} --host=${host} ${db} --port=3306 | sed -ne '2,$p' | while read table; do
      echo "delete from ${db}.${table}; drop table ${db}.${table};" | mysql -u${user} -p${pass} --host=${host} ${db} --port=3306 &>/dev/null
    done

    table_count=$[table_count - 1]
done

echo "Done."

echo -n "Table count after delete: "
echo 'show tables' | mysql -u${user} -p${pass} --host=${host} ${db} --port=3306 | sed -ne '2,$p' | wc -l

scripts/setup-database.sh

./archivesspace.sh start

rm -f self_destruct_time
