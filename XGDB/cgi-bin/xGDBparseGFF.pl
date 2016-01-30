#!/usr/bin/perl
use CGI ":all";
use CGI::Session;
use DBI;
use LWP::UserAgent;
use XML::Simple;

do 'SITEDEF.pl';
do 'getPARAM.pl';

my $file;

print header() . start_html();

if ( $file = param('GFFfile') ) {
	$DASactive = 0;
	$GFFactive = 1;

	my $tmpfilename = "${$}-uploaded.gff";

	open(TMPfile, ">${TMPDIR}$tmpfilename");
	while (<$file>) {

		print TMPfile $_;
		if ( ( !/^\#/ ) && ( !/^\s/ ) ) {
			/^(\S+)/;
			$scaffolds{$1} = 1;
		}
	}

	close(TMPfile);

#### Retrieve Projects from Primary DB
	my $projectHOST =
	  ( exists( $DBver[ $cgi_paramHR->{dbid} ]->{PROJECThost} ) )
	  ? $DBver[ $cgi_paramHR->{dbid} ]->{PROJECThost}
	  : ( exists( $DBver[ $cgi_paramHR->{dbid} ]->{DBhost} ) )
	  ? $DBver[ $cgi_paramHR->{dbid} ]->{DBhost}
	  : $DB_HOST;
	my $projectUSER =
	  ( exists( $DBver[ $cgi_paramHR->{dbid} ]->{PROJECTuser} ) )
	  ? $DBver[ $cgi_paramHR->{dbid} ]->{PROJECTuser}
	  : ( exists( $DBver[ $cgi_paramHR->{dbid} ]->{DBuser} ) )
	  ? $DBver[ $cgi_paramHR->{dbid} ]->{DBuser}
	  : $DB_USER;
	my $projectPASS =
	  ( exists( $DBver[ $cgi_paramHR->{dbid} ]->{PROJECTpass} ) )
	  ? $DBver[ $cgi_paramHR->{dbid} ]->{PROJECTpass}
	  : ( exists( $DBver[ $cgi_paramHR->{dbid} ]->{DBpass} ) )
	  ? $DBver[ $cgi_paramHR->{dbid} ]->{DBpass}
	  : $DB_PASSWORD;
	my $projectDB =
	  ( exists( $DBver[ $cgi_paramHR->{dbid} ]->{PROJECTdb} ) )
	  ? $DBver[ $cgi_paramHR->{dbid} ]->{PROJECTdb}
	  : $DBver[ $cgi_paramHR->{dbid} ]->{DB};
	my $pDBH = DBI->connect( "DBI:mysql:${projectDB}:${projectHOST}",
		$projectUSER, $projectPASS, { RaiseError => 1 } );
	$pDBH->{FetchHashKeyName} = 'NAME_lc';
	my $sth = $pDBH->prepare(
"select * from sessionprojects where sessid = '$cgi_paramHR->{USERsession}'"
	);
	$sth->execute();
	my $projectHR = $sth->fetchall_hashref('pname');
	$sth->finish();

### List user projects
	$prjSelection =
"<select id='GFFselect' name='GFFselect' class='ajaxParam' onChange='toggleProjEntry(this.value);'>\n<option value='NEWPROJECT' selected='selected'>Create a new Project</option>\n";
	foreach $proj ( sort { $a cmp $b } keys %$projectHR ) {
		$prjSelection .=
		  "<option value='$projectHR->{$proj}->{pid}'>$proj</option>\n";
	}
	$prjSelection .= "</select>\n";

#### Retrieve xGDB segments from Primary DB
	my $scaffoldAR = $pDBH->selectcol_arrayref(
		"select distinct(xID) from segments Order By xID ASC");
	my $scaffOpt =
"<option value='NoSelect'>Please select a ${SITENAMEshort} segment</option>\n";
	foreach $scaff (@$scaffoldAR) {
		$scaffOpt .= "<option value='$scaff'>$scaff</option>\n";
	}

### List / Verify genomic segments
	foreach $scaff ( keys %scaffolds ) {
		$scaffIDs .= "xref-${scaff}::";
		$segVerify .=
"$scaff =>  <select id='xref-${scaff}' name='xref-${scaff}' class='ajaxParam' >\n${scaffOpt}</select><br>\n";
	}

	print <<GFF_DIV;
<script type="text/javascript">
 \$(function () {
	\$(":button:contains('Add Track')").removeAttr("disabled").removeClass('ui-state-disabled');
 });
</script>
<input type="hidden" id="xrefs" name="xrefs" class="ajaxParam" value="${scaffIDs}" />
<input type="hidden" id="uploadedGFF" name="uploadedGFF" class="ajaxParam" value="${tmpfilename}" />
<p style='margin:0px; color:green; text-align:left;'>Select or create a project with which to associate these annotations.</p> 
$prjSelection
<input type="text" name="GFFproject" id="GFFproject" size=30 class="ajaxParam" />
<p style='margin:0px; font-size:8pt;'>This project name will be used to identify the display track for your annotations</p><br>
<p style='margin:0px; color:green; text-align:left;'>Please verify that the following GFF scaffold assignments are correct.</p> 
<p>GFF Scaffold => $SITENAMEshort segment<\p>
$segVerify

GFF_DIV

} else {
	print <<DEFAULT_GFF_DIV;
<label for="GFFfile">Please selected a GFF file to upload: (Max size = 500 KB)</label><br>
<input id="GFFfile" name="GFFfile" type="file" size=45 class="ajaxParam ui-widget-content ui-corner-all" />
<img id="GFFloading" src="${IMAGEDIR}loading.gif" style="display:none;" />
<input type="hidden" name="MAX_FILE_SIZE" value="500000" /><br>
<input type="hidden" id="activeTab" name="activeTab" value="$activeTab" />
<button id='GFFload' class='ajaxSubmit ajaxUpload ui-button ui-state-default ui-corner-all'>Upload this File</button>

DEFAULT_GFF_DIV

}

print end_html();

