#!/bin/bash
set -f
export PASSWORD=$NEO4J_PASSWORD
export USERNAME=$NEO4J_USERNAME
export DRIVER=com.simba.neo4j.jdbc.Driver
export URL=jdbc:$NEO4J_URI
export OUTPUT_DIR=export

mkdir -p $OUTPUT_DIR

echo "Fetching database table list..."

export TABLES=$(echo '!tables' | bin/sqlline --fastConnect -u "$URL" -d "$DRIVER" -n "$USERNAME" -p "$PASSWORD" --outputformat=csv --silent=true 2>/dev/null | cut -d, -f3 | grep "^'" | tail -n +2 | sed "s/'//g")

export_table() {
   SQL="SELECT * FROM $table ;"
   echo $SQL

   # Sed removes JDBC command prompts.
   bin/sqlline --fastConnect \
	-u "$URL" -d "$DRIVER" \
	-n "$USERNAME" -p "$PASSWORD" \
	--outputformat=csv --silent=true \
	| sed 's/^0: jdbc:.*> //' > "$OUTPUT_DIR/$table.csv"
}

for table in $TABLES ; do
   echo "Exporting table $table to $OUTPUT_DIR/$table.csv"
   export_table "$table"
done
