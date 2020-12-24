<?php 
header("Content-Type:application/json;charset=UTF8");
$gene=$_GET['gene']; 
$mergedatasets=$_GET['mergedatasets'];
$normalMed=$_GET['normalMed'];
$normalGene=$_GET['normalGene'];
$logScale=$_GET['logScale'];
$datatype=$_GET['datatype'];

if(PATH_SEPARATOR==':'){
  $zhiling="sudo Rscript 1.1.2-exp_levels_treat.R $gene $mergedatasets  $normalMed $normalGene $logScale  $datatype";
  }else{
  $zhiling="Rscript 1.1.2-exp_levels_treat.R $gene $mergedatasets  $normalMed $normalGene $logScale $datatype";
}


exec($zhiling,$output,$status);

//执行成功都是返回0
echo json_encode(array(
// "zhiling" =>$zhiling,
   "output" => $output,
   "status"=>$status
    ),JSON_UNESCAPED_UNICODE); 

?>