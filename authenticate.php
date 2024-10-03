<?php
    error_reporting(0);
ob_start();
  require_once('connection.php'); 
  ob_end_clean();
  include 'encrypt.php';
  
  $user = encrypt($_POST['user']);
      $password = encrypt($_POST['pw']);
  
  $getuser = mysqli_query($dbcon, "SELECT * FROM `authentication` WHERE `email_address`='".$user."' and `password`='".$password."'");
  $arr = array();
  if($getuser){
      if(mysqli_num_rows($getuser)<1){
         echo json_encode("-1"); 
      }else{
          while($fetch = mysqli_fetch_assoc($getuser)){
             $userfname = decrypt($fetch['fname']);
             $userlname = decrypt($fetch['lname']);
             $userid = decrypt($fetch['userid']);
             $details = $userfname." ".$userlname.",".$userid;
               
          }
          $myjson = json_encode($details);

          echo $myjson;
      }
  }else{
     echo json_encode("-2"); 
  }
  
  
?>