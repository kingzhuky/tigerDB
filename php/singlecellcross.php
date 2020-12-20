<?php 
header("Content-Type:application/json;charset=UTF8");
$cancer=$_GET['cancer']; 
$gloclu=$_GET['gloclu']; 
$subclu=$_GET['subclu'];

if(PATH_SEPARATOR==':'){
  $zhiling="sudo Rscript pic.crosstalk.table.R $cancer $gloclu \"$subclu\"";
  }else{
  $zhiling="Rscript pic.crosstalk.table.R $cancer $gloclu \"$subclu\"";
}


exec($zhiling,$output,$status);

//执行成功都是返回0
echo json_encode(array(
   "zhiling" =>$zhiling,
   "output" => $output,
   "status"=>$status
    ),JSON_UNESCAPED_UNICODE); 

?>