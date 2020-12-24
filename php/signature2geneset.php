<?php
header("Content-Type: text/html; charset=UTF-8");
header('Access-Control-Allow-Origin: *');
header("Access-Control-Allow-Headers: Origin, X-Requested-With, Content-Type, Accept");
header('Access-Control-Allow-Methods: GET, POST, PUT,DELETE');

if(PATH_SEPARATOR==':'){
  $conn=mysqli_connect("localhost:3306","read_only_user","dfdl651ZLYY.");
}else{
  $conn=mysqli_connect("localhost:3307","read_only_user","dfdl651ZLYY.");
}
if(!$conn){
    die("连接失败".mysqli_error($conn));
}

mysqli_query($conn , "set names utf8");

mysqli_select_db( $conn, 'tiger' );

$gene = $_POST['gene'];
$type=$_POST['type'];

  // query data
  $sql = "SELECT GeneSymbol FROM ".$type." WHERE SignatureName='".$gene."' LIMIT 0,1" ;
  $infos = array();
  // 拼接最终SQL
  
  $dataResult = mysqli_query($conn,$sql);

  while ($row = mysqli_fetch_assoc($dataResult)) {
    array_push($infos,$row);
  }

  echo json_encode(array(
      "status"=>200,
    // "sql"=>$sql,
      "list" =>$infos // necessary
      ),JSON_UNESCAPED_UNICODE); 

      mysql_close($conn);
    
  
?>