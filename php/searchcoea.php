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
$links = array();
$nodes = array();

$temp4= array();

$sql ="SELECT  a.genea,a.geneb,a.r,b.CellType FROM home_coea_table as a,homescinfo as b WHERE a.genea='".$gene."' AND a.SCID=b.SCID";

$dataResult = mysqli_query($conn,$sql);
while ($row = mysqli_fetch_assoc($dataResult)) {
//   $alltemp= array()
//   $temp= array();
//    array_push($temp,$row["genea"]);
//    array_push($temp,$row["geneb"]);
//    array_push($temp,$row["r"]);
$temp = array("source"=>$row["genea"], "target"=>$row["CellType"],"value"=>"1");
array_push($links,$temp);

$temp3 = array("source"=>$row["CellType"], "target"=>$row["geneb"],"value"=>$row["r"]);
array_push($links,$temp3);

foreach($row as $key=>$value){
  //echo $key."=>".$value."\n";
  if ($key!=="r"){
    array_push($temp4,$value);
  }
  
}


}

// query data
#$sql = "SELECT * FROM ".$type." WHERE GENE_SYMBOL='".$gene."'";
  // 拼接最终SQL
  $temp5=array_unique($temp4);


  foreach($temp5 as $value){
    //echo $key."=>".$value."\n";
    $temp6 = array("name"=>$value);
    array_push($nodes,$temp6);
  }
  


  echo json_encode(array(
      "status"=>200,
    // "sql"=>$sql,
      "links" =>$links, // necessary
      "nodes"=>$nodes
      ),JSON_UNESCAPED_UNICODE); 

mysql_close($conn);

    
  
?>