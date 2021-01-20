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

$datasetid = $_GET['datasetid'];
$conditi=$_GET['conditi'];
$infos = array();
$infosTable = array();

if ($conditi=="Responder"){
  $sql = "SELECT Log2FC,PValue,GENE_SYMBOL FROM homeresponsetable WHERE DatasetID='".$datasetid."' AND `Condition`='R-NR'";
  $dataResult = mysqli_query($conn,$sql);
  while ($row = mysqli_fetch_assoc($dataResult)) {
    $temp= array();
    array_push($temp,$row["Log2FC"]);
    array_push($temp,$row["PValue"]);
    array_push($temp,$row["GENE_SYMBOL"]);
    array_push($infos,array_values($temp));
  }


}else if ($conditi=="Therapy"){
  $sql = "SELECT Log2FC,PValue,GENE_SYMBOL FROM homeresponsetable WHERE DatasetID='".$datasetid."' AND `Condition`='Post-Pre'";
  $dataResult = mysqli_query($conn,$sql);
  while ($row = mysqli_fetch_assoc($dataResult)) {
    $temp= array();
    array_push($temp,$row["Log2FC"]);
    array_push($temp,$row["PValue"]);
    array_push($temp,$row["GENE_SYMBOL"]);
    array_push($infos,array_values($temp));
  }

}else if($conditi=="Survival"){
  $sql = "SELECT ZScore,PValue,GENE_SYMBOL FROM homesurvtable WHERE DatasetID='".$datasetid."' AND `Condition`='Survival'";
  $dataResult = mysqli_query($conn,$sql);
  while ($row = mysqli_fetch_assoc($dataResult)) {
    $temp= array();
    array_push($temp,$row["ZScore"]);
    array_push($temp,$row["PValue"]);
    array_push($temp,$row["GENE_SYMBOL"]);
    array_push($infos,array_values($temp));
  }
}



// query data
#$sql = "SELECT * FROM ".$type." WHERE GENE_SYMBOL='".$gene."'";
  // 拼接最终SQL
  

 


  echo json_encode(array(
      "status"=>200,
      // "sql"=>$sql,
      "sqltable"=>$sqltable,
      "list" =>$infos, // necessary
      "datatable"=>$datatable,
      "infosTable"=>$infosTable
      ),JSON_UNESCAPED_UNICODE); 

mysql_close($conn);

    
  
?>