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
$CellType = $_GET['CellType'];
$CancerType = $_GET['CancerType'];
$GlobalCluster = $_GET['GlobalCluster'];

$currentPage = $_GET['currentPage'];
$pageSize = $_GET['pageSize'];
$startPos=($currentPage-1)*$pageSize;

$sql ="SELECT  a.genea,a.geneb,a.r,b.CellType,a.COEAID,a.SCID,b.datasetid,b.GlobalCluster FROM home_coea_table as a,homescinfo as b WHERE a.genea='".$gene."' AND a.SCID=b.SCID ";
$sqlTotal ="SELECT COUNT(1) FROM home_coea_table as a,homescinfo as b WHERE a.genea='".$gene."' AND a.SCID=b.SCID";


if($CellType!==""){
  $sql=$sql." AND b.CellType='".$CellType."'";
  $sqlTotal=$sqlTotal." AND b.CellType='".$CellType."'";
}

if($CancerType!==""){
  $sql=$sql." AND b.datasetid='".$CancerType."'";
  $sqlTotal=$sqlTotal." AND b.datasetid='".$CancerType."'";
}
if($GlobalCluster!==""){
  $sql=$sql." AND b.GlobalCluster='".$GlobalCluster."'";
  $sqlTotal=$sqlTotal." AND b.GlobalCluster='".$GlobalCluster."'";
}

$sql = $sql." LIMIT ".$startPos.",".$pageSize;





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
    // "sql"=>$sql,
      "total"=>$total,
      "list" =>$infos // necessary
      ),JSON_UNESCAPED_UNICODE); 

mysql_close($conn);

    
  
?>