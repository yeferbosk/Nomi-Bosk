DELIMITER //

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
    DECLARE v_tiene_contrato INT DEFAULT 0;

    -- Inicializar valores por defecto
    SET p_salud = 0;
    SET p_pension = 0;
    SET p_retencion_fuente = 0;
    SET p_total_deducciones = 0;

    -- Verificar si el empleado tiene contrato activo
    SELECT COUNT(*) INTO v_tiene_contrato
    FROM Contrato
    WHERE id_empleado = p_id_empleado
    AND fecha_fin IS NULL;

    IF v_tiene_contrato > 0 THEN
        -- Obtener salario mensual
        SELECT IFNULL(salario_bruto, 0)
        INTO v_salario_mensual
        FROM Contrato
        WHERE id_empleado = p_id_empleado
        AND fecha_fin IS NULL
        ORDER BY fecha_inicio DESC
        LIMIT 1;

        -- Calcular salario anual
        SET v_salario_anual = v_salario_mensual * 12;

        -- Calcular deducciones de seguridad social
        SET p_salud = ROUND(v_salario_mensual * 0.04, 2);
        SET p_pension = ROUND(v_salario_mensual * 0.04, 2);

        -- Calcular retención en la fuente
        SET p_retencion_fuente = ROUND(calcular_retencion_fuente(v_salario_anual) / 12, 2);

        -- Calcular total deducciones
        SET p_total_deducciones = IFNULL(p_salud, 0) + IFNULL(p_pension, 0) + IFNULL(p_retencion_fuente, 0);
    END IF;

    -- Asegurar que ningún valor sea NULL
    SET p_salud = IFNULL(p_salud, 0);
    SET p_pension = IFNULL(p_pension, 0);
    SET p_retencion_fuente = IFNULL(p_retencion_fuente, 0);
    SET p_total_deducciones = IFNULL(p_total_deducciones, 0);

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
DELIMITER 




DELIMITER //

CREATE PROCEDURE actualizar_deducciones_masivas()
BEGIN
    DECLARE done INT DEFAULT FALSE;
    DECLARE v_id_empleado INT;
    DECLARE v_salud DECIMAL(10,2) DEFAULT 0;
    DECLARE v_pension DECIMAL(10,2) DEFAULT 0;
    DECLARE v_retencion_fuente DECIMAL(10,2) DEFAULT 0;
    DECLARE v_total_deducciones DECIMAL(10,2) DEFAULT 0;
    DECLARE v_salario DECIMAL(10,2) DEFAULT 0;
    DECLARE v_fecha_actual DATE;

    -- Cursor para recorrer todos los empleados activos
    DECLARE cur_empleados CURSOR FOR
        SELECT id_empleado
        FROM Empleado
        WHERE estado = 1;

    DECLARE CONTINUE HANDLER FOR NOT FOUND SET done = TRUE;

    SET v_fecha_actual = CURDATE();

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

        -- Asegurar que ningún valor sea NULL
        SET v_salud = IFNULL(v_salud, 0);
        SET v_pension = IFNULL(v_pension, 0);
        SET v_retencion_fuente = IFNULL(v_retencion_fuente, 0);
        SET v_total_deducciones = IFNULL(v_total_deducciones, 0);

        -- Actualizar Seguridad_Social
        IF EXISTS (SELECT 1 FROM Seguridad_Social WHERE id_empleado = v_id_empleado) THEN
            UPDATE Seguridad_Social
            SET salud = v_salud,
                pension = v_pension
            WHERE id_empleado = v_id_empleado;
        ELSE
            INSERT INTO Seguridad_Social (id_empleado, salud, pension)
            VALUES (v_id_empleado, v_salud, v_pension);
        END IF;

        -- Actualizar o crear registro en Liquidacion
        IF EXISTS (SELECT 1 FROM Liquidacion WHERE id_empleado = v_id_empleado AND fecha_pago = v_fecha_actual) THEN
            UPDATE Liquidacion
            SET total_deducciones = v_total_deducciones
            WHERE id_empleado = v_id_empleado AND fecha_pago = v_fecha_actual;
        ELSE
            INSERT INTO Liquidacion (
                id_empleado,
                fecha_pago,
                tipo_pago,
                total_deducciones,
                total_devengado,
                total_pago,
                prima_servicios,
                prima_servicios_empleador,
                auxilio_transporte,
                sena,
                total_pago_empleador
            )
            VALUES (
                v_id_empleado,
                v_fecha_actual,
                'mensual',
                v_total_deducciones,
                0, -- total_devengado
                0, -- total_pago
                0, -- prima_servicios
                0, -- prima_servicios_empleador
                0, -- auxilio_transporte
                0, -- sena
                0  -- total_pago_empleador
            );
        END IF;

    END LOOP;

    CLOSE cur_empleados;
END;
//
DELIMITER ;




-- Tabla Liquidacion
CREATE TABLE Liquidacion (
    id_liquidacion INT AUTO_INCREMENT PRIMARY KEY,
    tipo_pago VARCHAR(50),
    fecha_pago DATE NOT NULL,
    prima_servicios DECIMAL(10,2) DEFAULT 0,
    prima_servicios_empleador DECIMAL(10,2) DEFAULT 0,
    auxilio_transporte DECIMAL(10,2) DEFAULT 0,
    total_devengado DECIMAL(10,2) NOT NULL,
    total_deducciones DECIMAL(10,2) NOT NULL,
    total_pago DECIMAL(10,2) NOT NULL,
    total_pago_empleador DECIMAL(10,2) DEFAULT 0,
    sena DECIMAL(10,2) DEFAULT 0,
    id_empleado INT,
    FOREIGN KEY (id_empleado) REFERENCES Empleado(id_empleado) ON DELETE CASCADE
);