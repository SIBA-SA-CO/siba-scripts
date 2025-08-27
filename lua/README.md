
# Eliminación de Claves Redis por Rango de Fechas

Este repositorio incluye un script Lua que permite eliminar claves en Redis que contienen una fecha en su nombre, dentro de un rango de fechas especificado.

## 1. ¿Qué hace el script?

El archivo `delete_by_date_range.lua` realiza lo siguiente:

1. Escanea todas las claves de Redis usando el comando `SCAN`.
2. Busca claves que contengan fechas dentro del rango definido (`YYYY-MM-DD`).
3. Elimina todas las claves encontradas que cumplan con este criterio.
4. Devuelve la cantidad total de claves eliminadas.


## 2. Ejecución dentro de un contenedor Docker

### 2.1 Copiar el script al contenedor
```bash
docker cp delete_by_date_range.lua redis:/data/delete_by_date_range.lua
```

### 2.2 Acceder al contenedor y ejecutar el script
```bash
docker exec -i redis redis-cli   -u redis://admin:admin@localhost:6379   --eval /data/delete_by_date_range.lua , 2020-01-05 2020-01-07
```

- `2020-01-05` → Fecha de inicio del rango.
- `2020-01-07` → Fecha de fin del rango.
- El resultado será la cantidad de claves eliminadas.

## 3. Ejecución dentro del contenedor
```bash
redis-cli -u redis://admin:admin@127.0.0.1:6379   --eval ./delete_by_date_range.lua , 2020-01-05 2020-01-07
```

## 4. Notas importantes
- El script busca fechas en formato `YYYY-MM-DD` dentro de los nombres de las claves.
- El parámetro `COUNT 1000` en el comando `SCAN` determina cuántas claves procesa por iteración. Puedes ajustarlo según el tamaño de tu base de datos.
- El borrado es irreversible; asegúrate de ejecutar este script en un entorno controlado o tener un respaldo.

## 5. Ejemplo de salida
```bash
3
```
Esto significa que se eliminaron **3 claves** que contenían fechas entre `2020-01-05` y `2020-01-07`.
