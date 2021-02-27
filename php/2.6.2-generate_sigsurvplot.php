<?php 
header("Content-Type:application/json;charset=UTF8");
$gene=trim($_GET['gene']);
$sigid=trim($_GET['sigid']);
$dataset=trim($_GET['dataset']); 

if(PATH_SEPARATOR==':'){
  $zhiling="sudo Rscript 2.6.2-generate_sigsurvplot.R $gene \"$sigid\" $dataset";
}else{
  $zhiling="Rscript 2.6.2-generate_sigsurvplot.R $gene \"$sigid\" $dataset";
}



exec($zhiling,$output,$status);

//执行成功都是返回0
echo json_encode(array(
   "zhiling" => $zhiling,
   "output" => $output,
   "status" => $status
    ),JSON_UNESCAPED_UNICODE); 

?>