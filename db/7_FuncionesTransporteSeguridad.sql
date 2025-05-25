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