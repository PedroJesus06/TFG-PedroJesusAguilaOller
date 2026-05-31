<?php
ini_set('display_errors', 1);
error_reporting(E_ALL);
session_start();

if(!isset($_SESSION["usuario"])){
    header("Location: login.php");
    exit();
}

if(!isset($_SESSION["database"])){
    die("No hay base de datos seleccionada");
}

include 'conexion.php';
$database = $_SESSION["database"];

// Comparamos con el nombre real de MySQL
if($database == "database_rrhh"){
    $sql = "SELECT * FROM empleados";
} else {
    $sql = "SELECT * FROM productos";
}

$resultado = $conn->query($sql);

if(!$resultado){
    die("Error SQL ejecutado por " . $_SESSION["usuario"] . ": " . $conn->error);
}
?>
<!DOCTYPE html>
<html lang="es">
<head>
    <meta charset="UTF-8">
    <title>Ver registros</title>
</head>
<body>
<div>
    <h1>Listado de registros (Base de datos: <?php echo htmlspecialchars($database); ?>)</h1>
    <hr>

    <table border="1" cellpadding="10">
        <?php
        if($database == "database_rrhh"){
            echo "<tr><th>ID</th><th>Nombre</th><th>Apellidos</th><th>Email</th><th>Salario</th>";
        } else {
            echo "<tr><th>ID</th><th>Código</th><th>Nombre</th><th>Precio</th><th>Stock</th>";
        }

        if($_SESSION["rol"] == "admin"){
            echo "<th>Acciones</th>";
        }
        echo "</tr>";

        while($fila = $resultado->fetch_assoc()){
            echo "<tr>";

            if($database == "database_rrhh"){
                echo "<td>".$fila["id_empleado"]."</td>";
                echo "<td>".$fila["nombre"]."</td>";
                echo "<td>".$fila["apellidos"]."</td>";
                echo "<td>".$fila["email"]."</td>";
                echo "<td>".$fila["salario"]."</td>";
                $id = $fila["id_empleado"];
            } else {
                echo "<td>".$fila["id_producto"]."</td>";
                echo "<td>".$fila["codigo"]."</td>";
                echo "<td>".$fila["nombre"]."</td>";
                echo "<td>".$fila["precio"]."</td>";
                echo "<td>".$fila["stock"]."</td>";
                $id = $fila["id_producto"];
            }

            if($_SESSION["rol"] == "admin"){
                echo "<td>
                        <a href='editar_registro.php?id=$id'>Editar</a> | 
                        <a href='eliminar_registro.php?id=$id'>Eliminar</a>
                      </td>";
            }
            echo "</tr>";
        }
        ?>
    </table>
    <br>
    <a href="dashboard.php">Volver al dashboard</a>
</div>
</body>
</html>