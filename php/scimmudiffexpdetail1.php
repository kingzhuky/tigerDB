<?php 
header("Content-Type:application/json;charset=UTF8");

$cancer=trim($_GET['cancer']); 
$gloclu=trim($_GET['gloclu']); 
$subclu=$_GET['subclu'];
$gene=trim($_GET['gene']); 


if(PATH_SEPARATOR==':'){
  $zhiling="sudo pic.gene.R $cancer $gloclu \"$subclu\" $gene";
}else{
  $zhiling="Rscript pic.gene.R $cancer $gloclu \"$subclu\" $gene";
}

exec($zhiling,$output,$status);

//执行成功都是返回0
echo json_encode(array(
   "zhiling" =>$zhiling,
   "output" => $output,
   "status"=>$status
    ),JSON_UNESCAPED_UNICODE); 

?>
