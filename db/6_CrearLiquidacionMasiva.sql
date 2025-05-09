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