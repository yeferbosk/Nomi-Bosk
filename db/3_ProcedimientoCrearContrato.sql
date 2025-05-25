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
CREATE PROCEDURE eliminar_contrato_por_empleado(IN p_id_empleado INT)
BEGIN
    DELETE FROM contrato WHERE id_empleado = p_id_empleado;
    SELECT ROW_COUNT() AS filas_afectadas;
END //
DELIMITER ;

DELIMITER //
CREATE PROCEDURE obtener_contratos()
BEGIN
    SELECT *
    FROM 
        Contrato c
    JOIN 
        Empleado e ON c.id_empleado = e.id_empleado
    ORDER BY 
        c.fecha_inicio DESC;
END //
DELIMITER ;