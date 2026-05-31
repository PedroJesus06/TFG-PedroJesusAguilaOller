<?php

// Mostrar errores
ini_set('display_errors', 1);
error_reporting(E_ALL);


// Inicia sesión
session_start();


// Verifica login
if(!isset($_SESSION["usuario"])){

    header("Location: login.php");

    exit();
}


// Verifica base de datos
if(!isset($_SESSION["database"])){

    header("Location: seleccionar_db.php");

    exit();
}

?>

<!DOCTYPE html>

<html lang="es">

<head>

    <!-- Codificación -->
    <meta charset="UTF-8">

    <!-- Título -->
    <title>Dashboard</title>

</head>

<body>

    <!-- Contenedor principal -->
    <div>

        <!-- Título principal -->
        <h1>Panel de Administración</h1>

        <hr>

        <!-- Usuario actual -->
        <p>

            <strong>Usuario:</strong>

            <?php echo $_SESSION["usuario"]; ?>

        </p>

        <!-- Rol -->
        <p>

            <strong>Rol:</strong>

            <?php echo $_SESSION["rol"]; ?>

        </p>

        <!-- Base de datos -->
        <p>

            <strong>Base de datos:</strong>

            <?php echo $_SESSION["database"]; ?>

        </p>

        <hr>

        <!-- Ver registros -->
        <a href="ver_registros.php">

            Ver registros

        </a>

        <br><br>

        <!-- Consultar registros -->
        <a href="consultar_registro.php">

            Consultar registros

        </a>

        <br><br>

        <?php

        // Opciones solo administrador
        if($_SESSION["rol"] == "admin"){

        ?>

            <!-- Insertar -->
            <a href="insertar_registro.php">

                Insertar registros

            </a>

            <br><br>

        <?php

        }

        ?>

        <!-- Cerrar sesión -->
        <a href="logout.php">

            Cerrar sesión

        </a>

    </div>

</body>

</html>