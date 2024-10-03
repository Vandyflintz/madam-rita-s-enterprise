<?php
$dbcon=mysqli_connect("localhost","root","christabel02","mredb");  

if($dbcon){
echo "connected";
}else{
    echo "error";
}

?>