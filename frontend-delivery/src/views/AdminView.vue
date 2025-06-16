<template>
  <div class="admin-dashboard">
    <!-- Barra superior -->
    <div class="admin-header">
      <div class="header-left">
        <h1>Panel de Administración</h1>
        <p class="welcome-message">Bienvenido, Administrador</p>
      </div>
      <div class="header-right">
        <button class="refresh-btn" @click="fetchData">
          <i class="fas fa-sync-alt"></i> Actualizar
        </button>
        <span class="last-updated">Última actualización: {{ lastUpdated }}</span>
      </div>
    </div>
    <!-- Sección principal -->
    <div class="main-content">
      <!-- Consultas SQL -->
      <div class="card query-section">
        <div class="card-header">
          <h2>Consultas Analíticas</h2>
          <select v-model="selectedQuery" class="query-select">
            <option value="" disabled>Seleccione una consulta</option>
            <option value="1">Cliente que más ha gastado en pedidos entregados.</option>
            <option value="2">Productos más pedidos por categoría</option>
            <option value="3">Listar las empresas asociadas con más entregas fallidas.</option>
            <option value="4">Calcular el tiempo promedio entre pedido y entrega por repartidor.</option>
            <option value="5">Obtener los 3 repartidores con mejor rendimiento (basado en entregas y puntuación).</option>
            <option value="6">Obtener el medio de pago más usado en pedidos urgentes</option>
            <option value="7">[LAB 2] 5 puntos de entrega más cercanos a la empresa</option>
            <option value="8">[LAB 2] Punto de entrega más lejano desde cada empresa</option>
          </select>
          <input v-if="selectedQuery === '7'" v-model="empresaInput" placeholder="Nombre de la empresa" class="empresa-input" style="margin-left: 1rem; min-width: 200px;" />
          <button class="btn-run-query" @click="runQuery" :disabled="!selectedQuery || (selectedQuery === '7' && !empresaInput)">
            Ejecutar
          </button>
        </div>
        <div class="card-body">
          <div v-if="queryLoading" class="loading-indicator">
            <i class="fas fa-spinner fa-spin"></i> Procesando consulta...
          </div>
          <div v-else-if="queryResults" class="query-results">
            <div class="results-header">
              <h3>{{ queryTitle }}</h3>
            </div>
            <div class="table-responsive">
              <table class="results-table">
                <thead>
                  <tr>
                    <th v-for="(header, index) in queryHeaders" :key="index">{{ header }}</th>
                  </tr>
                </thead>
                <tbody>
                  <tr v-for="(row, rowIndex) in queryResults" :key="rowIndex">
                    <td v-for="(cell, cellIndex) in row" :key="cellIndex">{{ cell }}</td>
                  </tr>
                </tbody>
              </table>
            </div>
          </div>
          <div v-else class="empty-state">
            <i class="fas fa-chart-bar"></i>
            <p>Seleccione y ejecute una consulta para ver los resultados</p>
          </div>
        </div>
      </div>

      <!-- Vistas SQL como estadísticas clave -->
      <div class="card stats-section">
    <div class="card-header">
      <h2>Vistas SQL Clave</h2>
      <select v-model="selectedView" class="query-select" @change="loadView">
        <option value="" disabled>Seleccione una vista</option>
        <option value="13">Resumen de pedidos por cliente</option>
        <option value="14">Desempeño por repartidor</option>
        <option value="15">Empresas con mayor volumen</option>
      </select>
    </div>
    <div class="card-body">
      <div v-if="viewLoading" class="loading-indicator">
        <i class="fas fa-spinner fa-spin"></i> Cargando vista...
      </div>
      
      <!-- Caso específico para Desempeño por repartidor -->
      <RepartidorPerformanceTable v-else-if="selectedView === '14'" />
      <ClientSummary v-else-if="selectedView === '13'" />
      <TopCompany v-else-if="selectedView === '15'" />
      <!-- Otras vistas -->
      <div v-else-if="viewResults" class="query-results">
        <div class="results-header">
          <h3>{{ viewTitle }}</h3>
        </div>
        <div class="table-responsive">
          <table class="results-table">
            <thead>
              <tr>
                <th v-for="(header, index) in viewHeaders" :key="index">{{ header }}</th>
              </tr>
            </thead>
            <tbody>
              <tr v-for="(row, rowIndex) in viewResults" :key="rowIndex">
                <td v-for="(cell, cellIndex) in row" :key="cellIndex">{{ cell }}</td>
              </tr>
            </tbody>
          </table>
        </div>
      </div>
      <div v-else class="empty-state">
        <i class="fas fa-table"></i>
        <p>Seleccione una vista SQL para ver los resultados</p>
      </div>
    </div>
  </div>
    </div>
  </div>
</template>

<script>
import pagoService from '@/services/pagoService'; 
import detallePedidoService from '@/services/detallePedidoService'; 
import repartidorService from '@/services/repartidorService';
import clienteService from '@/services/clienteService';
import RepartidorPerformanceTable from '@/components/PerformanceDist.vue';
import ClientSummary from '@/components/ClientSummary.vue';
import TopCompany from '@/components/TopCompany.vue';
import orderService from '@/services/orderService';
import empresaService from '@/services/empresaService';


export default {
  name: 'AdminView',
  components: {
    RepartidorPerformanceTable,
    ClientSummary,
    TopCompany
  },
  data() {
    return {
      lastUpdated: new Date().toLocaleTimeString(),
      stats: {
        ordersToday: 42,
        ordersChange: 5.3,
        newCustomers: 8,
        pendingDeliveries: 15,
        reportedIssues: 3,
        issuesChange: -2.1
      },
      selectedQuery: '',
      queryLoading: false,
      queryResults: null,
      queryTitle: '',
      queryHeaders: [],
      selectedView: '',
      viewLoading: false,
      viewResults: null,
      viewTitle: '',
      viewHeaders: [],
      notifications: [
        {
          id: 1,
          type: 'warning',
          icon: 'fas fa-exclamation-circle',
          text: 'Pedido #1045 retrasado - Problema con el repartidor',
          time: 'Hace 15 min',
          read: false
        },
        {
          id: 2,
          type: 'success',
          icon: 'fas fa-check-circle',
          text: 'Nuevo registro de cliente premium',
          time: 'Hace 1 hora',
          read: true
        },
        {
          id: 3,
          type: 'info',
          icon: 'fas fa-info-circle',
          text: 'Actualización del sistema programada para hoy a las 23:00',
          time: 'Hace 3 horas',
          read: true
        }
      ],
      empresaInput: '',
    }
  },
  methods: {
    
    fetchData() {
      this.lastUpdated = new Date().toLocaleTimeString()
    },
    async runQuery() {
      this.queryLoading = true;
      this.queryResults = null;
      this.queryError = null;

      try {
        if (this.selectedQuery === '1') { // Cliente que más ha gastado
          const response = await clienteService.getClienteQueMasHaGastado();
          console.log('Respuesta del backend:', response.data);

          this.queryTitle = 'Cliente que más ha gastado';
          this.queryHeaders = ['Nombre', 'Email', 'Total Gastado'];

          // Maneja el Optional de Java (puede ser null)
          if (response.data) {
            this.queryResults = [[
              response.data.nombre,
              response.data.email,
              `$${response.data.totalGastado.toLocaleString('es-CL')}` // Formato chileno
            ]];
          } else {
            this.queryResults = [['No se encontraron datos', '', '']];
          }
        }

        else if (this.selectedQuery === '2') {
          const response = await detallePedidoService.getMasPedidosPorCategoria();
          console.log('Respuesta del backend:', response.data);

          this.queryTitle = 'Productos más pedidos por categoría';
          this.queryHeaders = ['Servicio', 'Categoría', 'Cantidad de pedidos'];

          this.queryResults = response.data.map(item => [
            item.servicio,
            item.categoria,
            item.cantidadPedidos
          ]);
        }

        else if (this.selectedQuery === '3') { 
          const response = await empresaService.getEmpresaConMasEntregasFallidas();
          console.log('Respuesta del backend:', response.data);

          this.queryTitle = 'Empresas con más entregas fallidas';
          this.queryHeaders = ['Empresa', 'Entregas Fallidas'];

          this.queryResults = response.data.map(item => [
            item.nombreempresa || 'Empresa no identificada',
            item.entregas_fallidas || 0
          ]);
          
          this.queryResults.sort((a, b) => b[1] - a[1]);
        }




        else if (this.selectedQuery === '4') { // Tiempo promedio por repartidor
          const response = await orderService.getTiempoPromedioEntregaPorRepartidor();
          console.log('Respuesta del backend:', response.data);

          this.queryTitle = 'Tiempo promedio de entrega por repartidor';
          this.queryHeaders = ['Repartidor', 'Tiempo Promedio'];

          // Función para formatear el tiempo (maneja valores negativos)
          const formatTime = (minutes) => {
            const absMinutes = Math.abs(minutes);
            const hours = Math.floor(absMinutes / 60);
            const mins = Math.floor(absMinutes % 60);
            return `${hours}h ${mins}m` + (minutes < 0 ? ' (valor negativo)' : '');
          };

          this.queryResults = response.data.map(item => [
            item.nombre_repartidor || 'Nombre no disponible',
            formatTime(item.tiempo_promedio_minutos)
          ]);
        }

        else if (this.selectedQuery === '5') { 
          const response = await repartidorService.getTop3Repartidores();
          console.log('Respuesta del backend:', response.data);

          this.queryTitle = 'Top 3 Repartidores por Rendimiento';
          this.queryHeaders = ['Nombre', 'Entregas Completadas', 'Puntuación Promedio', 'Rendimiento'];

          this.queryResults = response.data.map(item => [
            item.nombre, 
            item.entregasCompletadas,
            item.puntuacionPromedio.toFixed(2), 
            item.rendimiento.toFixed(2) 
          ]);
        }
        else if (this.selectedQuery === '6') {
          const { data } = await pagoService.getMedioPagoMasUsadoUrgentes();
          console.log('Respuesta del backend:', data);

          this.queryTitle = 'Medio de pago más usado en pedidos urgentes';
          this.queryHeaders = ['Medio de pago', 'Cantidad de veces usado'];

          this.queryResults = Array.isArray(data) ? data : [data];
          this.queryResults = this.queryResults.map(item => [
            item.nombremetododepago,
            item.cantidad
          ]);
        }
        else if (this.selectedQuery === '7') {
          const empresa = this.empresaInput.trim();
          const response = await detallePedidoService.getEntregasCercanas(empresa);
          console.log('Respuesta del backend:', response.data);

          this.queryTitle = `5 puntos de entrega más cercanos a la empresa "${empresa}"`;
          this.queryHeaders = ['Dirección', 'Distancia (km)', 'Latitud', 'Longitud'];

          this.queryResults = response.data.map(item => [
            item.direccion || 'No disponible',
            item.distancia?.toFixed(2) || '--',
            item.latitud || '--',
            item.longitud || '--'
          ]);
        }
        else if (this.selectedQuery === '8') {
          const response = await detallePedidoService.getPuntosEntregaMasLejano();
          console.log('Respuesta del backend:', response.data);

          this.queryTitle = 'Punto de entrega más lejano desde cada empresa';
          this.queryHeaders = ['Empresa', 'Dirección', 'Distancia (km)', 'Latitud', 'Longitud'];

          this.queryResults = response.data.map(item => [
            item.empresa || 'No disponible',
            item.direccion || 'No disponible',
            item.distancia?.toFixed(2) || '--',
            item.latitud || '--',
            item.longitud || '--'
          ]);
        }
      } catch (error) {
        console.error('Error al obtener los datos:', error);
        this.queryError = 'Hubo un problema al cargar los datos. Intenta de nuevo más tarde.';
      } finally {
        this.queryLoading = false;
      }
    },
    
    loadView() {
      if (this.selectedView === '14') {
        return;
      }
      if(this.selectedView === '13'){
        return;

      }
      if(this.selectedView === '15'){
        return;

      }
      this.viewLoading = true
      this.viewResults = null
      
      setTimeout(() => {
        switch(this.selectedView) {
          case '13':
            this.viewTitle = 'Resumen de pedidos por cliente'
            this.viewHeaders = ['Cliente', 'Total gastado', 'N° de pedidos', 'Último pedido']
            this.viewResults = [
              ['Ana Vargas', '$1,450,000', 18, '2023-05-15'],
              ['Luis Méndez', '$1,200,000', 15, '2023-05-14'],
              ['Carlota Ruiz', '$980,000', 12, '2023-05-10']
            ];
            break;
          case '14':
            this.viewTitle = 'Desempeño por repartidor'
            this.viewHeaders = ['Repartidor', 'Pedidos entregados', 'Retrasos']
            this.viewResults = [
              ['Juan Pérez', 50, 2],
              ['Carla Torres', 45, 1],
              ['Pedro López', 60, 0]
            ];
            break;
          case '15':
            this.viewTitle = 'Empresas con mayor volumen'
            this.viewHeaders = ['Empresa', 'Volumen total', 'Pedidos procesados']
            this.viewResults = [
              ['Empresa A', '$5,000,000', 100],
              ['Empresa B', '$4,200,000', 95],
              ['Empresa C', '$3,600,000', 90]
            ];
            break;
        }
        this.viewLoading = false
      }, 1000)
    },
    dismissNotification(id) {
      this.notifications = this.notifications.filter(notification => notification.id !== id);
    },  
  }
}
</script>

<style scoped>
.admin-dashboard {
  background-color: var(--bg-primary);
  min-height: 100vh;
  padding: 2rem;
}

.admin-header {
  background: linear-gradient(135deg, var(--bg-secondary) 0%, var(--card-bg) 100%);
  border-radius: 16px;
  border: 1px solid var(--border-blue);
  padding: 2rem;
  margin-bottom: 2rem;
  display: flex;
  justify-content: space-between;
  align-items: center;
  position: relative;
  overflow: hidden;
}

.admin-header::before {
  content: '';
  position: absolute;
  top: 0;
  left: 0;
  right: 0;
  height: 1px;
  background: linear-gradient(90deg, transparent, var(--blue-neon), transparent);
}

.header-left h1 {
  font-size: 2rem;
  margin-bottom: 0.5rem;
  background: linear-gradient(45deg, var(--text-primary), var(--blue-neon));
  -webkit-background-clip: text;
  -webkit-text-fill-color: transparent;
}

.welcome-message {
  color: var(--text-secondary);
  font-size: 1.1rem;
}

.header-right {
  display: flex;
  align-items: center;
  gap: 1rem;
}

.refresh-btn {
  background-color: var(--primary-blue);
  color: var(--text-primary);
  border: none;
  padding: 0.75rem 1.5rem;
  border-radius: 8px;
  cursor: pointer;
  display: flex;
  align-items: center;
  gap: 0.5rem;
  transition: all 0.3s ease;
}

.refresh-btn:hover {
  background-color: var(--primary-blue-hover);
  transform: translateY(-2px);
}

.last-updated {
  color: var(--text-secondary);
  font-size: 0.875rem;
}

.main-content {
  display: grid;
  gap: 2rem;
}

.card {
  background-color: var(--card-bg);
  border-radius: 12px;
  border: 1px solid var(--border-blue);
  padding: 1.5rem;
}

.card-header {
  display: flex;
  justify-content: space-between;
  align-items: center;
  margin-bottom: 1.5rem;
}

.card-header h2 {
  font-size: 1.25rem;
  color: var(--text-primary);
}

.query-section {
  display: flex;
  flex-direction: column;
  gap: 1rem;
}

.query-select {
  background-color: var(--bg-secondary);
  border: 1px solid var(--border-blue);
  color: var(--text-primary);
  padding: 0.75rem 1rem;
  border-radius: 8px;
  width: 100%;
  max-width: 500px;
}

.empresa-input {
  background-color: var(--bg-secondary);
  border: 1px solid var(--border-blue);
  color: var(--text-primary);
  padding: 0.75rem 1rem;
  border-radius: 8px;
}

@media (max-width: 768px) {
  .admin-dashboard {
    padding: 1rem;
  }

  .admin-header {
    flex-direction: column;
    text-align: center;
    gap: 1rem;
    padding: 1.5rem;
  }

  .header-right {
    flex-direction: column;
    width: 100%;
  }

  .refresh-btn {
    width: 100%;
    justify-content: center;
  }
}

.loading-indicator {
  display: flex;
  align-items: center;
  justify-content: center;
  padding: 40px;
  color: var(--text-secondary);
  gap: 10px;
}

.empty-state {
  text-align: center;
  padding: 40px;
  color: var(--text-secondary);
}

.empty-state i {
  font-size: 40px;
  margin-bottom: 15px;
}

.empty-state p {
  margin: 0;
  font-size: 14px;
}

.results-header {
  margin-bottom: 15px;
}

.results-header h3 {
  margin: 0;
  font-size: 16px;
  color: var(--text-primary);
}

.table-responsive {
  overflow-x: auto;
  border-radius: 6px;
  border: 1px solid var(--border-blue);
}

.results-table {
  width: 100%;
  border-collapse: collapse;
}

.results-table th, .results-table td {
  padding: 12px 15px;
  text-align: left;
  border-bottom: 1px solid var(--border-blue);
}

.results-table th {
  background: var(--bg-secondary);
  font-weight: 600;
  color: var(--primary-blue);
}

.results-table tr:hover td {
  background: var(--bg-primary);
}

.results-table tr:last-child td {
  border-bottom: none;
}

.stats-grid {
  display: grid;
  grid-template-columns: repeat(auto-fit, minmax(250px, 1fr));
  gap: 1.5rem;
  margin-bottom: 2rem;
}

.stat-card {
  background-color: var(--card-bg);
  padding: 1.5rem;
  border-radius: 8px;
  border: 1px solid var(--border-blue);
  box-shadow: 0 4px 6px var(--blue-glow);
}

.stat-title {
  color: var(--text-secondary);
  font-size: 0.875rem;
  margin-bottom: 0.5rem;
}

.stat-value {
  color: var(--text-primary);
  font-size: 1.5rem;
  font-weight: bold;
}

.data-table {
  background-color: var(--bg-secondary);
  border-radius: 8px;
  overflow: hidden;
  border: 1px solid var(--border-blue);
}

.table-header {
  background-color: var(--dark-gray);
  color: var(--text-primary);
  padding: 1rem;
}

.table-row {
  border-bottom: 1px solid var(--border-blue);
  transition: background-color 0.3s;
}

.table-row:hover {
  background-color: var(--bg-secondary);
}

.table-cell {
  padding: 1rem;
  color: var(--text-secondary);
}

.action-button {
  background-color: var(--primary-blue);
  color: var(--text-primary);
  padding: 0.5rem 1rem;
  border: none;
  border-radius: 4px;
  cursor: pointer;
  transition: background-color 0.3s;
}

.action-button:hover {
  background-color: var(--primary-blue-hover);
}

.filter-section {
  background-color: var(--card-bg);
  padding: 1.5rem;
  border-radius: 8px;
  margin-bottom: 2rem;
  border: 1px solid var(--border-blue);
}

.search-input {
  background-color: var(--bg-secondary);
  border: 1px solid var(--border-blue);
  color: var(--text-primary);
  padding: 0.5rem 1rem;
  border-radius: 4px;
}

.search-input::placeholder {
  color: var(--placeholder-color);
}
</style>