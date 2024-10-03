<?php
    error_reporting(0);
ob_start();
  require_once('connection.php'); 
  ob_end_clean();
  include 'encrypt.php';
  
  
     $emailaddr = encrypt($_POST['emailaddr']);
    
      
   $getdetailsquery = mysqli_query($dbcon, "SELECT * FROM `authentication` WHERE `email_address` = '".$emailaddr."'");   
     
      if(mysqli_num_rows($getdetailsquery)<1){
        echo json_encode("-1");
    }else {
        echo json_encode("1");
    } 
  
  
?>