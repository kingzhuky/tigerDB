<?php 
header("Content-Type:application/json;charset=UTF8");
$cancer=$_GET['cancer']; 
$celltype1=$_GET['celltype1']; 
$celltype2=$_GET['celltype2'];
$type=$_GET['datatype'];

if($type!=="table"){
  if(PATH_SEPARATOR==':'){
    $zhiling="sudo Rscript pic.crosstalk.R $cancer \"$celltype1\" \"$celltype2\"";
    }else{
    $zhiling="Rscript pic.crosstalk.R $cancer \"$celltype1\" \"$celltype2\"";
  }
}else{
  if(PATH_SEPARATOR==':'){
    $zhiling="sudo Rscript pic.crosstalk.table.R $cancer \"$celltype1\" \"$celltype2\"";
    }else{
    $zhiling="Rscript pic.crosstalk.table.R $cancer \"$celltype1\" \"$celltype2\"";
  }
}


exec($zhiling,$output,$status);

//执行成功都是返回0
echo json_encode(array(
   "zhiling" => $zhiling,
   "output" => $output,
   "status" => $status
    ),JSON_UNESCAPED_UNICODE); 

?>