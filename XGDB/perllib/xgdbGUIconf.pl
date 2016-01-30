# Modifying this menu? Sync it with other menus -->
# See also XGDB/perllib/xgdbFOOTER.pl
$dbpass='';
open FILE, "/xGDBvm/admin/dbpass";
while ($line=<FILE>){
$dbpass= $line;
}

my $DB_HOST = 'localhost';
my $dsn = "DBI:mysql:Genomes:$DB_HOST";
my $user = 'gdbuser';
my $pass = $dbpass;
my %attr = (PrintError => 0, RaiseError => 0);
my $dbh = DBI->connect($dsn,$user,$pass,\%attr) or die $DBI::errstr;
my $sth;
my $query = "select ID,DBname,Organism from xGDB_Log where Status='Current' order by ID";
$sth = $dbh->prepare($query);
$sth = $dbh->prepare($query) or die "Couldn't prepare statement: " . $dbh->errstr;
@xGDB;
%xGDBID;
    $sth->execute() or die "Couldn't execute statement: " . $sth->errstr;
while ($array_ref = $sth -> fetchrow_arrayref()){
                ($ID,$xGDB,$xOrg)=@$array_ref;
		$ID="GDB00".$ID if ($ID<10);
		$ID="GDB0".$ID if ($ID<100 and $ID>10);
		$ID="GDB".$ID if ($ID>100 and $ID<1000);
		$xGDBID{$xGDB}=$ID;
		push(@xGDB,$xGDBID);
#		print STDERR "$xGDB $ID kkkkkkkkkk\n";
	
}
my $sth2;
my $query2 = "select ID,DBname from xGDB_Log order by ID";
$sth2 = $dbh->prepare($query2);
$sth2 = $dbh->prepare($query2) or die "Couldn't prepare statement: " . $dbh->errstr;
@conf;
%conf_id;
    $sth2->execute() or die "Couldn't execute statement: " . $sth2->errstr;

while ($array_ref2 = $sth2 -> fetchrow_arrayref()){
                ($ID,$conf)=@$array_ref2;
		$ID="GDB00".$ID if ($ID<10);
		$ID="GDB0".$ID if ($ID<100 and $ID>10);
		$ID="GDB".$ID if ($ID>100 and $ID<1000);
		$conf_id{$conf}=$ID;
		push(@conf,$conf_id);
#		print STDERR "$conf $ID kkkkkkkkkk\n";
	
}
if ($ENV{'REQUEST_URI'} =~ m/nomenu/) { # Added this to speed up link checking.
  # Don't print menu!
}else{
$PGDBmenu =<<END_OF_PRINT;
 <div id="menuwidth"><!-- Modifying this menu? Sync it with our other menus. See the notes in /phplib/pgdbmenu.inc.php (reference copy). This menu is xgdbGUIconf.pl  -->
	<div id="pgdbmenu">
		<ul class="sf-menu">
			<li><a style="text-align:center" href="/">Home</a></li>
			<li><a style="text-align:center" href="/XGDB/manage/index.php">Manage</a>
				<ul style="width:160px" class="nowrap">
					<li><a title="Getting Started" href="/XGDB/manage/index.php/">-Getting Started- </a></li>
					<li><a title="Administrative pages" href="/admin/index.php/">Admin </a>
						<ul style="width:auto" class="nowrap">
							<li><a href="/admin/index.php">Getting Started</a></li>
							<li><a href="/admin/setup.php">Set Up Passwords</a></li>
							<li><a href="/admin/sitename.php">Set Up Site Name</a></li>
							<li><a href="/admin/email.php">Set Up Admin Email</a></li>
							<li><a href="/admin/users.php">Manage Users</a></li>
							<li><a href="/admin/groups.php">Manage User Groups</a></li>
							<li><a href="/XGDB/help/admin_gdb.php">&nbsp;&nbsp;Admin Help</a></li>
						</ul>	
					</li>
					<li><a title="Create / Manage" href="/XGDB/conf/index.php/">Configure/Create</a>
						<ul  style="width:15em" class="nowrap">
							<li><a href="/XGDB/conf/index.php">-Getting Started-</a></li>
							<li><a href="/XGDB/conf/instructions.php">Stepwise Instructions</a></li>
							<li><a href="/XGDB/conf/volumes.php">Data Volumes</a></li>
							<li><a href="/XGDB/conf/licenses.php">License Keys</a></li>
							<li><a href="/XGDB/conf/sources.php">Data Sources</a></li>
							<li><a href="/XGDB/conf/data.php">Data Requirements</a></li>
							<li><a href="/XGDB/conf/annotate.php">Annotation Guide</a></li>
							<li><a href="/XGDB/conf/new.php">Configure New GDB</a></li>
							<li><a href="/XGDB/conf/viewall.php">List All Configured</a></li>						
							<li><a href="/XGDB/conf/archive.php">Archive/Restore</a></li>						
END_OF_PRINT
foreach $key  ( sort { $conf_id{$a} cmp $conf_id{$b} } keys %conf_id ){ # Sort values - See http://www.linuxquestions.org/questions/programming-9/having-difficulty-sorting-hash-alphabetically-by-value-in-perl-693015/

		$PGDBmenu .= "
					<li style=\"background-color:#41BEE1; width:30em;\" title= \" $key\" class=\"overview nowrap\"><a href=\"/XGDB/conf/view.php?id=$conf_id{$key}\">Config: $conf_id{$key} $key</a></li> ";
	}
	$PGDBmenu .=<<END_OF_PRINT;
						</ul>
					</li>
					<li><a title="Remote Jobs pages" href="/XGDB/jobs/index.php/">Remote Jobs</a>
						 <ul style="width:15em" class="nowrap">
							<li><a href="/XGDB/jobs/index.php">-Getting Started-</a></li>
							<li><a href="/XGDB/jobs/instructions.php">Stepwise Instructions</a></li>
							<li><a href="/XGDB/jobs/resources.php">Estimate Resources</a></li>
							<li><a href="/XGDB/jobs/configure.php">Configure API</a></li>
							<li><a href="/XGDB/jobs/apps.php">Configure Apps</a></li>
							<li><a href="/XGDB/jobs/login.php">Configure for HPC</a></li>
							<li><a href="/XGDB/jobs/submit.php">Submit Standalone Job</a></li>
							<li><a href="/XGDB/jobs/submit_pipeline.php">Submit Pipeline Job</a></li>
							<li><a href="/XGDB/jobs/manage.php">Manage Jobs</a></li>
							<li><a href="/XGDB/jobs/jobs.php">List All Jobs</a></li>
						</ul>
					</li>
				</ul>
			</li>
			<li><a class="current nowrap" style="text-align:center" href="/XGDB/">View</a>
				<ul class="nowrap">
					<li style="width:30em; overflow:hidden"><a title="View- Getting Started" href="/XGDB/index.php">-Getting Started-</a></li>
					<li style="width:30em; overflow:hidden"><a title="List of current genomes" href="/XGDB/genomes.php">-Current Genomes-</a></li>
				
END_OF_PRINT
foreach $key  ( sort { $xGDBID{$a} cmp $xGDBID{$b} } keys %xGDBID ){ # Sort values - See http://www.linuxquestions.org/questions/programming-9/having-difficulty-sorting-hash-alphabetically-by-value-in-perl-693015/

		$PGDBmenu .= "
					<li style=\"width:30em; background-color:#41BEE1; overflow:hidden\"  title= \" $key\" class=\"overview nowrap\"><a href=\"/$xGDBID{$key}/\">$xGDBID{$key} &nbsp;&nbsp; $key</a></li> ";
	}
	$PGDBmenu .=<<END_OF_PRINT;
				</ul>
			</li>
			<li><a style=\"text-align:center\" href=\"/src/yrGATE/\">Annotate</a>
				<ul class="nowrap">
				<li style=\"width:18em;\"><a href=\"/src/yrGATE/\">- Getting Started -</a></li>
				<li style=\"width:18em;\"><a href=\"/src/yrGATE/overview.php\">yrGATE Overview </a></li>
END_OF_PRINT
foreach $key  ( sort { $xGDBID{$a} cmp $xGDBID{$b} } keys %xGDBID ){ # Sort values - See http://www.linuxquestions.org/questions/programming-9/having-difficulty-sorting-hash-alphabetically-by-value-in-perl-693015/

		$PGDBmenu .= "
					<li style=\"width:30em; background-color:#41BEE1; overflow:hidden\"  title= \" $key\" class=\"overview nowrap\"><a href=\"/yrGATE/$xGDBID{$key}/CommunityCentral.pl\">Annotate: $xGDBID{$key} &nbsp; $key</a></li> ";
	}
	$PGDBmenu .=<<END;
				</ul>
			</li>
			<li><a style="text-align:center" href="/XGDB/help/index.php">Help</a>
						<ul style="width:12em"  class="nowrap">
							<li><a title="View All Help Resources" href="/XGDB/help/index.php">- All Help Resources -</a></li>
							<li><a title="Video tutorials" href="/XGDB/help/video_tutorials.php">- Video Tutorials -</a></li>
							<li><a title="Help for Admin pages" href="/XGDB/help/admin_gdb.php">Administration</a></li>
							<li><a title="Locus tables displaying annotated loci (pre-computed or CpGAT-derived)" href="/XGDB/help/anno_tables.php/">Annotation Tables</a></li>
							<li><a title="List of community-annotated genes" href="/XGDB/help/community_central.php/">Community Central</a></li>
							<li><a title="Help for how to create genome browser" href="/XGDB/help/create_gdb.php">Configure/Create</a></li>
							<li><a title="CpGAT Annotation Pipeline" href="/XGDB/help/cpgat.php">CpGAT</a></li>
							<li><a title="Help with Genome Track tables" href="/XGDB/help/feature_tracks.php">Feature Tracks</a></li>
							<li><a title="Overview of data requirements for xGDBvm pipeline" href="/XGDB/conf/data.php">Data Requirements</a></li>
							<li><a title="Overview of GDB Feature Tracks tables" href="/XGDB/help/feature_tracks.php">Feature Tracks</a></li>
							<li><a title="Viewing, searching, analyzing GBD data" href="/XGDB/help/genome_browser.php">Genome Browsers</a></li>
							<li><a title="Overview of GAEVAL evaluation system for gene congruence with data" href="/XGDB/help/gaeval.php/">GAEVAL</a></li>
							<li><a title="Tabular view of data inputs and outputs for xGDBvm pipeline" href="/XGDB/conf/input_output.php">Inputs/Outputs</a></li>
							<li><a title="Help for how to create genome browser" href="/XGDB/help/remote_jobs.php">Remote Jobs</a></li>
							<li><a title="Overview of xGDBvm features" href="/XGDB/help/xgdbvm_overview.php">xGDBvm Overview</a></li>
							<li><a title="Help for yrGATE community annotation tool" href="/XGDB/help/yrgate.php/">yrGATE</a></li>
							<li><a title="Wiki documentation for xGDBvm" href="http://goblinx.soic.indiana.edu/wiki/doku.php">xGDBvm Wiki</a></li>
						</ul>
			</li>
		</ul>
	</div>
</div><!-- end of menuwidth div -->
END
}