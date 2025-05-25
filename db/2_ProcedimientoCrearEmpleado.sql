-- Procedimiento para crear un nuevo empleado y retirnar el ID del nuevo empleado
DELIMITER //

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
    IN p_fecha_ingreso DATE,
    OUT p_id_empleado INT
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

    SET p_id_empleado = LAST_INSERT_ID();
END;
//

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
CREATE PROCEDURE desactivar_empleado(IN p_id_empleado INT)
BEGIN
    UPDATE empleado
    SET estado = 0 
    WHERE id_empleado = p_id_empleado;
    
    SELECT ROW_COUNT() AS filas_afectadas;
END //
DELIMITER ;