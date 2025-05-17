CREATE OR REPLACE VIEW vista_nomina_vacacional AS
SELECT
    e.id_empleado,
    e.nombre,
    c.salario_bruto AS salario_base,
    v.fecha_inicio AS fecha_inicio_vacaciones,
    v.fecha_fin AS fecha_fin_vacaciones,
    v.dias_vacaciones,
    -- Cálculo de días laborados desde la última vacación (o ingreso si es la primera)
    DATEDIFF(v.fecha_inicio,
        IFNULL(
            (SELECT MAX(v2.fecha_fin) FROM Vacaciones v2 WHERE v2.id_empleado = e.id_empleado AND v2.fecha_fin < v.fecha_inicio),
            e.fecha_ingreso
        )
    ) AS dias_laborados,
    -- Cálculo del pago por vacaciones según la fórmula colombiana
    ROUND((c.salario_bruto *
        DATEDIFF(v.fecha_inicio,
            IFNULL(
                (SELECT MAX(v2.fecha_fin) FROM Vacaciones v2 WHERE v2.id_empleado = e.id_empleado AND v2.fecha_fin < v.fecha_inicio),
                e.fecha_ingreso
            )
        )
    ) / 720, 2) AS pago_vacaciones,
    -- Nómina total del mes de vacaciones
    ROUND(c.salario_bruto +
        ((c.salario_bruto *
            DATEDIFF(v.fecha_inicio,
                IFNULL(
                    (SELECT MAX(v2.fecha_fin) FROM Vacaciones v2 WHERE v2.id_empleado = e.id_empleado AND v2.fecha_fin < v.fecha_inicio),
                    e.fecha_ingreso
                )
            )
        ) / 720), 2) AS nomina_total_mes_vacacional
FROM Empleado e
JOIN Contrato c ON e.id_empleado = c.id_empleado AND c.fecha_fin IS NULL
JOIN Vacaciones v ON e.id_empleado = v.id_empleado
ORDER BY e.id_empleado, v.fecha_inicio;

-- ===========================================
-- PROCEDIMIENTO PARA CALCULAR Y REGISTRAR NÓMINA VACACIONAL DE UN EMPLEADO
-- ===========================================
DELIMITER $$

CREATE PROCEDURE CalcularNominaVacacional(
    IN p_id_empleado INT
)
BEGIN
    DECLARE v_salario_base DECIMAL(10,2);
    DECLARE v_fecha_inicio_vac DATE;
    DECLARE v_fecha_fin_vac DATE;
    DECLARE v_ultima_fecha_vac DATE;
    DECLARE v_fecha_ingreso DATE;
    DECLARE v_dias_laborados INT;
    DECLARE v_pago_vacaciones DECIMAL(10,2);
    DECLARE v_nomina_total DECIMAL(10,2);

    -- Obtener salario base y fechas de vacaciones más recientes
    SELECT c.salario_bruto, v.fecha_inicio, v.fecha_fin, e.fecha_ingreso
    INTO v_salario_base, v_fecha_inicio_vac, v_fecha_fin_vac, v_fecha_ingreso
    FROM Empleado e
    JOIN Contrato c ON e.id_empleado = c.id_empleado AND c.fecha_fin IS NULL
    JOIN Vacaciones v ON e.id_empleado = v.id_empleado
    WHERE e.id_empleado = p_id_empleado
    ORDER BY v.fecha_inicio DESC
    LIMIT 1;

    -- Buscar la última fecha de vacaciones anterior
    SELECT MAX(v2.fecha_fin)
    INTO v_ultima_fecha_vac
    FROM Vacaciones v2
    WHERE v2.id_empleado = p_id_empleado AND v2.fecha_fin < v_fecha_inicio_vac;

    -- Calcular días laborados desde la última vacación (o ingreso si es la primera)
    IF v_ultima_fecha_vac IS NULL THEN
        SET v_dias_laborados = DATEDIFF(v_fecha_inicio_vac, v_fecha_ingreso);
    ELSE
        SET v_dias_laborados = DATEDIFF(v_fecha_inicio_vac, v_ultima_fecha_vac);
    END IF;

    -- Calcular pago por vacaciones
    SET v_pago_vacaciones = ROUND((v_salario_base * v_dias_laborados) / 720, 2);

    -- Calcular nómina total del mes de vacaciones
    SET v_nomina_total = ROUND(v_salario_base + v_pago_vacaciones, 2);

    -- Actualizar el valor de vacaciones en la tabla Vacaciones
    UPDATE Vacaciones
    SET valor = v_pago_vacaciones
    WHERE id_empleado = p_id_empleado AND fecha_inicio = v_fecha_inicio_vac;

    -- (Opcional) Insertar registro en una tabla de nómina vacacional si se desea llevar histórico

    -- Mostrar resultado
    SELECT
        p_id_empleado AS id_empleado,
        v_salario_base AS salario_base,
        v_fecha_inicio_vac AS fecha_inicio_vacaciones,
        v_fecha_fin_vac AS fecha_fin_vacaciones,
        v_dias_laborados AS dias_laborados,
        v_pago_vacaciones AS pago_vacaciones,
        v_nomina_total AS nomina_total_mes_vacacional;
END $$

DELIMITER ;

-- ===========================================
-- PROCEDIMIENTO MASIVO PARA TODOS LOS EMPLEADOS
-- ===========================================
DELIMITER $$

CREATE PROCEDURE CalcularNominaVacacionalMasiva()
BEGIN
    DECLARE done INT DEFAULT FALSE;
    DECLARE v_id_empleado INT;
    DECLARE cur CURSOR FOR SELECT DISTINCT id_empleado FROM Vacaciones;
    DECLARE CONTINUE HANDLER FOR NOT FOUND SET done = TRUE;

    OPEN cur;

    read_loop: LOOP
        FETCH cur INTO v_id_empleado;
        IF done THEN
            LEAVE read_loop;
        END IF;
        CALL CalcularNominaVacacional(v_id_empleado);
    END LOOP;

    CLOSE cur;
END $$

DELIMITER ;

-- ===========================================
-- FIN DEL MÓDULO DE NÓMINA VACACIONAL
-- ===========================================