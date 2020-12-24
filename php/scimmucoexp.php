<?php 
header("Content-Type:application/json;charset=UTF8");
$cancer=trim($_GET['cancer']); 
$gloclu=trim($_GET['gloclu']); 
$gene=trim($_GET['gene']); 

if(PATH_SEPARATOR==':'){
  $zhiling="sudo Rscript pic.COEA.R $cancer $gloclu $gene";
}else{
  $zhiling="Rscript pic.COEA.R $cancer $gloclu $gene";
}

exec($zhiling,$output,$status);

//执行成功都是返回0
echo json_encode(array(
// "zhiling" =>$zhiling,
   "output" => $output,
   "status"=>$status
    ),JSON_UNESCAPED_UNICODE); 