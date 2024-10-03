<?php

ob_start();
  require_once('connection.php'); 
  ob_end_clean();
  
  if(isset($_GET['datamode'])){
      $gshop = mysqli_real_escape_string($dbcon, $_GET['shopname']);
       $gloc= mysqli_real_escape_string($dbcon, $_GET['location']);
     if(strpos($_GET['datamode'], 'getproductnames') !== false){
       $sql = mysqli_query($dbcon, "SELECT * FROM `products` where shopname='".$gshop."' and location = '".$gloc."'");
        
      if(mysqli_num_rows($sql)< 1){
        echo json_encode("-1");  
      }else{
          $arr = array();
         while($fetch=mysqli_fetch_assoc($sql)){
          $name = $fetch['product_name'];
          $img =  $fetch['prodimg'];
          $sname =  $fetch['shopname'];
          $loc =  $fetch['location'];  
          $pnid = $fetch['product_name_id']; 
          $arr[] = array("product_name"=> "$name","prodimg"=> "$img","shopname"=>"$sname" ,"location"=>"$loc","product_name_id"=>"$pnid");
    
          array_push($arr);
       
         } 
         $myjson = json_encode($arr,JSON_UNESCAPED_SLASHES);

         echo $myjson;  
      }   
          
     }
     
     if(strpos($_GET['datamode'], 'getproductquantities') !== false){
         $gshop = mysqli_real_escape_string($dbcon, $_GET['shopname']);
       $gloc= mysqli_real_escape_string($dbcon, $_GET['location']);
       $sql = mysqli_query($dbcon, "SELECT * FROM `product_quantity` where shopname='".$gshop."' and location = '".$gloc."'");
        
      if(mysqli_num_rows($sql)< 1){
        echo json_encode("-1");  
      }else{
          $arr = array();
         while($fetch=mysqli_fetch_assoc($sql)){
         $pname = $fetch['pid'];
         $pid = $fetch['product_id'];
         $psize = $fetch['product_size'];
         $sname = $fetch['shopname'];
         $loc = $fetch['location'];    
         $arr[] = array('pid'=>"$pname" ,
          'product_id'=>"$pid" , 'product_size'=>"$psize" , 'shopname'=> "$sname", 'location'=>"$loc");
    
          array_push($arr);    
         }   
         $myjson = json_encode($arr,JSON_UNESCAPED_SLASHES | JSON_PRETTY_PRINT );

         echo $myjson;
      }   
     }
     
     if(strpos($_GET['datamode'], 'getproductprices') !== false){
         $gshop = mysqli_real_escape_string($dbcon, $_GET['shopname']);
       $gloc= mysqli_real_escape_string($dbcon, $_GET['location']);
      $sql = mysqli_query($dbcon, "SELECT * FROM `product_prices` where shopname='".$gshop."' and location = '".$gloc."'");
        
      if(mysqli_num_rows($sql)< 1){
        echo json_encode("-1");  
      }else{
          $arr = array();
         while($fetch=mysqli_fetch_assoc($sql)){
         $psize = $fetch['product_size'];
         $price = $fetch['price'];
         $pname = $fetch['product_id'];
         $sname = $fetch['shopname'];
         $loc = $fetch['location'];
         $priceid = $fetch['product_price_id'];        
          $arr[] = array("product_size"=> "$psize", "price"=> "$price", "product_id"=> "$pname", "shopname"=> "$sname", "location"=> "$loc","product_price_id"=>"$priceid");
    
          array_push($arr);   
         } 
         $myjson = json_encode($arr,JSON_UNESCAPED_SLASHES);

         echo $myjson;  
      }    
     }
     if(strpos($_GET['datamode'], 'getworkersdata') !== false){
      $gshop = mysqli_real_escape_string($dbcon, $_GET['shopname']);
       $gloc= mysqli_real_escape_string($dbcon, $_GET['location']);   
      $sql = mysqli_query($dbcon, "SELECT * FROM `workers` where shopname='".$gshop."' and location = '".$gloc."'");
        
      if(mysqli_num_rows($sql)< 1){
        echo json_encode("-1");  
      }else{
          $arr = array();
         while($fetch=mysqli_fetch_assoc($sql)){
         $fname = $fetch['firstname'];
         $lname = $fetch['lastname'];
         $pw = $fetch['password'];
         $pic = $fetch['picture'];
         $role = $fetch['role'];
         $da = $fetch['date_added'];
         $is = $fetch['initial_salary'];
         $cs = $fetch['current_salary'];
         $con = $fetch['contact'];
         $addr = $fetch['address'];
         $srd = $fetch['salary_raise_date'];
         $sname = $fetch['shopname'];
         $wid = $fetch['worker_id'];
         $loc = $fetch['location'];    
         
         $arr[] = array("firstname"=>"$fname" , "lastname"=>"$lname" , "password"=>"$pw" , "picture"=>"$pic" , "role"=>"$role" , "date_added"=>"$da" , "initial_salary"=>"$is", "current_salary"=>"$cs" , "contact"=>"$con" , "address"=>"$addr" , "salary_raise_date"=>"$srd" , "shopname"=>"$sname" , "worker_id"=>"$wid" , "location"=>"$loc");
    
          array_push($arr);    
         } 
         $myjson = json_encode($arr,JSON_UNESCAPED_SLASHES);

         echo $myjson;  
      }    
     } 
    
  }
  ?>