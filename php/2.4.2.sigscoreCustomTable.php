<?php 
header("Content-Type:application/json;charset=UTF8");
$tablerdsfile=$_GET['tablerdsfile']; 
$sigid=$_GET['sigid'];
$id=$_GET['keyid'];
$datatype=$_GET['datatype'];

if(PATH_SEPARATOR==':'){
  $command="sudo Rscript 2.4.2-immunesig_custom_analysis_plot.R.R $tablerdsfile $sigid $id $datatype";
  }else{
  $command="Rscript 2.4.2-immunesig_custom_analysis_plot.R $tablerdsfile $sigid $id $datatype";
}


exec($command,$output,$status);

//执行成功都是返回0
echo json_encode(array(
  //  "command" => $command,
   "output" => $output,
   "status" => $status
    ),JSON_UNESCAPED_SLASHES); 

?>