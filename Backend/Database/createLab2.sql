-- Activar extensión PostGIS
CREATE EXTENSION IF NOT EXISTS postgis;

------------------------------
-- Crear tablas con campos geoespaciales
------------------------------

-- Tabla usuarios (se añade campo ubicación)
CREATE TABLE usuarios (
    id_usuario SERIAL PRIMARY KEY,
    rut VARCHAR(12) NOT NULL,
    name_param VARCHAR(100) NOT NULL,
    email VARCHAR(100) NOT NULL UNIQUE,
    phone VARCHAR(15),
    birthdate DATE NOT NULL,
    password VARCHAR(255) NOT NULL,
    role VARCHAR(50) NOT NULL,
    ubicacion GEOMETRY(Point, 4326)  -- ubicación del usuario
);

-- Tabla cliente (se añade campo ubicación)
CREATE TABLE cliente (
    cliente_id SERIAL PRIMARY KEY,
    nombre VARCHAR(100) NOT NULL,
    direccion TEXT DEFAULT 'Sin dirección',
    email VARCHAR(100) UNIQUE NOT NULL,
    telefono VARCHAR(20) NOT NULL,
    ubicacion GEOMETRY(Point, 4326)  -- ubicación del cliente
);

-- Tabla repartidor (se añade campo ubicación_actual)
CREATE TABLE repartidor (
    repartidor_id SERIAL PRIMARY KEY,
    nombre VARCHAR(100) NOT NULL,
    telefono VARCHAR(20) NOT NULL,
    disponible BOOLEAN DEFAULT TRUE,
    ubicacion_actual GEOMETRY(Point, 4326)  -- ubicación actual del repartidor
);

-- Tabla EmpresaAsociada (se añade campo ubicación)
CREATE TABLE EmpresaAsociada (
    idEmpresaAsociada SERIAL PRIMARY KEY,
    nombreEmpresa VARCHAR(255),
    direccionEmpresa VARCHAR(255),
    tipoServicio VARCHAR(100),
    ubicacion GEOMETRY(Point, 4326)  -- ubicación de la empresa
);

-- Tabla OrderEntity (se añade campo ruta_estimada)
CREATE TABLE OrderEntity (
    idPedido SERIAL PRIMARY KEY,
    cliente_id INT REFERENCES cliente(cliente_id) ON DELETE CASCADE,
    idEmpresaAsociada INT REFERENCES EmpresaAsociada(idEmpresaAsociada),
    repartidor_id INT REFERENCES repartidor(repartidor_id),
    fechaPedido TIMESTAMP,
    fechaEntrega TIMESTAMP,
    estadoPedido VARCHAR(50),
    prioridadPedido VARCHAR(50),
    ruta_estimada GEOMETRY(LineString, 4326)  -- ruta estimada
);

-- Tabla DetallePedido (se añaden campos ubicacionInicio y ubicacionDestino)
CREATE TABLE DetallePedido (
    idDetallePedido SERIAL PRIMARY KEY,
    idPedido INT REFERENCES OrderEntity(idPedido) ON DELETE CASCADE,
    idServicio INT,
    cantidad INT,
    direccionDestino VARCHAR(255),
    direccionInicio VARCHAR(255),
    ubicacionInicio GEOMETRY(Point, 4326),   -- ubicación de inicio
    ubicacionDestino GEOMETRY(Point, 4326)     -- ubicación destino
);

-- Tabla Servicios 
CREATE TABLE Servicios (
    idServicio SERIAL PRIMARY KEY,
    idEmpresaAsociada INT REFERENCES EmpresaAsociada(idEmpresaAsociada) ON DELETE SET NULL,
    nombreServicio VARCHAR(255),
    descripcionServicio TEXT,
    precioServicio INT,
    categoriaServicio VARCHAR(100),
    stock INT
);

-- Tabla MedioDePago
CREATE TABLE MedioDePago (
    idMetodoDePago SERIAL PRIMARY KEY,
    nombreMetodoDePago VARCHAR(100)
);

-- Tabla Pago
CREATE TABLE Pago (
    idPago SERIAL PRIMARY KEY,
    idPedido INT REFERENCES OrderEntity(idPedido) ON DELETE CASCADE,
    idMedioDePago INT REFERENCES MedioDePago(idMetodoDePago),
    monto DECIMAL(10,2)
);

-- Tabla Rating
CREATE TABLE Rating (
    idCalificacion SERIAL PRIMARY KEY,
    idPedido INT REFERENCES OrderEntity(idPedido) ON DELETE CASCADE,
    score INT CHECK (score BETWEEN 1 AND 5),
    comment TEXT
);

-- Tabla zonas de cobertura (agregamos zonas para el manejo espacial)
CREATE TABLE zonas_cobertura (
    zona_id SERIAL PRIMARY KEY,
    nombre VARCHAR(100),
    geom GEOMETRY(MultiPolygon, 4326)
);