-- Consulta 1 para obtener los 5 puntos de entrega más cercanos a la empresa "Express Chile"
SELECT 
    dp.idDetallePedido,
    ea.nombreEmpresa,
    dp.direccionDestino,
    ROUND(ST_Distance(ea.ubicacion::geography, dp.ubicacionDestino::geography)) AS distancia_metros,
    ST_MakeLine(ea.ubicacion, dp.ubicacionDestino) AS ruta_estimada
FROM 
    detallepedido dp
JOIN 
    servicios s ON dp.idServicio = s.idServicio
JOIN 
    empresaasociada ea ON s.idEmpresaAsociada = ea.idEmpresaAsociada
WHERE 
    ea.nombreEmpresa ILIKE '%Express Chile%'  
ORDER BY 
    distancia_metros
LIMIT 5;



-- Consulta 2 para verificar si un cliente está dentro de una zona de cobertura usando ST_Buffer
SELECT 
    c.cliente_id,
    c.nombre,
    z.zona_id,
    z.nombre AS nombre_zona
FROM 
    cliente c
JOIN 
    zonas_cobertura z
ON 
    ST_Intersects(
        ST_Buffer(c.ubicacion::geography, 1000)::geometry,  -- Buffer de 1000 metros alrededor del cliente
        z.geom
    );




-- consulta numero 3
SELECT EmpresaAsociada.nombreEmpresa, COUNT(*) AS entregas_fallidas  -- Selecciona el nombre de la empresa y cuenta cuántos pedidos fallidos tiene
FROM OrderEntity                                                     -- Desde la tabla de pedidos (OrderEntity)
JOIN EmpresaAsociada                                                 -- Une con la tabla EmpresaAsociada usando la clave foránea que vincula cada pedido con su empresa
  ON OrderEntity.idEmpresaAsociada = EmpresaAsociada.idEmpresaAsociada
WHERE OrderEntity.estadoPedido ILIKE 'Fallido'                       -- Filtra solo los pedidos cuyo estado sea 'Fallido'
GROUP BY EmpresaAsociada.nombreEmpresa                               -- Agrupa los resultados por nombre de empresa
ORDER BY entregas_fallidas DESC;                                     -- Ordena de mayor a menor según la cantidad de fallos



-- consulta numero 4
SELECT repartidor.nombre AS nombre_repartidor,                       -- Selecciona el nombre del repartidor
       ROUND(                                                        -- Redondea el resultado del promedio a un número entero
         AVG(                                                        -- Calcula el promedio de:
           EXTRACT(EPOCH FROM (OrderEntity.fechaEntrega - OrderEntity.fechaPedido)) / 60  -- Extrae la diferencia de tiempo entre la fecha de entrega y la de pedido en segundos, y lo convierte a minutos
         )
       ) AS tiempo_promedio_minutos
FROM OrderEntity                                                     -- Desde la tabla de pedidos
JOIN repartidor                                                      -- Une con la tabla Repartidor usando la clave foránea correspondiente
  ON OrderEntity.repartidor_id = repartidor.repartidor_id
WHERE OrderEntity.fechaEntrega IS NOT NULL                           -- Asegura que ambos timestamps existan (evita errores por NULL)
  AND OrderEntity.fechaPedido IS NOT NULL
GROUP BY repartidor.nombre
ORDER BY tiempo_promedio_minutos;
