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

// 4. Validar parámetro ID
if(!isset($_GET['id'])){
    die("Error: Falta el identificador (ID) del registro.");
}

$id = intval($_GET['id']);
$database = $_SESSION["database"];

// Configurar tabla según base de datos activa
if($database == "database_rrhh"){
    $tabla = "empleados";
    $pk = "id_empleado";
} else {
    $tabla = "productos";
    $pk = "id_producto";
}

// ==========================================
// PROCESAR GUARDADO DE CAMBIOS (POST)
// ==========================================
if($_SERVER["REQUEST_METHOD"] == "POST"){
    if($database == "database_rrhh"){
        $nombre = $_POST['nombre'];
        $apellidos = $_POST['apellidos'];
        $email = $_POST['email'];
        $salario = $_POST['salario'];
        $sql_update = "UPDATE empleados SET nombre='$nombre', apellidos='$apellidos', email='$email', salario='$salario' WHERE id_empleado=$id";
    } else {
        $codigo = $_POST['codigo'];
        $nombre = $_POST['nombre'];
        $precio = $_POST['precio'];
        $stock = $_POST['stock'];
        $sql_update = "UPDATE productos SET codigo='$codigo', nombre='$nombre', precio='$precio', stock='$stock' WHERE id_producto=$id";
    }

    if($conn->query($sql_update) === TRUE){
        header("Location: ver_registros.php");
        exit();
    } else {
        die("Error al actualizar los datos: " . $conn->error);
    }
}

// ==========================================
// LEER DATOS ACTUALES PARA EL FORMULARIO (GET)
// ==========================================
$sql_select = "SELECT * FROM $tabla WHERE $pk = $id";
$resultado = $conn->query($sql_select);

if(!$resultado || $resultado->num_rows == 0){
    die("Error: Registro no localizado en la tabla " . $tabla);
}

$fila = $resultado->fetch_assoc();
?>
<!DOCTYPE html>
<html lang="es">
<head>
    <meta charset="UTF-8">
    <title>Editar Registro</title>
</head>
<body style="font-family: Arial, sans-serif; margin: 30px;">

    <h1>Editar Registro (ID: <?php echo $id; ?>)</h1>
    <p>Base de datos activa: <strong><?php echo htmlspecialchars($database); ?></strong></p>
    <hr>

    <form method="POST">
    <?php
    // Renderizado seguro mediante PHP puro para evitar fallos de apertura/cierre de etiquetas
    if($database == "database_rrhh") {
        echo '<label><strong>Nombre:</strong></label><br>';
        echo '<input type="text" name="nombre" value="'.htmlspecialchars($fila['nombre']).'" required style="width:300px; padding:5px;"><br><br>';
        
        echo '<label><strong>Apellidos:</strong></label><br>';
        echo '<input type="text" name="apellidos" value="'.htmlspecialchars($fila['apellidos']).'" required style="width:300px; padding:5px;"><br><br>';
        
        echo '<label><strong>Email:</strong></label><br>';
        echo '<input type="email" name="email" value="'.htmlspecialchars($fila['email']).'" required style="width:300px; padding:5px;"><br><br>';
        
        echo '<label><strong>Salario (€):</strong></label><br>';
        echo '<input type="number" step="0.01" name="salario" value="'.htmlspecialchars($fila['salario']).'" required style="width:300px; padding:5px;"><br><br>';
    } else {
        echo '<label><strong>Código de Producto:</strong></label><br>';
        echo '<input type="text" name="codigo" value="'.htmlspecialchars($fila['codigo']).'" required style="width:300px; padding:5px;"><br><br>';
        
        echo '<label><strong>Nombre del Artículo:</strong></label><br>';
        echo '<input type="text" name="nombre" value="'.htmlspecialchars($fila['nombre']).'" required style="width:300px; padding:5px;"><br><br>';
        
        echo '<label><strong>Precio (€):</strong></label><br>';
        echo '<input type="number" step="0.01" name="precio" value="'.htmlspecialchars($fila['precio']).'" required style="width:300px; padding:5px;"><br><br>';
        
        echo '<label><strong>Stock:</strong></label><br>';
        echo '<input type="number" name="stock" value="'.htmlspecialchars($fila['stock']).'" required style="width:300px; padding:5px;"><br><br>';
    }
    ?>
        <hr>
        <button type="submit" style="padding: 10px 20px; background-color: #2196F3; color: white; border: none; cursor: pointer; font-weight: bold;">Guardar Cambios</button>
        <a href="ver_registros.php" style="margin-left: 20px; text-decoration: none; color: #333;">Volver Atrás</a>
    </form>

</body>
</html>