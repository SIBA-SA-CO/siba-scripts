# -*- coding: utf-8 -*-
import os
import time
import sys
import re
from datetime import datetime

folder_path = sys.argv[1]
output_file = sys.argv[2]
cliente = "[" + str(sys.argv[3]) + "]"
extension = sys.argv[4]

# Obtener la fecha actual en formato YYYYMMDD
today_str = datetime.now().strftime("%Y%m%d")

# Obtener la lista de archivos en la carpeta
file_list = os.listdir(folder_path)

# Filtrar los archivos que terminan en la extensión dada y contienen la fecha actual (SIBA_YYYYMMDD)
filtered_files = [
    file for file in file_list
    if file.endswith(extension) and f"SIBA_{today_str}" in file
]

# Ordenar los archivos por fecha de modificación
filtered_files.sort(key=lambda x: os.path.getmtime(os.path.join(folder_path, x)))

# Verificar si el archivo de registro ya existe
if os.path.exists(output_file):
    with open(output_file, 'r') as infile:
        existing_logs = infile.readlines()
else:
    existing_logs = []

# Limpiar registros existentes
existing_logs = [log.strip() for log in existing_logs]

# Procesar archivos y recolectar nuevas entradas
new_entries = []
for file_name in filtered_files:
    file_path = os.path.join(folder_path, file_name)
    error_content = ''
    channelId = ''

    # Procesar archivos según extensión
    if extension in [".errorlog", ".error"]:
        with open(file_path, 'r', encoding='utf-8') as error_file:
            error_content = error_file.read().replace('\n', ' ').replace("'", '"')

        file_timestamp = os.path.getmtime(file_path)
        file_date = time.ctime(file_timestamp)

        registro = f"{file_date} {cliente} {file_name} {error_content}"
        if registro.strip() not in existing_logs:
            new_entries.append(registro)

    elif extension == ".failed":
        with open(file_path, 'r', encoding='utf-8') as channelId_file:
            chanelid_content = channelId_file.read()

        match = re.search(r'<ChannelId>(.*?)</ChannelId>', chanelid_content)
        if match:
            channelId = match.group(1)

        file_timestamp = os.path.getmtime(file_path)
        file_date = time.ctime(file_timestamp)

        registro = f"{file_date} {cliente} {file_name}: {channelId}"
        if registro.strip() not in existing_logs:
            new_entries.append(registro)

# Escribir nuevas entradas en modo append (añadir al final)
if new_entries:
    with open(output_file, 'a', encoding='utf-8') as outfile:
        for entry in new_entries:
            outfile.write(entry + '\n')
