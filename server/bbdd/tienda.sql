-- ====================================================================
-- LIMPIEZA Y DESPLIEGUE DE LA BASE DE DATOS DE TIENDA (E-COMMERCE)
-- ====================================================================

DROP DATABASE IF EXISTS `database_tienda`;
CREATE DATABASE `database_tienda` CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;
USE `database_tienda`;

-- Estructura de Tablas
CREATE TABLE `clientes` (
  `id_cliente` INT AUTO_INCREMENT PRIMARY KEY,
  `nombre` VARCHAR(50) NOT NULL,
  `email` VARCHAR(100) NOT NULL UNIQUE,
  `telefono` VARCHAR(20),
  `fecha_registro` TIMESTAMP DEFAULT CURRENT_TIMESTAMP
) ENGINE=InnoDB;

CREATE TABLE `productos` (
  `id_producto` INT AUTO_INCREMENT PRIMARY KEY,
  `codigo` VARCHAR(20) NOT NULL UNIQUE,
  `nombre` VARCHAR(100) NOT NULL,
  `descripcion` TEXT,
  `precio` DECIMAL(10,2) NOT NULL,
  `stock` INT NOT NULL DEFAULT 0
) ENGINE=InnoDB;

CREATE TABLE `pedidos` (
  `id_pedido` INT AUTO_INCREMENT PRIMARY KEY,
  `id_cliente` INT NOT NULL,
  `fecha_pedido` DATETIME DEFAULT CURRENT_TIMESTAMP,
  `estado` ENUM('Pendiente', 'Enviado', 'Entregado', 'Cancelado') DEFAULT 'Pendiente',
  FOREIGN KEY (`id_cliente`) REFERENCES `clientes`(`id_cliente`) ON DELETE CASCADE
) ENGINE=InnoDB;

CREATE TABLE `detalles_pedido` (
  `id_pedido` INT NOT NULL,
  `id_producto` INT NOT NULL,
  `cantidad` INT NOT NULL,
  `precio_unitario` DECIMAL(10,2) NOT NULL,
  PRIMARY KEY (`id_pedido`, `id_producto`),
  FOREIGN KEY (`id_pedido`) REFERENCES `pedidos`(`id_pedido`) ON DELETE CASCADE,
  FOREIGN KEY (`id_producto`) REFERENCES `productos`(`id_producto`) ON DELETE RESTRICT
) ENGINE=InnoDB;

-- Inserción de Registros de Prueba
INSERT INTO `clientes` (`nombre`, `email`, `telefono`) VALUES
('Laura Romero', 'laura.romero@email.com', '600123456'),
('Javier Ortiz', 'javier.ortiz@email.com', '611987654'),
('Elena Delgado', 'elena.delgado@email.com', NULL);

INSERT INTO `productos` (`codigo`, `nombre`, `descripcion`, `precio`, `stock`) VALUES
('PROD001', 'Portátil Pro 15"', 'Intel i7, 16GB RAM, 512GB SSD', 1199.99, 14),
('PROD002', 'Ratón Inalámbrico', 'Ratón ergonómico con batería recargable', 35.50, 50),
('PROD003', 'Monitor 4K 27"', 'Monitor IPS ideal para diseño y desarrollo', 349.00, 8),
('PROD004', 'Teclado Mecánico RGB', 'Teclado con switches en español', 89.95, 22);

INSERT INTO `pedidos` (`id_cliente`, `estado`) VALUES
(1, 'Entregado'),
(2, 'Pendiente');

INSERT INTO `detalles_pedido` (`id_pedido`, `id_producto`, `cantidad`, `precio_unitario`) VALUES
(1, 1, 1, 1199.99),
(1, 2, 1, 35.50),
(2, 3, 2, 349.00);