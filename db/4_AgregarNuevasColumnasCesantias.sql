ALTER TABLE liquidacion
ADD COLUMN auxilio_transporte DECIMAL(10, 2) DEFAULT 0,
ADD COLUMN total_devengado DECIMAL(10, 2) NOT NULL,
ADD COLUMN total_deducciones DECIMAL(10, 2) NOT NULL;