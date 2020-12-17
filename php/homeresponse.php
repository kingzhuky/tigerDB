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
$infos = array();
$infosTable = array();

if ($conditi=="Responder"){
  $sql = "SELECT Log2FC,PValue,DatasetID FROM homeresponsetable WHERE GENE_SYMBOL='".$gene."' AND `Condition`='R-NR'";
  $sqltable = "SELECT * FROM datesetinfo WHERE `DatasetID` in (SELECT DatasetID FROM homeresponsetable WHERE GENE_SYMBOL='".$gene."' AND `Condition`='R-NR')";
  $dataResult = mysqli_query($conn,$sql);
  while ($row = mysqli_fetch_assoc($dataResult)) {
    $temp= array();
    array_push($temp,$row["Log2FC"]);
    array_push($temp,$row["PValue"]);
    array_push($temp,$row["DatasetID"]);
    array_push($infos,array_values($temp));
  }

  $dataResulttable = mysqli_query($conn,$sqltable);
  $datatable = array();
  while ($row = mysqli_fetch_assoc($dataResulttable)) {
    array_push($datatable,$row);
  }

}else if ($conditi=="Therapy"){
  $sql = "SELECT Log2FC,PValue,DatasetID FROM homeresponsetable WHERE GENE_SYMBOL='".$gene."' AND `Condition`='Post-Pre'";
  $sqltable = "SELECT * FROM datesetinfo WHERE `DatasetID` in (SELECT DatasetID FROM homeresponsetable WHERE GENE_SYMBOL='".$gene."' AND `Condition`='Post-Pre')";
  
  $dataResult = mysqli_query($conn,$sql);
  while ($row = mysqli_fetch_assoc($dataResult)) {
    $temp= array();
    array_push($temp,$row["Log2FC"]);
    array_push($temp,$row["PValue"]);
    array_push($temp,$row["DatasetID"]);
    array_push($infos,array_values($temp));
  }

  $dataResulttable = mysqli_query($conn,$sqltable);
  $datatable = array();
  while ($row = mysqli_fetch_assoc($dataResulttable)) {
    array_push($datatable,$row);
  }

}else if($conditi=="Survival"){
  $sql = "SELECT ZScore,PValue,DatasetID FROM homesurvtable WHERE GENE_SYMBOL='".$gene."' AND `Condition`='Survival'";
  $sqltable = "SELECT * FROM datesetinfo WHERE `DatasetID` in (SELECT DatasetID FROM homesurvtable WHERE GENE_SYMBOL='".$gene."' AND `Condition`='Survival')";
 
  $dataResult = mysqli_query($conn,$sql);
  while ($row = mysqli_fetch_assoc($dataResult)) {
    $temp= array();
    array_push($temp,$row["ZScore"]);
    array_push($temp,$row["PValue"]);
    array_push($temp,$row["DatasetID"]);
    array_push($infos,array_values($temp));
  }


  $dataResulttable = mysqli_query($conn,$sqltable);
  $datatable = array();
  while ($row = mysqli_fetch_assoc($dataResulttable)) {
    array_push($datatable,$row);
  }



}else{
  $sql ="SELECT a.Log2FoldChange,a.P_Value,b.datasetid,b.CancerType,b.CellType,b.GlobalCluster FROM ".$conditi." as a,homescinfo as b WHERE a.geneid='".$gene."' AND a.SCID=b.SCID";
  $dataResult = mysqli_query($conn,$sql);
  while ($row = mysqli_fetch_assoc($dataResult)) {
    $temp= array();
    array_push($temp,$row["Log2FoldChange"]);
    array_push($temp, round(log10(floatval(1+$row["P_Value"])),2)  );
    array_push($temp,$row["datasetid"]);
    array_push($temp,$row["GlobalCluster"]);
    array_push($temp,$row["CellType"]);
    array_push($temp,$row["CancerType"]);

    array_push($infos,array_values($temp));

    array_push($infosTable,$row);
    
  }
  


}



// query data
#$sql = "SELECT * FROM ".$type." WHERE GENE_SYMBOL='".$gene."'";
  // 拼接最终SQL
  

 


  echo json_encode(array(
      "status"=>200,
      "sql"=>$sql,
      "sqltable"=>$sqltable,
      "list" =>$infos, // necessary
      "datatable"=>$datatable,
      "infosTable"=>$infosTable
      ),JSON_UNESCAPED_UNICODE); 

mysql_close($conn);

    
  
?>