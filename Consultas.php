<!DOCTYPE HTML>  
<html>
<head>
<style>
.error {color: #FF0000;}
.success {color: #008000;}
</style>
</head>
<body> 

<?php

session_start();

$serverName = 'ERICK';
$connectionInfo = array('Database'=>'ProyectoBD');
$conn = sqlsrv_connect($serverName, $connectionInfo);

$Usuario = "";

if(isset($_SESSION['Usuario']))
    $Usuario = $_SESSION['Usuario'];

if($_GET){
  $Usuario = $_GET['user']; // print_r($_GET); //remember to add semicolon      
}else{
  $Usuario = $Usuario;
}

$_SESSION['Usuario'] = $Usuario;

$name = $inicioSemanaD = $finalSemanaD = $inicioMesD = $finalMesD = $inicioSemanaS = $finalSemanaS = $fechaCompareI = $fechaCompareF = "";
$found = "false";

?>
<div id="info" class="container">
<h1>Panel de Consultas</h1>
<form method="post" action="<?php echo htmlspecialchars($_SERVER["PHP_SELF"]);?>"> 
  <h3>Consulta de Planillas</h3>
  <input type="submit" name="submit" value="Planillas Semanales">
  <input type="submit" name="submit" value="Planillas Mensuales">
  <h3>Consulta de Deducciones</h3>
  <h4>Planilla Semanal</h4>
  Fecha Inicio:<input type="text" name="inicioSded" value="<?php echo $inicioSemanaD;?>">
  <br><br>
  Fecha Fin:<input type="text" name="finalSded" value="<?php echo $finalSemanaD;?>">
  <br><br>
  <input type="submit" name="submit" value="Consultar Deducciones Semanales">
  <h4>Planilla Mensual</h4>
  Fecha Inicio:<input type="text" name="inicioMded" value="<?php echo $inicioMesD;?>">
  <br><br>
  Fecha Fin:<input type="text" name="finalMded" value="<?php echo $finalMesD;?>">
  <br><br>
  <input type="submit" name="submit" value="Consultar Deducciones Mensuales">
  <h3>Consulta de Salario Bruto Semanal</h3>
  Fecha Inicio:<input type="text" name="inicioSsal" value="<?php echo $inicioSemanaS;?>">
  <br><br>
  Fecha Fin:<input type="text" name="finalSsal" value="<?php echo $finalSemanaS;?>">
  <br><br>
  <input type="submit" name="submit" value="Consultar Salario Bruto">
  <h3>Salir</h3>
  <input type="submit" name="submit" value="Log Off">
  <br><br>
</form>
</div>
<?php
if ($_SERVER["REQUEST_METHOD"] == "POST") {
  if($_POST['submit'] == 'Log Off'){
    header("Location: http://localhost/php_program/Log%20In%20Admin.php");
    exit();
  }
  else if($_POST['submit'] == 'Consultar Deducciones Semanales'){
    $found = "false";
    $inicioSemanaD = test_input($_POST["inicioSded"]);
    $finalSemanaD = test_input($_POST["finalSded"]);
    if(empty($inicioSemanaD)||empty($finalSemanaD)){
      echo "Hay espacios vacios";
    }
    else{
      $tsql = "EXEC [dbo].[RetornarFechaS] @inUsername = $Usuario";
      $stmt = sqlsrv_query( $conn, $tsql);
      while( $row = sqlsrv_fetch_array($stmt, SQLSRV_FETCH_ASSOC) ) {
        $fechaCompareI = date_format($row['FechaInicio'],"Ymd");
        $fechaCompareF = date_format($row['FechaFinal'],"Ymd");
        if($fechaCompareI==$inicioSemanaD && $fechaCompareF==$finalSemanaD){
            $found="true";
        }
      }
      if($found=="false"){
        echo "No existe una planilla semanal con las fechas dadas";
      }
      else{
        $tsql = "EXEC ConsultarDeducciones @inUsername = $Usuario, @inFechaIni = $inicioSemanaD, @inFechaFin = $finalSemanaD";
        $stmt = sqlsrv_query($conn, $tsql);
        echo "<table border='4' class='stats' cellspacing='0'>
          <tr>
          <td class='hed' colspan='8'>Deducciones de la Semana</td>
          </tr>
          <tr>
          <th>Nombre</th>
          <th>Porcentual</th>
          <th>Monto</th>
          </tr>"; 
        while( $row = sqlsrv_fetch_array($stmt, SQLSRV_FETCH_ASSOC) ) {
          echo "<tr>";
          echo "<td>" . $row['Nombre'] . "</td>";
          echo "<td>" . $row['Porcentual'] . "</td>";
          echo "<td>" . $row['Monto'] . "</td>";
          echo "</tr>";
        }
      }
    }
  }
  else if($_POST['submit'] == 'Consultar Deducciones Mensuales'){
    $found = "false";
    $inicioMesD = test_input($_POST["inicioMded"]);
    $finalMesD = test_input($_POST["finalMded"]);
    if(empty($inicioMesD)||empty($finalMesD)){
      echo "Hay espacios vacios";
    }
    else{
      $tsql = "EXEC [dbo].[RetornarFechaM] @inUsername = $Usuario";
      $stmt = sqlsrv_query( $conn, $tsql);
      while( $row = sqlsrv_fetch_array($stmt, SQLSRV_FETCH_ASSOC) ) {
        $fechaCompareI = date_format($row['FechaInicio'],"Ymd");
        $fechaCompareF = date_format($row['FechaFinal'],"Ymd");
        if($fechaCompareI==$inicioMesD && $fechaCompareF==$finalMesD){
            $found="true";
        }
      }
      if($found=="false"){
        echo "No existe una planilla semanal con las fechas dadas";
      }
      else{
        $tsql = "EXEC ConsultarDeducciones @inUsername = $Usuario, @inFechaIni = $inicioMesD, @inFechaFin = $finalMesD";
        $stmt = sqlsrv_query($conn, $tsql);
        echo "<table border='4' class='stats' cellspacing='0'>
          <tr>
          <td class='hed' colspan='8'>Deducciones del Mes</td>
          </tr>
          <tr>
          <th>Nombre</th>
          <th>Porcentual</th>
          <th>Monto</th>
          </tr>"; 
        while( $row = sqlsrv_fetch_array($stmt, SQLSRV_FETCH_ASSOC) ) {
          echo "<tr>";
          echo "<td>" . $row['Nombre'] . "</td>";
          echo "<td>" . $row['Porcentual'] . "</td>";
          echo "<td>" . $row['Monto'] . "</td>";
          echo "</tr>";
        }
      }
    }
  }
  else if ($_POST['submit'] == 'Consultar Salario Bruto'){
    $found = "false";
    $inicioSemanaS = test_input($_POST["inicioSsal"]);
    $finalSemanaS = test_input($_POST["finalSsal"]);
    if(empty($inicioSemanaS)||empty($finalSemanaS)){
      echo "Hay espacios vacios";
    }
    else{
      $tsql = "EXEC [dbo].[RetornarFechaS] @inUsername = $Usuario";
      $stmt = sqlsrv_query( $conn, $tsql);
      while( $row = sqlsrv_fetch_array($stmt, SQLSRV_FETCH_ASSOC) ) {
        $fechaCompareI = date_format($row['FechaInicio'],"Ymd");
        $fechaCompareF = date_format($row['FechaFinal'],"Ymd");
        if($fechaCompareI==$inicioSemanaS && $fechaCompareF==$finalSemanaS){
            $found="true";
        }
      }
      if($found=="false"){
        echo "No existe una planilla semanal con las fechas dadas";
      }
      else{
        $tsql = "EXEC ConsultarAsistencias @inUsername = $Usuario, @inFechaIni = $inicioSemanaS, @inFechaFin = $finalSemanaS";
        $stmt = sqlsrv_query($conn, $tsql);
        echo "<table border='4' class='stats' cellspacing='0'>
          <tr>
          <td class='hed' colspan='8'>Salario Bruto de la Semana</td>
          </tr>
          <tr>
          <th>Nombre</th>
          <th>Entrada</th>
          <th>Salida</th>
          <th>Horas</th>
          <th>Monto</th>
          </tr>"; 
        while( $row = sqlsrv_fetch_array($stmt, SQLSRV_FETCH_ASSOC) ) {
          $date1 = date_format($row['FechaEntrada'],"Ymd H:i:s");
          $date2 = date_format($row['FechaSalida'],"Ymd H:i:s");
          echo "<tr>";
          echo "<td>" . $row['Nombre'] . "</td>";
          echo "<td>" . $date1 . "</td>";
          echo "<td>" . $date2 . "</td>";
          echo "<td>" . $row['Horas'] . "</td>";
          echo "<td>" . $row['Monto'] . "</td>";
          echo "</tr>";
        }
      }
    }
  }
  else if ($_POST['submit'] == 'Planillas Semanales'){
    $tsql = "EXEC ConsultaSemanas @inUsername = $Usuario";
    $stmt = sqlsrv_query($conn, $tsql);
    echo "<table border='4' class='stats' cellspacing='0'>
      <tr>
      <td class='hed' colspan='8'>Planillas Semanales</td>
      </tr>
      <tr>
      <th>Inicio</th>
      <th>Fin</th>
      <th>Salario Bruto</th>
      <th>Salario Neto</th>
      <th>Deducciones</th>
      <th>Horas Ordinarias</th>
      <th>Horas Extras</th>
      <th>Horas Extras (Doble)</th>
      </tr>"; 
    while( $row = sqlsrv_fetch_array($stmt, SQLSRV_FETCH_ASSOC) ) {
      $date1 = date_format($row['FechaInicio'],"Ymd");
      $date2 = date_format($row['FechaFinal'],"Ymd");
      echo "<tr>";
      echo "<td>" . $date1 . "</td>";
      echo "<td>" . $date2 . "</td>";
      echo "<td>" . $row['SalarioBruto'] . "</td>";
      echo "<td>" . $row['SalarioNeto'] . "</td>";
      echo "<td>" . $row['Deducciones'] . "</td>";
      echo "<td>" . $row['HO'] . "</td>";
      echo "<td>" . $row['HE'] . "</td>";
      echo "<td>" . $row['HD'] . "</td>";
      echo "</tr>";
    }
  }
  else if ($_POST['submit'] == 'Planillas Mensuales'){
    $tsql = "EXEC SalariosAnuales @inUsername = $Usuario";
    $stmt = sqlsrv_query($conn, $tsql);
    echo "<table border='4' class='stats' cellspacing='0'>
      <tr>
      <td class='hed' colspan='8'>Planillas Mensuales</td>
      </tr>
      <tr>
      <th>Inicio</th>
      <th>Fin</th>
      <th>Salario Bruto</th>
      <th>Salario Neto</th>
      <th>Deducciones</th>
      </tr>"; 
    while( $row = sqlsrv_fetch_array($stmt, SQLSRV_FETCH_ASSOC) ) {
      $date1 = date_format($row['FechaInicio'],"Ymd");
      $date2 = date_format($row['FechaFinal'],"Ymd");
      echo "<tr>";
      echo "<td>" . $date1 . "</td>";
      echo "<td>" . $date2 . "</td>";
      echo "<td>" . $row['SalarioBruto'] . "</td>";
      echo "<td>" . $row['SalarioNeto'] . "</td>";
      echo "<td>" . $row['Deducciones'] . "</td>";
      echo "</tr>";
    }
  }
}

function test_input($data) {
  $data = trim($data);
  $data = stripslashes($data);
  $data = htmlspecialchars($data);
  return $data;
}
?>
</body>
</html>