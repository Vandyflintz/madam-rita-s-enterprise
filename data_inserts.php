<?php
ob_start();
  require_once('connection.php'); 
  ob_end_clean();
  include 'encrypt.php';
  
  
  if(isset($_POST['proname'])){
    $productname = mysqli_real_escape_string($dbcon,$_POST['pname']);
        $imgname = mysqli_real_escape_string($dbcon,$_POST['pimage']);
        $sname = mysqli_real_escape_string($dbcon,$_POST['shopname']);
        $loc = mysqli_real_escape_string($dbcon,$_POST['location']);
        $pn = mysqli_real_escape_string($dbcon,$_POST['product_name_id']);
        $imgpath = "images/".$productname.".jpg";

if(file_put_contents($imgpath, base64_decode($imgname))){
    $insert = mysqli_query($dbcon, "INSERT INTO `products`( `product_name`, `prodimg`,`shopname`, `location`,`product_name_id`) VALUES ('".$productname."','".$productname.".jpg"."','".$sname."','".$loc."','".$pn."')");
    echo json_encode("successful");
}else{
    echo json_encode("-1");
}
        
  }

if(isset($_POST['proprice'])){
    $name = mysqli_real_escape_string($dbcon,$_POST['pname']);
    $size = mysqli_real_escape_string($dbcon,$_POST['psize']);
    $price = mysqli_real_escape_string($dbcon,$_POST['price']);  
    $sname = mysqli_real_escape_string($dbcon,$_POST['shopname']);
    $loc = mysqli_real_escape_string($dbcon,$_POST['location']);
    $pid = mysqli_real_escape_string($dbcon,$_POST['product_price_id']);
    
    $insert = mysqli_query($dbcon, "INSERT INTO `product_prices`( `product_id`, `product_size`, `price`, `shopname`, `location`,`product_price_id` ) VALUES ('".$name."','".$size."','".$price."','".$sname."','".$loc."','".$pid."')");
       if($insert){
   
    echo json_encode("successful");
}else{
    echo json_encode("-1");
}
  }

if(isset($_POST['updproprice'])){
    $name = mysqli_real_escape_string($dbcon,$_POST['pname']);
    $size = mysqli_real_escape_string($dbcon,$_POST['psize']);
    $price = mysqli_real_escape_string($dbcon,$_POST['price']);
    $sname = mysqli_real_escape_string($dbcon,$_POST['shopname']);
    $loc = mysqli_real_escape_string($dbcon,$_POST['location']); 
    
    $update = mysqli_query($dbcon, "UPDATE `product_prices` SET  `price`='".$price."' WHERE `product_id` = '".$name."' and `product_size` = '".$size."' and `shopname` = '".$sname."' and `location` = '".$loc."'"); 
    
       if($update){
   
    echo json_encode("successful");
}else{
    echo json_encode("-1");
}
  }


if(isset($_POST['prodetails'])){
    $pid = mysqli_real_escape_string($dbcon,$_POST['pname']);
    $prodid = mysqli_real_escape_string($dbcon,$_POST['pid']);
    $size = mysqli_real_escape_string($dbcon,$_POST['psize']);
    $sname = mysqli_real_escape_string($dbcon,$_POST['shopname']);
    $loc = mysqli_real_escape_string($dbcon,$_POST['location']);
    
    $insert = mysqli_query($dbcon, "INSERT INTO `product_quantity`( `pid`, `product_id`, `product_size`,`shopname`, `location`) VALUES ('".$pid."','".$prodid."','".$size."','".$sname."','".$loc."')");
    if($insert){
   
    echo json_encode("successful");
}else{
    echo json_encode("-1");
}
  }

if(isset($_POST['solddetails'])){
 $array = json_decode($_POST['solddata']);
 $insertquery = '';
 $deletequery ='';
 $response='';
 $idarr = array();
 //print_r($array);



    $encoded = trim( json_encode($idarr,JSON_UNESCAPED_SLASHES),'[]');
    $add = "INSERT INTO `stock_tab`( `product_id`, `product_name`, `product_size`, `date_sold`, `price`, `sold_by`, `shopname`, `location`) VALUES (?,?,?,?,?,?,?,?)";
    
    if( $insertquery = $dbcon->prepare($add)){
        foreach($array as $row){
 $idarr[]= trim(mysqli_real_escape_string($dbcon,$row->product_id));
    $pid = trim(mysqli_real_escape_string($dbcon,$row->product_id));
    $pname = trim(mysqli_real_escape_string($dbcon,$row->product_name));
    $psize = trim(mysqli_real_escape_string($dbcon,$row->product_size));
    $pdate = trim(mysqli_real_escape_string($dbcon,$row->date_sold));
    $price = trim(mysqli_real_escape_string($dbcon,$row->price));
    $person = trim(mysqli_real_escape_string($dbcon,$row->sold_by));
    $shop = trim(mysqli_real_escape_string($dbcon,$row->shopname));
    $location = trim(mysqli_real_escape_string($dbcon,$row->location));
  array_push($idarr);  
    $insertquery->bind_param('ssssssss', $pid , $pname , $psize , $pdate, $price, $person, $shop, $location);    
    $insertquery->execute(); 
 }
        
          
    }
$sql = "DELETE FROM `product_quantity` WHERE `product_id` = ?";
if( $deletequery =$dbcon->prepare($sql)){
        foreach($array as $row){
    $pid = trim(mysqli_real_escape_string($dbcon,$row->product_id)); 
    $deletequery->bind_param('s', $pid);
    $response = $deletequery->execute();
 }
        
          
    }
    
    
   
   
    if($insertquery &&  $response){
    echo json_encode("successful");    
    }else{
      echo json_encode("-1");  
    }
}


if(isset($_POST['shopdetails'])){
   $sname = mysqli_real_escape_string($dbcon,$_POST['shopname']);
    $loc = mysqli_real_escape_string($dbcon,$_POST['location']);
    $sid = mysqli_real_escape_string($dbcon,$_POST['shop_id']);
    $insert = mysqli_query($dbcon, "INSERT INTO `shops`(`shopname`, `location`, `shop_id`) VALUES ('".$sname."','".$loc."','".$sid."')");
     if($insert){
   
    echo json_encode("successful");
}else{
    echo json_encode("-1");
}
             
}        
 if(isset($_POST['workerinsert'])){
   $sname = mysqli_real_escape_string($dbcon,$_POST['shopname']);
    $loc = mysqli_real_escape_string($dbcon,$_POST['location']);
    $fname = mysqli_real_escape_string($dbcon,$_POST['firstname']);
    $lname = mysqli_real_escape_string($dbcon,$_POST['lastname']);
    $userid = mysqli_real_escape_string($dbcon,$_POST['userid']);
    $role = mysqli_real_escape_string($dbcon,$_POST['role']);
    $password = mysqli_real_escape_string($dbcon,$_POST['password']);
    $dateemployed = mysqli_real_escape_string($dbcon,$_POST['dateemployed']);
    $salary = mysqli_real_escape_string($dbcon,$_POST['salary']);
    $contact = mysqli_real_escape_string($dbcon,$_POST['contact']);
    $address = mysqli_real_escape_string($dbcon,$_POST['address']);
    $img = mysqli_real_escape_string($dbcon,$_POST['profimg']);
    
    
     $imgpath = "images/".$userid.".jpg";
     $pic = $userid.".jpg";
if(file_put_contents($imgpath, base64_decode($img))){
     $insert = mysqli_query($dbcon, "INSERT INTO `workers`(`firstname`, `lastname`, `password`, `picture`, `role`, `date_added`, `initial_salary`, `current_salary`, `contact`, `address`, `worker_id`, `shopname`, `location`) VALUES ('".$fname."','".$lname."','".$password."','".$pic."','".$role."','".$dateemployed."','".$salary."','".$salary."','".$contact."','".$address."','".$userid."','".$sname."','".$loc."')"); 
    
     echo json_encode("successful");
}else{
    echo json_encode("-1");
}  
 }

     
if(isset($_POST['deletedetails'])){
   $sname = mysqli_real_escape_string($dbcon,$_POST['shopname']);
    $loc = mysqli_real_escape_string($dbcon,$_POST['location']);
    
    $deleteworkers = mysqli_query($dbcon, "DELETE FROM `workers` WHERE `shopname` = '".$sname."' and `location` = '".$loc."'");
    $deleteshop = mysqli_query($dbcon, "DELETE FROM `shops` WHERE `shopname` = '".$sname."' and `location` ='".$loc."'");
     
     
     if($deleteworkers && $deleteshop){
   
    echo json_encode("successful");
}else{
    echo json_encode("-1");
}
             
}   
  
   if(isset($_POST['updatesalary'])){
    $date = mysqli_real_escape_string($dbcon,$_POST['date']);
    $salary = mysqli_real_escape_string($dbcon,$_POST['salary']);
    $workerid = mysqli_real_escape_string($dbcon,$_POST['workerid']); 
    $shopname = mysqli_real_escape_string($dbcon,$_POST['shopname']);
    $location = mysqli_real_escape_string($dbcon,$_POST['location']);
    
    $query = mysqli_query($dbcon, "UPDATE `workers` SET `current_salary`='".$salary."',`salary_raise_date`='".$date."' WHERE `worker_id` = '".$workerid."'");
    
     if($query){
   
    echo json_encode("successful");
}else{
    echo json_encode("-1");
}
 
      
  }
   
   if(isset($_POST['deleteworker'])){
    $workerid = encrypt(mysqli_real_escape_string($dbcon,$_POST['workerid'])); 
    $query = mysqli_query($dbcon, "DELETE FROM `workers` WHERE `worker_id` = '".$workerid."'");
     if($query){
   
    echo json_encode("successful");
}else{
    echo json_encode("-1");
} 
      
  }
   
/*if(isset(mysqli_real_escape_string($_POST['prosold'])){
    $ = encrypt(mysqli_real_escape_string($_POST['']);
    $ = encrypt(mysqli_real_escape_string($_POST['']);
    $ = encrypt(mysqli_real_escape_string($_POST['']);  
  }

if(isset(mysqli_real_escape_string($_POST['pronotes'])){
    $ = encrypt(mysqli_real_escape_string($_POST['']);
    $ = encrypt(mysqli_real_escape_string($_POST['']);
    $ = encrypt(mysqli_real_escape_string($_POST['']);
    $ = encrypt(mysqli_real_escape_string($_POST['']);
    $ = encrypt(mysqli_real_escape_string($_POST['']); 
  }*/

?>
