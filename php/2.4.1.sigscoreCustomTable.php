<?php 
header("Content-Type:application/json;charset=UTF8");
$expfiletsv=$_GET['expfile']; 
$annofiletsv=$_GET['annofile'];
$id=$_GET['keyid'];

if(PATH_SEPARATOR==':'){
  $command="sudo Rscript 2.4.1-immunesig_custom_analysis_table.R $expfiletsv $annofiletsv $id";
  }else{
  $command="Rscript 2.4.1-immunesig_custom_analysis_table.R $expfiletsv $annofiletsv $id";
}


exec($command,$output,$status);

//执行成功都是返回0
echo json_encode(array(
  //  "command" => $command,
   "output" => $output,
   "status" => $status
    ),JSON_UNESCAPED_SLASHES); 

?>