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
    auxilio_transporte DECIMAL(10, 2) DEFAULT 0,
    total_devengado DECIMAL(10, 2) NOT NULL, 
    total_deducciones DECIMAL(10, 2) NOT NULL,
    total_pago DECIMAL(10, 2) NOT NULL,
    id_empleado INT,
    FOREIGN KEY (id_empleado) REFERENCES Empleado(id_empleado) ON DELETE CASCADE
);


-- Tabla de tipos de bonos
CREATE TABLE tipos_bonos (
    id_tipo_bono INT PRIMARY KEY AUTO_INCREMENT,
    nombre VARCHAR(50) NOT NULL,
    descripcion TEXT,
    es_constitutivo_salario BOOLEAN DEFAULT TRUE
);

-- Tabla de bonos
CREATE TABLE bonos (
    id_bono INT PRIMARY KEY AUTO_INCREMENT,
    id_empleado INT,
    id_tipo_bono INT,
    fecha_bono DATE NOT NULL,
    valor_bono DECIMAL(10,2) NOT NULL,
    porcentaje_cumplimiento DECIMAL(5,2),
    observaciones TEXT,
    FOREIGN KEY (id_empleado) REFERENCES empleados(id_empleado),
    FOREIGN KEY (id_tipo_bono) REFERENCES tipos_bonos(id_tipo_bono)
);

-- Tabla de metas
CREATE TABLE metas (
    id_meta INT PRIMARY KEY AUTO_INCREMENT,
    id_empleado INT,
    descripcion TEXT NOT NULL,
    valor_meta DECIMAL(10,2) NOT NULL,
    fecha_inicio DATE NOT NULL,
    fecha_fin DATE NOT NULL,
    estado ENUM('Pendiente', 'En Progreso', 'Completada', 'No Cumplida') DEFAULT 'Pendiente',
    FOREIGN KEY (id_empleado) REFERENCES empleados(id_empleado)
);

CREATE TABLE IF NOT EXISTS Seguridad_Social (
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

CREATE TABLE IF NOT EXISTS Contrato (
    id_contrato INT AUTO_INCREMENT PRIMARY KEY,
    salario_bruto DECIMAL(10,2) NOT NULL,
    tipo VARCHAR(50),
    horario VARCHAR(50),
    fecha_inicio DATE NOT NULL,
    fecha_fin DATE,
    id_empleado INT,
    FOREIGN KEY (id_empleado) REFERENCES Empleado(id_empleado) ON DELETE CASCADE
);

CREATE TABLE IF NOT EXISTS Liquidacion (
    id_liquidacion INT AUTO_INCREMENT PRIMARY KEY,
    tipo_pago VARCHAR(50),
    fecha_pago DATE NOT NULL,
    prima_servicios DECIMAL(10,2) DEFAULT 0,
    prima_servicios_empleador DECIMAL(10,2) DEFAULT 0,
    auxilio_transporte DECIMAL(10,2) DEFAULT 0,
    total_devengado DECIMAL(10,2) DEFAULT 0,
    total_deducciones DECIMAL(10,2) DEFAULT 0,
    total_pago DECIMAL(10,2) DEFAULT 0,
    total_pago_empleador DECIMAL(10,2) DEFAULT 0,
    sena DECIMAL(10,2) DEFAULT 0,
    id_empleado INT,
    FOREIGN KEY (id_empleado) REFERENCES Empleado(id_empleado) ON DELETE CASCADE
);

CREATE TABLE IF NOT EXISTS Cesantias (
    id_cesantias INT AUTO_INCREMENT PRIMARY KEY,
    fecha_pago DATE NOT NULL,
    valor DECIMAL(10,2) DEFAULT 0,
    i_c DECIMAL(10,2) DEFAULT 0,
    id_empleado INT,
    FOREIGN KEY (id_empleado) REFERENCES Empleado(id_empleado) ON DELETE CASCADE
);

CREATE TABLE IF NOT EXISTS Vacaciones (
    id_vacaciones INT AUTO_INCREMENT PRIMARY KEY,
    fecha_inicio DATE NOT NULL,
    fecha_fin DATE NOT NULL,
    dias_vacaciones INT NOT NULL,
    valor DECIMAL(10,2) DEFAULT 0,
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



ALTER TABLE liquidacion
ADD COLUMN auxilio_transporte DECIMAL(10, 2) DEFAULT 0,
ADD COLUMN total_devengado DECIMAL(10, 2) NOT NULL,
ADD COLUMN total_deducciones DECIMAL(10, 2) NOT NULL;



ALTER TABLE liquidacion
ADD COLUMN total_pago_empleador DECIMAL(10, 2) DEFAULT 0;

ALTER TABLE seguridad_social
ADD COLUMN salud_empleador DECIMAL(10, 2) DEFAULT 0,
ADD COLUMN pension_empleador DECIMAL(10, 2) DEFAULT 0;

ALTER TABLE cesantias
ADD COLUMN i_c DECIMAL(10, 2) DEFAULT 0;

ALTER TABLE liquidacion
ADD COLUMN sena DECIMAL(10, 2) DEFAULT 0;

ALTER TABLE liquidacion
ADD COLUMN prima_servicios_empleador DECIMAL(10, 2) DEFAULT 0;

ALTER TABLE vacaciones
ADD COLUMN valor DECIMAL(10, 2) DEFAULT 0;

