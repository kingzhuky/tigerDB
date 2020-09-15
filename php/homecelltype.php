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

mysqli_query($conn , "set names utf8");

mysqli_select_db( $conn, 'tiger' );

$gene = $_GET['gene'];
//$type=$_GET['type'];

  // query data
  //$sql = "SELECT * FROM ".$type." WHERE GENE_SYMBOL='".$gene."'";
  $sql = "SELECT abs(homemarkertable.Log2FoldChange),homescinfo.CancerType,homescinfo.CellType,homemarkertable.Log2FoldChange FROM homemarkertable,homescinfo WHERE GENE_SYMBOL='".$gene."' AND homemarkertable.SCID=homescinfo.SCID";

$sql2 = "SELECT DISTINCT homescinfo.CancerType FROM homemarkertable,homescinfo WHERE GENE_SYMBOL='".$gene."' AND homemarkertable.SCID=homescinfo.SCID";


  $infos = array();
  $cancers = array();
  // 拼接最终SQL
  
  $dataResult = mysqli_query($conn,$sql);
  $dataResult2 = mysqli_query($conn,$sql2);

  while ($row = mysqli_fetch_assoc($dataResult)) {
      array_push($infos,$row);
  }

   while ($row = mysqli_fetch_assoc($dataResult2)) {
      array_push($cancers,$row);
  }

  echo json_encode(array(
      "status"=>200,
      "sql"=>$sql,
      "list" =>$infos // necessary
      "cancers" =>$cancers // necessary
      ),JSON_UNESCAPED_UNICODE); 
      mysql_close($conn);
?>