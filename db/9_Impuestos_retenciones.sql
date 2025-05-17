-- Función para calcular retención en la fuente
DELIMITER //

CREATE FUNCTION calcular_retencion_fuente(
    salario_anual DECIMAL(10,2)
)
RETURNS DECIMAL(10,2)
DETERMINISTIC
BEGIN
    DECLARE retencion DECIMAL(10,2);

    -- Tabla de retención en la fuente para 2024
    IF salario_anual <= 10900000 THEN
        SET retencion = 0;
    ELSEIF salario_anual <= 17000000 THEN
        SET retencion = (salario_anual - 10900000) * 0.19;
    ELSEIF salario_anual <= 36000000 THEN
        SET retencion = (salario_anual - 17000000) * 0.28 + 1159000;
    ELSEIF salario_anual <= 51000000 THEN
        SET retencion = (salario_anual - 36000000) * 0.33 + 6475000;
    ELSEIF salario_anual <= 72000000 THEN
        SET retencion = (salario_anual - 51000000) * 0.35 + 11425000;
    ELSEIF salario_anual <= 97000000 THEN
        SET retencion = (salario_anual - 72000000) * 0.37 + 18775000;
    ELSEIF salario_anual <= 145000000 THEN
        SET retencion = (salario_anual - 97000000) * 0.39 + 28025000;
    ELSE
        SET retencion = (salario_anual - 145000000) * 0.40 + 46775000;
    END IF;

    RETURN retencion;
END //

-- Procedimiento para calcular deducciones de un empleado
CREATE PROCEDURE calcular_deducciones_empleado(
    IN p_id_empleado INT,
    OUT p_salud DECIMAL(10,2),
    OUT p_pension DECIMAL(10,2),
    OUT p_retencion_fuente DECIMAL(10,2),
    OUT p_total_deducciones DECIMAL(10,2)
)
BEGIN
    DECLARE v_salario_mensual DECIMAL(10,2);
    DECLARE v_salario_anual DECIMAL(10,2);
    DECLARE v_uvt DECIMAL(10,2) DEFAULT 42412; -- UVT 2024

    -- Obtener salario mensual
    SELECT salario_bruto
    INTO v_salario_mensual
    FROM Contrato
    WHERE id_empleado = p_id_empleado
    AND fecha_fin IS NULL
    LIMIT 1;

    -- Calcular salario anual
    SET v_salario_anual = v_salario_mensual * 12;

    -- Calcular deducciones de seguridad social
    SET p_salud = ROUND(v_salario_mensual * 0.04, 2);
    SET p_pension = ROUND(v_salario_mensual * 0.04, 2);

    -- Calcular retención en la fuente
    SET p_retencion_fuente = calcular_retencion_fuente(v_salario_anual) / 12;

    -- Calcular total deducciones
    SET p_total_deducciones = p_salud + p_pension + p_retencion_fuente;

    -- Actualizar la tabla Seguridad_Social
    UPDATE Seguridad_Social
    SET salud = p_salud,
        pension = p_pension
    WHERE id_empleado = p_id_empleado;

    -- Actualizar la tabla Liquidacion
    UPDATE Liquidacion
    SET total_deducciones = p_total_deducciones
    WHERE id_empleado = p_id_empleado
    AND fecha_pago >= CURDATE();
END //

-- Procedimiento para actualizar deducciones masivamente
CREATE PROCEDURE actualizar_deducciones_masivas()
BEGIN
    DECLARE done INT DEFAULT FALSE;
    DECLARE v_id_empleado INT;
    DECLARE v_salud DECIMAL(10,2);
    DECLARE v_pension DECIMAL(10,2);
    DECLARE v_retencion_fuente DECIMAL(10,2);
    DECLARE v_total_deducciones DECIMAL(10,2);

    -- Cursor para recorrer todos los empleados activos
    DECLARE cur_empleados CURSOR FOR
        SELECT id_empleado
        FROM Empleado
        WHERE estado = 1;

    DECLARE CONTINUE HANDLER FOR NOT FOUND SET done = TRUE;

    OPEN cur_empleados;

    read_loop: LOOP
        FETCH cur_empleados INTO v_id_empleado;
        IF done THEN
            LEAVE read_loop;
        END IF;

        -- Calcular deducciones para cada empleado
        CALL calcular_deducciones_empleado(
            v_id_empleado,
            v_salud,
            v_pension,
            v_retencion_fuente,
            v_total_deducciones
        );

    END LOOP;

    CLOSE cur_empleados;
END //

DELIMITER ;

-- Vista para mostrar información de impuestos y deducciones
CREATE VIEW vista_impuestos_deducciones AS
SELECT
    e.id_empleado,
    e.nombre,
    e.cargo,
    c.salario_bruto,
    ss.salud AS deduccion_salud,
    ss.pension AS deduccion_pension,
    ss.salud_empleador AS aporte_salud_empleador,
    ss.pension_empleador AS aporte_pension_empleador,
    ss.riesgos_laborales AS aporte_arl,
    ss.caja_compensacion AS aporte_ccf,
    l.total_devengado,
    l.total_deducciones,
    l.total_pago,
    l.total_pago_empleador,
    l.prima_servicios,
    l.prima_servicios_empleador,
    l.auxilio_transporte,
    l.sena,
    cs.valor AS cesantias,
    cs.i_c AS intereses_cesantias,
    v.valor AS valor_vacaciones
FROM Empleado e
JOIN Contrato c ON e.id_empleado = c.id_empleado AND c.fecha_fin IS NULL
LEFT JOIN Seguridad_Social ss ON e.id_empleado = ss.id_empleado
LEFT JOIN Liquidacion l ON e.id_empleado = l.id_empleado
LEFT JOIN Cesantias cs ON e.id_empleado = cs.id_empleado
LEFT JOIN Vacaciones v ON e.id_empleado = v.id_empleado
WHERE e.estado = 1;