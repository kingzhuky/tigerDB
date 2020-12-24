<?php 
header("Content-Type:application/json;charset=UTF8");
$Rdata=$_GET['Rdata']; 
$cancer=$_GET['cancer'];
$signature=$_GET['signature'];
$normalMed=$_GET['normalMed'];
$normalGene=$_GET['normalGene'];
$corMed=$_GET['corMed'];
$datatype=$_GET['datatype'];

if(PATH_SEPARATOR==':'){
  $zhiling="sudo Rscript 2.2-TCGA_scatter.R $Rdata $cancer $signature $normalMed $normalGene $corMed  $datatype";
  }else{
  $zhiling="Rscript 2.2-TCGA_scatter.R $Rdata $cancer $signature $normalMed $normalGene $corMed  $datatype";
}


exec($zhiling,$output,$status);

//执行成功都是返回0
echo json_encode(array(
  //  "zhiling" =>$zhiling,
   "output" => $output,
   "status"=>$status
    ),JSON_UNESCAPED_UNICODE); 

?>