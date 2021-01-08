<?php 
header("Content-type: text/html;charset=utf-8");
$cancer=$_GET['cancer']; 
$celltype1=$_GET['celltype1']; 
$celltype2=$_GET['celltype2'];
$type=$_GET['datatype'];

if($type!=="table"){
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
  $celltype_arr = explode("|",explode(",",$celltype2)[1]);
  $gene_arr = explode("_",$celltype1);
  $sql1 ="SELECT GlobalCluster FROM homescinfo WHERE datasetid='".$cancer."' AND CellType='".$celltype_arr[0]."'";
  $sql2 ="SELECT GlobalCluster FROM homescinfo WHERE datasetid='".$cancer."' AND CellType='".$celltype_arr[1]."'";
  $dataResult1 = mysqli_query($conn,$sql1);
  $dataResult2 = mysqli_query($conn,$sql2);
  $glo1 = mysqli_fetch_assoc($dataResult1)["GlobalCluster"];
  $glo2 = mysqli_fetch_assoc($dataResult2)["GlobalCluster"];
  if(PATH_SEPARATOR==':'){
    $zhiling="sudo Rscript pic.crosstalk.R $cancer \"$celltype1\" \"$celltype2\"";
    $zhiling2="sudo Rscript pic.marker.gene.R $cancer \"$glo1\" $gene_arr[0]";
    $zhiling3="sudo Rscript pic.marker.gene.R $cancer \"$glo2\" $gene_arr[1]";
    }else{
    $zhiling="Rscript pic.crosstalk.R $cancer \"$celltype1\" \"$celltype2\"";
    $zhiling2="Rscript pic.marker.gene.R $cancer \"$glo1\" $gene_arr[0]";
    $zhiling3="Rscript pic.marker.gene.R $cancer \"$glo2\" $gene_arr[1]";
  }
  exec($zhiling,$output1,$status);
  // exec($zhiling2,$output2,$status);
  // exec($zhiling3,$output3,$status);
  // $output = [$output1[0].",".$output2[0].",".$output3[0]];
  $output = $output1;
}else{
  if(PATH_SEPARATOR==':'){
    $zhiling="sudo Rscript pic.crosstalk.table.R $cancer \"$celltype1\" \"$celltype2\"";
    $zhiling2="123";
    }else{
    $zhiling="Rscript pic.crosstalk.table.R $cancer \"$celltype1\" \"$celltype2\"";
    $zhiling2="123";
  }
  exec($zhiling,$output,$status);
}




//执行成功都是返回0
echo json_encode(array(
   "zhiling" => $zhiling,
   "zhiling2" => $zhiling2,
   "output" => $output,
   "status" => $status
    ),JSON_UNESCAPED_UNICODE); 

?>