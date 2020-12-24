<?php
header("Content-type: text/html;charset=utf-8");
if(PATH_SEPARATOR==':'){
  $conn=mysqli_connect("localhost:3306","read_only_user","dfdl651ZLYY.");
}else{
  $conn=mysqli_connect("localhost:3307","read_only_user","dfdl651ZLYY.");
}
if(!$conn){
    die("连接失败".mysqli_error($conn));
}

mysqli_query($conn , "set names utf8");

mysqli_select_db( $conn, 'tiger' );

$gene = $_GET['gene'];


  // query data
  //$sql = "SELECT * FROM ".$tabl." WHERE ".$colu."='".$coluvalue."' LIMIT 1";
  $sql = "SELECT  * from  homescreen as a,immunescreenartle as b ,homescreen as c WHERE a.GENE_SYMBOL='".$gene."' and a.dataset_id=b.dataset_id and c.GENE_SYMBOL='".$gene."' and c.dataset_id=a.dataset_id;";
  //$infos2 = array();
  $infos = array();
  // 拼接最终SQL
  
$dataResult = mysqli_query($conn,$sql);

while ($row = mysqli_fetch_assoc($dataResult)) {
    array_push($infos,$row);
}


// foreach($infos2[0] as $key => $value){
//     $temp= array();
//     $temp["title"]=$key;
//     $temp["value"]=$value;
//     array_push($infos,$temp);
// }




echo json_encode(array(
    "status"=>200,
    // "sql"=>$sql,
    "list" =>$infos // necessary
    ),JSON_UNESCAPED_UNICODE); 

    mysql_close($conn);

  
?>