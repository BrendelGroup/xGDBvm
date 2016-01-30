### browser sniff redirect
# simple for transcript view
# Matt Wilkerson
$userAgent = $ENV{HTTP_USER_AGENT};
$ua = "";
if ($userAgent =~ /Mozilla\/5.0.+?Mac/i){
    $ua = "mozilla";
}elsif($userAgent =~ /Mozilla\/5.0.+?Windows/i){
    $ua = "mozilla";
}elsif($userAgent =~ /Mozilla\/5.0.+?Linux/i){
    $ua = "mozilla";
}elsif($userAgent =~ /MSIE 6.0.+?Windows/i){
    $ua = "IE";
}else{
    $ua = "bad";
}
