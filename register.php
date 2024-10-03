<?php
error_reporting(0);
ob_start();
  require_once('connection.php'); 
  ob_end_clean();
  include 'encrypt.php';
    global $dbcon;
    global $emailaddr;
    //global $contact;
    //global $dateString;
    //global $myDateTime;
    //global $dob;
    global $firstname;
    global $lastname;
    //global $gender;
    global $password;
    
    $emailaddr = encrypt($_POST['emailaddress']);
    //$contact = encrypt($_POST['contact']);
    //$dateString = $_POST['dob'];
    //$myDateTime = DateTime::createFromFormat('d-m-Y', $dateString);
    //$dob = $myDateTime->format('Y-m-d');
    $firstname = encrypt($_POST['firstname']);
    $lastname = encrypt($_POST['lastname']);
    //$gender = encrypt($_POST['gender']);
    $password = encrypt($_POST['password']);
    $uid = encrypt("mre".date('YmHis'));
    
    /*if($dbcon->ping()){
        echo "connection active";
    }else{
        echo "connection terminated";
    }*/
    
    
    
   
    $emailquery = mysqli_query($dbcon, "SELECT * FROM `authentication` WHERE `email_address` = '".$emailaddr."'");
    
  if(mysqli_num_rows($emailquery)>0){
        echo json_encode("-2");
    }
    
    else if( mysqli_num_rows($emailquery)< 1){
        $registerquery = mysqli_query($dbcon, "INSERT INTO `authentication`( `fname`, `lname`,  `email_address`, `password`,`date_created`, userid) VALUES ('".$firstname."','".$lastname."','".$emailaddr."','".$password."','".date('Y-m-d H:i:s')."','".$uid."')");
        echo json_encode("1");
    }
?>