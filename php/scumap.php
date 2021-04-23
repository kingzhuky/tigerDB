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
$type = $_GET['type'];
$umaptable = "scumap_".$datasetid;
$tissuetable = "sctissue_".$datasetid;
$celltypetable = "sccelltype_".$datasetid;

$sql ="SELECT a.Cell_id,a.Tissue_id,a.UMAP_1,a.UMAP_2,a.nCount_RNA,a.nFeature_RNA,b.CellType,b.GlobalCluster FROM ".$umaptable." as a,".$celltypetable." as b WHERE b.GlobalCluster='".$type."' AND a.Celltype_id=b.Celltype_id ";
$sqlTotal ="SELECT CellType FROM ".$celltypetable." WHERE GlobalCluster='".$type."' ";

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
      array_push($total,$row);
  }


  echo json_encode(array(
      "status"=>200,
    "sql"=>$sql,
      "total"=>$total,
      "list" =>$infos // necessary
      ),JSON_UNESCAPED_UNICODE); 

mysql_close($conn);

?>