<?php

##########################
# Security Validation    #
##########################

function shell_args_whitelist($argument) # 2/26/15 sanitize against code injection.d
{
	$pattern="/^[A-Za-z0-9\._\s\/-]+$/";
	if(preg_match($pattern, $argument))
	{ 
		$whitelist_argument=$argument;
	}
	else
	{
		$whitelist_argument="error";
	}
return $whitelist_argument; 
}

?>