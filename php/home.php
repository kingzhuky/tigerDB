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
  $sql = "SELECT abs(homemarkertable.Log2FoldChange),homescinfo.CancerType,homescinfo.CellType,homemarkertable.Log2FoldChange,homemarkertable.GENE_SYMBOL,homemarkertable.P_Value FROM homemarkertable,homescinfo WHERE GENE_SYMBOL='".$gene."' AND homemarkertable.SCID=homescinfo.SCID";
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