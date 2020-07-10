<?php 
header("Content-Type:application/json;charset=UTF8");
$gene=$_GET['gene']; 
#$cancer=$_GET['cancer'];
$signature=$_GET['signature'];
$normalMed=$_GET['normalMed'];
$normalGene=$_GET['normalGene'];
$corMed=$_GET['corMed'];
$mergedatasets=$_GET['mergedatasets'];
$datatype=$_GET['datatype'];

$zhiling="sudo Rscript survival.R $gene  $normalMed $normalGene $corMed $mergedatasets $datatype";

exec("Rscript survival.R $zhiling",$output, $status);

//执行成功都是返回0
echo json_encode(array(
   "gene" => $gene,
   "signature" =>$signature,
   "normalMed" =>$normalMed,
   "normalGene" =>$normalGene,
   "corMed" =>$corMed,
   "mergedatasets" =>$mergedatasets,
   "datatype" =>$datatype,
   "zhiling" =>$zhiling,
   "output" => $output,
   "status"=>$status
    ),JSON_UNESCAPED_UNICODE); 

?>