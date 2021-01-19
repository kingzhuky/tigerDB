<?php 
header("Content-Type:application/json;charset=UTF8");
$cancer=$_GET['cancer']; 
$gloclu=$_GET['gloclu'];

if(PATH_SEPARATOR==':'){
  $zhiling="sudo Rscript overview.R $cancer $gloclu";
  $zhiling2="sudo Rscript generate_json_cellnum.R $cancer $gloclu";
  }else{
  $zhiling="Rscript overview.R $cancer  $gloclu";
  $zhiling2="Rscript generate_json_cellnum.R $cancer $gloclu";
}


exec($zhiling,$output,$status);
exec($zhiling2,$output2,$status2);
//执行成功都是返回0
echo json_encode(array(
   "zhiling" =>$zhiling,
   "output" => $output,
   "status" => $status,
   "cellnum" => $output2
    ),JSON_UNESCAPED_UNICODE); 

?>