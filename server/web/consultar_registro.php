<?php
// 1. Forzar visualización absoluta de errores
ini_set('display_errors', 1);
ini_set('display_startup_errors', 1);
error_reporting(E_ALL);

// 2. Control estricto de sesión
session_start();
if(!isset($_SESSION["usuario"])){
    header("Location: login.php");
    exit();
}

// 3. Conexión centralizada inteligente
include 'conexion.php';
$database = $_SESSION["database"];

$resultado = null;
$busqueda = "";

// 4. Procesar la petición de búsqueda (GET)
if (isset($_GET['buscar']) && !empty(trim($_GET['buscar']))) {
    $busqueda = $conn->real_escape_string(trim($_GET['buscar']));
    
    if ($database == "database_rrhh") {
        // Búsqueda inteligente en Recursos Humanos (por ID, Nombre o Apellidos)
        $sql = "SELECT * FROM empleados WHERE id_empleado = '$busqueda' OR nombre LIKE '%$busqueda%' OR apellidos LIKE '%$busqueda%'";
    } else {
        // Búsqueda inteligente en la Tienda (por ID, Código o Nombre del Artículo)
        $sql = "SELECT * FROM productos WHERE id_producto = '$busqueda' OR codigo = '$busqueda' OR nombre LIKE '%$busqueda%'";
    }
    
    $resultado = $conn->query($sql);
}
?>
<!DOCTYPE html>
<html lang="es">
<head>
    <meta charset="UTF-8">
    <title>Consultar Registro</title>
</head>
<body style="font-family: Arial, sans-serif; margin: 30px;">

    <h1>Consultar Registros</h1>
    <p>Entorno de Auditoría Activo: <strong><?php echo htmlspecialchars($database); ?></strong></p>
    <hr>

    <form method="GET" action="consultar_registro.php">
        <label><strong>Introduzca el término a buscar:</strong></label><br>
        <input type="text" name="buscar" value="<?php echo htmlspecialchars($busqueda); ?>" 
               placeholder="<?php echo ($database == 'database_rrhh') ? 'Ej: ID, Nombre o Apellido' : 'Ej: ID, Código o Nombre'; ?>" 
               required style="width:350px; padding:7px; margin-top:5px; font-size:14px;">
        <button type="submit" style="padding: 7px 15px; background-color: #2196F3; color: white; border: none; cursor: pointer; font-weight: bold; font-size:14px;">Buscar Registro</button>
        
        <?php if (!empty($busqueda)): ?>
            <a href="consultar_registro.php" style="margin-left: 15px; text-decoration: none; color: #555; font-size: 14px;">❌ Limpiar Filtro</a>
        <?php endif; ?>
    </form>

    <br><br>

    <?php if ($resultado !== null): ?>
        <h2>Resultados para: "<?php echo htmlspecialchars($busqueda); ?>"</h2>
        
        <?php if ($resultado->num_rows > 0): ?>
            <table border="1" cellpadding="10" style="border-collapse: collapse; width: 100%; max-width: 900px; text-align: left;">
                <tr style="background-color: #f2f2f2;">
                    <?php if ($database == "database_rrhh"): ?>
                        <th>ID</th>
                        <th>Nombre</th>
                        <th>Apellidos</th>
                        <th>Email</th>
                        <th>Salario</th>
                        <th>Fecha Contratación</th>
                    <?php else: ?>
                        <th>ID</th>
                        <th>Código</th>
                        <th>Nombre</th>
                        <th>Precio</th>
                        <th>Stock</th>
                    <?php endif; ?>
                    
                    <?php if ($_SESSION["rol"] == "admin"): ?>
                        <th>Acciones de Auditoría</th>
                    <?php endif; ?>
                </tr>

                <?php while ($fila = $resultado->fetch_assoc()): ?>
                    <tr>
                        <?php if ($database == "database_rrhh"): ?>
                            <td><?php echo $fila["id_empleado"]; ?></td>
                            <td><?php echo $fila["nombre"]; ?></td>
                            <td><?php echo $fila["apellidos"]; ?></td>
                            <td><?php echo $fila["email"]; ?></td>
                            <td><?php echo $fila["salario"]; ?> €</td>
                            <td><?php echo isset($fila["fecha_contratacion"]) ? $fila["fecha_contratacion"] : '-'; ?></td>
                            <?php $id = $fila["id_empleado"]; ?>
                        <?php else: ?>
                            <td><?php echo $fila["id_producto"]; ?></td>
                            <td><?php echo $fila["codigo"]; ?></td>
                            <td><?php echo $fila["nombre"]; ?></td>
                            <td><?php echo $fila["precio"]; ?> €</td>
                            <td><?php echo $fila["stock"]; ?></td>
                            <?php $id = $fila["id_producto"]; ?>
                        <?php endif; ?>

                        <?php if ($_SESSION["rol"] == "admin"): ?>
                            <td>
                                <a href="editar_registro.php?id=<?php echo $id; ?>" style="color: #4CAF50; font-weight: bold; text-decoration: none;">Editar</a> | 
                                <a href="eliminar_registro.php?id=<?php echo $id; ?>" style="color: #f44336; font-weight: bold; text-decoration: none;" onclick="return confirm('¿Confirmar la eliminación definitiva de este registro?');">Eliminar</a>
                            </td>
                        <?php endif; ?>
                    </tr>
                <?php endwhile; ?>
            </table>
        <?php else: ?>
            <p style="color: #d32f2f; font-weight: bold; background-color: #fffe0e0; padding: 10px; border-left: 5px solid #d32f2f; max-width: 500px;">
                Ningún registro coincide con los parámetros de búsqueda especificados.
            </p>
        <?php endif; ?>
    <?php endif; ?>

    <hr style="margin-top: 50px;">
    <a href="dashboard.php" style="text-decoration: none; color: #000; font-weight: bold;">← Volver al Panel de Control</a>

</body>
</html>