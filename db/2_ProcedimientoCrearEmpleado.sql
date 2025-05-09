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