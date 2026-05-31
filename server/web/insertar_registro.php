<?php
// 1. Forzar visualización absoluta de errores
ini_set('display_errors', 1);
ini_set('display_startup_errors', 1);
error_reporting(E_ALL);

// 2. Control de sesión y seguridad
session_start();
if(!isset($_SESSION["usuario"]) || $_SESSION["rol"] !== "admin"){
    die("Acceso denegado: No tienes privilegios de administrador.");
}

// 3. Conexión centralizada
include 'conexion.php';

$database = $_SESSION["database"];

// ==========================================
// PROCESAR EL ENVÍO DEL FORMULARIO (POST)
// ==========================================
if($_SERVER["REQUEST_METHOD"] == "POST"){
    
    if($database == "database_rrhh"){
        // Recogemos campos de Recursos Humanos (incluyendo la fecha de contratación)
        $nombre = $_POST['nombre'];
        $apellidos = $_POST['apellidos'];
        $email = $_POST['email'];
        $salario = $_POST['salario'];
        $fecha_contratacion = $_POST['fecha_contratacion']; 
        
        // Query corregida incorporando la columna requerida por tu esquema MySQL
        $sql_insert = "INSERT INTO empleados (nombre, apellidos, email, salario, fecha_contratacion) VALUES ('$nombre', '$apellidos', '$email', '$salario', '$fecha_contratacion')";
    } else {
        // Recogemos campos de la Tienda
        $codigo = $_POST['codigo'];
        $nombre = $_POST['nombre'];
        $precio = $_POST['precio'];
        $stock = $_POST['stock'];
        
        $sql_insert = "INSERT INTO productos (codigo, nombre, precio, stock) VALUES ('$codigo', '$nombre', '$precio', '$stock')";
    }

    // Ejecutar la inserción real
    if($conn->query($sql_insert) === TRUE){
        header("Location: ver_registros.php");
        exit();
    } else {
        die("Error crítico al insertar el registro: " . $conn->error);
    }
}
?>
<!DOCTYPE html>
<html lang="es">
<head>
    <meta charset="UTF-8">
    <title>Insertar Registro</title>
</head>
<body style="font-family: Arial, sans-serif; margin: 30px;">

    <h1>Insertar Nuevo Registro</h1>
    <p>Entorno de Auditoría: Añadiendo datos en <strong><?php echo htmlspecialchars($database); ?></strong></p>
    <hr>

    <form method="POST">
    <?php
    // Renderizado dinámico de campos
    if($database == "database_rrhh") {
        echo '<label><strong>Nombre:</strong></label><br>';
        echo '<input type="text" name="nombre" placeholder="Ej. Juan" required style="width:300px; padding:5px;"><br><br>';
        
        echo '<label><strong>Apellidos:</strong></label><br>';
        echo '<input type="text" name="apellidos" placeholder="Ej. Gómez Pérez" required style="width:300px; padding:5px;"><br><br>';
        
        echo '<label><strong>Email:</strong></label><br>';
        echo '<input type="email" name="email" placeholder="Ej. juan@empresa.com" required style="width:300px; padding:5px;"><br><br>';
        
        echo '<label><strong>Salario (€):</strong></label><br>';
        echo '<input type="number" step="0.01" name="salario" placeholder="Ej. 1850.50" required style="width:300px; padding:5px;"><br><br>';

        // NUEVO: Input de tipo fecha inicializado con el día actual de forma automatizada
        echo '<label><strong>Fecha de Contratación:</strong></label><br>';
        echo '<input type="date" name="fecha_contratacion" value="'.date('Y-m-d').'" required style="width:300px; padding:5px;"><br><br>';
    } else {
        echo '<label><strong>Código de Producto:</strong></label><br>';
        echo '<input type="text" name="codigo" placeholder="Ej. PROD123" required style="width:300px; padding:5px;"><br><br>';
        
        echo '<label><strong>Nombre del Artículo:</strong></label><br>';
        echo '<input type="text" name="nombre" placeholder="Ej. Teclado Mecánico" required style="width:300px; padding:5px;"><br><br>';
        
        echo '<label><strong>Precio (€):</strong></label><br>';
        echo '<input type="number" step="0.01" name="precio" placeholder="Ej. 49.99" required style="width:300px; padding:5px;"><br><br>';
        
        echo '<label><strong>Stock inicial:</strong></label><br>';
        echo '<input type="number" name="stock" placeholder="Ej. 50" required style="width:300px; padding:5px;"><br><br>';
    }
    ?>
        <hr>
        <button type="submit" style="padding: 10px 20px; background-color: #4CAF50; color: white; border: none; cursor: pointer; font-weight: bold;">Crear Registro</button>
        <a href="dashboard.php" style="margin-left: 20px; text-decoration: none; color: #333;">Cancelar y Volver</a>
    </form>

</body>
</html>