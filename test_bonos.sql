-- Test data setup
USE nomina_proyectofinalbd;

-- Insert test employee
INSERT INTO empleados (id_empleado, nombre, apellido, departamento, salario_base) VALUES
(1, 'Juan', 'Pérez', 'Ventas', 5000.00);

-- Insert test goals
INSERT INTO metas (id_meta, id_empleado, descripcion, fecha_inicio, fecha_fin, estado) VALUES
(1, 1, 'Meta de ventas Q1', '2024-01-01', '2024-03-31', 'Completada'),
(2, 1, 'Meta de ventas Q2', '2024-01-01', '2024-03-31', 'Completada'),
(3, 1, 'Meta de ventas Q3', '2024-01-01', '2024-03-31', 'Pendiente');

-- Test 1: Calcular bono por metas
CALL calcular_bono_metas(1, 1000.00, '2024-01-01', '2024-03-31');

-- Test 2: Calcular bono por ventas
CALL calcular_bono_ventas(1, 50000.00, 2.5);

-- Test 3: Calcular bono por asistencia
CALL calcular_bono_asistencia(1, 500.00, 0);

-- Test 4: Calcular base de cotización
SELECT calcular_base_cotizacion(1, '2024-01-01', '2024-03-31') AS base_cotizacion;

-- Verificar resultados en la vista de reporte
SELECT * FROM v_reporte_bonos WHERE id_empleado = 1;

-- Limpiar datos de prueba
DELETE FROM bonos WHERE id_empleado = 1;
DELETE FROM metas WHERE id_empleado = 1;
DELETE FROM empleados WHERE id_empleado = 1; 