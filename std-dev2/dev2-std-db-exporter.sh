#!/bin/bash
dbpwd="RootMYSQL00!"

echo "Iniciando el proceso\n"
echo $(pwd)
echo "Borrando los archivos iniciales\n"
/bin/rm -f /home/siba/exports/sibastdapi.sql
/bin/rm -f /home/siba/exports/sibastdapi.sql.tar.gz
/bin/rm -f /var/www/html/sibastdapi.sql.tar.gz
echo "Iniciando la exportación de datos mysql\n"
/usr/bin/mysqldump -u root --password=$dbpwd epgdev2 > /home/siba/exports/sibastdapi.sql
cd /home/siba/exports
echo "En la carpeta..."
echo $(pwd)
echo $(ls -l)
echo "Comprimiendo el archivo /home/siba/exports/sibastdapi.sql.tar.gz"
/bin/tar -czvf /home/siba/exports/sibastdapi.sql.tar.gz /home/siba/exports/sibastdapi.sql & > /dev/null
/bin/chmod 777 /home/siba/exports/sibastdapi.sql.tar.gz & > /dev/null
/bin/rm -f /var/www/html/sibastdapi.sql.tar.gz
/bin/mv /home/siba/exports/sibastdapi.sql.tar.gz /var/www/html/ & > /dev/null
/bin/chown -f siba:siba /var/www/html/sibastdapi.sql.tar.gz & > /dev/null
/bin/rm /home/siba/exports/sibastdapi.sql.tar.gz
/bin/rm /home/siba/exports/sibastdapi.sql