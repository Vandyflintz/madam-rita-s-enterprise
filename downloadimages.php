<?php
ob_start();
  require_once('connection.php'); 
  ob_end_clean();
  

    $imgpath = "images/";
    if(is_dir_empty($imgpath)){
        echo json_encode("-1");
    }else{
     /* 
     header("Location: http://192.168.43.189/Madam_Rita_s_Enterprise/images.zip");*/
     //http://localhost/Madam_Rita_s_Enterprise/downloadimages.php?shop=Divine%20Baby%20Care&location=Near%20police%20station&shopid=sp63567288292
     if(isset($_GET['shop'])){
 $rootpath = realpath($imgpath);    
$query = mysqli_query($dbcon, "select prodimg from products WHERE `shopname` = '".mysqli_real_escape_string($dbcon, $_GET['shop'])."' and `location` = '".mysqli_real_escape_string($dbcon, $_GET['location'])."'");
 $imgstring ='';
 while ($fetch=mysqli_fetch_assoc($query)) {
     $imgstring.= $fetch['prodimg'].',';
 }

$zip = new ZipArchive();
$zip_name = $_GET['shopid'].".zip"; // Zip name
$zip->open($zip_name, ZipArchive::CREATE | ZipArchive::OVERWRITE);

$filesinSession = rtrim($imgstring,", ");
$filesToAdd = explode(',', trim($filesinSession, ','));
for ($i = 0; $i <= sizeof($filesToAdd) - 1; $i++) {
    $zip->addFile("images/".$filesToAdd[$i], basename($filesToAdd[$i]));
}
$zip->close();
$size = filesize($filename);
header('Content-Type: application/zip');
header('Content-Disposition: attachment; filename="' . $zip_name . '"');
header("Content-length: " . filesize($zip_name));
ob_end_clean();
flush();
readfile($zip_name);
exit();

 }else{
     $zipname = 'images.zip';
     $rootpath = realpath($imgpath);
     $zip = new ZipArchive();
     $zip->open($zipname,ZipArchive::CREATE | ZipArchive::OVERWRITE);
     $files = new RecursiveIteratorIterator(new RecursiveDirectoryIterator($rootpath), RecursiveIteratorIterator::LEAVES_ONLY);
     foreach ($files as $name => $file) {
         if(!$file->isDir()){
             $filepath = $file->getRealPath();
             $relativepath = substr($filepath, strlen($rootpath)+1);
             $zip->addFile($filepath, $relativepath);
         }
     } 
     $zip->close();
     /*$size = filesize($filename);
        header('Content-Type: application/zip');
        header('Content-Disposition: attachment; filename="' . $zip_name . '"');
        header("Content-length: " . filesize($zip_name));
        ob_end_clean();
        flush();
        readfile($zip_name);
        exit();*/
        header("Location: http://192.168.43.189/Madam_Rita_s_Enterprise/images.zip");
 }
     
    }
    
    
    function is_dir_empty($imgpath){
        $handle = opendir($imgpath);
        while(false !== ($entry = readdir($handle))){
            if($entry != "." && $entry !=".."){
             closedir($handle);
                return false;   
            }
        }
        closedir($handle);
        return TRUE;
    }
?>