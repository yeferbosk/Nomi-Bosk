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
