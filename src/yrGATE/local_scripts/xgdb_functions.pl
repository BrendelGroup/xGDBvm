#!/usr/bin/perl
init_xgdb(); 

sub init_xgdb{
  # initializes global values for xgdb implementation, add from xgdb cookie
  # temporary fix to use length of genome segment if (length($PRM->{chr}) 
  # >= 3 ){Not valid for Scaffold browsers
	if ($GV->{CHR_SELECT_BOX} == 0){# This value is initialized for each xgdb
		$GV->{altCONTEXT} = "BAC";
		$GV->{blastDB} = $GV->{altblastDB};
		# $GV->{CHR_SELECT_BOX} = 0;No need of this
	}else{
		$GV->{altCONTEXT} = "chr";
		$GV->{blastDB} = "GENOME";
    }

  #check for https (JFD)
  if (-e "/xGDBvm/admin/https") {
    $rootPath = "https://$ENV{SERVER_NAME}/";
  } else {
    $rootPath = "http://$ENV{SERVER_NAME}/";
  }
  return;
}
sub getGenomeSequence_xgdb{
  init_xgdb();
  my $seq;
  #This defines the UserAgent for https get/posts, verify_host checks the certificate
  my $userAg = LWP::UserAgent->new(
      ssl_opts=> {verify_hostname =>0},
  );
  my $link = $rootPath;
  $link .= "$GV->{SSIpath}returnFASTA.pl?db=$GV->{blastDB}&dbid=$GV->{dbid}&hits=$PRM->{chr}:$PRM->{start}:$PRM->{end}";
  print STDERR $link;
  
  #added http check (jfd)
  if (-e "/xGDBvm/admin/https") {
    my $res = $userAg->get($link);
    $seq = $res->decoded_content;
  } else {
    $seq = get("${link}");

  }
  $seq =~ s/.+?<pre>>.+?\n//is; # remove all html up to defline
  $seq =~ s/<\/pre>.+//is; # remove trailing html
  $seq =~ s/\W//sg; # remove all line breaks
  return $seq;
  
}

sub getImageMap_xgdb{
  # returns image html + image map + scale variable
    my $ua = LWP::UserAgent->new(
      ssl_opts=> {verify_hostname =>0},
    );
    
    init_xgdb();
    my $link = $rootPath;
    $link .= $GV->{SSIpath}."UCAimage.pl?l_pos=$PRM->{start}&r_pos=$PRM->{end}&dbid=$GV->{dbid}&imgWidth=$PRM->{imgWidth}";
    $link .= ($GV->{altCONTEXT} eq "BAC") ? "&gseg_gi=$PRM->{chr}&altCONTEXT=$GV->{altCONTEXT}" : "&chr=$PRM->{chr}";
    my @sessionCookie = cookie($GV->{SessCookieName}); # reads session id from cookie and accesses php session variables
  my $id = $sessionCookie[0];
  #  print STDERR $id;

  if ($id ne ""){
    my $session = PHP::Session->new($id, { create => 1,save_path => $GV->{session_path} });
    if ($session->is_registered($GV->{SessLoginParam})){
      my $sid = $session->get('USERsessionCGI');
      $link .= "&XGDBpassthrough=1&xGDB-cgisessid=$sid";
    }
  }
  #print STDERR $link;
 # added http check (jfd)
  if (-e "/xGDBvm/admin/https") {
     my $imagelinkALL = $ua->get($link);
    return $imagelinkALL->decoded_content;
  } else { 
    my $imagelinkALL = get("${link}");
    return $imagelinkALL;
  }
}
sub getScale_xgdb{
	my $zeroPos = int($PRM->{start});
	my $StartX=20;
	my $Margin=10;
	my $imgWidth = $PRM->{imgWidth};
	my $unit=1000;
	my $len=$PRM->{end}-$PRM->{start}+1;
	if($len<1000){
		$unit=10;
	}elsif($len<10000){
		$unit=100;
	}
	#my $zeroPos = int($start); # change to local
	my $seqLen = $PRM->{end} - $zeroPos + 1;
	my $ratio=$seqLen/($PRM->{imgWidth}-$StartX-2*$Margin);
	my $rulerLen=$seqLen/$ratio;
	my $scale=$seqLen/$rulerLen;
	$scale = sprintf("%.2f", $scale);
	
	return ($scale,$zeroPos,$StartX,$Margin); # [base to pixel scale] , [base position of start of graphic], [left padding white space in graphic]
}
sub GenomeContextLink_xgdb{
	my ($chr,$lp,$rp,$dbVer) = @_;
	my $link = "$GV->{rootPATH}$GV->{SSIpath}";
         #  $link .= (length($chr) <= 2) ? "getRegion.pl?dbid=$dbVer&chr=$chr&l_pos=$lp&r_pos=$rp" : "getGSEG_Region.pl?dbid=$dbVer&gseg_gi=$chr&bac_lpos=$lp&bac_rpos=$rp" ;# Not valid for Scaffold based browsers
	$link .= ($GV->{CHR_SELECT_BOX} != 0) ? "getRegion.pl?dbid=$dbVer&chr=$chr&l_pos=$lp&r_pos=$rp" : "getGSEG_Region.pl?dbid=$dbVer&gseg_gi=$chr&bac_lpos=$lp&bac_rpos=$rp" ;
	return $link;
}
sub headerExtra{
  # this is duplicated in pgdb_functions.pl
  my $s;
  # add script
  $s .= "Other yrGATE Databases:
	<script type='text/javascript'>
	/* <![CDATA[ */
	function changeDb(){
		url = document.forms[0].otherDb.options[document.forms[0].otherDb.selectedIndex].value;
		if (url == ''){return;}
    		location.href = url;
	}
	/* ]]> */
	</script>";
  $s .= "<select name='otherDb' onchange='changeDb();'>";
  my $otherB==0;
  foreach my $d (['Arabidopsis','AtGDB'],['Rice','OsGDB'],['Maize','ZmGDB'],['Maize, Sorghum','PlantGDB-GSS']){
    my ($org,$db) = @$d;
    my $url = $GV->{rootPATH};
    chop $url;
    $url .= "$GV->{CGIPATH}";
    $url =~ s/$GV->{dbTitle}/$db/;
	    $s .= "<option value='${url}CommunityCentral.pl' ";
	    $s .= ($GV->{CGIPATH} =~ /$db/) ? " selected " : "";
	    $otherB = ($GV->{CGIPATH} =~ /$db/) ? 1 : $otherB;
	    $s .= " >$org - $db</option>";
  }
  $s .= "<option value='http://www.plantgdb.org/prj/Genome_browser.php' ";
  $s .= ($otherB==0) ? " selected='selected' " : "";
  $s .= ">Others</option>";
  $s .= "</select>";
  return $s;
}
1;
