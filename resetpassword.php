<?php
    error_reporting(0);
ob_start();
  require_once('connection.php'); 
  ob_end_clean();
  include 'encrypt.php';
  
  
     $emailaddr = encrypt($_POST['emailaddr']);
      $password = encrypt($_POST['pw']);
    
    $updatequery = mysqli_query($dbcon, "UPDATE `authentication` SET `password`='".$password."' WHERE  `email_address` = '".$emailaddr."'");  
      
    if($updatequery){
        echo json_encode("1");
    }else{
        echo json_encode("-1");
    }
    
    
?>