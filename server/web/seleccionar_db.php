<?php
session_start();
if(!isset($_SESSION["usuario"])){
    header("Location: login.php");
    exit();
}

if($_SERVER["REQUEST_METHOD"] == "POST"){
    $_SESSION["database"] = $_POST["database"];
    header("Location: dashboard.php");
    exit();
}
?>
<!DOCTYPE html>
<html lang="es">
<head>
    <meta charset="UTF-8">
    <title>Seleccionar Base de Datos</title>
</head>
<body>
<div>
    <h1>Seleccionar Base de Datos</h1>
    <form method="POST">
        <select name="database">
            <option value="database_rrhh">Recursos Humanos</option>
            <option value="database_tienda">Tienda</option>
        </select>
        <br><br>
        <button type="submit">Acceder</button>
    </form>
</div>
</body>
</html>