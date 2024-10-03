<?php
    error_reporting(0);
ob_start();
  require_once('connection.php'); 
  ob_end_clean();
  include 'encrypt.php';
  
  $user = $_POST['user'];
      $password = mysqli_real_escape_string($dbcon, $_POST['pw']);
  
  $getuser = mysqli_query($dbcon, "SELECT * FROM `workers` WHERE `worker_id`='".$user."' and `password`='".$password."'");
  $arr = array();
  if($getuser){
      if(mysqli_num_rows($getuser)<1){
         echo json_encode("-1"); 
      }else{
          while($fetch = mysqli_fetch_assoc($getuser)){
             $userfname = $fetch['firstname'];
             $userlname =$fetch['lastname'];
             $userid = $fetch['worker_id'];
             $shop = $fetch['shopname'];
             $loc = $fetch['location'];
             $details = $userfname." ".$userlname.",".$userid.",".$shop.",".$loc;
               
          }
          $myjson = json_encode($details);

          echo $myjson;
      }
  }else{
     echo json_encode("-2"); 
  }
  
  
?>