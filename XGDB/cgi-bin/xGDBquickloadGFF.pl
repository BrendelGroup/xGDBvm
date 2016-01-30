#!/usr/bin/perl
## Implementation to support dynamic track creation from a GFF file already fond on the server e.g. CpGAT output

use CGI ":all";
use GSQDB;

do 'SITEDEF.pl';
do 'getPARAM.pl';

my $db = new GSQDB($cgi_paramHR);

my $content = "";

my $GFFfile = param('preloadedGFF');
my %scaffXref = ();

if ( $projID = param('GFFselect') ) {
	### Load optional scaffold crossref If not loaded - directly uses GFF scaffold IDs
	if( my $scaffIDs = param('xrefs')) {
		$scaffIDs =~ s/::$//;
		foreach my $scaff ( split( '::', $scaffIDs ) ) {
			$scname = $scaff;
			$scname =~ s/^xref-//;
			$scaffXref{$scname} = param($scaff);
		}
	}
	### Process local GFF file to selected project
	if ( $projID eq 'NEWPROJECT' ) {
		if ( param('GFFproject') eq '' ) {
			$projID = 0;
		} else {
			$projID = $db->createProject( $cgi_paramHR, param('GFFproject') );
		}
	}
	### Time to Load the GFF
	eval "require DSO::GFFann";
	$db->connectToProjectDB($cgi_paramHR) if ( !exists( $db->{pDBH} ) );
	my $pDSO = GFFann->new( dbh => $db->{pDBH} );
	$pDSO->loadGFF3(
		{
			GFFfile  => "$GFFfile",
			pid      => $projID,
			gsegXref => \%scaffXref
		}
	);

	if ( param('GFFselect') eq 'NEWPROJECT' ) {
		my $trackHR = {
			DSOname     => "GFFann",
			pid         => $projID,
			chrVIEWABLE => 1,
			BACVIEWABLE => 1,
		};

		$db->updateSessionTracks($cgi_paramHR, $trackHR);
	}

	$content = <<END;
<script type="text/javascript">
	document.guiFORM.submit();
</script>
END

} else {
	### Provide project selection form
	my $prjSelection = $db->getProjectSelectMenu($cgi_paramHR);
	my $scaffHTML = "";
	if( my $scaffIDs = param('xrefs')) {
		$scaffIDs =~ s/::$//;
		$scaffHTML = "<input type='hidden' id='xrefs' name = 'xrefs' class='ajaxParam' value='$scaffIDs'>\n";
		foreach my $scaff ( split( '::', $scaffIDs ) ) {
			$scaffHTML .= "<input type='hidden' id='$scaff' name = '$scaff' class='ajaxParam' value='" . param($scaff) . "'>\n";
		}
	}
	
	$content = <<GFF_DIV;
<script type="text/javascript">
 \$(function () {
	\$(":button:contains('Add Track')").removeAttr("disabled").removeClass('ui-state-disabled');
 });
</script>
$scaffHTML
<input type="hidden" id="preloadedGFF" name="preloadedGFF" class="ajaxParam" value="${GFFfile}" />
<p style='margin:0px; color:green; text-align:left;'>Select or create a project with which to associate these annotations.</p>
$prjSelection
<input type="text" name="GFFproject" id="GFFproject" size=30 class="ajaxParam" />
<p style='margin:0px; font-size:8pt;'>This project name will be used to identify the display track for your annotations</p><br>

GFF_DIV
	
}

print header() . $content;
