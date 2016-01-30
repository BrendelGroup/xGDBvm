//Sniffer
IE4 = (document.all)?true:false;
NS4 = (document.layers)?true:false;
DOM = ((document.getElementById)&&(!IE4))?true:false;

$( function(){
  $('#userRegisterDialog').dialog({
	title: 'Account Registration',
        bgiframe: true,
        autoOpen: false,
        height: 400,
        width: 600,
        modal: true,
        buttons: {
                'Sign Up': function() {
                        var dataObj = new Object();
                        $('.registrationInput').each( function() { dataObj[$(this).attr('name')] = $(this).attr('value'); });
                        dataObj['mode'] = 'register';
                        $.get(UCAPATH + 'userlight.pl', dataObj, function(text) {
                                var LoginStatus = text;
                                switch(LoginStatus){
                                case "SUCCESS":
					$.get(CGIPATH + 'xGDBupdateSession.pl',{'LOGINUPDATE':'COORDONLY'}, function() {document.location.href = document.location.href;});
                                        break;
                                case "BADUSER":
                                        $('.registrationMSG').each(function(){$(this).css('display','none');});
                                        $('#usernameMSG').css('display','block');
                                        $('#registrationMSG').css('display','block');
                                        break;
                                case "BADNAME":
                                        $('.registrationMSG').each(function(){$(this).css('display','none');});
                                        $('#fullnameMSG').css('display','block');
                                        $('#registrationMSG').css('display','block');
                                        break;
                                case "BADPASS":
                                        $('.registrationMSG').each(function(){$(this).css('display','none');});
                                        $('#passwordMSG').css('display','block');
                                        $('#registrationMSG').css('display','block');
                                        break;
                                case "BADEMAIL":
                                        $('.registrationMSG').each(function(){$(this).css('display','none');});
                                        $('#emailMSG').css('display','block');
                                        $('#registrationMSG').css('display','block');
                                        break;
                                default:
                                        $('#registrationMSG').css('display','block');
                                }
                        });
                },
                Cancel: function() {
		  $('.registrationMSG').each(function(){$(this).css('display','none');});
                  $(this).dialog('close');
                }
        }
  });

  $('#RegisterLink').click( function(){ $('#userRegisterDialog').dialog('open');});

  $('#LoginButton').click( function(){
    var dataObj = new Object();
    $('#formLogin').css('display','none');
    $('#authenticatingLogin').css('display','inline');
    $('.loginParam').each( function() { dataObj[$(this).attr('name')] = $(this).attr('value'); });
    dataObj['mode'] = 'login';
    $.get(UCAPATH + 'userlight.pl', dataObj, function(text) {
						var LoginStatus = text;
						switch(LoginStatus){
						  case "SUCCESS":
						    $.get(CGIPATH + 'xGDBupdateSession.pl',{'LOGINUPDATE':'COORDONLY'}, function() {document.location.href = document.location.href;});
						    break;
						  case "BADUSER":
						  case "BADPASS":
						    $('#badLoginMSG').css('display','inline');
						    $('#authenticatingLogin').css('display','none');
						    $('#formLogin').css('display','inline');
						    break;
						  default:
						    window.alert('Invalid login status code!');
						}
    });
  });

  $('#LogoutButton').click( function(){
    $.get(UCAPATH + 'userlight.pl',{'mode':'logout'},function(text) {
                                                var LoginStatus = text;
                                                switch(LoginStatus){
                                                  case "SUCCESS":
                                                    document.location.href = document.location.href;
                                                    break;
                                                  default:
                                                    window.alert('Invalid login status code!');
                                                }
    });
  });
});

function IEsucksAtCSS(obj,clName){
  if(IE4){
    obj.className=clName;
  }
}

function reqCurrVer(){
  if(document.guiFORM.dbid.selectedIndex < (eval(document.guiFORM.dbid.length) - 1)){
    window.alert("This tool requires that you work with the most recent version of the genome annotation!");
    return 0;
  }
  return 1;
}

function outOfChrBounds(chr,start,end){
  if(eval(start) > eval(end)){
    document.guiFORM.l_pos.value = end;
    document.guiFORM.r_pos.value   = start;
  }
  if(eval(start) <= 0){
    document.guiFORM.l_pos.value = 1;
  }
  if(eval(end) > ChrLen[chr]){
    document.guiFORM.r_pos.value   = ChrLen[chr];
  }
  if((eval(document.guiFORM.r_pos.value) - eval(document.guiFORM.l_pos.value)) > 300000){
    document.guiFORM.r_pos.value = eval(document.guiFORM.l_pos.value) + 300000;
    if(eval(end) > ChrLen[chr]){
      document.guiFORM.r_pos.value = ChrLen[chr];
    }
    window.alert('The maximum view range allowed is 300KB!');
  }
  return 0;
}

function submitTo(aURL){
  document.guiFORM.action = aURL;
  document.guiFORM.submit();
}

function submitToSearch(aURL){
  document.guiFORM.action = aURL;
  document.guiFORM.submit();
}


function doLogin(aURL){
  window.open(aURL,'USERhome','toolbar=no,status=yes,scrollbars=yes,location=no,menubar=yes,directories=no,resizable=yes,width=800,height=600');
}
function doLogout(aURL){
  window.open(aURL,'USERhome','toolbar=no,status=yes,scrollbars=yes,location=no,menubar=yes,directories=no,resizable=yes,width=800,height=600');
}
function doRegister(aURL){
  window.open(aURL,'REGISTER','toolbar=no,status=yes,scrollbars=yes,location=no,menubar=yes,directories=no,resizable=yes,width=800,height=600');
}
function goHome(aURL){
  window.open(aURL,'USERhome','toolbar=no,status=yes,scrollbars=yes,location=no,menubar=yes,directories=no,resizable=yes,width=800,height=600');
}

function getRegion(aURL){
  document.guiFORM.action = aURL;
  document.guiFORM.submit();
}

function RunGeneSeqer(){
  var Hlink;
  var Wname;
  if(reqCurrVer()){
    outOfChrBounds(document.guiFORM.chr.selectedIndex,document.guiFORM.l_pos.value,document.guiFORM.r_pos.value);
    Hlink = GSQwebpath + "?chr=" + eval(document.guiFORM.chr.selectedIndex + 1) + "&_a=" + document.guiFORM.l_pos.value + "&_b=" + document.guiFORM.r_pos.value;
    Wname = "chr" + eval(document.guiFORM.chr.selectedIndex + 1) + "_" + document.guiFORM.l_pos.value + "_" + document.guiFORM.r_pos.value;
    window.open(Hlink,Wname);
  }
}

function GSEGRunGeneSeqer(){
        var Hlink;
        var Wname;
        if(reqCurrVer()){
        Hlink = GSQwebpath + "?acc=" + document.guiFORM.gseg_gi.value + "&_a=" + document.guiFORM.l_pos.value + "&_b=" + document.guiFORM.r_pos.value + "&_s=maize";
    Wname = document.guiFORM.gseg_gi.value + "_" + document.guiFORM.l_pos.value + "_" + document.guiFORM.r_pos.value;
    window.open(Hlink,Wname);
  }
}

function doAnnotation(altCONTEXT,blastDB){
  var Hlink;
  if(altCONTEXT == 'BAC'){
    Hlink = UCAwebpath + "?start=" + document.guiFORM.bac_lpos.value + "&end=" + document.guiFORM.bac_rpos.value +  "&dbid=" + document.guiFORM.curDBID.value + "&blastDB=" + blastDB + "&altCONTEXT=" + altCONTEXT + "&chr=" + document.guiFORM.gseg_gi.value;
  }else if(reqCurrVer()){
    Hlink = UCAwebpath + "?start=" + document.guiFORM.l_pos.value + "&end=" + document.guiFORM.r_pos.value +  "&dbid=" + document.guiFORM.curDBID.value + "&blastDB=" + blastDB + "&altCONTEXT=" + altCONTEXT + "&chr=" + eval(document.guiFORM.chr.selectedIndex + 1);
  }
  window.open(Hlink,'UCA','scrollbars=yes,resizable=yes,screenX=100,screenY=100,toolbar=no,status=yes,location=no,menubar=no,directories=no');
}

function doAnnotation_generic(dbid,altCONTEXT,gseg,l_pos,r_pos,blastDB){
  var Hlink;
    Hlink = UCAwebpath + "?start=" + l_pos + "&end=" + r_pos +  "&dbid=" + dbid + "&blastDB=" + blastDB + "&altCONTEXT=" + altCONTEXT + "&chr=" + gseg;

  window.open(Hlink,'UCA','scrollbars=yes,resizable=yes,screenX=100,screenY=100,toolbar=no,status=yes,location=no,menubar=no,directories=no');
}


function go_to(){
}

function checkEnter(event,sb){     
  var code = 0;
  if(NS4){
    code = event.which;
  }else{
    code = event.keyCode;
  }

  if(code==13){     // ENTER key
    submitTo(sb);
  }
}

function check2KEY(event,sb1,sb2){
  var code = 0;
  if(NS4){
    code = event.which;
  }else{
    code = event.keyCode;
  }

  if(event.shiftKey){
    if(code==13){      // SHIFT + ENTER key
      submitTo(sb2);
    }
  }else if(code==13){  // ENTER key
    submitTo(sb1);
  }

  return 0;
}
