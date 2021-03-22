<?php 
header("Content-Type:application/json;charset=UTF8");
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

$cancer=trim($_GET['cancer']); 
$celltype=trim($_GET['celltype']); 
$type=$_GET['type'];  // 用于区分三种情景
$gene=trim($_GET['gene']); 
$gloclu=trim($_GET['gloclu']); 




if ($type=="celltype"){
    // query data 
  
  if(PATH_SEPARATOR==':'){
    $zhiling="sudo Rscript pic.marker.gene.R $cancer $gloclu $gene";
    $zhiling2="sudo Rscript overview.R $cancer $gloclu";
  }else{
    $zhiling="Rscript pic.marker.gene.R $cancer $gloclu $gene";
    $zhiling2="Rscript overview.R $cancer $gloclu";
  }
}else if($type=="evolution"){
  if(PATH_SEPARATOR==':'){
    $zhiling="sudo  Rscript pic.evlou.R $cancer $gloclu $gene";
  }else{
    $zhiling="Rscript pic.evlou.R $cancer $gloclu $gene";
  }
}else if($type=="pathway"){
  if(PATH_SEPARATOR==':'){
    $zhiling="sudo Rscript pic.marker.pathway.R $cancer $gloclu \"$gene\"";
    $zhiling2="sudo Rscript overview.R $cancer $gloclu";
  }else{
    $zhiling="Rscript pic.marker.pathway.R $cancer $gloclu \"$gene\"";
    $zhiling2="Rscript overview.R $cancer $gloclu";
  }
}else if($type=="pathwaydiff"){
  if(PATH_SEPARATOR==':'){
    $zhiling="sudo Rscript pic.TN.pathway.R $cancer $gloclu \"$gene\"";
    $zhiling2="sudo Rscript overview.R $cancer $gloclu";
  }else{
    $zhiling="sudo Rscript pic.TN.pathway.R $cancer $gloclu \"$gene\"";
    $zhiling2="sudo Rscript overview.R $cancer $gloclu";
  }
}else{
  $sql = "SELECT GlobalCluster FROM homescinfo WHERE datasetid = '".$cancer."' AND CellType='".$celltype."'";
  $infos = array();
  // 拼接最终SQL
  
  $dataResult = mysqli_query($conn,$sql);
  
  while ($row = mysqli_fetch_assoc($dataResult)) {
    $gloclu=$row["GlobalCluster"];
  }
  if(PATH_SEPARATOR==':'){
    $zhiling="sudo Rscript pic.TN.gene.R $cancer $gloclu \"$celltype\" $gene";
    $zhiling2="sudo Rscript overview.R $cancer $gloclu";
  }else{
    $zhiling="Rscript pic.TN.gene.R $cancer $gloclu \"$celltype\" $gene";
    $zhiling2="Rscript overview.R $cancer $gloclu";
  }
}







exec($zhiling,$output,$status);
exec($zhiling2,$output2,$status2);

//执行成功都是返回0
echo json_encode(array(
  //  "zhiling" =>$zhiling,
  //  "zhiling2" => $zhiling2,
   "output" => $output,
   "output2" => $output2,
 // "sql"=>$sql,
   "gloclu"=>$gloclu,
   "status"=>$status,
   "status2"=>$status2
    ),JSON_UNESCAPED_UNICODE); 

?>
