$(function() {
	$('#loginDialog').load(cgiPATH + 'userlight.pl?mode=loginForm');
	$('#loginDialog').dialog({
		title: 'Account Login',
		bgiframe: true,
                autoOpen: false,
                height: 400,
                width: 600,
                modal: true,
               	buttons: {
			'Login': function(){
				var dataObj = new Object();
				$('#loginDialog .loginFormInput').each( function(){
					dataObj[$(this).attr('id')] = $(this).attr('value');
				});
				dataObj['mode'] = 'login';
				$.get(cgiPATH + 'userlight.pl',dataObj,function(text){
					var LoginStatus = text;
					switch(LoginStatus){
					case "SUCCESS":
						top.opener.location.href = top.opener.location.href;
						formSubmit("","",'_self');
					break;
					default:
						$('#loginDialog').load(cgiPATH + 'userlight.pl?mode=loginForm&retry=1');
					}
				});
			},
			Cancel: function() {
				$(this).dialog('close');
				$(this).load(cgiPATH + 'userlight.pl?mode=loginForm');
			}
		}
	});
	$('#registerDialog').load(cgiPATH + 'userlight.pl?mode=registerForm');
	$('#registerDialog').dialog({
		title: 'Account Registration',
                bgiframe: true,
                autoOpen: false,
                height: 400,
                width: 600,
                modal: true,
                buttons: {
                        'Sign up': function(){
                                var dataObj = new Object();
                                $('#registerDialog .registerFormInput').each( function(){
                                        dataObj[$(this).attr('id')] = $(this).attr('value');
                                });
                                dataObj['mode'] = 'register';
                                $.get(cgiPATH + 'userlight.pl',dataObj,function(text){
                                        var LoginStatus = text;
                                        switch(LoginStatus){
                                        case "SUCCESS":
						top.opener.location.href = top.opener.location.href;
						formSubmit("","",'_self');
                                        break;
                                        default:
                                                $('#registerDialog').load(cgiPATH + 'userlight.pl?mode=registerForm&retry=1');
                                        }
                                });
                        },
                        Cancel: function() {
                                $(this).dialog('close');
                                $(this).load(cgiPATH + 'userlight.pl?mode=registerForm');
                        }
                }
        });
	$('#toggleLogin').click(function(){ $('#loginDialog').dialog('open');});
	$('#toggleRegister').click(function(){ $('#registerDialog').dialog('open');});
});
