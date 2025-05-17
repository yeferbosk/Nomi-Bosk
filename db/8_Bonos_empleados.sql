-- Procedimiento para calcular bono por cumplimiento de metas
DELIMITER //
CREATE PROCEDURE calcular_bono_metas(
    IN p_id_empleado INT,
    IN p_valor_bono_maximo DECIMAL(10,2),
    IN p_fecha_inicio DATE,
    IN p_fecha_fin DATE
)
BEGIN
    DECLARE v_porcentaje_cumplimiento DECIMAL(5,2);
    DECLARE v_valor_bono DECIMAL(10,2);

    -- Calcular porcentaje de cumplimiento
    SELECT
        (COUNT(CASE WHEN estado = 'Completada' THEN 1 END) * 100.0 / COUNT(*))
    INTO v_porcentaje_cumplimiento
    FROM metas
    WHERE id_empleado = p_id_empleado
    AND fecha_inicio >= p_fecha_inicio
    AND fecha_fin <= p_fecha_fin;

    -- Calcular valor del bono
    SET v_valor_bono = (v_porcentaje_cumplimiento / 100) * p_valor_bono_maximo;

    -- Insertar el bono
    INSERT INTO bonos (id_empleado, id_tipo_bono, fecha_bono, valor_bono, porcentaje_cumplimiento)
    VALUES (p_id_empleado, 1, CURDATE(), v_valor_bono, v_porcentaje_cumplimiento);

    SELECT v_valor_bono AS bono_calculado, v_porcentaje_cumplimiento AS porcentaje_cumplimiento;
END //
DELIMITER ;

-- Procedimiento para calcular bono por ventas
DELIMITER //
CREATE PROCEDURE calcular_bono_ventas(
    IN p_id_empleado INT,
    IN p_ventas_mes DECIMAL(10,2),
    IN p_porcentaje_comision DECIMAL(5,2)
)
BEGIN
    DECLARE v_valor_bono DECIMAL(10,2);

    -- Calcular bono por ventas
    SET v_valor_bono = p_ventas_mes * (p_porcentaje_comision / 100);

    -- Insertar el bono
    INSERT INTO bonos (id_empleado, id_tipo_bono, fecha_bono, valor_bono)
    VALUES (p_id_empleado, 3, CURDATE(), v_valor_bono);

    SELECT v_valor_bono AS bono_calculado;
END //
DELIMITER ;

-- Procedimiento para calcular bono por asistencia
DELIMITER //
CREATE PROCEDURE calcular_bono_asistencia(
    IN p_id_empleado INT,
    IN p_valor_bono DECIMAL(10,2),
    IN p_ausencias INT
)
BEGIN
    DECLARE v_valor_bono_final DECIMAL(10,2);

    -- Si no hay ausencias, otorgar el bono completo
    IF p_ausencias = 0 THEN
        SET v_valor_bono_final = p_valor_bono;
    ELSE
        SET v_valor_bono_final = 0;
    END IF;

    -- Insertar el bono
    INSERT INTO bonos (id_empleado, id_tipo_bono, fecha_bono, valor_bono)
    VALUES (p_id_empleado, 4, CURDATE(), v_valor_bono_final);

    SELECT v_valor_bono_final AS bono_calculado;
END //
DELIMITER ;

-- Función para calcular base de cotización
DELIMITER //
CREATE FUNCTION calcular_base_cotizacion(
    p_id_empleado INT,
    p_fecha_inicio DATE,
    p_fecha_fin DATE
) RETURNS DECIMAL(10,2)
DETERMINISTIC
BEGIN
    DECLARE v_salario_base DECIMAL(10,2);
    DECLARE v_total_bonos DECIMAL(10,2);

    -- Obtener salario base
    SELECT salario_base INTO v_salario_base
    FROM empleados
    WHERE id_empleado = p_id_empleado;

    -- Obtener suma de bonos constitutivos de salario
    SELECT COALESCE(SUM(valor_bono), 0) INTO v_total_bonos
    FROM bonos b
    JOIN tipos_bonos tb ON b.id_tipo_bono = tb.id_tipo_bono
    WHERE b.id_empleado = p_id_empleado
    AND b.fecha_bono BETWEEN p_fecha_inicio AND p_fecha_fin
    AND tb.es_constitutivo_salario = TRUE;

    RETURN v_salario_base + v_total_bonos;
END //
DELIMITER ;

-- Insertar tipos de bonos básicos
INSERT INTO tipos_bonos (nombre, descripcion, es_constitutivo_salario) VALUES
('Bono por Metas', 'Bono variable basado en el cumplimiento de objetivos', TRUE),
('Bono Fijo', 'Bono de reconocimiento o fidelización', TRUE),
('Bono por Ventas', 'Comisión sobre ventas realizadas', TRUE),
('Bono por Asistencia', 'Bono por mantener asistencia perfecta', TRUE);

-- Vista para reporte de bonos
CREATE VIEW v_reporte_bonos AS
SELECT
    e.id_empleado,
    CONCAT(e.nombre, ' ', e.apellido) AS nombre_completo,
    e.departamento,
    tb.nombre AS tipo_bono,
    b.fecha_bono,
    b.valor_bono,
    b.porcentaje_cumplimiento,
    tb.es_constitutivo_salario
FROM bonos b
JOIN empleados e ON b.id_empleado = e.id_empleado
JOIN tipos_bonos tb ON b.id_tipo_bono = tb.id_tipo_bono;