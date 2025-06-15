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
SELECT
    r.repartidor_id,
    r.nombre,
    SUM(ST_Distance(dp.ubicacionInicio::geography, dp.ubicacionDestino::geography)) AS distancia_total_metros
FROM
    repartidor r
        JOIN
    orderentity o ON o.repartidor_id = r.repartidor_id
        JOIN
    detallepedido dp ON dp.idpedido = o.idpedido
WHERE
    o.fechaentrega >= NOW() - INTERVAL '1 month'
  AND dp.ubicacionInicio IS NOT NULL
  AND dp.ubicacionDestino IS NOT NULL
GROUP BY
    r.repartidor_id, r.nombre;


-- consulta numero 4

