CREATE DATABASE coworking_db;
USE coworking_db;

-- Tabla de usuarios
CREATE TABLE usuarios (
    usuario_id INT AUTO_INCREMENT PRIMARY KEY,
    nombre VARCHAR(50) NOT NULL,
    apellidos VARCHAR(100) NOT NULL,
    fecha_nacimiento DATE NOT NULL,
    email VARCHAR(100) UNIQUE NOT NULL,
    telefono VARCHAR(20),
    empresa VARCHAR(100),
    documento_id VARCHAR(50) UNIQUE,
    fecha_registro DATETIME DEFAULT CURRENT_TIMESTAMP
);

-- Tabla de tipos de membresía
CREATE TABLE tipos_membresia (
    tipo_membresia_id INT AUTO_INCREMENT PRIMARY KEY,
    nombre VARCHAR(50) NOT NULL,
    descripcion TEXT,
    precio_base DECIMAL(10, 2) NOT NULL,
    duracion_dias INT NOT NULL,
    beneficios TEXT
);

-- Tabla de membresías
CREATE TABLE membresias (
    membresia_id INT AUTO_INCREMENT PRIMARY KEY,
    usuario_id INT,
    tipo_membresia_id INT,
    fecha_inicio DATE NOT NULL,
    fecha_fin DATE NOT NULL,
    estado ENUM('Activa', 'Suspendida', 'Vencida') DEFAULT 'Activa',
    precio_final DECIMAL(10, 2) NOT NULL,
    FOREIGN KEY (usuario_id) REFERENCES usuarios(usuario_id),
    FOREIGN KEY (tipo_membresia_id) REFERENCES membresias (membresia_id),
    INDEX idx_usuario_estado (usuario_id, estado),
    INDEX idx_fecha_fin (fecha_fin)
);

-- Tabla de espacios
CREATE TABLE espacios (
    espacio_id INT AUTO_INCREMENT PRIMARY KEY,
    nombre VARCHAR(100) NOT NULL,
    tipo_espacio ENUM('Escritorio flexible', 'Oficina privada', 'Sala de reuniones', 'Sala de eventos') NOT NULL,
    capacidad_max INT NOT NULL,
    descripcion TEXT,
    precio_hora DECIMAL(10, 2) NOT NULL,
    precio_dia DECIMAL(10, 2),
    estado ENUM('Disponible', 'Mantenimiento', 'No disponible') DEFAULT 'Disponible',
    caracteristicas TEXT
);

-- Tabla de reservas
CREATE TABLE reservas (
    reserva_id INT AUTO_INCREMENT PRIMARY KEY,
    usuario_id INT,
    espacio_id INT,
    fecha_reserva DATE NOT NULL,
    hora_inicio TIME NOT NULL,
    hora_fin TIME NOT NULL,
    duracion_horas DECIMAL(4, 2) NOT NULL,
    estado ENUM('Confirmada', 'En curso', 'Finalizada', 'Cancelada') DEFAULT 'Confirmada',
    precio_total DECIMAL(10, 2) NOT NULL,
    fecha_creacion DATETIME DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (usuario_id) REFERENCES usuarios(usuario_id),
    FOREIGN KEY (espacio_id) REFERENCES espacios(espacio_id),
    INDEX idx_fecha_reserva (fecha_reserva),
    INDEX idx_usuario_fecha (usuario_id, fecha_reserva)
);

-- Tabla de servicios adicionales
CREATE TABLE servicios (
    servicio_id INT AUTO_INCREMENT PRIMARY KEY,
    nombre VARCHAR(100) NOT NULL,
    descripcion TEXT,
    precio DECIMAL(10, 2) NOT NULL,
    tipo_servicio ENUM('Internet', 'Almacenamiento', 'Consumibles', 'Equipamiento') NOT NULL,
    disponible BOOLEAN DEFAULT TRUE
);

-- Tabla de relación servicios-reservas
CREATE TABLE servicios_reserva (
    servicio_reserva_id INT AUTO_INCREMENT PRIMARY KEY,
    reserva_id INT,
    servicio_id INT,
    cantidad INT DEFAULT 1,
    precio_unitario DECIMAL(10, 2) NOT NULL,
    precio_total DECIMAL(10, 2) NOT NULL,
    FOREIGN KEY (reserva_id) REFERENCES reservas(reserva_id),
    FOREIGN KEY (servicio_id) REFERENCES servicios(servicio_id)
);

-- Tabla de facturas
CREATE TABLE facturas (
    factura_id INT AUTO_INCREMENT PRIMARY KEY,
    usuario_id INT,
    fecha_emision DATETIME DEFAULT CURRENT_TIMESTAMP,
    fecha_vencimiento DATE NOT NULL,
    concepto ENUM('Membresía', 'Reserva', 'Servicios') NOT NULL,
    concepto_id INT NOT NULL, -- ID de la membresía, reserva o servicio
    subtotal DECIMAL(10, 2) NOT NULL,
    impuestos DECIMAL(10, 2) NOT NULL,
    total DECIMAL(10, 2) NOT NULL,
    estado ENUM('Pagada', 'Pendiente', 'Vencida', 'Cancelada') DEFAULT 'Pendiente',
    detalles TEXT,
    FOREIGN KEY (usuario_id) REFERENCES usuarios(usuario_id),
    INDEX idx_estado_vencimiento (estado, fecha_vencimiento)
);

-- Tabla de pagos
CREATE TABLE pagos (
    pago_id INT AUTO_INCREMENT PRIMARY KEY,
    factura_id INT,
    metodo_pago ENUM('Efectivo', 'Tarjeta', 'Transferencia', 'PayPal') NOT NULL,
    monto DECIMAL(10, 2) NOT NULL,
    fecha_pago DATETIME DEFAULT CURRENT_TIMESTAMP,
    referencia VARCHAR(100),
    estado ENUM('Completado', 'Pendiente', 'Fallido', 'Reembolsado') DEFAULT 'Completado',
    detalles TEXT,
    FOREIGN KEY (factura_id) REFERENCES facturas(factura_id),
    INDEX idx_fecha_metodo (fecha_pago, metodo_pago)
);

-- Tabla de control de acceso
CREATE TABLE acceso (
    acceso_id INT AUTO_INCREMENT PRIMARY KEY,
    usuario_id INT,
    espacio_id INT,
    fecha_hora_entrada DATETIME DEFAULT CURRENT_TIMESTAMP,
    fecha_hora_salida DATETIME,
    metodo_acceso ENUM('RFID', 'QR', 'Manual') NOT NULL,
    resultado ENUM('Permitido', 'Denegado') NOT NULL,
    motivo_denegacion TEXT,
    FOREIGN KEY (usuario_id) REFERENCES usuarios(usuario_id),
    FOREIGN KEY (espacio_id) REFERENCES espacios(espacio_id),
    INDEX idx_usuario_fecha (usuario_id, fecha_hora_entrada)
);

-- Tabla de registros de asistencia
CREATE TABLE asistencia (
    asistencia_id INT AUTO_INCREMENT PRIMARY KEY,
    usuario_id INT,
    fecha DATE NOT NULL,
    hora_entrada TIME,
    hora_salida TIME,
    tiempo_total TIME,
    FOREIGN KEY (usuario_id) REFERENCES usuarios(usuario_id),
    INDEX idx_usuario_fecha (usuario_id, fecha)
);

INSERT INTO usuarios (nombre, apellidos, fecha_nacimiento, email, telefono, empresa, documento_id) VALUES
('Lucía', 'Hernández Gil', '1990-02-18', 'lucia@email.com', '+34600123457', 'Tech Solutions', '12345678B'),
('Javier', 'Díaz Castro', '1988-07-22', 'javier@email.com', '+34611234568', 'Design Studio', '87654321C'),
('Sofía', 'Pérez López', '1993-11-15', 'sofia@email.com', '+34622345679', NULL, '13579246D'),
('Daniel', 'Ruiz Martín', '1985-04-30', 'daniel@email.com', '+34633456790', 'Data Analytics', '24681357E'),
('Eva', 'Gómez Sánchez', '1994-09-12', 'eva@email.com', '+34644567891', NULL, '98765432F'),
('Miguel', 'Serrano Torres', '1991-12-05', 'miguel@email.com', '+34655678902', 'Web Developers', '55544433G'),
('Carmen', 'Ortega Navarro', '1987-03-28', 'carmen@email.com', '+34666789013', 'Consulting Group', '11122233H'),
('Alejandro', 'Jiménez Ruiz', '1995-06-14', 'alejandro@email.com', '+34677890124', 'Creative Minds', '99988877I'),
('Isabel', 'Molina Vargas', '1989-08-07', 'isabel@email.com', '+34688901235', NULL, '44455566J'),
('Raúl', 'Castro Méndez', '1992-01-23', 'raul@email.com', '+34699012346', 'Tech Innovations', '77788899K'),
('Teresa', 'Santos León', '1990-05-19', 'teresa@email.com', '+34600123458', 'Tech Solutions', '12345678C'),
('Roberto', 'Lorenzo Campos', '1988-07-23', 'roberto@email.com', '+34611234569', 'Design Studio', '87654321D'),
('Olga', 'Vázquez Iglesias', '1993-11-16', 'olga@email.com', '+34622345680', NULL, '13579246E'),
('Patricia', 'Núñez Cordero', '1994-09-13', 'patricia@email.com', '+34644567892', NULL, '98765432G'),
('Andrés', 'Méndez Peña', '1991-12-06', 'andres@email.com', '+34655678903', 'Web Developers', '55544433H'),
('Rosa', 'Gil Rojas', '1987-03-29', 'rosa@email.com', '+34666789014', 'Consulting Group', '11122233I'),
('Jorge', 'Herrera Soto', '1995-06-15', 'jorge@email.com', '+34677890125', 'Creative Minds', '99988877J'),
('Silvia', 'Flores Campos', '1989-08-08', 'silvia@email.com', '+34688901236', NULL, '44455566K'),
('Víctor', 'Reyes Ortega', '1992-01-24', 'victor@email.com', '+34699012347', 'Tech Innovations', '77788899L'),
('Beatriz', 'Cabrera Guzmán', '1990-05-20', 'beatriz@email.com', '+34600123459', 'Tech Solutions', '12345678D'),
('Alberto', 'Otero Montes', '1988-07-24', 'alberto@email.com', '+34611234570', 'Design Studio', '87654321E'),
('Nuria', 'Santana Pacheco', '1993-11-17', 'nuria@email.com', '+34622345681', NULL, '13579246F'),
('Guillermo', 'Rivas Aguilar', '1985-05-01', 'guillermo@email.com', '+34633456792', 'Data Analytics', '24681357G'),
('Concepción', 'Márquez Delgado', '1994-09-14', 'concepcion@email.com', '+34644567893', NULL, '98765432H'),
('Ricardo', 'Campos Calderón', '1991-12-07', 'ricardo@email.com', '+34655678904', 'Web Developers', '55544433I'),
('Aurora', 'Gutiérrez Vega', '1987-03-30', 'aurora@email.com', '+34666789015', 'Consulting Group', '11122233J'),
('Felix', 'Soto Cruz', '1995-06-16', 'felix@email.com', '+34677890126', 'Creative Minds', '99988877K'),
('Lorena', 'Iglesias Reyes', '1989-08-09', 'lorena@email.com', '+34688901237', NULL, '44455566L'),
('Héctor', 'Fuentes Navarro', '1992-01-25', 'hector@email.com', '+34699012348', 'Tech Innovations', '77788899M'),
('Marina', 'Cruz Molina', '1990-05-21', 'marina@email.com', '+34600123460', 'Tech Solutions', '12345678E'),
('Santiago', 'Montes Serrano', '1988-07-25', 'santiago@email.com', '+34611234571', 'Design Studio', '87654321F'),
('Ester', 'Pacheco López', '1993-11-18', 'ester@email.com', '+34622345682', NULL, '13579246G'),
('Jonatan', 'Aguilar Martínez', '1985-05-02', 'jonatan@email.com', '+34633456793', 'Data Analytics', '24681357H'),
('Amparo', 'Delgado Fernández', '1994-09-15', 'amparo@email.com', '+34644567894', NULL, '98765432I'),
('Fermín', 'Calderón González', '1991-12-08', 'fermin@email.com', '+34655678905', 'Web Developers', '55544433J'),
('Clara', 'Vega Díaz', '1987-03-31', 'clara@email.com', '+34666789016', 'Consulting Group', '11122233K'),
('Nicolás', 'Cruz Sánchez', '1995-06-17', 'nicolas@email.com', '+34677890127', 'Creative Minds', '99988877L'),
('Miriam', 'Reyes Pérez', '1989-08-10', 'miriam@email.com', '+34688901238', NULL, '44455566M'),
('Saúl', 'Navarro Torres', '1992-01-26', 'saul@email.com', '+34699012349', 'Tech Innovations', '77788899N');

-- 2. Tipos de membresía adicionales (ya tenemos 10, no es necesario añadir más)

-- 3. Membresías adicionales (40 más)
INSERT INTO membresias (usuario_id, tipo_membresia_id, fecha_inicio, fecha_fin, estado, precio_final) VALUES
(1, 1, '2024-03-01', '2024-03-31', 'Activa', 99.99),
(2, 2, '2024-03-05', '2024-04-04', 'Activa', 199.99),
(3, 3, '2024-03-10', '2024-04-09', 'Vencida', 449.99),
(4, 4, '2024-03-15', '2024-03-15', 'Activa', 0.00),
(5, 5, '2024-03-20', '2024-04-19', 'Activa', 79.99),
(6, 6, '2024-04-01', '2024-05-01', 'Activa', 69.99),
(7, 7, '2024-04-05', '2024-04-05', 'Vencida', 19.99),
(8, 8, '2024-04-10', '2024-05-10', 'Activa', 29.99),
(9, 9, '2024-04-15', '2024-04-15', 'Activa', 39.99),
(10, 10, '2024-04-20', '2024-04-20', 'Vencida', 49.99);

-- 4. Espacios adicionales (40 más)
INSERT INTO espacios (nombre, tipo_espacio, capacidad_max, descripcion, precio_hora, precio_dia, estado, caracteristicas) VALUES
('Sala Amsterdam', 'Sala de reuniones', 6, 'Sala con decoración moderna', 14.00, 90.00, 'Disponible', 'Pantalla 50", café incluido'),
('Oficina Roma', 'Oficina privada', 3, 'Oficina con estilo clásico', 18.00, 130.00, 'Disponible', 'Air conditioning, lockers'),
('Escritorio C3', 'Escritorio flexible', 1, 'En zona tranquila', 4.50, 28.00, 'Disponible', 'Monitor externo opcional'),
('Sala Events II', 'Sala de eventos', 40, 'Espacio para talleres', 90.00, 550.00, 'Disponible', 'Equipo de sonido, proyector'),
('Sala Kyoto', 'Sala de reuniones', 4, 'Estilo minimalista', 11.00, 75.00, 'Disponible', 'Té verde gratis'),
('Oficina Barcelona', 'Oficina privada', 5, 'Vistas a la ciudad', 22.00, 160.00, 'No disponible', 'Biblioteca incluida'),
('Escritorio D4', 'Escritorio flexible', 1, 'Zona colaborativa', 5.50, 32.00, 'Disponible', 'Acceso a printer 3D'),
('Sala Lisboa', 'Sala de reuniones', 8, 'Mesa de reuniones mediana', 16.00, 110.00, 'Disponible', 'Video conferencia equipada'),
('Oficina Berlin', 'Oficina privada', 7, 'Diseño industrial', 28.00, 190.00, 'Disponible', 'Frigobar, sofa'),
('Coworking Zone II', 'Escritorio flexible', 30, 'Zona abierta secundaria', 2.50, 18.00, 'Disponible', '24/7 access, coffee bar'),
('Sala Vienna', 'Sala de reuniones', 7, 'Sala acogedora', 15.00, 95.00, 'Disponible', 'Pantalla 55", café incluido'),
('Oficina Dublin', 'Oficina privada', 4, 'Estilo rústico', 19.00, 140.00, 'Disponible', 'Air conditioning, lockers'),
('Escritorio E5', 'Escritorio flexible', 1, 'Zona silenciosa', 5.00, 30.00, 'Mantenimiento', 'Monitor externo opcional'),
('Sala Events III', 'Sala de eventos', 60, 'Espacio para conferencias grandes', 110.00, 650.00, 'Disponible', 'Equipo de sonido, proyector'),
('Sala Osaka', 'Sala de reuniones', 5, 'Estilo japonés', 12.50, 85.00, 'Disponible', 'Té verde gratis'),
('Oficina Milan', 'Oficina privada', 6, 'Diseño elegante', 24.00, 170.00, 'Disponible', 'Biblioteca incluida'),
('Escritorio F6', 'Escritorio flexible', 1, 'Zona networking', 4.00, 26.00, 'Disponible', 'Acceso a printer 3D'),
('Sala Porto', 'Sala de reuniones', 9, 'Mesa de reuniones grande', 17.00, 115.00, 'Disponible', 'Video conferencia equipada'),
('Oficina Munich', 'Oficina privada', 8, 'Vistas al jardín', 29.00, 195.00, 'Disponible', 'Frigobar, sofa'),
('Coworking Zone III', 'Escritorio flexible', 40, 'Zona abierta terciaria', 3.50, 22.00, 'Disponible', '24/7 access, coffee bar'),
('Sala Prague', 'Sala de reuniones', 6, 'Sala con estilo bohemio', 13.50, 88.00, 'Disponible', 'Pantalla 50", café incluido'),
('Oficina Athens', 'Oficina privada', 3, 'Estilo mediterráneo', 17.50, 125.00, 'Disponible', 'Air conditioning, lockers'),
('Escritorio G7', 'Escritorio flexible', 1, 'En zona luminosa', 4.75, 29.00, 'Disponible', 'Monitor externo opcional'),
('Sala Events IV', 'Sala de eventos', 55, 'Espacio para presentaciones', 95.00, 580.00, 'Disponible', 'Equipo de sonido, proyector'),
('Sala Hiroshima', 'Sala de reuniones', 4, 'Estilo tradicional', 11.50, 78.00, 'Disponible', 'Té verde gratis'),
('Oficina Valencia', 'Oficina privada', 5, 'Vistas al mar', 21.50, 155.00, 'Disponible', 'Biblioteca incluida'),
('Escritorio H8', 'Escritorio flexible', 1, 'Zona creativa', 5.25, 31.00, 'Disponible', 'Acceso a printer 3D'),
('Sala Coimbra', 'Sala de reuniones', 8, 'Mesa de reuniones moderna', 16.50, 105.00, 'Disponible', 'Video conferencia equipada'),
('Oficina Hamburg', 'Oficina privada', 7, 'Diseño contemporáneo', 27.50, 185.00, 'Disponible', 'Frigobar, sofa'),
('Coworking Zone IV', 'Escritorio flexible', 35, 'Zona abierta', 3.00, 20.00, 'Disponible', '24/7 access, coffee bar'),
('Sala Budapest', 'Sala de reuniones', 7, 'Sala con detalles clásicos', 14.50, 92.00, 'Disponible', 'Pantalla 55", café incluido'),
('Oficina Edinburgh', 'Oficina privada', 4, 'Estilo victoriano', 18.50, 135.00, 'Disponible', 'Air conditioning, lockers'),
('Escritorio I9', 'Escritorio flexible', 1, 'Zona tranquila', 5.50, 33.00, 'Disponible', 'Monitor externo opcional'),
('Sala Events V', 'Sala de eventos', 45, 'Espacio íntimo', 85.00, 520.00, 'Disponible', 'Equipo de sonido, proyector'),
('Sala Nagoya', 'Sala de reuniones', 5, 'Estilo zen', 12.00, 80.00, 'Disponible', 'Té verde gratis'),
('Oficina Seville', 'Oficina privada', 6, 'Patio andaluz', 23.50, 165.00, 'Disponible', 'Biblioteca incluida'),
('Escritorio J10', 'Escritorio flexible', 1, 'Zona inspiradora', 4.25, 27.00, 'Disponible', 'Acceso a printer 3D'),
('Sala Braga', 'Sala de reuniones', 9, 'Mesa de reuniones ejecutiva', 17.50, 112.00, 'Disponible', 'Video conferencia equipada'),
('Oficina Cologne', 'Oficina privada', 8, 'Vistas al río', 28.50, 192.00, 'Disponible', 'Frigobar, sofa'),
('Coworking Zone V', 'Escritorio flexible', 25, 'Zona acogedora', 2.75, 19.00, 'Disponible', '24/7 access, coffee bar');

-- 5. Reservas adicionales (40 más)
-- Continuamos desde la reserva_id 11
INSERT INTO reservas (usuario_id, espacio_id, fecha_reserva, hora_inicio, hora_fin, duracion_horas, estado, precio_total) VALUES
(1, 1, '2024-03-10', '10:00:00', '12:00:00', 2.00, 'Finalizada', 28.00),
(2, 2, '2024-03-11', '11:00:00', '13:00:00', 2.00, 'Finalizada', 38.00),
(3, 3, '2024-03-12', '14:00:00', '16:00:00', 2.00, 'Cancelada', 9.00),
(4, 4, '2024-03-13', '15:00:00', '17:00:00', 2.00, 'En curso', 180.00),
(5, 5, '2024-03-14', '16:00:00', '18:00:00', 2.00, 'Confirmada', 23.00),
(6, 6, '2024-03-15', '09:00:00', '11:00:00', 2.00, 'Confirmada', 48.00),
(7, 7, '2024-03-16', '10:00:00', '12:00:00', 2.00, 'Finalizada', 8.00),
(8, 8, '2024-03-17', '11:00:00', '13:00:00', 2.00, 'Confirmada', 32.00),
(9, 9, '2024-03-18', '12:00:00', '14:00:00', 2.00, 'Confirmada', 56.00),
(10, 10, '2024-03-19', '13:00:00', '15:00:00', 2.00, 'Confirmada', 5.00),
(11, 11, '2024-03-20', '14:00:00', '16:00:00', 2.00, 'Confirmada', 27.00);

-- 6. Servicios adicionales (40 más)
INSERT INTO servicios (nombre, descripcion, precio, tipo_servicio, disponible) VALUES
('Internet Básico', '100 Mbps compartido', 4.99, 'Internet', TRUE),
('Alquiler Portátil', 'Portátil HP 15"', 10.00, 'Equipamiento', TRUE),
('Impresiones Blanco/Negro', 'Hasta 100 páginas', 0.10, 'Consumibles', TRUE),
('Lockers Pequeños', 'Lockers 24h', 1.50, 'Almacenamiento', TRUE),
('Cabina Videollamadas', 'Cabina insonorizada con webcam', 10.00, 'Equipamiento', TRUE),
('Coffee Pack Premium', 'Café especial ilimitado', 5.00, 'Consumibles', TRUE),
('Mensajería', 'Gestión de mensajería urgente', 15.00, 'Almacenamiento', TRUE),
('Pantalla Táctil', 'Pantalla táctil 65"', 20.00, 'Equipamiento', TRUE),
('Escáner A4', 'Escáner rápido', 3.00, 'Equipamiento', TRUE),
('Recepción Paquetes Grande', 'Recepción y almacenamiento grande', 2.50, 'Almacenamiento', TRUE),
('Internet Empresarial', '500 Mbps dedicado', 19.99, 'Internet', TRUE),
('Alquiler Tablet', 'Tablet iPad', 7.00, 'Equipamiento', TRUE),
('Fotocopias Color', 'Hasta 50 páginas', 0.30, 'Consumibles', TRUE),
('Lockers Grandes', 'Lockers 48h', 3.00, 'Almacenamiento', TRUE),
('Sala Streaming', 'Equipo streaming completo', 25.00, 'Equipamiento', TRUE),
('Refresh Pack', 'Bebidas energéticas y snacks', 8.00, 'Consumibles', TRUE),
('Gestión Postal', 'Gestión de correo postal', 20.00, 'Almacenamiento', TRUE),
('Micrófono Profesional', 'Micrófono Shure', 12.00, 'Equipamiento', TRUE),
('Impresora 3D', 'Uso de impresora 3D', 18.00, 'Equipamiento', TRUE),
('Almacenamiento Archivos', 'Almacenamiento físico de archivos', 5.00, 'Almacenamiento', TRUE),
('Internet Gaming', '2 Gbps baja latencia', 29.99, 'Internet', TRUE),
('Alquiler Monitor Curvo', 'Monitor curvo 32"', 8.00, 'Equipamiento', TRUE),
('Tóner Impresora', 'Recambio tóner color', 50.00, 'Consumibles', FALSE),
('Lockers con Carga', 'Lockers con carga para dispositivos', 4.00, 'Almacenamiento', TRUE),
('Sala Podcast', 'Equipo podcast completo', 30.00, 'Equipamiento', TRUE),
('Lunch Pack', 'Comida ligera y bebida', 12.00, 'Consumibles', TRUE),
('Digitalización Documents', 'Digitalización de documentos', 0.50, 'Almacenamiento', TRUE),
('Cámara Video', 'Cámara 4K profesional', 25.00, 'Equipamiento', TRUE),
('Plotter Impresión', 'Plotter de impresión A0', 35.00, 'Equipamiento', TRUE),
('Archivado físico', 'Archivado físico mensual', 10.00, 'Almacenamiento', TRUE),
('Internet Respaldo', 'Conexión de respaldo', 9.99, 'Internet', TRUE),
('Alquiler Silla Ergonómica', 'Silla ergonómica premium', 5.00, 'Equipamiento', TRUE),
('Papel Premium', 'Resma de papel premium', 15.00, 'Consumibles', TRUE),
('Lockers con Refrigeración', 'Lockers refrigerados', 6.00, 'Almacenamiento', FALSE),
('Sala Fotografía', 'Sala con equipo fotografía', 40.00, 'Equipamiento', TRUE),
('Wellness Pack', 'Agua infusionada y fruta', 6.00, 'Consumibles', TRUE),
('Gestión Paquetes Frágiles', 'Gestión especial para frágiles', 8.00, 'Almacenamiento', TRUE),
('Trípode', 'Trípode profesional', 7.00, 'Equipamiento', TRUE),
('Impresión Gran Formato', 'Impresión hasta A0', 45.00, 'Equipamiento', TRUE),
('Bóveda Seguridad', 'Almacenamiento en caja fuerte', 20.00, 'Almacenamiento', TRUE);

-- 7. Servicios_reserva adicionales (40 más)
INSERT INTO servicios_reserva (reserva_id, servicio_id, cantidad, precio_unitario, precio_total) VALUES
(1, 1, 1, 4.99, 4.99),
(2, 2, 1, 10.00, 10.00),
(3, 3, 30, 0.10, 3.00),
(4, 4, 2, 1.50, 3.00),
(5, 5, 1, 10.00, 10.00),
(6, 6, 1, 5.00, 5.00),
(7, 7, 1, 15.00, 15.00),
(8, 8, 1, 20.00, 20.00),
(9, 9, 1, 3.00, 3.00),
(10, 10, 3, 2.50, 7.50),
(11, 11, 1, 19.99, 19.99);

-- 8. Facturas adicionales (40 más)
INSERT INTO facturas (usuario_id, fecha_vencimiento, concepto, concepto_id, subtotal, impuestos, total, estado, detalles) VALUES
(1, '2024-03-31', 'Membresía', 11, 99.99, 21.00, 120.99, 'Pagada', 'Membresía Básica marzo'),
(2, '2024-04-04', 'Membresía', 12, 199.99, 42.00, 241.99, 'Pagada', 'Membresía Premium abril'),
(3, '2024-04-09', 'Membresía', 13, 449.99, 94.50, 544.49, 'Vencida', 'Membresía Empresa abril'),
(4, '2024-03-15', 'Membresía', 14, 0.00, 0.00, 0.00, 'Pagada', 'Membresía Flex marzo'),
(5, '2024-04-19', 'Membresía', 15, 79.99, 16.80, 96.79, 'Pagada', 'Membresía Nocturna abril'),
(6, '2024-05-01', 'Membresía', 16, 69.99, 14.70, 84.69, 'Pagada', 'Membresía Estudiante mayo'),
(7, '2024-04-05', 'Membresía', 17, 19.99, 4.20, 24.19, 'Vencida', 'Day Pass abril'),
(8, '2024-05-10', 'Membresía', 18, 29.99, 6.30, 36.29, 'Pagada', 'Membresía Virtual mayo'),
(9, '2024-04-15', 'Membresía', 19, 39.99, 8.40, 48.39, 'Pagada', 'Meeting Pass abril'),
(10, '2024-04-20', 'Membresía', 20, 49.99, 10.50, 60.49, 'Vencida', 'Event Pass abril'),
(11, '2024-05-31', 'Membresía', 21, 99.99, 21.00, 120.99, 'Pagada', 'Membresía Básica mayo');

-- 9. Pagos adicionales (40 más)
INSERT INTO pagos (factura_id, metodo_pago, monto, fecha_pago, referencia, estado, detalles) VALUES
(1, 'Tarjeta', 120.99, '2024-03-31 10:30:00', 'REF123457', 'Completado', 'Pago completo con Visa'),
(2, 'PayPal', 241.99, '2024-04-04 14:22:00', 'PP987655', 'Completado', 'Pago via PayPal'),
(3, 'Transferencia', 544.49, '2024-04-10 09:45:00', 'TRF555445', 'Fallido', 'Transferencia no recibida'),
(4, 'Efectivo', 0.00, '2024-03-15 16:10:00', 'CASH790', 'Completado', 'Pago en efectivo'),
(5, 'Tarjeta', 96.79, '2024-04-19 11:30:00', 'REF333223', 'Completado', 'Pago con Mastercard'),
(6, 'Tarjeta', 84.69, '2024-05-01 12:05:00', 'REF111223', 'Completado', 'Pago con American Express'),
(7, 'PayPal', 24.19, '2024-04-05 13:15:00', 'PP444556', 'Reembolsado', 'Cancelación membresía'),
(8, 'Transferencia', 36.29, '2024-05-10 08:45:00', 'TRF666778', 'Completado', 'Transferencia recibida'),
(9, 'Efectivo', 48.39, '2024-04-15 17:20:00', 'CASH889', 'Completado', 'Pago en efectivo'),
(10, 'Tarjeta', 60.49, '2024-04-20 10:00:00', 'REF999001', 'Fallido', 'Tarjeta rechazada'),
(11, 'Tarjeta', 120.99, '2024-05-31 10:30:00', 'REF123458', 'Completado', 'Pago completo con Visa');

-- 10. Acceso adicional (40 más)
INSERT INTO acceso (usuario_id, espacio_id, fecha_hora_entrada, fecha_hora_salida, metodo_acceso, resultado, motivo_denegacion) VALUES
(1, 1, '2024-03-10 09:58:00', '2024-03-10 12:02:00', 'QR', 'Permitido', NULL),
(2, 2, '2024-03-11 10:55:00', '2024-03-11 13:05:00', 'RFID', 'Permitido', NULL),
(3, 3, '2024-03-12 13:45:00', NULL, 'Manual', 'Denegado', 'Espacio en mantenimiento'),
(4, 4, '2024-03-13 14:59:00', '2024-03-13 17:01:00', 'RFID', 'Permitido', NULL),
(5,5, '2024-03-14 15:45:00', '2024-03-14 18:00:00', 'QR', 'Permitido', NULL),
(6, 6, '2024-03-15 08:58:00', '2024-03-15 11:02:00', 'RFID', 'Permitido', NULL),
(7, 7, '2024-03-16 09:55:00', '2024-03-16 12:05:00', 'Manual', 'Permitido', NULL),
(8, 8, '2024-03-17 10:58:00', '2024-03-17 13:02:00', 'QR', 'Permitido', NULL),
(9, 9, '2024-03-18 11:55:00', '2024-03-18 14:05:00', 'RFID', 'Permitido', NULL),
(10, 10, '2024-03-19 12:50:00', '2024-03-19 15:00:00', 'Manual', 'Permitido', NULL),
(11, 11, '2024-03-20 13:58:00', '2024-03-20 16:02:00', 'QR', 'Permitido', NULL);

-- 11. Asistencia adicional (40 más)
INSERT INTO asistencia (usuario_id, fecha, hora_entrada, hora_salida, tiempo_total) VALUES
(1, '2024-03-10', '09:58:00', '12:02:00', '02:04:00'),
(2, '2024-03-11', '10:55:00', '13:05:00', '02:10:00'),
(4, '2024-03-13', '14:59:00', '17:01:00', '02:02:00'),
(5, '2024-03-14', '15:45:00', '18:00:00', '02:15:00'),
(6, '2024-03-15', '08:58:00', '11:02:00', '02:04:00'),
(7, '2024-03-16', '09:55:00', '12:05:00', '02:10:00'),
(8, '2024-03-17', '10:58:00', '13:02:00', '02:04:00'),
(9, '2024-03-18', '11:55:00', '14:05:00', '02:10:00'),
(10, '2024-03-19', '12:50:00', '15:00:00', '02:10:00'),
(11, '2024-03-20', '13:58:00', '16:02:00', '02:04:00');

-- Vista  

CREATE OR REPLACE VIEW VW_EstadoEspacios AS
SELECT 
    e.espacio_id,
    e.nombre AS espacio,
    CASE 
        WHEN EXISTS (
            SELECT 1
            FROM reservas r
            WHERE r.espacio_id = e.espacio_id
              AND r.estado IN ('Confirmada', 'En curso')
              AND NOW() BETWEEN r.hora_inicio AND r.hora_fin
        )
        THEN 'Ocupado'
        ELSE 'Libre'
    END AS estado,
    (
        SELECT MIN(r.hora_inicio)
        FROM reservas r
        WHERE r.espacio_id = e.espacio_id
          AND r.estado IN ('Confirmada','En curso')
          AND r.hora_inicio > NOW()
    ) AS proxima_reserva
FROM espacios e;

-- Procedimiento almacenado 

CREATE PROCEDURE sp_GenerarReporteDiario()
BEGIN
    DECLARE total_reservas INT;
    DECLARE usuarios_activos INT;
    DECLARE ingresos_dia DECIMAL(10,2);

    -- Total de reservas para hoy
    SELECT COUNT(*) INTO total_reservas
    FROM reservas
    WHERE DATE(hora_inicio) = CURDATE();

    -- Usuarios que tuvieron reservas hoy (activos)
    SELECT COUNT(DISTINCT usuario_id) INTO usuarios_activos
    FROM reservas
    WHERE DATE(hora_inicio) = CURDATE();

    -- Ingresos del día (sumando facturas pagadas hoy)
    SELECT IFNULL(SUM(total),0) INTO ingresos_dia
    FROM facturas
    WHERE DATE(fecha_emision) = CURDATE()
      AND estado = 'Pagada';

    -- Resultado final
    SELECT total_reservas AS TotalReservasHoy,
           usuarios_activos AS UsuariosActivosHoy,
           ingresos_dia AS IngresosDelDia;
END;

-- Consulta 

SELECT CONCAT(
    'Ahora mismo hay ',
    COUNT(DISTINCT a.usuario_id),
    ' personas en el coworking.'
) AS Mensaje
FROM acceso a
WHERE a.resultado = 'Permitido'
  AND a.fecha_hora_entrada <= NOW()
  AND (a.fecha_hora_salida IS NULL OR a.fecha_hora_salida > NOW());