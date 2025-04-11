import pandas as pd
import xml.etree.ElementTree as ET
import os
import sys
import re
from datetime import timedelta

regiones = [
    (1, 2999, 'Colombia / México', 0),
    (5000, 7999, 'Argentina', 5000),
    (8000, 9999, 'Colombia Triplicación', 8000),
    (3000, 4999, 'Panamá', 3000),
    (13000, 15999, 'Ecuador', 13000),
    (16000, 18999, 'Paraguay', 16000),
    (10000, 12999, 'Colombia', 10000),
    (19000, 21999, 'México', 19000),
    (22000, 24999, 'Perú', 22000),
    (25000, 27999, 'Chile', 25000),
    (28000, 30999, 'Uruguay', 28000),
    (31000, 33999, 'Costa Rica', 31000),
    (34000, 36999, 'Guatemala', 34000),
    (37000, 39999, 'Honduras', 37000),
    (40000, 42999, 'Nicaragua', 40000),
    (43000, 45999, 'El Salvador', 43000),
    (46000, 48999, 'República Dominicana', 46000),
]

def mostrar_clientes_disponibles():
    # Mostrar todos los clientes disponibles
    print("Clientes disponibles:")
    for _, _, nombre, _ in regiones:
        print(f"- {nombre}")
    print("- todos")

def obtener_region(numero):
    for inicio, fin, nombre, _ in regiones:
        if inicio <= numero <= fin:
            return nombre
    return None

def obtener_texto(element):
    return element.text if element is not None and element.text is not None else " "

def convert_amco_xml_to_csv(file_name, input_file_path, output_path=None):
    # Determinar la región y la diferencia horaria con la función de ejemplo

    df = pd.DataFrame()
    file_path = os.path.join(input_file_path, file_name)
    
    # Parseo del archivo XML
    tree = ET.parse(file_path)
    root = tree.getroot()

    
    # Extracción de eventos
    events = root[1][0].findall('Event')

    # Listas para almacenar los valores extraídos
    beginTime = []
    name = []
    description = []
    eventId = []
    actors = []
    director = []
    year = []
    country = []
    seriesID = []
    episodeID = []

    for event in events:
        beginTime.append(event.attrib['beginTime'])
        eventId.append(event[0].text)
        name.append(obtener_texto(event.find('EpgProduction')[0][0]))
        description.append(obtener_texto(event.find('EpgProduction')[0][2]))
        actors.append(obtener_texto(event.find('EpgProduction')[0][5]))
        director.append(obtener_texto(event.find('EpgProduction')[0][6]))
        year.append(obtener_texto(event.find('EpgProduction')[0][7]))
        country.append(obtener_texto(event.find('EpgProduction')[0][8]))
        seriesID.append(obtener_texto(event.find('EpgProduction')[0][11]))
        episodeID.append(obtener_texto(event.find('EpgProduction')[0][12]))

    # Crear un DataFrame con los datos
    data = {
        'Fecha y hora (UTC)': beginTime,
        'Título': name,
        'Sinopsis': description,
        'EventID': eventId,
        'Directores': director,
        'Actores': actors,
        'Año': year,
        'Pais': country,
        'SerieID': seriesID,
        'EpisodeID': episodeID
    }

    df = pd.DataFrame.from_dict(data)

    # Si no se proporciona una ruta de salida, usar la misma carpeta que el archivo de entrada
    if output_path is None:
        output_path = input_file_path

    # Obtener el nombre del archivo sin la extensión
    file_name_without_extension = file_name.split('.')[0]

    # Crear el nombre del archivo de salida (CSV)
    output_file_name = file_name_without_extension + '.csv'
    output_file_path = os.path.join(output_path, output_file_name)

    # Guardar el DataFrame en un archivo CSV con delimitador '|'
    df.to_csv(output_file_path, sep='|', index=False, encoding='utf-8')


def procesar_archivos(ruta, cliente,output_path=None):
    archivos = [f for f in os.listdir(ruta) if f.lower().endswith('.xml')]

    # Si el cliente es diferente de "todos" y no se encuentra en la lista de clientes disponibles, mostrar un mensaje y detener el proceso
    if cliente.lower() != "todos" and not any(region.lower() == cliente.lower() for _, _, region, _ in regiones):
        print(f"Cliente '{cliente}' no válido. Los clientes disponibles son:")
        mostrar_clientes_disponibles()
        return
    
    for archivo in archivos:
        # Extraemos el número del archivo usando regex
        numeros = re.findall(r'\d+', archivo)
        if not numeros:
            continue  # Si no tiene números, lo saltamos
        
        numero = int(numeros[0])
        region = obtener_region(numero)

        if region:
            if cliente.lower() == "todos" or region.lower() == cliente.lower():
                convert_amco_xml_to_csv(
                file_name=archivo,
                input_file_path=ruta,
                output_path = output_path)

if __name__ == "__main__":
    if len(sys.argv) < 3:
        print("Uso: python script.py <ruta_archivos> <cliente|todos> [ruta_salida]")
        mostrar_clientes_disponibles()
        sys.exit(1)

    ruta_archivos = sys.argv[1]
    cliente = sys.argv[2]
    output_path = sys.argv[3] if len(sys.argv) > 3 else None

    procesar_archivos(ruta_archivos, cliente, output_path)
