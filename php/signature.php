<?php 
header("Content-Type:application/json;charset=UTF8");
$gene=$_GET['gene']; 
$cancer=$_GET['cancer'];
$signature=$_GET['signature'];
$normalMed=$_GET['normalMed'];
$normalGene=$_GET['normalGene'];
$corMed=$_GET['corMed'];
$mergedatasets=$_GET['mergedatasets'];
$datatype=$_GET['datatype'];

if(PATH_SEPARATOR==':'){
  $zhiling="sudo Rscript correlation_TCGA.R $gene $cancer $signature $normalMed $normalGene $corMed $mergedatasets $datatype";
}else{
  $zhiling="Rscript correlation_TCGA.R $gene $cancer $signature $normalMed $normalGene $corMed $mergedatasets $datatype";
}

exec($zhiling,$output,$status);

//执行成功都是返回0
echo json_encode(array(
// "zhiling" =>$zhiling,
   "output" => $output,
   "status"=>$status
    ),JSON_UNESCAPED_UNICODE); 

?>