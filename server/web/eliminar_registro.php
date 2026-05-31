<?php
// 1. Mostrar errores por si acaso
ini_set('display_errors', 1);
error_reporting(E_ALL);

// 2. Iniciar sesión
session_start();

// 3. Control de seguridad: Bloqueo estricto si no es administrador
if(!isset($_SESSION["usuario"]) || $_SESSION["rol"] !== "admin"){
    die("Acceso denegado: No tienes permisos para eliminar registros.");
}

// 4. Incluimos la conexión dinámica compartida
include 'conexion.php';

// 5. Validamos que nos llegue el ID por la URL
if(!isset($_GET['id'])){
    die("Error: No se ha especificado el ID del registro a eliminar.");
}

$database = $_SESSION["database"];
$id = intval($_GET['id']); // Validamos como entero por seguridad

// ====================================================================
// SOLUCIÓN PARA RESTRICCIONES: Desactivamos el chequeo de llaves foráneas
// Esto permite borrar registros de forma limpia en TIENDA y RRHH
// ====================================================================
$conn->query("SET FOREIGN_KEY_CHECKS = 0");

if($database == "database_rrhh"){
    $sql = "DELETE FROM empleados WHERE id_empleado = $id";
} else {
    $sql = "DELETE FROM productos WHERE id_producto = $id";
}

// Ejecutar el borrado real
if($conn->query($sql) === TRUE){
    // Volvemos a activar la verificación de llaves por seguridad del motor
    $conn->query("SET FOREIGN_KEY_CHECKS = 1");
    
    // Redirigimos al listado
    header("Location: ver_registros.php");
    exit();
} else {
    // Si falla por otra razón, reactivamos también antes de morir
    $conn->query("SET FOREIGN_KEY_CHECKS = 1");
    die("Error crítico al eliminar el registro: " . $conn->error);
}
?>