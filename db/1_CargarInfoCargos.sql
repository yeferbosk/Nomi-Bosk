-- Procedimiento almacenado para obtener los cargos de los empleados
DELIMITER //

CREATE PROCEDURE obtener_cargos()
BEGIN
    SELECT DISTINCT cargo 
    FROM Empleado
    WHERE cargo IS NOT NULL AND cargo != '';
END //

DELIMITER ;
