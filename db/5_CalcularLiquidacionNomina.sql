ALTER TABLE liquidacion
ADD COLUMN total_pago_empleador DECIMAL(10, 2) DEFAULT 0;

ALTER TABLE seguridad_social
ADD COLUMN salud_empleador DECIMAL(10, 2) DEFAULT 0,
ADD COLUMN pension_empleador DECIMAL(10, 2) DEFAULT 0;

ALTER TABLE cesantias
ADD COLUMN i_c DECIMAL(10, 2) DEFAULT 0;

ALTER TABLE liquidacion
ADD COLUMN sena DECIMAL(10, 2) DEFAULT 0;

ALTER TABLE liquidacion
ADD COLUMN prima_servicios_empleador DECIMAL(10, 2) DEFAULT 0;

ALTER TABLE vacaciones
ADD COLUMN valor DECIMAL(10, 2) DEFAULT 0;

DELIMITER //

CREATE PROCEDURE crear_liquidacion_nomina (
    IN p_id_empleado INT,
    IN p_tipo_pago VARCHAR(50)
)
BEGIN
    -- Variables de cálculo base
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

    -- Variables de costos del empleador
    DECLARE v_salud_empleador DECIMAL(10,2) DEFAULT 0;
    DECLARE v_pension_empleador DECIMAL(10,2) DEFAULT 0;
    DECLARE v_riesgos_laborales DECIMAL(10,2) DEFAULT 0;
    DECLARE v_cesantias_valor DECIMAL(10,2) DEFAULT 0;
    DECLARE v_cesantias_ic DECIMAL(10,2) DEFAULT 0;
    DECLARE v_prima_empleador DECIMAL(10,2) DEFAULT 0;
    DECLARE v_vacaciones DECIMAL(10,2) DEFAULT 0;
    DECLARE v_sena_icbf_caja DECIMAL(10,2) DEFAULT 0;
    DECLARE v_total_pago_empleador DECIMAL(10,2) DEFAULT 0;

    -- Obtener salario bruto
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

    -- Calcular prima de servicios (si estamos en junio o diciembre)
    IF MONTH(CURDATE()) IN (6, 12) THEN
        SET v_prima = v_salario / 2;
    ELSE
        SET v_prima = 0;
    END IF;

    -- Calcular horas extra
    SELECT IFNULL(SUM(valor), 0)
    INTO v_horas_extra
    FROM Horas_Extra
    WHERE id_empleado = p_id_empleado
      AND MONTH(fecha) = MONTH(CURDATE());

    -- Calcular deducciones (empleado)
    SET v_salud = ROUND(v_salario * 0.04, 2);
    SET v_pension = ROUND(v_salario * 0.04, 2);

    -- Calcular total devengado
    SET v_total_devengado = v_auxilio + v_prima + v_horas_extra;

    -- Calcular total deducciones
    SET v_total_deducciones = v_salud + v_pension;

    -- Calcular total a pagar al empleado
    SET v_total_pago = v_salario + v_total_devengado - v_total_deducciones;

    -- Fecha de pago
    IF p_tipo_pago = 'mensual' THEN
        SET v_fecha_pago = LAST_DAY(CURDATE());
    ELSE
        SET v_fecha_pago = CURDATE();
    END IF;

    -- COSTOS DEL EMPLEADOR
    SET v_salud_empleador = ROUND((v_salario + v_horas_extra) * 0.085, 2);
    SET v_pension_empleador = ROUND((v_salario + v_horas_extra) * 0.12, 2);
    SET v_riesgos_laborales = ROUND((v_salario + v_horas_extra) * 0.00522, 2);

    SET v_cesantias_valor = ROUND(v_total_devengado * 0.0833, 2);
    SET v_cesantias_ic = ROUND(v_cesantias_valor * 0.12, 2);

    SET v_prima_empleador = ROUND(v_total_devengado * 0.0833, 2);
    SET v_vacaciones = ROUND(v_salario * 0.0417, 2);

    SET v_sena_icbf_caja = ROUND((v_salario + v_horas_extra) * 0.09, 2);

    -- Total pago empleador
    SET v_total_pago_empleador = v_salud_empleador + v_pension_empleador + v_riesgos_laborales
        + v_cesantias_valor + v_cesantias_ic + v_prima_empleador + v_vacaciones + v_sena_icbf_caja;

    -- Actualizar Seguridad_Social
    UPDATE Seguridad_Social
    SET salud = v_salud,
        pension = v_pension,
        salud_empleador = v_salud_empleador,
        pension_empleador = v_pension_empleador,
        riesgos_laborales = v_riesgos_laborales
    WHERE id_empleado = p_id_empleado;

    -- Actualizar Cesantias
    UPDATE Cesantias
    SET valor = v_cesantias_valor,
        i_c = v_cesantias_ic
    WHERE id_empleado = p_id_empleado;

    -- Actualizar Vacaciones
    UPDATE Vacaciones
    SET valor = v_vacaciones
    WHERE id_empleado = p_id_empleado;

    -- Insertar o actualizar Liquidacion
    IF EXISTS (SELECT 1 FROM Liquidacion WHERE id_empleado = p_id_empleado AND tipo_pago = p_tipo_pago) THEN
        UPDATE Liquidacion
        SET fecha_pago = v_fecha_pago,
            auxilio_transporte = v_auxilio,
            prima_servicios = v_prima,
            total_devengado = v_total_devengado,
            total_deducciones = v_total_deducciones,
            total_pago = v_total_pago,
            prima_servicios_empleador = v_prima_empleador,
            sena = v_sena_icbf_caja,
            total_pago_empleador = v_total_pago_empleador
        WHERE id_empleado = p_id_empleado AND tipo_pago = p_tipo_pago;
    ELSE
        INSERT INTO Liquidacion (
            tipo_pago,
            fecha_pago,
            auxilio_transporte,
            prima_servicios,
            total_devengado,
            total_deducciones,
            total_pago,
            prima_servicios_empleador,
            sena,
            total_pago_empleador,
            id_empleado
        ) VALUES (
            p_tipo_pago,
            v_fecha_pago,
            v_auxilio,
            v_prima,
            v_total_devengado,
            v_total_deducciones,
            v_total_pago,
            v_prima_empleador,
            v_sena_icbf_caja,
            v_total_pago_empleador,
            p_id_empleado
        );
    END IF;

END //

DELIMITER ;
