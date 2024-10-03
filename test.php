<?php
function decrypt($value){
    $pass = 'madam2020rita!';
    $method = 'AES-128-ECB';
    $value=openssl_decrypt($value, $method, $pass);
    return $value;
}

echo decrypt("MASRe989KegnLX8XJpM1aw6qhv17FyDe49acVSs6q8w=")."<br/><br/>".decrypt("vnRcHxVJNVuQRUFK72ucow==");

?>