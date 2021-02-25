<?php 
header("Content-Type:application/json;charset=UTF8");
$gene=trim($_GET['gene']); 

if(PATH_SEPARATOR==':'){
  $zhiling="sudo Rscript 2.1-generate_sig_mat.R $gene";
}else{
  $zhiling="Rscript 2.1-generate_sig_mat.R $gene";
}

exec($zhiling,$output,$status);

//执行成功都是返回0
echo json_encode(array(
  //  "zhiling" =>$zhiling,
   "output" => $output,
   "status" => $status
    ),JSON_UNESCAPED_UNICODE); 

?>