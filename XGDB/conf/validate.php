<?php

/*If the text box doesn't have required data e.g; empty text box for a required field or alphabets in numeric field*/
/*Changes styling of the label corresponding to the text box to Red*/
function error_text_box($error, $field)
{
	if($error[$field])
	{
	print("class=\"empty_field\"");
	}
}



// email

function checkEmail ($strng) {
$error = false;
if ($strng == "") {
   $error = true;
}

    $emailFilter="/^.+@.+\..{2,3}$/";
    if (preg_match($emailFilter,$strng)==0) { 
       $error = true;
    }
    else {
//test email for illegal characters
       $illegalChars= "/[\(\)\<\>\,\;\:\\\"\[\]]/";
         if (preg_match($illegalChars,$strng)==1) {
          $error = true;
       }
    }
return $error;    
}


// phone number - strip out delimiters and check for 10 digits

function checkPhone ($strng) {
$error = false;
if ($strng == "") {
   $error = true;
}

$strng = preg_replace('/[\(\)\.\-\ ]/', "", $strng); //strip out acceptable non-numeric characters
if (!is_numeric($strng)) {
       $error = true;
  
    }
return $error;
}


// non-empty textbox

function isEmpty($strng) {
$error = false;
  if (trim($strng) == "") {
     $error = true;
  }
return $error;	  
}


// valid selector from dropdown list

function checkDropdown($choice) {
$error = false;
    if ($choice == "") {
    $error = true;
    }    
return $error;
}    
?>
