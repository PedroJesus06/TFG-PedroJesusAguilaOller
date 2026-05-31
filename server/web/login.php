<?php

// Muestra errores PHP
ini_set('display_errors', 1);
error_reporting(E_ALL);


// Inicia sesión
session_start();


// Variable para mostrar errores
$error = "";


// Comprueba si se ha enviado el formulario
if($_SERVER["REQUEST_METHOD"] == "POST"){


    // Guarda usuario introducido
    $usuario = $_POST["usuario"];

    // Guarda contraseña introducida
    $password = $_POST["password"];


    // Login administrador
    if(
        $usuario == "asir_admin" &&
        $password == "AdminContrasenaSegura2026*"
    ){

        // Guarda usuario en sesión
        $_SESSION["usuario"] = $usuario;

        // Guarda rol administrador
        $_SESSION["rol"] = "admin";

        // Redirige selección base de datos
        header("Location: seleccionar_db.php");

        exit();
    }


    // Login usuario limitado
    elseif(
        $usuario == "asir_user" &&
        $password == "UserContrasenaSegura2026*"
    ){

        // Guarda usuario en sesión
        $_SESSION["usuario"] = $usuario;

        // Guarda rol limitado
        $_SESSION["rol"] = "limitado";

        // Redirige selección base de datos
        header("Location: seleccionar_db.php");

        exit();
    }


    // Error credenciales
    else{

        $error = "Usuario o contraseña incorrectos";
    }
}

?>

<!DOCTYPE html>

<html lang="es">

<head>

    <!-- Codificación UTF8 -->
    <meta charset="UTF-8">

    <!-- Título -->
    <title>Login Database.sl</title>

</head>

<body>

    <!-- Contenedor principal -->
    <div>

        <!-- Título -->
        <h1>Login Database.sl</h1>

        <!-- Formulario login -->
        <form method="POST">

            <!-- Etiqueta usuario -->
            <label>Usuario</label>

            <!-- Input usuario -->
            <input
                type="text"
                name="usuario"
                required
            >

            <br><br>

            <!-- Etiqueta contraseña -->
            <label>Contraseña</label>

            <!-- Input contraseña -->
            <input
                type="password"
                name="password"
                required
            >

            <br><br>

            <!-- Botón login -->
            <button type="submit">

                Iniciar sesión

            </button>

        </form>

        <br>

        <!-- Mensaje error -->
        <p>

            <?php echo $error; ?>

        </p>

    </div>

</body>

</html>
