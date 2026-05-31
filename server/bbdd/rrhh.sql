-- ====================================================================
-- LIMPIEZA Y DESPLIEGUE DE LA BASE DE DATOS DE RECURSOS HUMANOS (RRHH)
-- ====================================================================

DROP DATABASE IF EXISTS `database_rrhh`;
CREATE DATABASE `database_rrhh` CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;
USE `database_rrhh`;

-- Estructura de Tablas
CREATE TABLE `departamentos` (
  `id_departamento` INT AUTO_INCREMENT PRIMARY KEY,
  `nombre` VARCHAR(50) NOT NULL UNIQUE,
  `ubicacion` VARCHAR(100) NOT NULL,
  `presupuesto_anual` DECIMAL(12,2) NOT NULL
) ENGINE=InnoDB;

CREATE TABLE `empleados` (
  `id_empleado` INT AUTO_INCREMENT PRIMARY KEY,
  `nombre` VARCHAR(50) NOT NULL,
  `apellidos` VARCHAR(100) NOT NULL,
  `email` VARCHAR(100) NOT NULL UNIQUE,
  `fecha_contratacion` DATE NOT NULL,
  `salario` DECIMAL(10,2) NOT NULL,
  `id_departamento` INT,
  FOREIGN KEY (`id_departamento`) REFERENCES `departamentos`(`id_departamento`) ON DELETE SET NULL
) ENGINE=InnoDB;

-- Inserción de Registros de Prueba
INSERT INTO `departamentos` (`nombre`, `ubicacion`, `presupuesto_anual`) VALUES
('Sistemas e Informática', 'Planta 3 - Oficina A', 150000.00),
('Recursos Humanos', 'Planta 1 - Oficina B', 45000.00),
('Contabilidad y Finanzas', 'Planta 2 - Oficina C', 80000.00),
('Marketing y Ventas', 'Planta 1 - Oficina A', 60000.00);

INSERT INTO `empleados` (`nombre`, `apellidos`, `email`, `fecha_contratacion`, `salario`, `id_departamento`) VALUES
('Pedro Jesús', 'Águila Oller', 'pedro.aguila@empresa.sl', '2025-01-15', 3200.00, 1),
('Ana', 'García Martínez', 'ana.garcia@empresa.sl', '2024-03-22', 2400.00, 2),
('Carlos', 'López Rodriguez', 'carlos.lopez@empresa.sl', '2023-11-01', 2800.00, 3),
('María', 'Sánchez Gómez', 'maria.sanchez@empresa.sl', '2025-02-10', 2100.00, 4),
('Juan', 'Pérez Fernández', 'juan.perez@empresa.sl', '2024-07-19', 2600.00, 1);