#!/usr/bin/perl
package GDBgui;

do 'SITEDEF.pl';

use CGI ":all";
use GSQDB;

sub new{
  my $class = shift;
  my ($argHR) = @_;
  my $self = {};
  bless $self, ref($class) || $class;
  return $self;
}

sub printXGDB_page{
  my ($self,$cpHR) = @_;
  $self->printXGDB_Head($cpHR);
  $self->printXGDB_StartHtml($cpHR);
  print $cpHR->{preHeader};
  $self->print_SiteHeader($cpHR);
  $self->print_LeftSidebar($cpHR);
  print "<div id=\"xgdbmaincontentscontainer\"><div id=\"xgdbmaincontents\">  $cpHR->{main}  </div></div><!--end mainWLS--><br /><br />\n";
  print $cpHR->{preFooter};
  $self->print_SiteFooter($cpHR);
  print "</div></div>";
  $self->printXGDB_EndHtml($cpHR);

  return 1;
}

sub printXGDB_Head{
  my ($self,$cpHR) = @_;

  ## set default HTML <head> properties ($cpHR->{headHR})
  print header(%{$cpHR->{headHR}}) . "\n";

  return 1;
}

sub printXGDB_StartHtml{

  my ($self,$cpHR) = @_;
	$cpHR->{htmlHR}->{-title} =(exists($cpHR->{htmlHR}->{-title})) ? $cpHR->{htmlHR}->{-title}:$SITENAME;

  ## set default HTML <html> PROPERTIES ($CPhr->{HTMLhR})
  $cpHR->{htmlHR}->{-title} =(exists($cpHR->{htmlHR}->{-title})) ? $cpHR->{htmlHR}->{-title} : $SITENAME;
  unshift(@{$cpHR->{htmlHR}->{-style}}, ({-src=>"/XGDB/css/superfish.css"}, {-src=>"/XGDB/css/plantgdb.css"},{-src=>"/src/yrGATE/yrGATE.css"}, {-src=>"/XGDB/javascripts/jquery/themes/base/ui.all.css"}, {-src=>"/XGDB/css/sortable_context_region.css"}, {-src=>$defaultStyleSheet}));

  if(exists($cpHR->{htmlHR}->{-script})){
    unshift(@{$cpHR->{htmlHR}->{-script}},(
		{-src=>"/XGDB/javascripts/jquery/jquery-1.3.2.js"},
		{-src=>"/XGDB/javascripts/jquery/ui/ui.core.js"},
		{-src=>"/XGDB/javascripts/jquery/ui/ui.sortable.js"},
		{-src=>"/XGDB/javascripts/jquery/ui/ui.draggable.js"},
		{-src=>"/XGDB/javascripts/jquery/ui/ui.resizable.js"},
		{-src=>"/XGDB/javascripts/jquery/ui/ui.dialog.js"},
		{-src=>"/XGDB/javascripts/jquery/ui/effects.core.js"},
		{-src=>"/XGDB/javascripts/jquery/ui/effects.highlight.js"},
		{-src=>"/XGDB/javascripts/jquery/external/bgiframe/jquery.bgiframe.js"},
		{-src=>"/XGDB/javascripts/default_xgdb.js"}, ## WARNING! The tablesorter function in this script breaks jquery if loaded after it! Not sure why?? ##
		{-src=>"/XGDB/javascripts/superfish.js"},
		{-src=>"/XGDB/javascripts/hoverIntent.js"},
		{-src=>"/XGDB/javascripts/XGDBheader.js"},
	   ));
  }else{
    $cpHR->{htmlHR}->{-script}  =  [
		{-src=>"${JSPATH}jquery/jquery-1.3.2.js"},
		{-src=>"${JSPATH}jquery/ui/ui.core.js"},
		{-src=>"${JSPATH}jquery/ui/ui.sortable.js"},
		{-src=>"${JSPATH}jquery/ui/ui.draggable.js"},
		{-src=>"${JSPATH}jquery/ui/ui.resizable.js"},
		{-src=>"${JSPATH}jquery/ui/ui.dialog.js"},
		{-src=>"${JSPATH}jquery/ui/effects.core.js"},
		{-src=>"${JSPATH}jquery/ui/effects.highlight.js"},
		{-src=>"${JSPATH}jquery/external/bgiframe/jquery.bgiframe.js"},
		{-src=>"${JSPATH}default_xgdb.js"}, ## WARNING! The tablesorter function in this script breaks jquery if loaded after it! Not sure why?? ##
		{-src=>"${JSPATH}superfish.js"},
		{-src=>"${JSPATH}hoverIntent.js"},
		{-src=>"${JSPATH}XGDBheader.js"},
		];
  }

  print start_html(%{$cpHR->{htmlHR}}) . "\n";
  return 1;
}

sub printXGDB_EndHtml{
  my ($self,$cpHR) = @_;

  print end_html();

  return 1;
}

sub print_SiteHeader{
  my ($self,$cpHR) = @_;
  my $fontstyle  = "'font-family: Verdana,Arial,sans-serif;font-size: 12px;'";
  my $fontstyle2 = "'font-family: Verdana,Arial,sans-serif;font-size: 16px;'";
  my $link_color = (exists($cpHR->{gseg_gi}))?'#0000FF':'#FFFFFF';
  do 'xgdbGUIconf.pl';
  
  ## Print header javascript
  my $CHRLIST = join(',',@{$DBver[$cpHR->{dbid}]->{chrSIZE}});
  print <<END_OF_PRINT;
<script type="text/javascript">
/* <![CDATA[ */
var ChrLen   = new Array(${CHRLIST});
var GSQwebpath = "${GSQwebpath}";
var UCAwebpath = "${ucaPATH}AnnotationTool.pl";
var UCAPATH  = "${ucaPATH}";
var IMAGEDIR = "${IMAGEDIR}";
var CGIPATH  = "${CGIPATH}";
var JSPATH   = "${JSPATH}";
var CSSPATH  = "${CSSPATH}";
var XGDBHTML = "${XGDBHTML}";
var HAS_TRACK_CONTROL = 0;
var xgdb_state = "${SITENAMEshort}_state";
/* ]]> */
</script>

	<div id="xgdbcontainer">
	
	<form action="" method="post" enctype="multipart/form-data" name="guiFORM">
	<input type="text" name="wsize" value="$cpHR->{wsize}" class="debug" />
	<input type="text" name="resid" value="$cpHR->{resid}" class="debug" />
	<input type="text" name="curDBID" value="$cpHR->{dbid}" class="debug" />
	<input type="text" name="userid" value="$cpHR->{USERid}" class="debug" />

	<!-- deprecated now using session control w/ajax update
	<input type="text" name="trackORDER" value="$cpHR->{trackORDER}" class="debug" />
	<input type="text" name="trackVISIBLE" value="$cpHR->{trackVISIBLE}" class="debug" />
	<input type="text" name="trackDATA" value="$cpHR->{trackDATA}" class="debug" />
	<input type="text" name="customORDER" value="$cpHR->{customORDER}" class="debug" />
	<input type="text" name="customVISIBLE" value="$cpHR->{customVISIBLE}" class="debug" /-->

END_OF_PRINT


  ## Print query search row ( header row 2 )
  my $LOGGEDin   =  ((exists($cpHR->{USERid}))&&($cpHR->{USERid}))?
    (defined(%UserManage) && exists($UserManage{userHome}))?a($UserManage{userHome},"$cpHR->{USERid} @ ${SITENAMEshort}"):"$cpHR->{USERid} @ ${SITENAMEshort}":
    (defined(%UserManage) && exists($UserManage{login}))?a($UserManage{login},"Anonymous"):"Anonymous";

	if ($GDBDIR =~ /(GDB\d+)/){
		$GDBDIR1 = $1;
		
	}

  my $loginPANE = <<EOP;
<ul id='loginPane' style='display:none;'>
<li>
	<div id='authenticatingLogin' style='display:none;'>
		Authenticating Login. Please wait.
		<img id='authenticatingIMG' src='${IMAGEDIR}DNA_small.gif' alt='Loading...' />
	</div>
	<div id='formLogin'>
		<span id='badLoginMSG' style='display:none;'>Unrecognized User/Password combination! Please try again.<br /></span>
		Username: <input type='text' class='loginParam' name='username' id='login_username' size='20' /><br />
		Password: <input type='password' class='loginParam' name='password' id='login_password' size='20' /><br />
		Stay logged in until I:
		<select class='loginParam' name='persistence' id='persistence'>
			<option value='0'>close my browser</option>
			<option value='+1d'>am inactive for a day</option>
			<option value='+10y' selected='selected'>click logout</option>
		</select>
		<button type='button' id='LoginButton'>Login</button>
		<a href='/yrGATE/${GDBDIR1}GDB/loginReset.pl'>Forgot username / password</a>
	</div>
</li>
</ul>
EOP

  my $loginMenu = (exists($cpHR->{USERid})&&($cpHR->{USERid}))?"<li id='LogoutButton' class='last'>Logout</li>":"<li>Login${loginPANE}</li><li id='RegisterLink' class=\"last\">Register</li>";

	my $file = "/xGDBvm/admin/sitename";
	my $document = do {
		local $/ = undef;
		open my $fh, "<", $file;
		<$fh>;
	};
	my $sitename=$document;
	
  ## Print logo and title ( header top )
  print <<END_OF_PRINT;
<div id="userRegisterDialog" style='display:none;'>

  <p id='registrationMSG' class='registrationMSG' style='display:none;'>That username or email is already registered, or you have forgotten to enter a required field.  Please try again.</p>
  <hr /><br />
  <p id='usernameMSG' class='registrationMSG' style='display:none;'>This username is invalid or already in use! Please choose another.</p>
  <p>user name <input class='registrationInput' type='text' id='reg_username' name='username' /></p>
  <p id='passwordMSG' class='registrationMSG' style='display:none;'>This password is invalid! Please choose another.</p>
  <p>password <input class='registrationInput' type='password' id='reg_password' name='password' /></p>
  <p id='emailMSG' class='registrationMSG' style='display:none;'>This email address is invalid or already in use! Please choose another.</p>
  <p>email <input class='registrationInput' type='text' id='email' name='email' /></p>
  <p id='fullnameMSG' class='registrationMSG' style='display:none;'>Please supply an account name.</p>
  <p>name <input class='registrationInput' type='text' id='fullname' name='fullname' /></p>
  <p>phone <input class='registrationInput' type='text' id='phone' name='phone' /> (not required) </p>
</div>

<div id="logomenucontainer">
        <div id="headerwidth">
		<div id="topLeftLogo" ><h1 style="  margin-top:3px; margin-bottom:18px" class="GroupID larger"><a title="GDB Home Page for this genome" href="/XGDB/phplib/index.php?GDB=${GDBDIR1}">${GDBDIR1}</a> </h1></div>
        <div id="pgdblogo">
		<div style="position:absolute; top:32px; left:2%"><span id="sitename">$sitename</span></div>
                                <a style="background:none" href= "/"><img id="xgdbvm_banner" alt="xGDBvm Banner" border="none" src="/XGDB/images/Banner.png" /></a>
         </div>

<div id="topleft">
	<ul id="userlogin" class="sf-menu corner-menu">
		<li>$LOGGEDin</li>
		$loginMenu
	</ul>
</div>

	<div id="topright">
        <ul>
                <li></li>
                </ul>

</div>


END_OF_PRINT
print "${PGDBmenu}";
print <<END_OF_PRINT;
<div id="topRow">
</div>
</div></div>

<div id="HeaderRow2">
	<p id="searchCONTROL" class="bold">Search: &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
		<input class="searchINPUT" name="searchSTR" type="text" size="20" value="" onfocus="this.value='';" onkeypress="check2KEY(event,'${CGIPATH}findRegion.pl','${CGIPATH}findRecord.pl')" />
		&nbsp;&nbsp;Display: 
		<input class="searchINPUT" name="Genome" type="button" value="Genome" onclick="submitTo('${CGIPATH}findRegion.pl');" />
		<input class="searchINPUT" name="Records" type="button" value="Records" onclick="submitTo('${CGIPATH}findRecord.pl');" />
		<img id='genome_quicksearch' title='Search Help' class='xgdb-help-button' src='/XGDB/images/help-icon.png' alt='?' />
		</p>
</div>
END_OF_PRINT

  ## Print genome navigation row ( header row 3 )

## print SITEDEF defined alternativecontexts
if(defined($altCONTEXT)){
  foreach my $ACname (keys %$altCONTEXT){
    if($cpHR->{altCONTEXT} eq $ACname){
      print <<END_OF_PRINT;
<div id='HeaderRow3_${ACname}'>
	<p id="loginMenu">$loginMenu</p>
	
	$altCONTEXT->{$ACname}
</div>

END_OF_PRINT
    }
  }
}

if(($cpHR->{altCONTEXT} eq 'BAC') && !exists($altCONTEXT->{BAC})){
## print standard alternative context ( BAC )
    print <<END_OF_PRINT;
<div id='HeaderRow3_BAC'>
<p class='segmentSelect bold' id='bacNav'>
END_OF_PRINT
## Get the cgi session hash reference "last visited" location, if user has visited a region.
    if(defined($USE_BAC_MENU_IN_HEADER) && $USE_BAC_MENU_IN_HEADER){
      my $db=new GSQDB($cpHR);
      $cpHR->{GSEGresid} = exists($cpHR->{GSEGresid})?$cpHR->{GSEGresid}:
                           defined($DEFAULT_GSEG_RESID)?$DEFAULT_GSEG_RESID:0;
      print "${GSEG_SRC}: " . $db->getGsegMenu($cpHR) . "<br />";
    }else{
      print <<END_OF_PRINT;
Segment ID: <input name="gseg_gi" class="navINPUT" type="text" value="$cpHR->{gseg_gi}" size="20" />
END_OF_PRINT
    }

print <<END_OF_PRINT;
&nbsp;Start: <input name="bac_lpos" class="navINPUT" type="text" value="$cpHR->{l_pos}" size="7" onkeypress="checkEnter(event,'')" />
&nbsp;End: <input name="bac_rpos" class="navINPUT" type="text" value="$cpHR->{r_pos}" size="7" onkeypress="checkEnter(event,'')" />
<input name="bac_GoButton" class="navINPUT" type="button" value="Go" onclick="getRegion('${CGIPATH}getGSEG_Region.pl');" />
</p>
</div>

END_OF_PRINT
}

if($cpHR->{altCONTEXT} eq 'chr'){
## print default context ( pseudo-chromosome )
  my $chrDROPDOWN  = '';
  for($x=1;$x<=scalar(@{$DBver[$cpHR->{dbid}]->{chrSIZE}});$x++){
    $chrDROPDOWN .= (exists($DBver[$cpHR->{dbid}]->{ChrMap_full}))?
			($x == $cpHR->{chr})?"<option value=\"$x\" selected=\"selected\">$DBver[$cpHR->{dbid}]->{ChrMap_full}->[$x-1]</option>\n":"<option value=\"$x\">$DBver[$cpHR->{dbid}]->{ChrMap_full}->[$x-1]</option>\n"
		    :(exists($DBver[$cpHR->{dbid}]->{ChrMap}))?($x == $cpHR->{chr})?"<option value=\"$x\" selected=\"selected\">$DBver[$cpHR->{dbid}]->{ChrMap}->[$x-1]</option>\n":"<option value=\"$x\">$DBver[$cpHR->{dbid}]->{ChrMap}->[$x-1]</option>\n"
			:($x == $cpHR->{chr})?"<option value=\"$x\" selected=\"selected\">$x</option>\n":"<option value=\"$x\">$x</option>\n";
  }
  my $dbidDROPDOWN = '';
  for($x=0;$x<=$#DBver;$x++){
    $dbidDROPDOWN .= ($x == $cpHR->{dbid})?"<option class=\"normalfont\" value=\"$x\" selected=\"selected\">$DBver[$x]->{DBtag}</option>\n":"<option class=\"normalfont\" value=\"$x\">$DBver[$x]->{DBtag}</option>\n";
  }
  print <<END_OF_PRINT;
<div id="HeaderRow3_pCHR">
	<p class="segmentSelect normalfont" id="pseudochromosomeNav">
		Assembly/Version:<select id="dbid" name="dbid" class="navINPUT">${dbidDROPDOWN}</select>
		&nbsp;Chr:<select id="chr" name="chr" class="navINPUT">${chrDROPDOWN}</select>
		&nbsp;Start:<input name="l_pos" class="navINPUT" type="text" value="$cpHR->{l_pos}" size="9" style="text-align:right" onkeypress="checkEnter(event,'')" />
		&nbsp;End:<input name="r_pos" class="navINPUT" type="text" value="$cpHR->{r_pos}" size="9" style="text-align:right" onkeypress="checkEnter(event,'')" />
		Display: <input name="GoButton" class="navINPUT" type="button" value="Genome Context" onclick="getRegion('${CGIPATH}getRegion.pl');" />
		${DisplayLoci}
	</p>
</div>

END_OF_PRINT
}

  return 1;
}

sub print_LeftSidebar{
	my ($self,$cpHR) = @_;
	
	my @links = (); my $linkAR = '';
	foreach $linkAR (@sidebarLinks){
		push(@links,a($linkAR->[0],$linkAR->[1]));
	}
	
	print <<END_OF_PRINT;
<div id="LeftSidebar">
END_OF_PRINT


if ($ENV{'REQUEST_URI'} =~ m/index.php/ || length($ENV{'REQUEST_URI'}) == 8) { #  /GDB001/ = 8
  print "<div class=\"NavMenu first\"><a class=\"current_xgdb\" title=\"GDB Home Page\" href=\"/XGDB/phplib/index.php?GDB=${GDBDIR1}\">GDB Home</a></div>";
} else {
  print "<div class=\"NavMenu first\"><a title=\"GDB Home Page\" href=\"/XGDB/phplib/index.php?GDB=${GDBDIR1}\">GDB Home</a></div>";
}
  print "<div class=\"NavMenu first\"><a class=\"\" title=\"GDB List Page\" href=\"/XGDB/genomes.php\">List All</a></div>";

print <<END_OF_PRINT;
<h2 class="GroupID">Genome View</h2>
END_OF_PRINT

if ($ENV{'REQUEST_URI'} =~ m/getGSEG_Region.pl/) { #  Genome Context View
  print "<div class=\"NavMenu first\"><a class=\"current_xgdb\" title=\"View in Genome Context\" href=\"/${GDBDIR1}/cgi-bin/getGSEG_Region.pl\">Current Region</a></div>";
} else {
  print "<div class=\"NavMenu first\"><a title=\"View in Genome Context\" href=\"/${GDBDIR1}/cgi-bin/getGSEG_Region.pl\">Current Region</a></div>";
}


print <<END_OF_PRINT;
<h2 class="GroupID">Search/Retrieve</h2>
END_OF_PRINT

if ($ENV{'REQUEST_URI'} =~ m/cgi-bin\/search/) {
  print "<div class=\"NavMenu first \"><a class=\"current_xgdb\" title=\"Open Advanced Search Window\" href=\"/${GDBDIR1}/cgi-bin/search.pl\">By ID/Keyword</a></div>";
} else {
  print "<div class=\"NavMenu first \"><a title=\"Open Advanced Search Window\" href=\"/${GDBDIR1}/cgi-bin/search.pl\">By ID/Keyword</a></div>";
}

if ($ENV{'REQUEST_URI'} =~ m/downloadGDB/ || $ENV{'REQUEST_URI'} =~ m/formatReader/) {
  print "<div class=\"NavMenu\"><a class=\"current_xgdb\" title=\"Open Search by Region Window\" href=\"/${GDBDIR1}/cgi-bin/downloadGDB.pl\">By Region</a></div>";
} else {
  print "<div class=\"NavMenu\"><a title=\"Open Search by Region Window\" href=\"/${GDBDIR1}/cgi-bin/downloadGDB.pl\">By Region</a></div>";
}


print <<END_OF_PRINT;
<h2 class="GroupID">Feature Tracks</h2>
END_OF_PRINT

# print <<END_OF_PRINT;
#<h3 class="indent2 GroupID">Precomputed</h3>
#END_OF_PRINT
#my($Gffnum) = &GffLocus_Count($GDBDIR1); #testing JPD

if ($ENV{'REQUEST_URI'} =~ m/DisplayLoci/) {
        print "<div class=\"NavMenu\"><a  class=\"current_xgdb\" title=\"Tabular view(s) of gene models for $GDBDIR1\" href=\"/XGDB/phplib/DisplayLoci.php?GDB=$GDBDIR1\">Gene Models </a></div>";
} else {
        print "<div class=\"NavMenu\"><a title=\"Tabular view(s) of gene models for $GDBDIR1\" href=\"/XGDB/phplib/DisplayLoci.php?GDB=$GDBDIR1\">Gene Models </a></div>";
}

if ($ENV{'REQUEST_URI'} =~ m/DisplayProteins/) {
			print "<div class='NavMenu'><a class=\"current_xgdb\" href=\"/XGDB/phplib/DisplayProteins.php?GDB=$GDBDIR1\" title=\"Tabular view of related-species proteins aligned to the genome, with functional annotations\">Aligned Proteins </a></div>";
} else {
			print "<div class='NavMenu'><a href=\"/XGDB/phplib/DisplayProteins.php?GDB=$GDBDIR1\" title=\"Tabular view(s) of related-species proteins aligned to the genome, with descriptions (if any)\">Aligned Proteins </a> </div>";
}

if ($ENV{'REQUEST_URI'} =~ m/DisplayTranscripts/) {
			print "<div class='NavMenu'><a class=\"current_xgdb\" href=\"/XGDB/phplib/DisplayTranscripts.php?GDB=$GDBDIR1\" title=\"Ordered list of transcripts aligned to the genome, with functional annotations\">Aligned Transcripts </a></div>";
} else {
			print "<div class='NavMenu'><a href=\"/XGDB/phplib/DisplayTranscripts.php?GDB=$GDBDIR1\" title=\"Tabular view(s) of transcripts aligned to the genome, with descriptions (if any)\">Aligned Transcripts </a> </div>";
}

if ($ENV{'REQUEST_URI'} =~ m/GAEVAL.*/) {
  print "<div class=\"NavMenu\"><a class=\"current_xgdb\" title=\"Tables that evaluate congruence between gene models and evidence alignments\" href=\"/XGDB/phplib/GAEVAL.php?source=GFF&amp;GDB=$GDBDIR1\"> GAEVAL Scores </a></div>";
} else {
  print "<div class=\"NavMenu\"><a title=\"Tables that evaluate congruence between gene models and evidence alignments\" href=\"/XGDB/phplib/GAEVAL.php?source=GFF&amp;GDB=$GDBDIR1\"> GAEVAL Scores </a></div>";
}


print <<END_OF_PRINT;
<h2 class="GroupID">Community Central</h2>
END_OF_PRINT


print <<END_OF_PRINT;
<div class="NavMenu first"><a href="${ucaPATH}CommunityCentral.pl" target= "_blank" title="Community Annotated Gene Models">Curated Annotations </a></div>
END_OF_PRINT

print <<END_OF_PRINT;
<div class="NavMenu first"><a href="${ucaPATH}/AnnotationAccount.pl?sort=modDate!" target= "_blank" title="My Annotation Account">My Annotations </a></div>
END_OF_PRINT


if ($ENV{'REQUEST_URI'} =~ m/annotation.*/) {
  print "<div class=\"NavMenu\"><a class=\"current_xgdb\" title=\"Annotation workflow and video tutorials\" href=\"/XGDB/phplib/annotation.php?GDB=$GDBDIR1\"> Tutorials</a></div>";
} else {
  print "<div class=\"NavMenu\"><a title=\"Annotation workflow and video tutorials\" href=\"/XGDB/phplib/annotation.php?GDB=$GDBDIR1\">Tutorials</a></div>";
}



print <<END_OF_PRINT;
<h2 class="GroupID">Alignment Tools</h2>
END_OF_PRINT

if ($ENV{'REQUEST_URI'} =~ m/blastGDB/) {
  print "<div class=\"NavMenu first\"><a class=\"current_xgdb\" title=\"Run BLAST analysis using ${GDBDIR1} datasets\" href=\"${CGIPATH}blastGDB.pl\">BLAST this GDB</a></div>";
} else {
  print "<div class=\"NavMenu first\"><a title=\"Run BLAST analysis using ${GDBDIR1} datasets\" href=\"${CGIPATH}blastGDB.pl\">BLAST this GDB</a></div>";
}

if ($ENV{'REQUEST_URI'} =~ m/blastAllGDB/) {
  print "<div class=\"NavMenu\"><a class=\"current_xgdb\" title=\"Run BLAST analysis using ALL GDB datasets\" href=\"${CGIPATH}blastAllGDB.pl\">BLAST all GDBs</a></div>";
} else {
  print "<div class=\"NavMenu\"><a title=\"Run BLAST analysis using ALL GDB datasets\" href=\"${CGIPATH}blastAllGDB.pl\">BLAST all GDBs</a></div>";
}
#if ($ENV{'REQUEST_URI'} =~ m/GeneSeqer/) {
#print "<div class=\"NavMenu\"><a class=\"current_xgdb\" title=\"Carry out spliced alignment of transcript to genomic DNA\" href=\"$GSQwebpath\">GeneSeqer</a></div>";
#} else {
#print "<div class=\"NavMenu\"><a title=\"Carry out spliced alignment of transcript to genomic DNA\" href=\"$GSQwebpath\">GeneSeqer</a></div>";
#}
if ($ENV{'REQUEST_URI'} =~ m/GenomeThreader.pl/) {
print  "<div class=\"NavMenu\"><a class=\"current_xgdb\" title=\"Carry out spliced alignment of protein to genomic DNA\" href=\"$GTHwebpath\">GenomeThreader</a></div>";
} else {
print "<div class=\"NavMenu\"><a title=\"Carry out spliced alignment of protein to genomic DNA\" href=\"$GTHwebpath\">GenomeThreader</a></div>";
}

print <<END_OF_PRINT;
<h2 class="GroupID">Resources</h2>
END_OF_PRINT

if ($ENV{'REQUEST_URI'} =~ m/data/) {
  print "<div class=\"NavMenu\"><a class=\"current_xgdb\" title=\"View data sources and methods used to build this genome database\" href=\"/XGDB/phplib/resource.php?GDB=$GDBDIR1&amp;type=data\">Data Sources</a></div>";
} else {
  print "<div class=\"NavMenu\"><a title=\"View data sources and methods used to build this genome database\" href=\"/XGDB/phplib/resource.php?GDB=$GDBDIR1&amp;type=data\">Data Sources</a></div>";
}


if ($ENV{'REQUEST_URI'} =~ m/download.php/) {
  print "<div class=\"NavMenu\"><a class=\"current_xgdb\" title=\"Download output files for this genome database\" href=\"/XGDB/phplib/download.php?GDB=$GDBDIR1&amp;dir=download\">Data Download</a></div>";
} else {
  print "<div class=\"NavMenu\"><a title=\"Download input files for this genome database\" href=\"/XGDB/phplib/download.php?GDB=$GDBDIR1&amp;dir=download\">Data Download</a></div>";
}

if ($ENV{'REQUEST_URI'} =~ m/Pipeline_procedure/) {
  print  "<div class=\"NavMenu\"><a class=\"current_xgdb\" title=\"View logfile used to build this genome database\" href=\"/XGDB/phplib/resource.php?GDB=$GDBDIR1&amp;type=Pipeline_procedure\">Pipeline Logs</a></div>";
} else {
  print "<div class=\"NavMenu\"><a title=\"View logfile used to build this genome database\" href=\"/XGDB/phplib/resource.php?GDB=$GDBDIR1&amp;type=Pipeline_procedure\">Pipeline Logs</a></div>";
}

  print "<div class=\"NavMenu\"><a  title=\"View Configuration Data (admin only)\" href=\"/XGDB/conf/view.php?id=$GDBDIR1\">Configuration...</a></div>";


print <<END_OF_PRINT;
<h2 class="GroupID">Help</h2>
<div class="NavMenu first"><a  title="All Help resources" href="/XGDB/help/index.php"><span class=" help_style">All Help Resources</span></a></div>
<div class="NavMenu"><a title="Searching and analyzing GBD data" href="/XGDB/help/genome_browser.php"><span class=" help_style" >Genome Browser</span></a></div>
<div class="NavMenu"><a title="List of community-annotated genes" href="/XGDB/help/community_central.php"><span class="help_style" >Community Central</span></a></div>
<div class="NavMenu"><a title="Feature Tracks help" href="/XGDB/help/feature_tracks.php"><span class="help_style" >Feature Tracks</span></a></div>
<div class="NavMenu"><a title="Overview of CpGAT tool for gene annotation" href="/XGDB/help/cpgat.php"><span class=" help_style" >Using CpGAT</span></a></div>
<div class="NavMenu"><a title="Overview of GAEVAL evaluation system for gene congruence with data" href="/XGDB/help/gaeval.php"><span class=" help_style" >Using GAEVAL</span></a></div>
<div class="NavMenu"><a title="Wiki documentation for xGDBvm" href="http://goblinx.soic.indiana.edu/wiki/doku.php/"><span class=" help_style">Wiki</span></a></div>
<div class="NavMenu"><a title="Help for yrGATE community annotation tool" href="/XGDB/help/yrgate.php"><span class="help_style" >yrGATE</span></a></div>

END_OF_PRINT


print <<END_OF_PRINT;
<br />
<br />
</div>
END_OF_PRINT




	return 1;
}

sub print_RightSidebar{
  my ($self) = @_;

  do 'xgdbSidebarRIGHT.pl'; ## define @sidebarNoteworthy

  my @links = (); my $linkAR = '';
  foreach $linkAR (@sidebarNoteworthy){
    push(@links,a($linkAR->[0],$linkAR->[1]));
  }
#  my $noteworthy_list = ul({-class=>'LinkList'},li({-class=>'LinkList'},\@links)); # Removed ul: -type=>'none', (property doesn't exist)

  print <<END_OF_PRINT;
<div id="RightSidebar">
<h2 class="GroupID">${COMMONORGN} Links</h2>
$noteworthy_list
</div>

END_OF_PRINT

  return 1;
}

sub print_SiteFooter{
  print "\n</form> <!--end guiFORM-->\n";
  my ($self) = @_;
  do 'xgdbFOOTER.pl';
  return 1;
}

1;

