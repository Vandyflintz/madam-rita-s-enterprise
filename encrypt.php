<?php
function encrypt($value){
    $pass = 'madam2020rita!';
    $method = 'AES-128-ECB';
    $value = openssl_encrypt($value, $method, $pass);
    return $value;
}
function decrypt($value){
    $pass = 'madam2020rita!';
    $method = 'AES-128-ECB';
    $value=openssl_decrypt($value, $method, $pass);
    return $value;
}


?>