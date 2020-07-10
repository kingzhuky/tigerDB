<?php 
header("Content-Type:application/json;charset=UTF8");
$gene=$_GET['gene']; 
$normalMed=$_GET['normalMed'];
$normalGene=$_GET['normalGene'];
$expcutoff=$_GET['expcutoff'];
$mergedatasets=$_GET['mergedatasets'];
$datatype=$_GET['datatype'];


if(PATH_SEPARATOR==':'){
  $zhiling="sudo Rscript 1.3-response_surv.R $gene $mergedatasets $normalMed $normalGene $expcutoff  $datatype";
}else{
  $zhiling="Rscript 1.3-response_surv.R $gene $mergedatasets $normalMed $normalGene $expcutoff  $datatype";
}

exec($zhiling,$output,$status);

//执行成功都是返回0
echo json_encode(array(
   "zhiling" =>$zhiling,
   "output" => $output,
   "status"=>$status
    ),JSON_UNESCAPED_UNICODE); 

?>