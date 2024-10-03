<?php
ob_start();
  require_once('connection.php'); 
  ob_end_clean();
  
  if(isset($_GET['datamode'])){
     if(strpos($_GET['datamode'], 'getproductnames') !== false){
       $sql = mysqli_query($dbcon, "SELECT * FROM `products`");
        
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
       $sql = mysqli_query($dbcon, "SELECT * FROM `product_quantity`");
        
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
         $arr[] = array("pid"=>"$pname" , "product_id"=>"$pid" , "product_size"=>"$psize" , "prodimg"=>"" , "price"=>"" , "shopname"=> "$sname", "location"=>"$loc");
    
          array_push($arr);    
         }   
         $myjson = json_encode($arr,JSON_UNESCAPED_SLASHES);

         echo $myjson;
      }   
     }
     
     if(strpos($_GET['datamode'], 'getproductprices') !== false){
      $sql = mysqli_query($dbcon, "SELECT * FROM `product_prices`");
        
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
     
     if(strpos($_GET['datamode'], 'getproductstock') !== false){
       $sql = mysqli_query($dbcon, "SELECT * FROM `stock_tab`");
        
      if(mysqli_num_rows($sql)< 1){
        echo json_encode("-1");  
      }else{
          $arr = array();
         while($fetch=mysqli_fetch_assoc($sql)){
         $pname = $fetch['product_name'];
         $psize = $fetch['product_size'];
         $pid = $fetch['product_id'];
         $price = $fetch['price'];
         $pdate = $fetch['date_sold'];
         $psby = $fetch['sold_by'];
         $sname = $fetch['shopname'];
         $loc = $fetch['location'];        
          $arr[] = array("product_name"=> "$pname","product_size"=> "$psize", "product_id"=> "$pid", "price"=> "$price", "date_sold"=> "$pdate", "sold_by"=> "$psby", "shopname"=> "$sname", "location"=> "$loc");
    
          array_push($arr);   
         }   
         $myjson = json_encode($arr,JSON_UNESCAPED_SLASHES);

         echo $myjson;
      }   
     }
     
     if(strpos($_GET['datamode'], 'getworkersdata') !== false){
      $sql = mysqli_query($dbcon, "SELECT * FROM `workers`");
        
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
     
     if(strpos($_GET['datamode'], 'getshopdata') !== false){
      $sql = mysqli_query($dbcon, "SELECT * FROM `shops`");
        
      if(mysqli_num_rows($sql)< 1){
        echo json_encode("-1");  
      }else{
          $arr = array();
         while($fetch=mysqli_fetch_assoc($sql)){
         $sname = $fetch['shopname'];
         $loc = $fetch['location'];
         $sid = $fetch['shop_id'];        
         $arr[] = array("shopname"=> "$sname","location"=> "$loc","shop_id"=>"$sid");
    
          array_push($arr);    
         } 
         $myjson = json_encode($arr,JSON_UNESCAPED_SLASHES);

         echo $myjson;  
      }    
     }
     
  }

?>