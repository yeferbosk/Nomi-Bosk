DELIMITER //

CREATE PROCEDURE crear_liquidacion_nomina (
    IN p_id_empleado INT,
    IN p_tipo_pago VARCHAR(50)
)
BEGIN
    DECLARE v_salario DECIMAL(10,2);
    DECLARE v_prima DECIMAL(10,2) DEFAULT 0;
    DECLARE v_horas_extra DECIMAL(10,2) DEFAULT 0;
    DECLARE v_auxilio DECIMAL(10,2) DEFAULT 0;
    DECLARE v_salud DECIMAL(10,2) DEFAULT 0;
    DECLARE v_pension DECIMAL(10,2) DEFAULT 0;
    DECLARE v_total_devengado DECIMAL(10,2) DEFAULT 0;
    DECLARE v_total_deducciones DECIMAL(10,2) DEFAULT 0;
    DECLARE v_total_pago DECIMAL(10,2) DEFAULT 0;
    DECLARE v_fecha_pago DATE DEFAULT 0;

    -- Obtener salario brutoss
    SELECT salario_bruto
    INTO v_salario
    FROM Contrato
    WHERE id_empleado = p_id_empleado
    ORDER BY fecha_inicio DESC
    LIMIT 1;

    -- Calcular auxilio de transporte
    IF v_salario < 2800000 THEN
        SET v_auxilio = 200000;
    ELSE
        SET v_auxilio = 0;
    END IF;

    -- Calcular la prima de servicios (si estamos en junio o diciembre)
    IF MONTH(CURDATE()) IN (6, 12) THEN
        SET v_prima = v_salario / 2; -- Prima de servicios = mitad del salario
    ELSE
        SET v_prima = 0;
    END IF;

    -- Calcular horas extra desde la tabla Horas_Extra
    SELECT IFNULL(SUM(valor), 0)
    INTO v_horas_extra
    FROM Horas_Extra
    WHERE id_empleado = p_id_empleado
      AND MONTH(fecha) = MONTH(CURDATE());

    -- Calcular deducciones (salud y pensión)
    SET v_salud = ROUND(v_salario * 0.04, 2);
    SET v_pension = ROUND(v_salario * 0.04, 2);

    -- Actualizar total devengado sumando auxilio, prima y horas extra
    SET v_total_devengado = v_auxilio + v_prima + v_horas_extra;

    -- Calcular total de deducciones (salud + pensión)
    SET v_total_deducciones = v_salud + v_pension;

    -- Calcular total a pagar
	SET v_total_pago = v_salario + v_total_devengado - v_total_deducciones;


    -- Determinar la fecha de pago según tipo de pago
    IF p_tipo_pago = 'mensual' THEN
        SET v_fecha_pago = LAST_DAY(CURDATE());
    ELSE
        SET v_fecha_pago = CURDATE();
    END IF;

    -- Comprobar si ya existe una liquidación para este empleado y tipo de pago
    IF EXISTS (SELECT 1 FROM Liquidacion WHERE id_empleado = p_id_empleado AND tipo_pago = p_tipo_pago) THEN
        -- Actualizar la liquidación existente
        UPDATE Liquidacion
        SET
            fecha_pago = v_fecha_pago,
            auxilio_transporte = v_auxilio,
            prima_servicios = v_prima,
            total_devengado = v_total_devengado,
            total_deducciones = v_total_deducciones,
            total_pago = v_total_pago
        WHERE id_empleado = p_id_empleado AND tipo_pago = p_tipo_pago;
    ELSE
        -- Insertar nueva liquidación
        INSERT INTO Liquidacion (
            tipo_pago,
            fecha_pago,
            auxilio_transporte,
            prima_servicios,
            total_devengado,
            total_deducciones,
            total_pago,
            id_empleado
        ) VALUES (
            p_tipo_pago,
            v_fecha_pago,
            v_auxilio,
            v_prima,
            v_total_devengado,
            v_total_deducciones,
            v_total_pago,
            p_id_empleado
        );
    END IF;

    -- Actualizar los valores de salud y pensión en la tabla Seguridad_Social
    UPDATE Seguridad_Social
    SET salud = v_salud, pension = v_pension
    WHERE id_empleado = p_id_empleado;

END //

DELIMITER ;