-- Base de datos, Base de datos 2
CREATE DATABASE Nomina_ProyectoFinalBD;
USE Nomina_ProyectoFinalBD;

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

select * from Empleado;

CREATE TABLE Seguridad_Social (
    id_seguridadSocial INT AUTO_INCREMENT PRIMARY KEY,
    salud VARCHAR(50),
    riesgos_laborales VARCHAR(50),
    caja_compensacion VARCHAR(50),
    pension VARCHAR(50),
    id_empleado INT,
    FOREIGN KEY (id_empleado) REFERENCES Empleado(id_empleado) ON DELETE CASCADE
);

CREATE TABLE Cesantias (
    id_cesantias INT AUTO_INCREMENT PRIMARY KEY,
    fecha_pago DATE NOT NULL,
    valor DECIMAL(10, 2) NOT NULL,
    id_empleado INT,
    FOREIGN KEY (id_empleado) REFERENCES Empleado(id_empleado) ON DELETE CASCADE
);

CREATE TABLE Incapacidad (
    id_incapacidad INT AUTO_INCREMENT PRIMARY KEY,
    tipo VARCHAR(50),
    fecha_inicio DATE NOT NULL,
    fecha_fin DATE NOT NULL,
    dias_incapacidad INT,
    porcentaje_pago DECIMAL(5, 2),
    id_empleado INT,
    FOREIGN KEY (id_empleado) REFERENCES Empleado(id_empleado) ON DELETE CASCADE
);

CREATE TABLE Contrato (
    id_contrato INT AUTO_INCREMENT PRIMARY KEY,
    salario_bruto DECIMAL(10, 2) NOT NULL,
    tipo VARCHAR(50),
    horario VARCHAR(50),
    fecha_inicio DATE NOT NULL,
    fecha_fin DATE,
    id_empleado INT,
    FOREIGN KEY (id_empleado) REFERENCES Empleado(id_empleado) ON DELETE CASCADE
);

CREATE TABLE Vacaciones (
    id_vacaciones INT AUTO_INCREMENT PRIMARY KEY,
    fecha_inicio DATE NOT NULL,
    fecha_fin DATE NOT NULL,
    dias_vacaciones INT NOT NULL,
    id_empleado INT,
    FOREIGN KEY (id_empleado) REFERENCES Empleado(id_empleado) ON DELETE CASCADE
);

CREATE TABLE Horas_Extra (
    id_horaExtra INT AUTO_INCREMENT PRIMARY KEY,
    fecha DATE NOT NULL,
    tipo VARCHAR(50),
    cantidad INT NOT NULL,
    valor DECIMAL(10, 2) NOT NULL,
    id_empleado INT,
    FOREIGN KEY (id_empleado) REFERENCES Empleado(id_empleado) ON DELETE CASCADE
);

CREATE TABLE Liquidacion (
    id_liquidacion INT AUTO_INCREMENT PRIMARY KEY,
    tipo_pago VARCHAR(50),
    fecha_pago DATE NOT NULL,
    prima_servicios DECIMAL(10, 2),
    total_pago DECIMAL(10, 2) NOT NULL,
    id_empleado INT,
    FOREIGN KEY (id_empleado) REFERENCES Empleado(id_empleado) ON DELETE CASCADE
);

ALTER TABLE Cesantias ADD COLUMN id_liquidacion INT;
ALTER TABLE Cesantias ADD FOREIGN KEY (id_liquidacion) REFERENCES Liquidacion(id_liquidacion);

ALTER TABLE Contrato ADD COLUMN id_seguridad_social INT;
ALTER TABLE Contrato ADD FOREIGN KEY (id_seguridad_social) REFERENCES Seguridad_Social(id_seguridadSocial);

ALTER TABLE Horas_Extra ADD COLUMN id_contrato INT;
ALTER TABLE Horas_Extra ADD FOREIGN KEY (id_contrato) REFERENCES Contrato(id_contrato);

ALTER TABLE Incapacidad ADD COLUMN id_seguridad_social INT;
ALTER TABLE Incapacidad ADD FOREIGN KEY (id_seguridad_social) REFERENCES Seguridad_Social(id_seguridadSocial);


INSERT INTO Empleado (email, nombre, fecha_nacimiento, telefono, estado_civil, genero, n_documento, cargo, estado, direccion, fecha_ingreso)
VALUES
('juan.perez@example.com', 'Juan Pérez', '1985-02-15', '3001234567', 'Soltero', 'Masculino', '1234567890', 'Desarrollador', TRUE, 'Calle Ficticia 123, Ciudad', '2020-01-10'),
('maria.garcia@example.com', 'María García', '1990-07-22', '3007654321', 'Casada', 'Femenino', '0987654321', 'Analista', TRUE, 'Avenida Real 456, Ciudad', '2018-05-15');

INSERT INTO Seguridad_Social (salud, riesgos_laborales, caja_compensacion, pension, id_empleado)
VALUES
('EPS SaludPlus', 'ARL RiesgosPlus', 'Caja Compensación ABC', 'Fondo Pensión A', 1),
('EPS Bienestar', 'ARL Bienestar', 'Caja Compensación XYZ', 'Fondo Pensión B', 2);

INSERT INTO Cesantias (fecha_pago, valor, id_empleado)
VALUES
('2024-06-30', 1500.00, 1),
('2024-06-30', 2000.00, 2);

INSERT INTO Incapacidad (tipo, fecha_inicio, fecha_fin, dias_incapacidad, porcentaje_pago, id_empleado)
VALUES
('Enfermedad común', '2024-03-10', '2024-03-20', 10, 75.00, 1),
('Accidente de trabajo', '2024-04-01', '2024-04-10', 9, 100.00, 2);

INSERT INTO Contrato (salario_bruto, tipo, horario, fecha_inicio, fecha_fin, id_empleado, id_seguridad_social)
VALUES
(3000.00, 'Indefinido', '9am - 6pm', '2020-01-10', NULL, 1, 1),
(3500.00, 'Temporal', '8am - 5pm', '2022-06-15', '2023-06-15', 2, 2);

INSERT INTO Vacaciones (fecha_inicio, fecha_fin, dias_vacaciones, id_empleado)
VALUES
('2023-12-01', '2023-12-15', 15, 1),
('2024-02-01', '2024-02-10', 10, 2);

INSERT INTO Horas_Extra (fecha, tipo, cantidad, valor, id_empleado, id_contrato)
VALUES
('2024-03-15', 'Nocturna', 5, 150.00, 1, 1),
('2024-04-02', 'Diurna', 4, 120.00, 2, 2);

INSERT INTO Liquidacion (tipo_pago, fecha_pago, prima_servicios, total_pago, id_empleado)
VALUES
('Quincenal', '2024-06-15', 250.00, 3500.00, 1),
('Mensual', '2024-04-30', 300.00, 4200.00, 2);

SELECT * FROM `Empleado`;


DELIMITER //

SHOW PROCEDURE STATUS WHERE Db = 'Nomina_ProyectoFinalBD';

CALL crear_empleado(
  'Carlos López',
  'carlos.lopez@example.com',
  '1992-05-20',
  '3011122333',
  'Soltero',
  'Masculino',
  '1122334455',
  'Contador',
  1,
  'Calle 45 #67-89',
  '2024-04-01'
);

SELECT * FROM Empleado ORDER BY id_empleado DESC;


USE Nomina_ProyectoFinalBD2;
SHOW PROCEDURE STATUS WHERE Db = 'Nomina_ProyectoFinalBD2';

DELIMITER //

CREATE PROCEDURE obtener_empleados()
BEGIN
    SELECT * FROM Empleado;
END;
//

DELIMITER ;



DELIMITER //

CREATE PROCEDURE crear_liquidacion_nomina (
    IN p_id_empleado INT,
    IN p_tipo_pago VARCHAR(50),
    IN p_fecha_pago DATE
)
BEGIN
    DECLARE v_salario DECIMAL(10,2);
    DECLARE v_prima DECIMAL(10,2) DEFAULT 0;
    DECLARE v_horas_extra DECIMAL(10,2) DEFAULT 0;
    DECLARE v_total DECIMAL(10,2);

    -- Obtener salario
SELECT
    salario_bruto
INTO v_salario FROM
    Contrato
WHERE
    id_empleado = p_id_empleado
ORDER BY fecha_inicio DESC
LIMIT 1;

    -- Calcular prima (por simplicidad: 8.33% del salario mensual)
    SET v_prima = v_salario * 0.0833;

    -- Sumar horas extra
SELECT
    IFNULL(SUM(valor), 0)
INTO v_horas_extra FROM
    Horas_Extra
WHERE
    id_empleado = p_id_empleado
        AND MONTH(fecha) = MONTH(p_fecha_pago);

    -- Total devengado
    SET v_total = v_salario + v_prima + v_horas_extra;

    -- Insertar liquidación
    INSERT INTO Liquidacion (tipo_pago, fecha_pago, prima_servicios, total_pago, id_empleado)
    VALUES (p_tipo_pago, p_fecha_pago, v_prima, v_total, p_id_empleado);
END;
//

DELIMITER ;
