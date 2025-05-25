CREATE DATABASE Nomina_ProyectoFinalBD;
USE Nomina_ProyectoFinalBD;



-- Tabla Empleado
CREATE TABLE Empleado (
    id_empleado INT AUTO_INCREMENT PRIMARY KEY,
    email VARCHAR(100) NOT NULL,
    nombre VARCHAR(100) NOT NULL,
    fecha_nacimiento DATE NOT NULL,
    telefono VARCHAR(20),
    estado_civil VARCHAR(20),
    genero VARCHAR(10),
    n_documento VARCHAR(20) NOT NULL,
    cargo VARCHAR(50),
    estado BOOLEAN DEFAULT 1,
    direccion TEXT,
    fecha_ingreso DATE NOT NULL
);

-- Tabla Seguridad_Social
CREATE TABLE Seguridad_Social (
    id_seguridadSocial INT AUTO_INCREMENT PRIMARY KEY,
    salud DECIMAL(10,2) DEFAULT 0,
    pension DECIMAL(10,2) DEFAULT 0,
    salud_empleador DECIMAL(10,2) DEFAULT 0,
    pension_empleador DECIMAL(10,2) DEFAULT 0,
    riesgos_laborales DECIMAL(10,2) DEFAULT 0,
    caja_compensacion DECIMAL(10,2) DEFAULT 0,
    id_empleado INT,
    FOREIGN KEY (id_empleado) REFERENCES Empleado(id_empleado) ON DELETE CASCADE
);

-- Tabla Contrato
CREATE TABLE Contrato (
    id_contrato INT AUTO_INCREMENT PRIMARY KEY,
    salario_bruto DECIMAL(10,2) NOT NULL,
    tipo VARCHAR(50),
    horario VARCHAR(50),
    fecha_inicio DATE NOT NULL,
    fecha_fin DATE,
    id_empleado INT,
    id_seguridad_social INT,
    FOREIGN KEY (id_empleado) REFERENCES Empleado(id_empleado) ON DELETE CASCADE,
    FOREIGN KEY (id_seguridad_social) REFERENCES Seguridad_Social(id_seguridadSocial)
);

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

-- Tabla Cesantias
CREATE TABLE Cesantias (
    id_cesantias INT AUTO_INCREMENT PRIMARY KEY,
    fecha_pago DATE NOT NULL,
    valor DECIMAL(10,2) DEFAULT 0,
    i_c DECIMAL(10,2) DEFAULT 0,
    id_empleado INT,
    id_liquidacion INT,
    FOREIGN KEY (id_empleado) REFERENCES Empleado(id_empleado) ON DELETE CASCADE,
    FOREIGN KEY (id_liquidacion) REFERENCES Liquidacion(id_liquidacion)
);

-- Tabla Incapacidad
CREATE TABLE Incapacidad (
    id_incapacidad INT AUTO_INCREMENT PRIMARY KEY,
    tipo VARCHAR(50),
    fecha_inicio DATE NOT NULL,
    fecha_fin DATE NOT NULL,
    dias_incapacidad INT,
    porcentaje_pago DECIMAL(5,2),
    id_empleado INT,
    id_seguridad_social INT,
    FOREIGN KEY (id_empleado) REFERENCES Empleado(id_empleado) ON DELETE CASCADE,
    FOREIGN KEY (id_seguridad_social) REFERENCES Seguridad_Social(id_seguridadSocial)
);

-- Tabla Vacaciones
CREATE TABLE Vacaciones (
    id_vacaciones INT AUTO_INCREMENT PRIMARY KEY,
    fecha_inicio DATE NOT NULL,
    fecha_fin DATE NOT NULL,
    dias_vacaciones INT NOT NULL,
    valor DECIMAL(10,2) DEFAULT 0,
    id_empleado INT,
    FOREIGN KEY (id_empleado) REFERENCES Empleado(id_empleado) ON DELETE CASCADE
);

-- Tabla Horas_Extra
CREATE TABLE Horas_Extra (
    id_horaExtra INT AUTO_INCREMENT PRIMARY KEY,
    fecha DATE NOT NULL,
    tipo VARCHAR(50),
    cantidad INT NOT NULL,
    valor DECIMAL(10,2) NOT NULL,
    id_empleado INT,
    id_contrato INT,
    FOREIGN KEY (id_empleado) REFERENCES Empleado(id_empleado) ON DELETE CASCADE,
    FOREIGN KEY (id_contrato) REFERENCES Contrato(id_contrato)
);

-- Tabla Tipos_Bonos
CREATE TABLE tipos_bonos (
    id_tipo_bono INT AUTO_INCREMENT PRIMARY KEY,
    nombre VARCHAR(50) NOT NULL,
    descripcion TEXT,
    es_constitutivo_salario BOOLEAN DEFAULT TRUE
);

-- Tabla Bonos
CREATE TABLE bonos (
    id_bono INT AUTO_INCREMENT PRIMARY KEY,
    id_empleado INT,
    id_tipo_bono INT,
    fecha_bono DATE NOT NULL,
    valor_bono DECIMAL(10,2) NOT NULL,
    porcentaje_cumplimiento DECIMAL(5,2),
    observaciones TEXT,
    FOREIGN KEY (id_empleado) REFERENCES Empleado(id_empleado),
    FOREIGN KEY (id_tipo_bono) REFERENCES tipos_bonos(id_tipo_bono)
);

-- Tabla Metas
CREATE TABLE metas (
    id_meta INT AUTO_INCREMENT PRIMARY KEY,
    id_empleado INT,
    descripcion TEXT NOT NULL,
    valor_meta DECIMAL(10,2) NOT NULL,
    fecha_inicio DATE NOT NULL,
    fecha_fin DATE NOT NULL,
    estado ENUM('Pendiente', 'En Progreso', 'Completada', 'No Cumplida') DEFAULT 'Pendiente',
    FOREIGN KEY (id_empleado) REFERENCES Empleado(id_empleado)
);


-- PROCEDURES:

DELIMITER //

DROP PROCEDURE IF EXISTS crear_empleado //

CREATE PROCEDURE crear_empleado (
    IN p_nombre VARCHAR(100),
    IN p_email VARCHAR(100),
    IN p_fecha_nacimiento DATE,
    IN p_telefono VARCHAR(20),
    IN p_estado_civil VARCHAR(20),
    IN p_genero VARCHAR(10),
    IN p_n_documento VARCHAR(20),
    IN p_cargo VARCHAR(50),
    IN p_estado BOOLEAN,
    IN p_direccion TEXT,
    IN p_fecha_ingreso DATE
)
BEGIN
    INSERT INTO Empleado (
        nombre, email, fecha_nacimiento, telefono,
        estado_civil, genero, n_documento, cargo,
        estado, direccion, fecha_ingreso
    )
    VALUES (
        p_nombre, p_email, p_fecha_nacimiento, p_telefono,
        p_estado_civil, p_genero, p_n_documento, p_cargo,
        p_estado, p_direccion, p_fecha_ingreso
    );
END //

DELIMITER ;




DELIMITER //

CREATE PROCEDURE obtener_empleados()
BEGIN
    SELECT * FROM Empleado;
END;
//

DELIMITER ;




DELIMITER //
CREATE FUNCTION calcular_auxilio_transporte(salario_base DECIMAL(10,2))
RETURNS DECIMAL(10,2)
DETERMINISTIC
BEGIN
    IF salario_base < 2800000 THEN
        RETURN 200000;
    ELSE
        RETURN 0;
    END IF;
END;
//
DELIMITER ;




DELIMITER //
CREATE FUNCTION calcular_aporte_seguridad(salario_base DECIMAL(10,2))
RETURNS DECIMAL(10,2)
DETERMINISTIC
BEGIN
    RETURN ROUND(salario_base * 0.04, 0);
END;
	//
	DELIMITER ;
    
    
    
    
-- Procedimiento almacenado para obtener los cargos de los empleados
DELIMITER //

DROP PROCEDURE IF EXISTS obtener_cargos //

CREATE PROCEDURE obtener_cargos()
BEGIN
    SELECT DISTINCT cargo
    FROM Empleado
    WHERE cargo IS NOT NULL 
    AND TRIM(cargo) != ''
    ORDER BY cargo;
END //

DELIMITER ;




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
    DECLARE v_fecha_pago DATE DEFAULT NULL;

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
    IF v_salario < 2847000 THEN
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

    -- Calcular total deducciones (solo salud y pensión)
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
        + v_cesantias_valor + v_cesantias_ic + v_prima_empleador + v_vacaciones + v_sena_icbf_caja + v_total_pago;

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


Drop procedure crear_liquidacion_nomina;



DELIMITER //

CREATE PROCEDURE crear_liquidaciones_masivas (
    IN p_tipo_pago VARCHAR(50)
)
BEGIN
    DECLARE done INT DEFAULT FALSE;
    DECLARE v_id_empleado INT;
    DECLARE cur CURSOR FOR SELECT id_empleado FROM Empleado;
    DECLARE CONTINUE HANDLER FOR NOT FOUND SET done = TRUE;

    OPEN cur;

    leer_empleados: LOOP
        FETCH cur INTO v_id_empleado;
        IF done THEN
            LEAVE leer_empleados;
        END IF;

        CALL crear_liquidacion_nomina(v_id_empleado, p_tipo_pago);
    END LOOP;

    CLOSE cur;
END //

DELIMITER ;



-- Procedimento para crear un nuevo contrato y asociarlo a un empleado existente
DELIMITER //

CREATE PROCEDURE crear_contrato(
    IN p_salario_bruto DECIMAL(10,2),
    IN p_tipo VARCHAR(50),
    IN p_horario VARCHAR(50),
    IN p_fecha_inicio DATE,
    IN p_fecha_fin DATE,
    IN p_id_empleado INT
)
BEGIN
    INSERT INTO Contrato (salario_bruto, tipo, horario, fecha_inicio, fecha_fin, id_empleado)
    VALUES (p_salario_bruto, p_tipo, p_horario, p_fecha_inicio, p_fecha_fin, p_id_empleado);
END //

DELIMITER ;




DELIMITER //

CREATE PROCEDURE FiltrarEmpleados(
    IN p_tipo_filtro VARCHAR(20),
    IN p_valor_filtro VARCHAR(100),
    IN p_operador_salario VARCHAR(2) -- Nuevo parámetro para el operador de comparación
)
BEGIN
    -- Filtrar por cargo
    IF p_tipo_filtro = 'CARGO' THEN
        SELECT
            e.id_empleado,
            e.nombre,
            e.cargo,
            co.salario_bruto as salario,
            co.fecha_inicio as fecha_contratacion,
            e.email,
            e.telefono,
            e.estado_civil,
            e.genero
        FROM Empleado e
        JOIN Contrato co ON e.id_empleado = co.id_empleado
        WHERE LOWER(e.cargo) LIKE LOWER(CONCAT('%', p_valor_filtro, '%'))
        AND co.fecha_fin IS NULL;

    -- Filtrar por salario
    ELSEIF p_tipo_filtro = 'SALARIO' THEN
        IF p_operador_salario NOT IN ('>', '<', '>=', '<=') THEN
            SIGNAL SQLSTATE '45000'
            SET MESSAGE_TEXT = 'Operador de salario no válido. Use: >, <, >=, <=';
        END IF;

        SET @query = CONCAT('
            SELECT
                e.id_empleado,
                e.nombre,
                e.cargo,
                co.salario_bruto as salario,
                co.fecha_inicio as fecha_contratacion,
                e.email,
                e.telefono,
                e.estado_civil,
                e.genero
            FROM Empleado e
            JOIN Contrato co ON e.id_empleado = co.id_empleado
            WHERE co.salario_bruto ', p_operador_salario, ' ', CAST(p_valor_filtro AS DECIMAL(10,2)), '
            AND co.fecha_fin IS NULL
        ');

        PREPARE stmt FROM @query;
        EXECUTE stmt;
        DEALLOCATE PREPARE stmt;

    -- Filtrar por fecha de contratación
    ELSEIF p_tipo_filtro = 'FECHA' THEN
        SELECT
            e.id_empleado,
            e.nombre,
            e.cargo,
            co.salario_bruto as salario,
            co.fecha_inicio as fecha_contratacion,
            e.email,
            e.telefono,
            e.estado_civil,
            e.genero
        FROM Empleado e
        JOIN Contrato co ON e.id_empleado = co.id_empleado
        WHERE co.fecha_inicio >= STR_TO_DATE(p_valor_filtro, '%Y-%m-%d')
        AND co.fecha_fin IS NULL;

    ELSE
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Tipo de filtro no válido. Use: CARGO, SALARIO o FECHA';
    END IF;
END //

DELIMITER ;




DELIMITER $$

CREATE PROCEDURE CalcularCesantias()
BEGIN
    DECLARE v_id_empleado INT;
    DECLARE v_nombre VARCHAR(100);
    DECLARE v_salario_bruto DECIMAL(10,2);
    DECLARE v_valor_cesantias DECIMAL(10,2);
    DECLARE v_intereses DECIMAL(10,2);
    DECLARE done INT DEFAULT 0;

    -- Cursor para recorrer empleados con su salario
    DECLARE cur_empleados CURSOR FOR
        SELECT e.id_empleado, e.nombre, c.salario_bruto
        FROM Empleado e
        JOIN Contrato c ON e.id_empleado = c.id_empleado;

    DECLARE CONTINUE HANDLER FOR NOT FOUND SET done = 1;

    -- Abrir el cursor
    OPEN cur_empleados;

    -- Bucle para recorrer los empleados
    read_loop: LOOP
        FETCH cur_empleados INTO v_id_empleado, v_nombre, v_salario_bruto;
        IF done THEN
            LEAVE read_loop;
        END IF;

        -- Cesantías completas (360 días)
        SET v_valor_cesantias = v_salario_bruto;

        -- Intereses del 12% anual sobre cesantías
        SET v_intereses = v_valor_cesantias * 0.12;

        -- Verificar si ya existe un registro de cesantías para este empleado
        IF EXISTS (SELECT 1 FROM Cesantias WHERE id_empleado = v_id_empleado) THEN
            -- Actualizar el registro existente de cesantías
            UPDATE Cesantias
            SET valor = v_valor_cesantias,
                i_c = v_intereses,
                fecha_pago = CURDATE()
            WHERE id_empleado = v_id_empleado;
        ELSE
            -- Insertar un nuevo registro de cesantías si no existe
            INSERT INTO Cesantias (fecha_pago, valor, id_empleado, i_c)
            VALUES (CURDATE(), v_valor_cesantias, v_id_empleado, v_intereses);
        END IF;

    END LOOP;

    -- Cerrar el cursor
    CLOSE cur_empleados;

END$$

DELIMITER ;




DELIMITER $$

CREATE PROCEDURE CalcularSeguridadSocial(IN p_id_empleado INT)
BEGIN
    DECLARE v_salario DECIMAL(10, 2);
    DECLARE v_dias_trab INT DEFAULT 30;

    -- Variables para cálculos del empleado
    DECLARE v_salud_empleado DECIMAL(10,2);
    DECLARE v_pension_empleado DECIMAL(10,2);

    -- Variables para cálculos del empleador
    DECLARE v_salud_empleador DECIMAL(10,2);
    DECLARE v_pension_empleador DECIMAL(10,2);
    DECLARE v_arl DECIMAL(10,2);
    DECLARE v_ccf DECIMAL(10,2);

    -- Verifica si el empleado tiene contrato
    IF EXISTS (SELECT 1 FROM Contrato WHERE id_empleado = p_id_empleado) THEN

        -- Obtiene el salario del contrato más reciente
        SELECT salario_bruto
        INTO v_salario
        FROM Contrato
        WHERE id_empleado = p_id_empleado
        ORDER BY fecha_inicio DESC
        LIMIT 1;

        -- Cálculos empleado
        SET v_salud_empleado = ROUND(v_salario * 0.04, 2);
        SET v_pension_empleado = ROUND(v_salario * 0.04, 2);

        -- Cálculos empleador
        SET v_salud_empleador = ROUND(v_salario * 0.085, 2);
        SET v_pension_empleador = ROUND(v_salario * 0.12, 2);
        SET v_arl = ROUND(v_salario * 0.05, 2);  -- Nivel de riesgo predeterminado 5%
        SET v_ccf = ROUND(v_salario * 0.04, 2);

        -- Verificar si ya existe un registro en Seguridad_Social
        IF EXISTS (SELECT 1 FROM Seguridad_Social WHERE id_empleado = p_id_empleado) THEN
            -- Actualizar el registro existente en Seguridad_Social
            UPDATE Seguridad_Social
            SET salud = v_salud_empleado,
                pension = v_pension_empleado,
                salud_empleador = v_salud_empleador,
                pension_empleador = v_pension_empleador,
                riesgos_laborales = v_arl,
                caja_compensacion = v_ccf
            WHERE id_empleado = p_id_empleado;
        ELSE
            -- Insertar un nuevo registro si no existe
            INSERT INTO Seguridad_Social (
                salud,
                salud_empleador,
                pension,
                pension_empleador,
                riesgos_laborales,
                caja_compensacion,
                id_empleado
            )
            VALUES (
                v_salud_empleado,
                v_salud_empleador,
                v_pension_empleado,
                v_pension_empleador,
                v_arl,
                v_ccf,
                p_id_empleado
            );
        END IF;

    ELSE
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'El empleado no tiene contrato registrado.';
    END IF;
END$$

DELIMITER ;





DELIMITER //

CREATE PROCEDURE ObtenerEstadisticasDashboard()
BEGIN
    -- Variables para almacenar los resultados
    DECLARE v_total_nominas INT;
    DECLARE v_total_pagado DECIMAL(15,2);
    DECLARE v_total_empleados INT;
    DECLARE v_total_devengado DECIMAL(15,2);
    DECLARE v_total_deducciones DECIMAL(15,2);
    DECLARE v_total_empleador DECIMAL(15,2);
    DECLARE v_ultimo_mes VARCHAR(20);
    DECLARE v_mes_actual VARCHAR(20);

    -- Obtener total de nóminas
    SELECT COUNT(DISTINCT id_liquidacion) INTO v_total_nominas
    FROM Liquidacion;

    -- Obtener total pagado (suma de total_pago)
    SELECT COALESCE(SUM(total_pago), 0) INTO v_total_pagado
    FROM Liquidacion;

    -- Obtener total de empleados activos
    SELECT COUNT(*) INTO v_total_empleados
    FROM Empleado
    WHERE estado = 1;

    -- Obtener total devengado del mes actual
    SELECT COALESCE(SUM(total_devengado), 0) INTO v_total_devengado
    FROM Liquidacion
    WHERE MONTH(fecha_pago) = MONTH(CURDATE())
    AND YEAR(fecha_pago) = YEAR(CURDATE());

    -- Obtener total deducciones del mes actual
    SELECT COALESCE(SUM(total_deducciones), 0) INTO v_total_deducciones
    FROM Liquidacion
    WHERE MONTH(fecha_pago) = MONTH(CURDATE())
    AND YEAR(fecha_pago) = YEAR(CURDATE());

    -- Obtener total a pagar por empleador del mes actual
    SELECT COALESCE(SUM(total_pago_empleador), 0) INTO v_total_empleador
    FROM Liquidacion
    WHERE MONTH(fecha_pago) = MONTH(CURDATE())
    AND YEAR(fecha_pago) = YEAR(CURDATE());

    -- Obtener el mes con mayor pago
    SELECT DATE_FORMAT(fecha_pago, '%M %Y') INTO v_ultimo_mes
    FROM Liquidacion
    GROUP BY YEAR(fecha_pago), MONTH(fecha_pago)
    ORDER BY SUM(total_pago) DESC
    LIMIT 1;

    -- Obtener el mes actual
    SET v_mes_actual = DATE_FORMAT(CURDATE(), '%M %Y');

    -- Retornar todos los resultados
    SELECT
        v_total_nominas as total_nominas,
        v_total_pagado as total_pagado,
        v_total_empleados as total_empleados,
        v_total_devengado as total_devengado,
        v_total_deducciones as total_deducciones,
        v_total_empleador as total_empleador,
        v_ultimo_mes as ultimo_mes,
        v_mes_actual as mes_actual;

END //

DELIMITER ;




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
DELIMITER 

DROP procedure actualizar_deducciones_masivas;

DELIMITER //

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
END;
//
DELIMITER ;
-- =========================================
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

DELIMITER //

CREATE PROCEDURE actualizar_contrato(
    IN p_id_contrato INT,
    IN p_salario_bruto DECIMAL(10,2),
    IN p_tipo VARCHAR(50),
    IN p_horario VARCHAR(50),
    IN p_fecha_inicio DATE,
    IN p_fecha_fin DATE
)
BEGIN
    UPDATE Contrato
    SET salario_bruto = p_salario_bruto,
        tipo = p_tipo,
        horario = p_horario,
        fecha_inicio = p_fecha_inicio,
        fecha_fin = p_fecha_fin
    WHERE id_contrato = p_id_contrato;
END //
DELIMITER ;

DELIMITER //

CREATE PROCEDURE actualizar_empleado(
    IN p_id_empleado INT,
    IN p_nombre VARCHAR(100),
    IN p_n_documento VARCHAR(50),
    IN p_email VARCHAR(100),
    IN p_telefono VARCHAR(20),
    IN p_cargo VARCHAR(50),
    IN p_fecha_ingreso DATE,
    IN p_fecha_nacimiento DATE,
    IN p_genero VARCHAR(10),
    IN p_estado_civil VARCHAR(20),
    IN p_estado TINYINT,
    IN p_direccion TEXT
)
BEGIN
    UPDATE Empleado
    SET nombre = p_nombre,
        n_documento = p_n_documento,
        email = p_email,
        telefono = p_telefono,
        cargo = p_cargo,
        fecha_ingreso = p_fecha_ingreso,
        fecha_nacimiento = p_fecha_nacimiento,
        genero = p_genero,
        estado_civil = p_estado_civil,
        estado = p_estado,
        direccion = p_direccion
    WHERE id_empleado = p_id_empleado;
END //


DELIMITER //
CREATE PROCEDURE desactivar_empleado(IN p_id_empleado INT)
BEGIN
    UPDATE empleado
    SET estado = 0 
    WHERE id_empleado = p_id_empleado;
    
    SELECT ROW_COUNT() AS filas_afectadas;
END //
DELIMITER ;

DELIMITER //
CREATE PROCEDURE eliminar_contrato_por_empleado(IN p_id_empleado INT)
BEGIN
    DELETE FROM contrato WHERE id_empleado = p_id_empleado;
    SELECT ROW_COUNT() AS filas_afectadas;
END //
DELIMITER ;

DELIMITER //

-- Procedimiento para obtener un contrato por el ID del empleado
CREATE PROCEDURE sp_obtener_contrato_por_id_empleado (
    IN p_id_empleado INT
)
BEGIN
    SELECT * FROM Contrato
    WHERE id_empleado = p_id_empleado
    LIMIT 1; -- En caso de que tenga varios contratos y solo quieras uno
END //

DELIMITER ;


DELIMITER //
CREATE PROCEDURE obtener_contratos()
BEGIN
    SELECT 
        c.id_contrato,
        c.id_empleado,
        e.nombre as nombre_empleado,
        e.cargo,
        c.salario_bruto,
        c.tipo,
        c.horario,
        c.fecha_inicio,
        c.fecha_fin
    FROM 
        Contrato c
    JOIN 
        Empleado e ON c.id_empleado = e.id_empleado
    ORDER BY 
        c.fecha_inicio DESC;
END //
DELIMITER ;


--Procedimiento para obtener un empleado por su ID
DELIMITER //

CREATE PROCEDURE obtener_empleado_por_id (
    IN p_id_empleado INT
)
BEGIN
    SELECT * FROM empleados WHERE id_empleado = p_id_empleado;
END //

DELIMITER ;





-- CREATE VIEW



-- Vista para nómina vacacional
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


-- Vista para reporte de bonos
CREATE OR REPLACE VIEW v_reporte_bonos AS
SELECT
    e.id_empleado,
    e.nombre AS nombre_completo,
    e.cargo,
    tb.nombre AS tipo_bono,
    b.fecha_bono,
    b.valor_bono,
    b.porcentaje_cumplimiento,
    tb.es_constitutivo_salario
FROM bonos b
JOIN Empleado e ON b.id_empleado = e.id_empleado
JOIN tipos_bonos tb ON b.id_tipo_bono = tb.id_tipo_bono;

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