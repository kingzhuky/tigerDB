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

$sigid = $_GET['sigid'];

$sql = "SELECT a.dataset_id, a.".$sigid.", b.Dataset, b.CancerType, b.Therapy, b.PMID, b.SampleSize, b.ResponseSampleCount, b.NonresponseSampleCount FROM sigauctable as a, datesetinfo as b WHERE a.".$sigid." IS NOT NULL AND a.dataset_id=b.DatasetID";
$sqlTotal ="SELECT COUNT(1) FROM sigauctable as a, datesetinfo as b WHERE a.".$sigid." IS NOT NULL AND a.dataset_id=b.DatasetID";

 // query data
 $infos = array();
 // 拼接最终SQL
 
 $dataResult = mysqli_query($conn,$sql);

 while ($row = mysqli_fetch_assoc($dataResult)) {
     array_push($infos,$row);
 }

  // query data
  $total = array();
  // 拼接最终SQL
  
  $dataResultTotal = mysqli_query($conn,$sqlTotal);
 
  while ($row = mysqli_fetch_assoc($dataResultTotal)) {
      array_push($total,intval($row["COUNT(1)"]));
  }


  echo json_encode(array(
      "status"=>200,
      "sql"=>$sql,
      "total"=>$total,
      "list" =>$infos // necessary
      ),JSON_UNESCAPED_UNICODE); 

mysql_close($conn);

    
  
?>