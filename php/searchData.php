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
$conditi=$_GET['conditi'];
$currentPage = $_GET['currentPage'];
$pageSize = $_GET['pageSize'];
$startPos=($currentPage-1)*$pageSize;
$order_column=$_GET['sortcol'];
$order_dir=$_GET['sortorder'];

if(strcmp($order_dir,"ascending")==0){
  $order_dir="asc";
}else if(strcmp($order_dir,"descending")==0){
  $order_dir="desc";
}
$orderSql = "";
if((!empty($order_column))&&(!strcmp($order_dir,"None")==0)){
    $orderSql = " order by ISNULL(`".$order_column."`),`".$order_column."` ".$order_dir;
}

$infos = array();
$total = array();

if ($conditi=="Responder"){
  $sql = "SELECT Log2FC,PValue,DatasetID FROM homeresponsetable WHERE GENE_SYMBOL='".$gene."' AND `Condition`='R-NR'";
  // $sqltable = "SELECT * FROM datesetinfo WHERE `DatasetID` in (SELECT DatasetID,Log2FC,PValue FROM homeresponsetable WHERE GENE_SYMBOL='".$gene."' AND `Condition`='R-NR')";
  $sqltable = "SELECT a.*,b.DatasetID,b.Log2FC,b.PValue FROM datesetinfo as a,homeresponsetable as b WHERE b.GENE_SYMBOL='".$gene."' AND a.DatasetID=b.DatasetID AND b.`Condition`='R-NR'";
  $dataResult = mysqli_query($conn,$sql);
  while ($row = mysqli_fetch_assoc($dataResult)) {
    $temp= array();
    array_push($temp,$row["Log2FC"]);
    array_push($temp,$row["PValue"]);
    array_push($temp,$row["DatasetID"]);
    array_push($infos,array_values($temp));
  }
  $sqltable = $sqltable.$orderSql." LIMIT ".$startPos.",".$pageSize;
  $dataResulttable = mysqli_query($conn,$sqltable);
  $datatable = array();
  while ($row = mysqli_fetch_assoc($dataResulttable)) {
    array_push($datatable,$row);
  }

  $sqlTotal = "SELECT COUNT(1) FROM datesetinfo as a,homeresponsetable as b WHERE b.GENE_SYMBOL='".$gene."' AND a.DatasetID=b.DatasetID AND b.`Condition`='R-NR'";
  $total = array();
  // 拼接最终SQL
  $dataResultTotal = mysqli_query($conn,$sqlTotal);
  while ($row = mysqli_fetch_assoc($dataResultTotal)) {
      array_push($total,intval($row["COUNT(1)"]));
  }
  
}else if ($conditi=="Therapy"){
  $sql = "SELECT Log2FC,PValue,DatasetID FROM homeresponsetable WHERE GENE_SYMBOL='".$gene."' AND `Condition`='Post-Pre'";
  // $sqltable = "SELECT * FROM datesetinfo WHERE `DatasetID` in (SELECT DatasetID,Log2FC,PValue FROM homeresponsetable WHERE GENE_SYMBOL='".$gene."' AND `Condition`='Post-Pre')";
  $sqltable = "SELECT a.*,b.DatasetID,b.Log2FC,b.PValue FROM datesetinfo as a,homeresponsetable as b WHERE b.GENE_SYMBOL='".$gene."' AND a.DatasetID=b.DatasetID  AND b.`Condition`='Post-Pre'";
  
  $dataResult = mysqli_query($conn,$sql);
  while ($row = mysqli_fetch_assoc($dataResult)) {
    $temp= array();
    array_push($temp,$row["Log2FC"]);
    array_push($temp,$row["PValue"]);
    array_push($temp,$row["DatasetID"]);
    array_push($infos,array_values($temp));
  }
  $sqltable = $sqltable.$orderSql." LIMIT ".$startPos.",".$pageSize;
  $dataResulttable = mysqli_query($conn,$sqltable);
  $datatable = array();
  while ($row = mysqli_fetch_assoc($dataResulttable)) {
    array_push($datatable,$row);
  }
  $sqlTotal = "SELECT COUNT(1) FROM datesetinfo as a,homeresponsetable as b WHERE b.GENE_SYMBOL='".$gene."' AND a.DatasetID=b.DatasetID  AND b.`Condition`='Post-Pre'";
  $total = array();
  // 拼接最终SQL
  $dataResultTotal = mysqli_query($conn,$sqlTotal);
  while ($row = mysqli_fetch_assoc($dataResultTotal)) {
      array_push($total,intval($row["COUNT(1)"]));
  }

}else if($conditi=="Survival"){
  $sql = "SELECT ZScore,PValue,DatasetID FROM homesurvtable WHERE GENE_SYMBOL='".$gene."' AND `Condition`='Survival'";
  // $sqltable = "SELECT * FROM datesetinfo WHERE `DatasetID` in (SELECT DatasetID,ZScore,PValue FROM homesurvtable WHERE GENE_SYMBOL='".$gene."' AND `Condition`='Survival')";
  $sqltable = "SELECT a.*,b.DatasetID,b.ZScore,b.PValue FROM datesetinfo as a,homesurvtable as b WHERE b.GENE_SYMBOL='".$gene."' AND a.DatasetID=b.DatasetID";
  $dataResult = mysqli_query($conn,$sql);
  while ($row = mysqli_fetch_assoc($dataResult)) {
    $temp= array();
    array_push($temp,$row["ZScore"]);
    array_push($temp,$row["PValue"]);
    array_push($temp,$row["DatasetID"]);
    array_push($infos,array_values($temp));
  }

  $sqltable = $sqltable.$orderSql." LIMIT ".$startPos.",".$pageSize;
  $dataResulttable = mysqli_query($conn,$sqltable);
  $datatable = array();
  while ($row = mysqli_fetch_assoc($dataResulttable)) {
    array_push($datatable,$row);
  }

  $sqlTotal = "SELECT COUNT(1) FROM datesetinfo as a,homesurvtable as b WHERE b.GENE_SYMBOL='".$gene."' AND a.DatasetID=b.DatasetID";
  $total = array();
  // 拼接最终SQL
  $dataResultTotal = mysqli_query($conn,$sqlTotal);
  while ($row = mysqli_fetch_assoc($dataResultTotal)) {
    array_push($total,intval($row["COUNT(1)"]));
  }

}else if($conditi=="Marker"){
  $sql = "SELECT abs(a.Log2FoldChange),b.CancerType,b.CellType,a.Log2FoldChange,a.GENE_SYMBOL,a.P_Value,b.datasetid,b.GlobalCluster FROM homemarkertable as a,homescinfo as b WHERE a.GENE_SYMBOL='".$gene."' AND a.SCID=b.SCID";
  $dataResult = mysqli_query($conn,$sql);
  while ($row = mysqli_fetch_assoc($dataResult)) {
    array_push($infos,array_values($row));
  }
  
  $sqltable = $sql.$orderSql." LIMIT ".$startPos.",".$pageSize;
  $dataResulttable = mysqli_query($conn,$sqltable);
  $datatable = array();
  while ($row = mysqli_fetch_assoc($dataResulttable)) {
    array_push($datatable,$row);
  }

  $sqlTotal = "SELECT COUNT(1) FROM homemarkertable as a,homescinfo as b WHERE a.GENE_SYMBOL='".$gene."' AND a.SCID=b.SCID";
  $total = array();
  // 拼接最终SQL
  $dataResultTotal = mysqli_query($conn,$sqlTotal);
  while ($row = mysqli_fetch_assoc($dataResultTotal)) {
    array_push($total,intval($row["COUNT(1)"]));
  }

}else{
  $sql ="SELECT a.Log2FoldChange,a.P_Value,b.datasetid,b.CancerType,b.CellType,b.GlobalCluster FROM ".$conditi." as a,homescinfo as b WHERE a.geneid='".$gene."' AND a.SCID=b.SCID";
  $dataResult = mysqli_query($conn,$sql);
  while ($row = mysqli_fetch_assoc($dataResult)) {
    $temp= array();
    array_push($temp,$row["Log2FoldChange"]);
    array_push($temp, round($row["P_Value"],2)  );
    array_push($temp,$row["datasetid"]);
    array_push($temp,$row["GlobalCluster"]);
    array_push($temp,$row["CellType"]);
    array_push($temp,$row["CancerType"]);
    array_push($infos,array_values($temp));
    
  }
  
  $sqltable = $sql.$orderSql." LIMIT ".$startPos.",".$pageSize;
  $dataResulttable = mysqli_query($conn,$sqltable);
  $datatable = array();
  while ($row = mysqli_fetch_assoc($dataResulttable)) {
    array_push($datatable,$row);
  }

  $sqlTotal = "SELECT COUNT(1) FROM ".$conditi." as a,homescinfo as b WHERE a.geneid='".$gene."' AND a.SCID=b.SCID";
  $total = array();
  // 拼接最终SQL
  $dataResultTotal = mysqli_query($conn,$sqlTotal);
  while ($row = mysqli_fetch_assoc($dataResultTotal)) {
    array_push($total,intval($row["COUNT(1)"]));
  }
}



// query data
#$sql = "SELECT * FROM ".$type." WHERE GENE_SYMBOL='".$gene."'";
  // 拼接最终SQL
  

 


  echo json_encode(array(
      "status"=>200,
      // "sql"=>$sql,
      // "sqltable"=>$sqltable,
      "total"=>$total,
      "list" =>$infos, // necessary
      "datatable"=>$datatable,
      // "infosTable"=>$infosTable
      ),JSON_UNESCAPED_UNICODE); 

mysql_close($conn);

    
  
?>