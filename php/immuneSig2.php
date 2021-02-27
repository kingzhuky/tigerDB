<?php 
header("Content-Type:application/json;charset=UTF8");
$gene=trim($_GET['gene']); 
$condition=trim($_GET['condi']); 
if($condition=="response"){
  if(PATH_SEPARATOR==':'){
    $zhiling="sudo Rscript 2.5.1-generate_sig_auc_mat.R $gene";
  }else{
    $zhiling="Rscript 2.5.1-generate_sig_auc_mat.R $gene";
  }
}else if($condition=="survival"){
  if(PATH_SEPARATOR==':'){
    $zhiling="sudo Rscript 2.6.1-generate_sig_surv_mat.R $gene";
  }else{
    $zhiling="Rscript 2.6.1-generate_sig_surv_mat.R $gene";
  }
}else{
  if(PATH_SEPARATOR==':'){
    $zhiling="sudo Rscript 2.1-generate_sig_mat.R $gene";
  }else{
    $zhiling="Rscript 2.1-generate_sig_mat.R $gene";
  }
}


exec($zhiling,$output,$status);

//执行成功都是返回0
echo json_encode(array(
   "zhiling" => $zhiling,
   "output" => $output,
   "status" => $status
    ),JSON_UNESCAPED_UNICODE); 

?>