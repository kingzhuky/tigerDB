<?php
header("Content-type: text/html;charset=utf-8");
if(PATH_SEPARATOR==':'){
  $conn=mysqli_connect("localhost:3306","read_only_user","dfdl651ZLYY.");
}else{
  $conn=mysqli_connect("localhost:3307","read_only_user","dfdl651ZLYY.");
}
if(!$conn){
  die("连接失败".mysqli_error($conn));
}

mysqli_query($conn, "set names utf8");

mysqli_select_db($conn, 'tiger');

$tabl = $_GET['table'];

$sql = "SELECT * FROM ".$tabl;

$tabledata= array();
// 拼接最终SQL

$dataResult = mysqli_query($conn,$sql);

while ($row = mysqli_fetch_assoc($dataResult)) {
array_push($tabledata,$row);
}

echo json_encode(array(
  "status" => 200,
  "sql"=>$sql,
  "tabledata" => $tabledata, // necessary
  ),JSON_UNESCAPED_UNICODE); 
mysql_close($conn);

?>