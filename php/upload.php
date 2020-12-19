<?php
$target_dir = "upload/";
$target_file = $target_dir.basename($_FILES['exptable']['name']);
$uploadOk = 1;

// Check if file already exists
// if (file_exists($target_file)) {
//   echo "Sorry, file already exists.";
//   $uploadOk = 0;
// }

// Check if $uploadOk is set to 0 by an error
move_uploaded_file($_FILES['exptable']['tmp_name'], $target_file);

echo json_encode(array(
    "status"=> 200,
    "list" => $target_file, // necessary
    ),JSON_UNESCAPED_SLASHES); 
?>