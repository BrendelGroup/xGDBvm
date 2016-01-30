#!/usr/bin/perl
use CGI ":all";
use GSQDB;
use GDBgui;
use DBI;

do 'SITEDEF.pl';
do 'getPARAM.pl';
my $myDB=$DBver[$#DBver]->{DB};
if( !exists($cgi_paramHR->{imgW})){

  $inputs = "<input type='hidden' name='imgW' size='40' value='0' />\n";

  print(header((-cookie=>[$sCookie])),
        "<html>
			<head>
				<title>Calculating Window Size</title>
				<script type=\"text/javascript\" src=\"${JSPATH}dynamicWindow.js\"></script></head>\n",
        "	<body onload='setIMGW();'>
				<form action='${CGIPATH}getGSEG_Region.pl' enctype='multipart/form-data' method='post' name='guiFORM'>\n${inputs}</form>
			</body>\n",
        "</html>"
        );

  exit 1;
}
my $db=new GSQDB($cgi_paramHR);
$cgi_paramHR->{acc}=param('acc');
my ($resid,$UIDtype,$gi,$version1);
my $bacAcc=$cgi_paramHR->{acc};
my ($acc1,$version); 
if($bacAcc =~ /^(\S+)\.(\d+)/){
	$acc1=$1;
	$version=$2;
#print STDERR "mmmmmmmmmmmmmmmmmmm $acc1 mmmmmmmmmmmmmmmm $version\n";
}else{
	$acc1=$bacAcc;
}
if ($acc1){
($resid,$UIDtype,$gi) = $db->findRECORD({gi=>$acc1});
($resid,$UIDtype,$version1) = $db->findVersion({gi=>$acc1});
#print STDERR "Kkkkkkkkkkkkkkkkkkkk $gi kkkkkkkkkkkkkkkkk $version1\n";
	if (($version == $version1) or ($acc1 eq $bacAcc)){
		$cgi_paramHR->{gseg_gi}=$gi;
	}else{
		$cgi_paramHR->{gseg_gi}="";
	}
}

my $GDBpage = new GDBgui();
do 'getACCKEYWORD.pl';
#############Ann Added 07/24/09###########
#### Append user defined tracks ####
if(exists($cgi_paramHR->{frozen_user_tracks})){
  eval($cgi_paramHR->{frozen_user_tracks});
}
$db->mergeDynamicDSO($cgi_paramHR,$user_tracks) if(defined($user_tracks) && scalar(@$user_tracks));


## create page
$cgi_paramHR->{altCONTEXT} = "BAC";

my $contextDIV = $db->showREGION($cgi_paramHR);

my $PAGE_CONTENTS =<<END_OF_PAGE;
<!-- wz_tooltip.js must be loaded inline in the body section instead of the standard head section -->
<script src="${JSPATH}wz_tooltip.js" type="text/javascript"></script>

<input type='hidden' name='imgW' value="$cgi_paramHR->{imgW}" />
<input type='hidden' name='name' value=">gi|$cgi_paramHR->{gseg_gi}| bases $cgi_paramHR->{l_pos} - $cgi_paramHR->{r_pos}" />
<input type='hidden' name='name' value=">acc|$cgi_paramHR->{acc}| bases $cgi_paramHR->{l_pos} - $cgi_paramHR->{r_pos}" />
<input type='hidden' name='genome' value='F' />
<br />
<h1>"$SITENAME" &nbsp;
	<span class='heading'>
		  Help with this page <img id='genome_view' class='xgdb-help-button' src='/XGDB/images/help-icon.png' alt='?' />	
		&nbsp;  &nbsp;Track Color Codes <a title="Key to the Glyph Images used for Tracks" class="image-button help_link" id="XGDB_Glyphs:600:784"></a>
		&nbsp;  &nbsp;	 <a title='Right click to copy the exact link to this page' href='${CGIPATH}getGSEG_Region.pl?dbid=$cgi_paramHR->{dbid}&gseg_gi=$cgi_paramHR->{gseg_gi}&bac_lpos=$cgi_paramHR->{bac_lpos}&bac_rpos=$cgi_paramHR->{bac_rpos}'>Link to this Page</a>
		
	
	</span>
</h1>
<br />	
$contextDIV

<br /><br />

<a title='Right click to copy the exact link to this page' id='selfReference' href='${CGIPATH}getGSEG_Region.pl?dbid=$cgi_paramHR->{dbid}&gseg_gi=$cgi_paramHR->{gseg_gi}&bac_lpos=$cgi_paramHR->{bac_lpos}&bac_rpos=$cgi_paramHR->{bac_rpos}'>Link to this Page</a>
END_OF_PAGE


$cgi_paramHR->{headHR}    = {-cookie=>[$sCookie]};
$cgi_paramHR->{htmlHR}    = {-title=>"${SITENAMEshort} $cgi_paramHR->{gseg_gi}:$cgi_paramHR->{l_pos} - $cgi_paramHR->{r_pos}",
			     -script=>[
					{-src=>"${JSPATH}tools.js"},
					{-src=>"${JSPATH}ajaxfileupload.js"},
					{-src=>"${JSPATH}BACview.js"},
					{-src=>"${JSPATH}dynamicWindow.js"},
					{-src=>"${JSPATH}sortable_context_region.js"},
				      ],
			     -onResize=>'setIMGW();'
			    };
$cgi_paramHR->{main}      = $PAGE_CONTENTS;


$GDBpage->printXGDB_page($cgi_paramHR);

