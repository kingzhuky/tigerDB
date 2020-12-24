<?php 
header("Content-Type:application/json;charset=UTF8");

$cancer=trim($_GET['cancer']); 
$gloclu=trim($_GET['gloclu']); 
$gene=trim($_GET['gene']); 
$clickgene=$_GET['clickgene']; 
$cluster=$_GET['cluster']; 
$method=$_GET['method'];
$isdeletezero=$_GET['delzero'];

if(PATH_SEPARATOR==':'){
  $zhiling="sudo Rscript pic.scatter.R $cancer $gloclu $gene $clickgene \"$cluster\" $method $isdeletezero";
}else{
  $zhiling="Rscript pic.scatter.R $cancer $gloclu $gene $clickgene \"$cluster\" $method $isdeletezero";
}

exec($zhiling,$output,$status);

//执行成功都是返回0
echo json_encode(array(
// "zhiling" =>$zhiling,
   "output" => $output,
   "status"=>$status
    ),JSON_UNESCAPED_UNICODE); 

?>
