<?php 
header("Content-Type:application/json;charset=UTF8");
$cancer=$_GET['cancer']; 
$subclu=$_GET['subclu'];
$ligand=$_GET['ligand'];
$recepto=$_GET['recepto'];

if(PATH_SEPARATOR==':'){
  $zhiling="sudo Rscript pic.cross.R $cancer  $subclu $ligand $recepto";
  }else{
  $zhiling="Rscript pic.cross.R $cancer  $subclu $ligand $recepto";
}


exec($zhiling,$output,$status);

//执行成功都是返回0
echo json_encode(array(
   "zhiling" =>$zhiling,
   "output" => $output,
   "status"=>$status
    ),JSON_UNESCAPED_UNICODE); 

?>