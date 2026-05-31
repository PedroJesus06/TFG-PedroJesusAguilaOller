<?php
// Inicia la sesión del usuario
session_start();


// Redirige automáticamente al login
header("Location: login.php");

exit();
?>