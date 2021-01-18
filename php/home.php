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
#$type=$_GET['type'];

  // query data
#$sql = "SELECT * FROM ".$type." WHERE GENE_SYMBOL='".$gene."'";
  $sql = "SELECT abs(a.Log2FoldChange),b.CancerType,b.CellType,a.Log2FoldChange,a.GENE_SYMBOL,a.P_Value,b.datasetid,b.GlobalCluster FROM homemarkertable as a,homescinfo as b WHERE a.GENE_SYMBOL='".$gene."' AND a.SCID=b.SCID";
  $infos = array();
  $cancer = array();
  $tabledata= array();
  // 拼接最终SQL
  
  $dataResult = mysqli_query($conn,$sql);

  while ($row = mysqli_fetch_assoc($dataResult)) {
    array_push($tabledata,$row);
    array_push($infos,array_values($row));
	  array_push($cancer,$row["CancerType"]);
  }


  echo json_encode(array(
      "status"=>200,
      // "sql"=>$sql,
      "list" =>$infos, // necessary
      "tabledata" =>$tabledata, // necessary
      "cancer" =>array_unique($cancer) // necessary
      ),JSON_UNESCAPED_UNICODE); 

mysql_close($conn);

    
  
?>