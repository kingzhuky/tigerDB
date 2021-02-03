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

$draw = $_GET['draw']; //第几次请求

$order_column=$_GET['sortcol'];

$order_dir=$_GET['sortorder'];

if(strcmp($order_dir,"ascending")==0){
  $order_dir="asc";
}else if(strcmp($order_dir,"descending")==0){
  $order_dir="desc";
}

//拼接排序sql
$orderSql = "";
if((!empty($order_column))&&(!strcmp($order_dir,"None")==0)){
    $orderSql = " order by ISNULL(`".$order_column."`),`".$order_column."` ".$order_dir;
}


//搜索
$search = $_GET['search'];//获取前台传过来的过滤条件
//$search = "exon";

//分页
$start = $_GET['start'];//从多少开始
$length = $_GET['length'];//数据长度

if ($start<0){
    echo json_encode(array(
      "status"=>202,
    ),JSON_UNESCAPED_UNICODE); 
}else{
  $limitSql = '';
  $limitFlag = isset($_GET['start']) && $length != -1 ;
  //$limitFlag = isset($start) && $length != -1 ;

  if ($limitFlag ) {
      $limitSql = " LIMIT ".intval($start).", ".intval($length);
  }

  $type=$_GET['type'];
  //定义查询数据总记录数sql
  $sumSql = "SELECT count(gene) as sum FROM ".$type;

  //条件过滤后记录数 必要
  $recordsFiltered = 0;
  //表的总记录数 必要
  $recordsTotal = 0;


  $recordsTotalResult = mysqli_query($conn,$sumSql);
  while($row=mysqli_fetch_assoc($recordsTotalResult)){ //关联数组
      $recordsTotal = $row['sum'];
  }

  $j = 1;

  // 综合搜索sql
  $zSearchSql = " gene LIKE '%".$search."%'";

  // 拼接搜索SQL

  $sumSearchSql = '';
  if(strlen($search)>0){
      $sumSearchSql = " WHERE ".$zSearchSql;
  }else{
      $sumSearchSql = '';
  }

  if(strlen($sumSearchSql)>0){
      $recordsFilteredResult = mysqli_query($conn,$sumSql.$sumSearchSql);
      while ($row = mysqli_fetch_assoc($recordsFilteredResult)) {
          $recordsFiltered =  $row['sum'];
      }
  }else{
      $recordsFiltered = $recordsTotal;
  }

  // query data
  $sql='';
  $totalResultSql = "SELECT * FROM ".$type;
  $infos = array();
  // 拼接最终SQL
  $sql=$totalResultSql.$sumSearchSql.$orderSql.$limitSql;
  $dataResult = mysqli_query($conn,$sql);

  while ($row = mysqli_fetch_assoc($dataResult)) {
      array_push($infos,$row);
  }



  echo json_encode(array(
      "status" => 200,
      "draw" => $draw,
    "sql" => $sql,
      "recordsTotal" => $recordsTotal,  // necessary
      "recordsFiltered" => $recordsFiltered, // necessary
      "list" => $infos // necessary
      ),JSON_UNESCAPED_UNICODE); 
  }

  mysql_close($conn);

?>