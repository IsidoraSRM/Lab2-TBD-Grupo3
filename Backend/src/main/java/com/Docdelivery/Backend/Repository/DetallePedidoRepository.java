package com.Docdelivery.Backend.Repository;

import com.Docdelivery.Backend.Entity.DetallePedidoEntity;
import com.Docdelivery.Backend.dto.ServiciosDto;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.jdbc.core.JdbcTemplate;
import org.springframework.jdbc.core.RowMapper;
import org.springframework.stereotype.Repository;

import java.sql.ResultSet;
import java.sql.SQLException;
import java.util.List;
import java.util.Map;
import java.util.Collections;

@Repository
public class DetallePedidoRepository {

    @Autowired
    private JdbcTemplate jdbcTemplate;

    private static class DetallePedidoRowMapper implements RowMapper<DetallePedidoEntity> {
        @Override
        public DetallePedidoEntity mapRow(ResultSet rs, int rowNum) throws SQLException {
            return new DetallePedidoEntity(
                    rs.getLong("idDetallePedido"),
                    rs.getLong("idPedido"),
                    rs.getLong("idServicio"),
                    rs.getInt("cantidad"),
                    rs.getString("direccionDestino"),
                    rs.getString("direccionInicio"),
                    rs.getObject("ubicacion", org.locationtech.jts.geom.Point.class)
            );
        }
    }

    // Guardar detalle de pedido
    public void save(DetallePedidoEntity detalle) {
        String sql = "INSERT INTO DetallePedido (idPedido, idServicio, cantidad,direccionDestino,direccionInicio) VALUES (?, ?, ?,?,?)";
        jdbcTemplate.update(sql, detalle.getIdPedido(), detalle.getIdServicio(), detalle.getCantidad());
    }

    // Read
    public List<DetallePedidoEntity> findAll() {
        String sql = "SELECT * FROM DetallePedido";
        return jdbcTemplate.query(sql, new DetallePedidoRowMapper());
    }

    // Update
    public void update(DetallePedidoEntity detalle) {
        String sql = "UPDATE DetallePedido SET cantidad = ? WHERE idDetallePedido = ?";
        jdbcTemplate.update(sql, detalle.getCantidad(), detalle.getIdDetallePedido());
    }

    // Delete
    public boolean deleteById(Long id) {
        String sql = "DELETE FROM DetallePedido WHERE idDetallePedido = ?";
        int rowsAffected = jdbcTemplate.update(sql, id);
        return rowsAffected > 0;
    }


    // Obtener detalles por ID de pedido
    public List<DetallePedidoEntity> findByPedidoId(Long idPedido) {
        String sql = "SELECT * FROM DetallePedido WHERE idPedido = ?";
        return jdbcTemplate.query(sql, new DetallePedidoRowMapper(), idPedido);
    }

    public List<ServiciosDto> getServiciosMasPedidosUltimoMes() {
        String sql = """
        SELECT s.nombreServicio AS servicio, s.categoriaServicio AS categoria, COUNT(dp.idDetallePedido) AS cantidad_pedidos
        FROM DetallePedido dp
        JOIN Servicios s ON dp.idServicio = s.idServicio
        JOIN OrderEntity o ON dp.idPedido = o.idPedido
        WHERE o.fechaPedido >= NOW() - INTERVAL '1 MONTH'
        GROUP BY s.nombreServicio, s.categoriaServicio
        ORDER BY cantidad_pedidos DESC
    """;

        return jdbcTemplate.query(sql, (rs, rowNum) -> new ServiciosDto(
                rs.getString("servicio"),
                rs.getString("categoria"),
                rs.getInt("cantidad_pedidos")
        ));
    }


    // Consulta 4: Identificar el punto de entrega más lejano desde cada empresa asociada.
    public List<Map<String, Object>> getPuntosEntregaMasLejano() {
        String sql = """
        SELECT 
            e.nombreEmpresa, 
            d.direccionDestino,
            ST_Distance(
                ST_Transform(e.ubicacion, 3857),
                ST_Transform(d.ubicacionDestino, 3857)
            ) / 1000 AS distancia_km
        FROM DetallePedido d
        JOIN OrderEntity o ON d.idPedido = o.idPedido
        JOIN EmpresaAsociada e ON o.idEmpresaAsociada = e.idEmpresaAsociada
        WHERE ST_Distance(
            ST_Transform(e.ubicacion, 3857),
            ST_Transform(d.ubicacion, 3857)
        ) = (
            SELECT MAX(ST_Distance(
                ST_Transform(e2.ubicacion, 3857),
                ST_Transform(d2.ubicacion, 3857)
            ))
            FROM DetallePedido d2
            JOIN OrderEntity o2 ON d2.idPedido = o2.idPedido
            JOIN EmpresaAsociada e2 ON o2.idEmpresaAsociada = e2.idEmpresaAsociada
            WHERE e2.idEmpresaAsociada = e.idEmpresaAsociada
        )
        ORDER BY distancia_km DESC
    """;
    try {
        return jdbcTemplate.queryForList(sql);
    } catch (Exception e) {
        e.printStackTrace();
        return Collections.emptyList();
    }
}
    
}