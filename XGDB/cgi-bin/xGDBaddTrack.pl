#!/usr/bin/perl
use CGI ":all";
use CGI::Session;
use DBI;
use LWP::UserAgent;
use XML::Simple;

do 'SITEDEF.pl';
do 'getPARAM.pl';

my $DASactive  = 0;
my $GFFactive  = 1;
my $GFFcontent = "";
my $content    = "";

if ( $GFFfile = param('uploadedGFF') ) {
	$DASactive = 0;
	$GFFactive = 1;

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

	if ( param('GFFselect') eq 'NEWPROJECT' ) {
		if ( param('GFFproject') eq '' ) {
			$projID = 0;
		} else {
			$projID = createProject( $pDBH, param('GFFproject') );
		}
	} else {
		$projID = param('GFFselect');
	}

	my $scaffIDs = param('xrefs');
	$scaffIDs =~ s/::$//;
	my $scaffsValid = 1;
	foreach $scaff ( split( '::', $scaffIDs ) ) {
		if ( param($scaff) eq 'NoSelect' ) {
			$scaffsValid = 0;
		} else {
			$scname = $scaff;
			$scname =~ s/^xref-//;
			$scaffXref{$scname} = param($scaff);
		}
	}

	if ( !$scaffsValid || !$projID ) {
		## invalid input fields -- requery user
		my $pidMSG =
		  ( !$projID )
		  ? "<p style='margin:0px; color:red; text-align:left;'>You must either select an existing project or enter a name for a new project!</p>"
		  : "";
		my $scaffMSG =
		  ( !$scaffsValid )
		  ? "<p style='margin:0px; color:red; text-align:left;'> Each GFF scaffold must be associated with a ${SITENAMEshort} segment!</p>"
		  : "";

		#### Retrieve Projects from Primary DB

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
			  ( $projID == $projectHR->{$proj}->{pid} )
			  ? "<option value='$projectHR->{$proj}->{pid}' selected>$proj</option>\n"
			  : "<option value='$projectHR->{$proj}->{pid}'>$proj</option>\n";
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
		foreach $scaff ( split( '::', $scaffIDs ) ) {
			$scaff =~ s/^xref-//;
			$segVerify .=
"$scaff =>  <select id='xref-${scaff}' name='xref-${scaff}' class='ajaxParam' >\n<option value='NoSelect'>Please select a ${SITENAMEshort} segment</option>\n";
			foreach my $scaffn (@$scaffoldAR) {
				$segVerify .=
				  ( param("xref-${scaff}") eq $scaffn )
				  ? "<option value='$scaffn' selected>$scaffn</option>\n"
				  : "<option value='$scaffn'>$scaffn</option>\n";
			}
			$segVerify .= "</select><br>\n";
		}

		$GFFcontent = <<GFF_DIV;
<script type="text/javascript">
 \$(function () {
	\$(":button:contains('Add Track')").removeAttr("disabled").removeClass('ui-state-disabled');
 });
</script>
<input type="hidden" id="xrefs" name="xrefs" class="ajaxParam" value="${scaffIDs}" />
<input type="hidden" id="uploadedGFF" name="uploadedGFF" class="ajaxParam" value="${GFFfile}" />
<p style='margin:0px; color:green; text-align:left;'>Select or create a project with which to associate these annotations.</p>
$pidMSG 
$prjSelection
<input type="text" name="GFFproject" id="GFFproject" size=30 class="ajaxParam" />
<p style='margin:0px; font-size:8pt;'>This project name will be used to identify the display track for your annotations</p><br>
<p style='margin:0px; color:green; text-align:left;'>Please verify that the following GFF scaffold assignments are correct.</p> 
$scaffMSG
<p>GFF Scaffold => $SITENAMEshort segment<\p>
$segVerify

GFF_DIV

	} else {
		### Valid Input -- Time to Load the GFF
		eval "require DSO::GFFann";
		my $pDSO = GFFann->new( dbh => $pDBH );
		$pDSO->loadGFF3(
			{
				GFFfile  => "${TMPDIR}$GFFfile",
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

			updateSessionTracks($trackHR);
		}

		$GFFcontent = <<END;
<script type="text/javascript">
	document.guiFORM.submit();
</script>
END

	}

} elsif ( param('addTrack') ) {
	$DASactive = 1;
	$GFFactive = 0;

	my $trackHR = {
		DSOname         => param('DSOname'),
		trackname       => param('DAS_trackname'),
		DASservice      => param('DAS_host'),
		DASdsn          => param('DAS_dsn'),
		forceGroupLabel => 1,
		primaryColor    => "green",
		chrVIEWABLE     => 1,
		BACVIEWABLE     => 1,
	};

	updateSessionTracks($trackHR);

	$content = <<END;
<script type="text/javascript">
	document.guiFORM.submit();
</script>
END

} elsif ( param('DAS_dsn') ) {
	my $dasURL = param('DAS_host');
	my $dasDSN = param('DAS_dsn');

	$DASactive = 1;
	$GFFactive = 0;

	$content = <<END;
<script type="text/javascript">
 \$(function () {
	\$(":button:contains('Add Track')").removeAttr("disabled").removeClass('ui-state-disabled');
 });
</script>
<input type="hidden" name="addTrack" id="addTrack" class="ajaxParam" value='DAS' />
<input type="hidden" name="DSOname" id="DSOname" class="ajaxParam" value='DAS' />
<input type="hidden" name="DAS_dsn" id="DAS_dsn" class="ajaxParam" value='$dasDSN' />
<input type="hidden" name="DAS_host" id="DAS_host" class="ajaxParam" value="$dasURL" />
<p style='text-align:left;'>DAS Service:<br>$dasURL</p>
<p style='text-align:left;'>DAS Data Source Name (dsn):<br>$dasDSN</p>
<p style='width:90%; color:red; text-align:center;'>Please enter a track name</p>
<label for="DAS_trackname">Track name:</label><BR>
<input type="text" name="DAS_trackname" id="DAS_trackname" size=45 class="ajaxParam text ui-widget-content ui-corner-all" value="$dasDSN" />
END

} elsif ( param('DAS_host') ) {
	my $DASurl = param('DAS_host');
	my $ua     = LWP::UserAgent->new();
	my $xp     = XML::Simple->new();

	$DASactive = 0;
	$GFFactive = 1;

	$DASurl = "http://$DASurl" if ( $DASurl !~ /^http/ );
	$DASurl .= '/' if ( $DASurl !~ /\/$/ );
	my $response = $ua->get("${DASurl}dsn");
	my $goodDSN  = 1;
	if ( $response->content() !~ /<DASDSN/ ) {
		$goodDSN = 0;
		if ( $DASurl !~ /das\/$/ ) {
			if ( $DASurl =~ /^(.*das\/)/ ) {
				my $tmpDASurl = $1;
				$response = $ua->get("${tmpDASurl}dsn");
				if ( $response->content() =~ /<DASDSN/ ) {
					$DASurl  = $tmpDASurl;
					$goodDSN = 1;
				}
			} else {
				$response = $ua->get("${DASurl}das/dsn");
				if ( $response->content() =~ /<DASDSN/ ) {
					$DASurl .= 'das/';
					$goodDSN = 1;
				} else {
					$response = $ua->get("${DASurl}cgi-bin/das/dsn");
					if ( $response->content() =~ /<DASDSN/ ) {
						$DASurl .= 'cgi-bin/das/';
						$goodDSN = 1;
					}
				}
			}
		}
	}
	if ( !$goodDSN ) {
		$errorMSG =
"DAS services were NOT available at<br><a href='${DASurl}dsn' target='_blank'>$DASurl</a><br>Please enter a valid DAS service URL.";
		$content = getDASURL($errorMSG);
	} else {
		$dasdsnHR = $xp->XMLin(
			$response->content(),
			KeyAttr    => [],
			ForceArray => ['DSN']
		);
		my $dsnLabel;
		foreach my $dsnHR ( @{ $dasdsnHR->{'DSN'} } ) {
			$dsnLabel =
			  ( exists( $dsnHR->{'SOURCE'}->{'content'} ) )
			  ? $dsnHR->{'SOURCE'}->{'content'}
			  : $dsnHR->{'SOURCE'}->{'id'};
			$dsnLIST->{$dsnLabel} = $dsnHR->{'SOURCE'}->{'id'};
		}
		$content = getDASDSN( $DASurl, $dsnLIST );
	}

} else {
	$content = getDASURL();
}

my $sesUID      = $$;
my $activeTab   = ( $DASactive == 1 ) ? "DAS" : "GFF";
my $DASselected = ( $DASactive == 1 ) ? "ui-selected" : "";
my $DASdisplay  = ( $DASactive == 1 ) ? "" : "hidden";
my $GFFselected = ( $GFFactive == 1 ) ? "ui-selected" : "";
my $GFFdisplay  = ( $GFFactive == 1 ) ? "" : "hidden";

if ( $GFFcontent eq "" ) {
	$GFFcontent = <<DEFAULT_GFF_DIV;
<label for="GFFfile">Please select a GFF3 file to upload: (Max size = 500 KB)</label><br />
<input id="GFFfile" name="GFFfile" type="file" size=45 class="ajaxParam ui-widget-content ui-corner-all" />
<img id="GFFloading" src="${IMAGEDIR}loading.gif" style="display:none;" />
<input type="hidden" name="MAX_FILE_SIZE" value="500000" /><br>
<input type="hidden" id="activeTab" name="activeTab" value="$activeTab" />
<button id='GFFload' class='ajaxSubmit ajaxUpload ui-button ui-state-default ui-corner-all'>Upload this File</button>

DEFAULT_GFF_DIV
}

print header();
print <<END_OF_PRINT;
<ul class='sf-menu'>
  <li id="DAStab" class="CTR_ctrl tabOption ui-selectable ui-corner-top $DASselected">DAS</li>
  <li id="GFFtab" class="bold CTR_ctrl tabOption ui-selectable ui-corner-top $GFFselected">GFF</li>
</ul>
<div id="DASdialog" class="$DASdisplay" style="clear:left; border:2px solid #FCCF6F; height:86%; text-align:left; padding:15px;">
$content
</div>
<div id="GFFdialog" class="$GFFdisplay" style="clear:left; background-color: #FCCF6F; height:86%; text-align:left; padding:15px;">
$GFFcontent
</div>
<script type="text/javascript">
 \$(function () {
        \$('#DAStab').click(function(){\$('#activeTab').val('DAS'); \$('#GFFdialog').toggleClass('hidden'); \$('#DASdialog').toggleClass('hidden');});
        \$('#GFFtab').click(function(){\$('#activeTab').val('GFF'); \$('#DASdialog').toggleClass('hidden'); \$('#GFFdialog').toggleClass('hidden');});
        \$('.ajaxSubmit').mouseenter(function(){
                if(! \$(this).hasClass('ui-state-disabled')){
                        \$(this).toggleClass('ui-state-hover');
                }
        }).mouseleave(function(){
                if(! \$(this).hasClass('ui-state-disabled')){
                        \$(this).toggleClass('ui-state-hover');
                }
        });
 });

</script>

END_OF_PRINT

sub updateSessionTracks {
	my ($newTrackHR) = @_;
	my $cgiSID =
	     $cgi_paramHR->{'USERsession'}
	  || CGI::cookie($CookieNAME)
	  || CGI::param($CookieNAME)
	  || undef;
	my $sessionHOST =
	  ( exists( $DBver[ $cgi_paramHR->{dbid} ]->{SESSIONhost} ) )
	  ? $DBver[ $cgi_paramHR->{dbid} ]->{SESSIONhost}
	  : ( exists( $DBver[ $cgi_paramHR->{dbid} ]->{DBhost} ) )
	  ? $DBver[ $cgi_paramHR->{dbid} ]->{DBhost}
	  : $DB_HOST;
	my $sessionUSER =
	  ( exists( $DBver[ $cgi_paramHR->{dbid} ]->{SESSIONuser} ) )
	  ? $DBver[ $cgi_paramHR->{dbid} ]->{SESSIONuser}
	  : ( exists( $DBver[ $cgi_paramHR->{dbid} ]->{DBuser} ) )
	  ? $DBver[ $cgi_paramHR->{dbid} ]->{DBuser}
	  : $DB_USER;
	my $sessionPASS =
	  ( exists( $DBver[ $cgi_paramHR->{dbid} ]->{SESSIONpass} ) )
	  ? $DBver[ $cgi_paramHR->{dbid} ]->{SESSIONpass}
	  : ( exists( $DBver[ $cgi_paramHR->{dbid} ]->{DBpass} ) )
	  ? $DBver[ $cgi_paramHR->{dbid} ]->{DBpass}
	  : $DB_PASSWORD;
	my $sessionDB =
	  ( exists( $DBver[ $cgi_paramHR->{dbid} ]->{SESSIONdb} ) )
	  ? $DBver[ $cgi_paramHR->{dbid} ]->{SESSIONdb}
	  : $DBver[ $cgi_paramHR->{dbid} ]->{DB};
	my $sDBH = DBI->connect( "DBI:mysql:${sessionDB}:${sessionHOST}",
		$sessionUSER, $sessionPASS, { RaiseError => 1 } );
	my $session =
	  new CGI::Session( "dr:MySQL;id:xgdb_md5", $cgiSID, { Handle => $sDBH } );

	if ( exists( $cgi_paramHR->{frozen_user_tracks} ) ) {
		eval( $cgi_paramHR->{frozen_user_tracks} );
	} else {
		$user_tracks = [];
	}
	unshift( @$user_tracks, $newTrackHR );

	## Validate trackORDER/VISIBILE
	my @tmpORD = split( ',', $cgi_paramHR->{trackORDER} );
	my @tmpVIS = split( ',', $cgi_paramHR->{trackVISIBLE} );
	my @preORD = split( ',', $DBver[ $cgi_paramHR->{dbid} ]->{trackORD} );
	my $ctcnt  = scalar(@tmpORD);
	my $ptcnt  = scalar(@preORD);
	my $dtcnt   = scalar(@$user_tracks);
	my $dtresid = $ptcnt;
	my @newORD  = ( $tmpORD[0], $dtresid );
	for ( my $idx = 1 ; $idx < $ctcnt ; $idx++ ) {
		$tmpORD[$idx] += 1 if ( $tmpORD[$idx] >= $dtresid );
		push( @newORD, $tmpORD[$idx] );
	}
	for ( my $idx = ( $ptcnt + $dtcnt - 1 ) ;
		$idx >= ( $dtresid + 1 ) ; $idx-- )
	{
		$tmpVIS[$idx] = $tmp[ $idx - 1 ];
	}
	$tmpVIS[$dtresid] = '1';
	$cgi_paramHR->{trackORDER}   = join( ',', @newORD );
	$cgi_paramHR->{trackVISIBLE} = join( ',', @tmpVIS );
	##

	#### UPDATE SESSION STATE STORE #### (Data::Dumper inherited from getParam.pl)
	$cgi_paramHR->{frozen_user_tracks} =
	  Data::Dumper->Dump( [$user_tracks], ["user_tracks"] );
	$session->param( "cgi_paramHR", $cgi_paramHR );

}

sub getDASDSN {
	my ( $dasURL, $dsnHR, $MSG ) = @_;

	$MSG =
	  defined($MSG)
	  ? "<p style='width:90%; color:red; text-align:center;'>$MSG</p>"
	  : "<p style='width:90%; color:red; text-align:center;'>Please select a Data Source.</p>";
	my $content = <<END;
<input type="hidden" name="DAS_host" id="DAS_host" class="ajaxParam" value="$dasURL" />
<p style='text-align:left;'>DAS Service: $dasURL</p>
$MSG
<ol style='list-style-type:none; margin:0px 0px 10px 0px; padding:1px; height:35%; overflow:auto; border:2px inset black;'>
END
	foreach my $dn ( sort keys(%$dsnHR) ) {
		$content .= "\t<li class='ui-selectable' id='$dsnHR->{$dn}'>$dn</li>\n";
	}
	$content .= <<END;
</ol>
<button id='DAS_dsn' class='ajaxSubmit ajaxParam ui-button ui-state-default ui-state-disabled ui-corner-all'>Select DSN</button>
<script type="text/javascript">
 \$(function () {
	\$('.ajaxSubmit').mouseenter(function(){
		if(! \$(this).hasClass('ui-state-disabled')){
			\$(this).toggleClass('ui-state-hover');
		}
	}).mouseleave(function(){
		if(! \$(this).hasClass('ui-state-disabled')){
			\$(this).toggleClass('ui-state-hover');
		}
	});
	\$(":button:contains('Add Track')").attr('disabled','disabled').addClass('ui-state-disabled');
 });
</script>
END

	return $content;
}

sub getDASURL {
	my ($MSG) = @_;
	$MSG =
	  defined($MSG)
	  ? "<p style='width:90%; color:red; text-align:center;'>$MSG</p>"
	  : "<p style='width:90%; color:red; text-align:center;'>Please enter a DAS service URL.</p>";
	return <<END;
$MSG
<label for="DAS_host">DAS Server:</label><BR>
<input type="text" name="DAS_host" id="DAS_host" size=45 class="ajaxParam ui-widget-content ui-corner-all" />
<p style='margin:0px; font-size:8pt;'>e.g. ${rootPATH}${CGIPATH}das</p><br>
<button id='validateDASserver' class='ajaxSubmit ui-button ui-state-default ui-corner-all'>Validate Service</button>
<script type="text/javascript">
 \$(function () {
	\$('.ajaxSubmit').mouseenter(function(){
		if(! \$(this).hasClass('ui-state-disabled')){
			\$(this).toggleClass('ui-state-hover');
		}
	}).mouseleave(function(){
		if(! \$(this).hasClass('ui-state-disabled')){
			\$(this).toggleClass('ui-state-hover');
		}
	});
	\$(":button:contains('Add Track')").attr('disabled','disabled').addClass('ui-state-disabled');
 });
</script>
END
}

sub createProject {
	my ( $dbh, $projName ) = @_;
	$dbh->do(
		"INSERT INTO projects (pid,ppass,pname) VALUES (0,'xgdb','$projName')");
	my $pid = $dbh->last_insert_id( undef, undef, 'projects', 'pid' );
	$dbh->do(
"INSERT INTO sessionprojects (pid,sessid,pname) VALUES ($pid,'$cgi_paramHR->{USERsession}','$projName')"
	);
	return $pid;
}
