#!/usr/bin/perl

use strict "vars";
use Data::Dumper;
use vars qw(
$GV
$GVportal
$PRM
@modes
$DBH
$zeroPos
$UCAcgiPATH
$IMAGEDIR
$GENSCAN_speciesModel
);
require 'yrGATE_conf.pl';
require 'yrGATE_functions.pl';

&{$GV->{InitFunction}};

#$PRM->{USERid} = &{$GV->{getUserIdFunction}};
$PRM->{owner}  = param('owner') ? param('owner') : $PRM->{USERid};
$PRM->{owner} =~ s/[^A-Za-z0-9\s-_]//g; # 2/25/15 JPD
$PRM->{gdb} = $GV->{dbTitle};
########################
## Access limits to tool
########################
my ($MSG1,$MSGclass);
if(!$PRM->{USERid} && $GV->{login_required}){
  ## Request user login for annotation creation
 #temp bailOut("You must <a href=\"/yrGATE/$GV->{dbTitle}/login.pl\">log in</a> before using this tool. $GV->{dbTitle}");
  $MSG1 = <<END_OF_MSG;
You are not logged in. You may create an annotation, but you will have to log in before you can save it.
<button type='button' id='toggleLogin'>Log In</button>
<button type='button' id='toggleRegister'>Create Account</button>
<div id='loginDialog' style='display:none;'></div>
<div id='registerDialog' style='display:none;'></div>
END_OF_MSG

  $MSGclass = "warning";
}
# Check to see if user is admin
my $isAdmin = &{$GV->{getUserGroupFunction}}($PRM->{USERid});
# Check to see if user is group admin (could be both)
my $isGroupAdmin = &{$GV->{getWorkingGroupAdminFunction}}($PRM->{USERid});

my $ownedRef = &{$GV->{getAdminOwnershipFunction}};
# if owned and owned by this admin
my $ownedByAnyAdmin = ($$ownedRef{$PRM->{uid}}) ? 1 : 0;
my $ownedByThisAdmin = (($$ownedRef{$PRM->{uid}} eq $PRM->{USERid} )) ? 1 : 0;
my $ownedByThisAdminAnnotator = ($PRM->{USERid} eq $PRM->{owner} ) ? 1 : 0;

if ($PRM->{chr} eq ""){
$PRM->{chr} = "0"; # allow for chr/scaffold =zero
}

if ($PRM->{start} == 0){
    $PRM->{start} = 1; # minimum base position is 1
}

if($PRM->{uid} and ($PRM->{modifyState} != "1") ){
  # do not requery database for UCA, if page is reloaded for evidence range change
    my $loadreturn = &loadUCA();
    if (!$loadreturn){
      bailOut("No Annotation Exists with that ID");
    }
    $PRM->{editedUID} = $PRM->{id};
    if ( (!$isAdmin && !$isGroupAdmin) && ($PRM->{USERid} ne $PRM->{owner})){
      bailOut("You do not own this annotation.");
    }
}

if (($isAdmin || !$isGroupAdmin) && (!$ownedByThisAdmin) && $PRM->{uid} && ($PRM->{owner} ne $PRM->{USERid}) ){
    bailOut("You do not have permission to administrate this annotation at this time. $isAdmin && (!$ownedByThisAdmin) $$ownedRef{$PRM->{uid}}"); # "At this time"? WTF, why don't we explain this to user?
}

if (($PRM->{start} eq "") or ($PRM->{end} eq "") or ($PRM->{chr} eq "")){
    bailOut("Incomplete genome region parameters. segment: chromosome $PRM->{chr} start:  $PRM->{start} end: $PRM->{end}.");
}

#sanitize inputs

$PRM->{start} =~ s/[^0-9]//g; # 2/25/15 JPD
$PRM->{end} =~ s/[^0-9]//g; # 2/25/15 JPD
$PRM->{chr} =~ s/[^A-Za-z0-9\.\-_:]//g; # 2/25/15 JPD updated 10/7/15 JPD

#if (($PRM->{imgWidth} != 400)&&($PRM->{imgWidth} != 800)){
#    bailOut('Invalid Image Size');
#}

if ($$ownedRef{$PRM->{uid}} && ($$ownedRef{$PRM->{uid}} ne $PRM->{USERid}) ){
    bailOut("Annotation $PRM->{geneId} is currently under review and you do not have permission to edit it.");
}

############################
## end Access limits to tool
############################


#####################
## Submission actions
#####################
my ($stat);
my $mode = $PRM->{mode};

  $PRM->{UDEsource} = "$PRM->{Esource}<newline>$PRM->{UDEsource}" ;

  #for save, subtract UDE not in structure (User Defined Exons?)
  if ( ($mode eq "UCAsave") || ($mode eq "UCAsubmit")|| ( $isAdmin and ( ($mode eq "UCAaccept")||($mode eq "UCAreject") ) )){
  my @Elines = split /<newline>/, $PRM->{UDEsource};
  my @newElines;
  for (my $i=0;$i<scalar(@Elines);$i++){
    my ($Ecoord) = $Elines[$i] =~ /^(\d+\s\d+)/;
    $Ecoord =~ s/\s/\.\./;
    if ($PRM->{info} =~ /$Ecoord/ ){
      #$PRM->{UDEsource} =~ s/$Elines[$i]//;
      $newElines[++$#newElines] = $Elines[$i];
    }
  }
  $PRM->{UDEsource} = join("<newline>",@newElines);
  }
  $PRM->{Esource} = $PRM->{UDEsource}; # for field

if ($mode eq 'UCAprint'){
  # Ideal: print header(-type=>'application/xhtml+xml', -charset=>'utf-8', -expires=>'now'); # Have to settle for line below:
  print header(-expires=>'now');
  print "<html><body>
  <pre>";
  print printAnnotation();
  print "</pre></body></html>";
  exit;
}
if ($mode eq 'UCAgff'){
  # Ideal: print header(-type=>'application/xhtml+xml', -charset=>'utf-8', -expires=>'now'); # Have to settle for line below:
  print header(-expires=>'now');
  print "<html><body>
  <pre>";
  print "#gff-version 3\n";
  my ($txt,$tmp) = yrgateToGFF3();
  print $txt;
  print "</pre></body></html>";
  exit;
}

if( (($mode eq "UCAsave") || ($mode eq "UCAsubmit")) && ($PRM->{UCAannid} eq "")){
    $MSG1 = "Annotation ID is required.";
    $MSGclass = 'warning';
    $mode = "";
}

#JD add: require anno class.
if( (($mode eq "UCAsave") || ($mode eq "UCAsubmit")) && ($PRM->{annotation_class} eq "")){
    $MSG1 = "Annotation class is required. Select one from the dropdown below, and then re-submit or save.";
    $MSGclass = 'warning';
    $mode = "";
}
#JD add: require locus_id
if( (($mode eq "UCAsave") || ($mode eq "UCAsubmit")) && ($PRM->{locusId} eq "")){
    $MSG1 = "Locus ID is required, to describe which locus is being annotated. Select an ID from the dropdown below, and then re-submit or save.";
    $MSGclass = 'warning';
    $mode = "";
}

if ( ($mode eq "UCAsave") || ($mode eq "UCAsubmit")|| ( $isAdmin and ( ($mode eq "UCAaccept")||($mode eq "UCAreject") ) ) ){
    if ( ($isAdmin and !$ownedByThisAdmin and $ownedByAnyAdmin) ){
	# if admin has checked out annotation if the annotation is not owned by the admin
	bailOut("Your administration session for this annotation has ended.  <br /> To curate this annotation, please check it out again.");
    }

 # actions are equivalent except for status field
    if ($mode eq 'UCAsave'){
	$stat = "SAVED";
    }elsif($mode eq 'UCAsubmit') {
	$stat = "SUBMITTED_FOR_REVIEW";
    }elsif($mode eq 'UCAaccept') {
	$stat = "ACCEPTED";
    }elsif($mode eq 'UCAreject') {
	$stat = "REJECTED";
    }

  my $updated = 0;


  if($PRM->{uid}){
    #### User wants to change annotation name  DEPRECATED This is no longer up to the user
    ## Check availability of new entry name DEPRECATED This is no longer up to the user

    if( &updateAnnotation($stat) ){
      $updated = 1;
      $PRM->{status} = $stat;
    }else{
      #### annotation ID collision;
      $stat = 'NOT SAVED';
      $MSGclass = 'warning';
      if ($PRM->{UCAannid}){
          $MSG1 = "There was a problem with this structure. Please contact PlantGDB staff."; # Debugging this? Make sure SQL isn't broken. - dhrasmus
      }else{
          $MSG1 = "Annotation ID is required.";
      }
      goto LOAD_FIELDS;	## reload submitted form values
    }

  }elsif($PRM->{info} eq ''){
    #### No structure info was reported
    $stat = 'NOT SAVED';
    $MSG1 = "No structure coordinates were entered. A valid structure is required to save this record!";
    goto LOAD_FIELDS;   ## reload submitted form values

  }elsif( !(&addUserAnnotation($stat)) ){
    # if add is successful,  else is not, name already taken
    $stat = 'NOT SAVED';

    $MSG1 = "There was a problem saving this annotation. Please contact PlantGDB staff."; # Updated 2/24/12 JPD
    $MSGclass = 'warning';
    goto LOAD_FIELDS;	## reload submitted form values
  }

  # successful messages (user is submitting)
    if ($mode eq 'UCAsave'){
	$MSG1 .= "Annotation ID: $PRM->{UCAannid} has been saved for editing at a later time!";
    }elsif($mode eq 'UCAsubmit') {
	$MSG1 .= "Annotation ID: $PRM->{UCAannid} has been submitted for review!";
    }elsif($mode eq 'UCAaccept') {
    
		my $accept_msg=save_accept_msg(); #append Admin message to Description.
		if ($accept_msg){
		$MSG1 .= "Annotation ID: $PRM->{UCAannid} has been accepted. Your comments have been appended to the Description field.";
		}else{
		$MSG1 .= "Annotation ID: $PRM->{UCAannid} has been accepted but we were unable to add Admin message to Description Field.";
		}
    	if (getWorkingGroupAnno($PRM->{USERid})){ ## Anno has working group and Admin has permission
    	extraGroupAdminSubmit(); # email to owner and cc group admin & admin
   		 }else{ #The owner doesn't below to any private groups -- use the default submit.
    	extraAdminSubmit(); # accepted email to owner and cc admin
    	}
    	
    }elsif($mode eq 'UCAreject') {
    	my $sth=""; #debug
		my $reject_msg=save_reject_msg(); #update table column 'comment'.
		if ($reject_msg){
		$MSG1 .= "Annotation ID: $PRM->{UCAannid} has been rejected and your comments have been added to the comment field.";
		}else{
		$MSG1 .= "Annotation ID: $PRM->{UCAannid} has been rejected but we were unable to add Admin message to comment field - sth=$sth.";
		}


    	if (getWorkingGroupAnno($PRM->{USERid})){ ## Anno has working group and Admin has permission
    	extraGroupAdminSubmit(); # rejection email to owner and cc group admin & admin
   		 }else{ #The user doesn't belong to any private groups
    	extraAdminSubmit(); # rejection email to owner and cc admin
    	}
    
    }

  if (($PRM->{editedUID} ne $PRM->{id}) and $PRM->{editedUID} ne ""){
      $MSG1 .= "<br />Locus $PRM->{editedUID} renamed.";
  }
  if ($mode eq 'UCAsubmit') {
      $MSG1 .= "<br /><br /> Close this window to end this annotation session."; #don't invite them to make any changes. JD
      $MSGclass= 'success';
    }else {
      $MSG1 .= "<br /><br /> Close this window to end this annotation session or continue to make changes and save again.";
      $MSGclass= 'success';
	}
    $PRM->{status} = $stat;
}elsif($mode eq "UCAdelete"){
  $MSG1 .= "Annotation ID: $PRM->{UCAannid} deleted";
  $MSGclass = 'success';
  if($PRM->{uid}){
    &removeAnnotation();
  }else{
    $PRM->{editedUID} = $PRM->{UCAannid};
  }
  my $PAGE_CONTENTS = "<span class='annoToolPage'><span class='bold' style='font-size:24px'>yrGATE:<br />&nbsp; &nbsp; &nbsp;Gene Annotation Tool</span><br />
<span class='bold' style='font-size:14px'>&nbsp; &nbsp; &nbsp;&nbsp; &nbsp; &nbsp;$GV->{speciesName} &nbsp;&nbsp;($GV->dbTitle)</span><br /><br />
<h3 class='bold attention_text' style='font-size:14px;'>Locus: $PRM->{UCAannid} id: $PRM->{uid} withdrawn!</h3>";
  goto PRINT_PAGE_CONTENTS;
}

#########################
## end Submission actions
#########################  jfd edits here
LOAD_FIELDS:
############################################
## get gene evidence, genome sequence, scale
############################################
my $evidenceHashRef = &{$GV->{EvidenceFunction}};
my $imagelinkALL = &{$GV->{ImageMapFunction}};
$PRM->{GenomeSequence} = &{$GV->{GenomeSeqFunction}};
$PRM->{Elist} = getEvidenceList($evidenceHashRef); #return all evidence for current annotation
my $localTime = time();
printToFile($PRM->{Elist},"/xGDBvm/tmp/$GV->{dbTitle}/elist_$localTime");


my ($eTable,$etableJscript) = getEvidenceTable($evidenceHashRef);
my ($scale,$zeroPos,$StartX,$graphicMargin) = &{$GV->{ScaleFunction}};

################################################
## end get gene evidence, genome sequence, scale
################################################

################################################
## construct annotation id( unique name)
################################################

my $gene_annotation_id_prefix = substr $GV->{dbTitle}, 0, 6; # Use GDBnnn for name
# $gene_annotation_id_prefix .= $GV->{dbid}; # Add dbid (digit) to prefix. Don't need this for current implementation

my $gene_annotation_id;
$gene_annotation_id .= textfield(-name=>'gene_id_prefix',id=>'gene_id_prefix',-value=>"yrGATE-$gene_annotation_id_prefix.",-size=>12,-class=>'noshow',-readonly=>'readonly',); # The prefix goes first
$gene_annotation_id .= textfield(-name=>'new_locus_gene_id',id=>'new_locus_gene_id',-value=>"$gene_annotation_id_prefix-chr$PRM->{chr}-$PRM->{start}-$PRM->{end}",-size=>30,-class=>'noshow',-readonly=>'readonly',-title=>'Auto-generated prefix for new locus creation'); # if new locus, this gets appended on.
$gene_annotation_id .= textfield(-name=>'UCAannid',id=>'UCAannid_txt',-value=>$PRM->{UCAannid},-size=>60,-readonly=>'readonly'); # -title=>'String that will be saved to database'
 
my $reject_txt_user;
if ($PRM->{status} eq "REJECTED" && !$$ownedRef{$PRM->{uid}}){ #  (for users) Show Admin comments to a "rejected" User
$reject_txt_user = "<br />
<span class='normalfont bold' style='color:#DF2940'>
      	Administrator Comments / Reason for Rejection:
</span>
<img id='yrgate_reject_comments' src='/XGDB/images/help-icon.png' alt='?' title='[click for details]' class='xgdb-help-button' />
<br /><textarea class='reject_txt' readonly cols='50' rows='8' name='reject_txt_user'>$PRM->{comment}</textarea>";
}
my $reject_txt_admin;
if ($ownedByThisAdminAnnotator && $PRM->{comment} ne ""){ # (for admin) Show previous Admin commments if any
$reject_txt_admin = "<br />
<span class='normalfont bold' style='color:#DF2940'>
      	Previous Administrator Comments / Reason for Rejection:
</span>
<img id='yrgate_reject_comments' src='/XGDB/images/help-icon.png' alt='?' title='[click for details]' class='xgdb-help-button' />
<br /><textarea class='reject_txt' readonly cols='100' rows='8' name='reject_txt_admin'>$PRM->{comment}</textarea>";
}


my $maxAmt = 200; #maximum amount of exons
my $leftMargin = 10;
my $RangeChrFIELD = popup_menu(-name=>'chr',-value=>$GV->{CHR_LIST},-default=>$PRM->{chr},);
my $navigation = ($GV->{CHR_SELECT_BOX}) ? "<br /><span class='s3'>Chromosome: </span> $RangeChrFIELD ": "<br /><span class='s3 indent'>Genome Segment: </span><input readonly='readonly' size='10' name='chr' value='$PRM->{chr}'><br />";
$navigation .= '<span class="s3 indent">start: </span><input name="RangeStart" value='.$PRM->{start}.' size="10"><span class="s3"> end: </span><input name="RangeEnd" value='.$PRM->{end}.' size="10">&nbsp;';
$navigation .= '<input type="button" value="Change Location" class="buttons" onclick="EvidenceRangeSet();">';

# Category:
my @categories = recordCategory();
my $categoryField = popup_menu(-name=>'category_options',-id=>'category_options',-value=>\@categories,-onchange=>"togglefield(this.value,'category_txt');");
$categoryField .= "<img id='yrgate_category_help' src='/XGDB/images/help-icon.png' alt='?' title='(Optional) Select or Create a Project for this Annotation [click for details]' class='xgdb-help-button' />";
$categoryField .= "<br />" . textfield(-name=>'category',-id=>'category_txt',-value=>"$PRM->{category}",-size=>25,-placeholder=>'Enter a new Category',-class=>"noshow");
my $category = '<span id="yrgate_category">' . $categoryField . '</span>';


# anno_types: types of annotations.
# my $anno_typeField = popup_menu(-name=>'anno_type_options',-id=>'anno_type_options',-value=>\@anno_types,-attributes=>\%anno_type_attributes, -onchange=>"togglefield_annotype(this.value);");

#changing the following? Be sure to synch with AnnotationTool.js togglefield_annotype!
my $anno_classField = "";
$anno_classField .= '<select name="anno_type_options" id="anno_type_options" onchange="togglefield_annotype(this.value);">
<option title="Please choose one of the other options" value="">[Select...]</option>
<!--option title="Please select one of the other options" value=""></option-->
<option title="Confirm an existing gene model" value="Confirm">Confirm Existing Model</option>
<option title="Correct or amend an existing gene model" value="Improve">Improve Existing Model</option>
<option title="Extend or trim UTR of an existing gene model" value="Extend or Trim">Extend or Trim Existing Model</option>
<option title="Add a new splicing isoform at this locus" value="Variant">Add New Transcript Variant</option>
<option title="Cannot resolve structure" value="Not Resolved">Not Resolved</option>
<option title="Annotate a previously un-annotated locus" value="New Locus">Annotate New Locus</option>
<option title="The model is invalid and should be removed from the list" value="Delete">Recommend Deletion of a Model</option>
</select>';

$anno_classField .= "<img id='yrgate_anno-class_help' src='/XGDB/images/help-icon.png' alt='?' title='Select whether your model is improving, confirming, adding, or deleting a model [click for details]' class='xgdb-help-button' />";
$anno_classField .= "<br />" . textfield(-name=>'annotation_class',-id=>'anno_class_txt',-value=>"$PRM->{annotation_class}",-size=>9,-class=>"noshow");
my $anno_class = '<span id="yrgate_anno_class">' . $anno_classField . '</span>';

# Locus ID
my @locus_ids = recordLocusId();
my $locus_idField = popup_menu(-name=>'locus_id_options',-id=>'locus_id_options',-value=>\@locus_ids,-onchange=>"change_locus(this.value);");
$locus_idField .= "<img id='yrgate_locus-id_help' src='/XGDB/images/help-icon.png' alt='?' title='Select the locus to be annotated [click for details]' class='xgdb-help-button' />";
my $locus_id = '<span id="yrgate_locus-id">' . $locus_idField . '</span>';

# Transcript ID
my @transcript_ids = recordTranscriptId();
my $transcript_idField = popup_menu(-name=>'transcript_id_options',-id=>'transcript_id_options',-value=>\@transcript_ids,-onchange=>"togglefield(this.value,'transcript_id_txt');");
$transcript_idField .= "<img id='yrgate_transcript-id_help' src='/XGDB/images/help-icon.png' alt='?' title='Select the transcript ID your annotation is improving or confirming [click for details]' class='xgdb-help-button' />";
$transcript_idField .= "<br />" . textfield(-name=>'transcriptId',-id=>'transcript_id_txt',-value=>$PRM->{transcriptId},-size=>20,-class=>'noshow');
my $transcript_id = '<span id="yrgate_transcript-id">' . $transcript_idField . '</span>';

# New Locus entry
my $locus_id_textfield = textfield(-name=>'locusId',-id=>'locus_id_txt',-value=>"$PRM->{locusId}",-size=>30,-readonly=>'readonly');
my $new_locus_id = '<span id="yrgate_new-locus-id">' . $locus_id_textfield . "<img id='yrgate_new-locusID_help' src='/XGDB/images/help-icon.png' alt='?' title='Enter the Locus ID associated with this annotation [click for details]' class='xgdb-help-button' /></span>";


# Working Group:
my @working_groups = recordWorkingGroup();
my $working_groupField .= popup_menu(-name=>'working_group_options',-id=>'working_group_options',-value=>\@working_groups, -onchange=>"togglefield(this.value,'working_group_txt');");
$working_groupField .= "<img id='yrgate_working-group_help' src='/XGDB/images/help-icon.png' alt='?' title='(optional) Select or Create a Working Group to which this annotation belongs [click for details]' class='xgdb-help-button' />";
$working_groupField .= "<br />" . textfield(-name=>'working_group',-id=>'working_group_txt',-value=>"$PRM->{working_group}",-size=>25,-placeholder=>'Enter a new Working Group',-class=>"noshow");
## for reasons related to javascript dependencies, deleting the above line results in incorrect "your structure" image display. Event though this user input option is turned off, we leave this code in place.	
my $working_group = '<span id="yrgate_working_group">' . $working_groupField . '</span>';

my $status_brief = substr($PRM->{status}, 0, 9);
## Form Elements Hash
my %FE = (
      "Annotation ID" => $gene_annotation_id." <span class='anno_property ".$PRM->{status}."'>(".$status_brief.")</span><br />"
	  .$reject_txt_user,
	  "Annotation Class" => $anno_class,
	  "Locus ID" => $locus_id,
	  "Transcript ID" => $transcript_id,
	  "New Locus ID" => $new_locus_id,
	  "Project" => $category,
	  "Working Group" => $working_group,
	  "Genome Location" => $navigation,
	  "Strand" => "<input type='radio' name='UCAstrand' id='UCAstrand_forward' value='forward strand' checked='checked' onclick='reverseStrand();'><label for='UCAstrand_forward' class='s3 nbsp'> forward </label><input type='radio' name='UCAstrand' id='UCAstrand_reverse' value='reverse' onclick='reverseStrand();'><label for='UCAstrand_reverse' class='s3 nbsp'> reverse strand </label><input type='button' class='buttons nbsp' value='Reset mRNA structure' onclick='resetMRNA();'>",
	  "Protein Coding Region" => "<span class='instructions'>Use the ORF finder!</span><br /><span class='s3 nbsp'>Start</span>".textfield(-name=>'UCAcdsstart',-value=>$PRM->{cds_start},-size=>10,-maxlength=>10,-onchange=>'EnterORF();')." <span class='s3 nbsp'>End </span>".textfield(-name=>'UCAcdsend',-value=>$PRM->{cds_end},-size=>10,-maxlength=>10,-onChange=>'EnterORF();')."<input type='button' class='buttons nbsp' value='ORF Finder' onclick='GORF();'><img id='yrgate_orf-finder_help' src='/XGDB/images/help-icon.png' alt='?' title='ORF Finder Tool Help' class='xgdb-help-button' style='margin-bottom:-4px' />",
	  "mRNA Structure" => textarea(-name=>'UCAstruct', -value=>$PRM->{info},-rows=>3,-cols=>50,-onchange=>'structTextEnter();'),
	  "Description" => "<img id='yrgate_description_help' src='/XGDB/images/help-icon.png' alt='?' title='Tips for Description' class='xgdb-help-button' />".textarea(-name=>'UCAdesc',-value=>$PRM->{desc},-rows=>8,-cols=>50),
	  "Putative Protein Product" => "<img id='yrgate_protein_help' src='/XGDB/images/help-icon.png' alt='?' title='Tips for Protein Product' class='xgdb-help-button' />".textarea(-name=>'UCAprod',-value=>$PRM->{prod},rows=>1,-cols=>50),
	  "Gene Aliases" => "<img id='yrgate_gene-alias_help' src='/XGDB/images/help-icon.png' alt='?' title='Tips for Gene Alias' class='xgdb-help-button' />".textarea(-name=>'UCAannalias',-value=>$PRM->{geneAlias},-rows=>1,-cols=>50),
	  "Protein Aliases" =>  "<img id='yrgate_protein-alias_help' src='/XGDB/images/help-icon.png' alt='?' title='Tips for Protein Alias' class='xgdb-help-button' />".textarea(-name=>'UCAprotalias',-value=>$PRM->{protAlias},-rows=>1,-cols=>50),
	  "mRNA" => "<input name='mRNAlength' size='18'><br /><textarea class='seqTextArea morepadding' rows='10' cols='50' name='mRNAseq' readonly='readonly'></textarea><a class='portallink nbsp' href=\"javascript:Blast('n');\">blastn</a> <a class='portallink nbsp' href=\"javascript:Blast('x');\">blastx</a><a class='portallink' href=\"javascript:Blast('tx');\">tblastx</a> <a class='portallink' href=\"javascript:miRBASE();\">miRBASE</a><img id='yrgate_mirbase_help' style='margin-left:5px' src='/XGDB/images/help-icon.png' alt='?' title='Tips for miRBASE analysis' class='xgdb-help-button' />",
	  "Protein" => "<input name='proteinlength' size='18'><textarea rows='6' class='seqTextArea' class='morepadding' cols='50' cols='50' name='protein' readonly='readonly'></textarea><a class='portallink nbsp' href=\"javascript:Blast('p');\">blastp</a><a class='portallink' href=\"javascript:Blast('tn');\">tblastn</a><img id='yrgate_blast_help' style='margin-left:5px' src='/XGDB/images/help-icon.png' alt='?' title='Tips for protein blast analysis' class='xgdb-help-button nbsp' /><a class='portallink' href=\"javascript:InterProScan();\">InterProScan</a><img id='yrgate_interproscan_help' style='margin-left:5px' src='/XGDB/images/help-icon.png' alt='?' title='Tips for InterPro Scan analysis' class='xgdb-help-button' />",
	  "Genome Sequence Edits" => "<img id='yrgate_genome-edit_help' src='/XGDB/images/help-icon.png' alt='?' title='Tips for Description' class='xgdb-help-button' /><textarea rows='1' cols='50' name='GSeqEdits' readonly='readonly'>$PRM->{GSeqEdits}</textarea><a href=\"javascript:goSeqEdit();\" class='portallink'>Genome Sequence Editor</a><br />\n",
	  "Gene Annotation Type" => popup_menu(-name=>'annotation_type',-value=>$GV->{ANNOTATION_TYPES},-default=>$PRM->{annotation_type})
	  );

$FE{"User Defined Exons"} = <<END_UDE;
    <table cellpadding='2' class='mainTable' style='padding: 0 0 2px 0'>
    <tr>
     <td>
       <div style='border:thin gray solid; background:white; margin-right:5px' class="s3"><!--<p class="s2">User-Defined Exons Table</p>-->
         <div id='UserBox'></div>
       </div>
     </td>
     <td>
       <s1>Portals and Tools&nbsp;<img id='yrgate_portal_help' src='/XGDB/images/help-icon.png' alt='?' title='Use a portal to find additional exon structures [click for details]' class='xgdb-help-button' /></s1> <br />

       <a href="#topA" onclick="GoCpGAT();" class="portallink">CpGAT</a><br />
       <a href="#topA" onclick="GoGM();" class="portallink">GeneMark</a>
       <a href="#topA" onclick="GoGS();" class="portallink">GENSCAN</a><br />
       <a href="#topA" onclick="GoGTH();" class="portallink">Genome Threader</a><br />
       
      <s1>Manual Entry &nbsp;<img id='yrgate_manual-entry_help' src='/XGDB/images/help-icon.png' alt='?' title='You can add your own exon coordinates here [click for details]' class='xgdb-help-button' /></s1><br />
       <label for="new5" class="s3 nbsp">start</label><input name="new5" id="new5" class="manual smaller" size="10"><br />
       <label for="new3" class="s3 nbsp">end</label><input name="new3" id="new3" class="manual smaller" size="10"><a href="javascript:addUDE(document.forms['$GV->{formName}'].new5.value,document.forms['$GV->{formName}'].new3.value,'manual','');" class="portallink">add</a>
     </td>
     </tr></table>
     <input class="buttons" type="button" value="Clear User-Defined Exons Table" onclick="clearUserExons();updateMRNA();" />
END_UDE

#jfd : removed portal link from above until GSQ is functional
#<a href="#topA" onclick="GoGSQ();" class="portallink">GeneSeqer at PlantGDB</a><br />

# Changing order of @FEorder1 or @FEorder1_ids? See PRINTFIELDS area (below)
my @FEorder1 = ("Annotation ID","Annotation Class","Locus ID","Transcript ID","New Locus ID","Project","Working Group","Genome Location","Strand");
my @FEorder1_ids = ("gene_annotation_id","annotation_class","locus_id","transcript_id","new_locus_id","category","working_group","genome_location","strand");
my @FEorder2 = ("User Defined Exons","mRNA","Protein Coding Region","Protein","mRNA Structure","Gene Annotation Type","Description","Putative Protein Product","Gene Aliases","Protein Aliases","Genome Sequence Edits"); # order of form elements in page


my $GAEVAL = ""; ## need

my $previewStruct = "
<script type='text/javascript'>
/* <![CDATA[ */
var exonMaxsize = $maxAmt;
var baseScale = $scale;
var pad = $StartX;
var lmargin = $leftMargin;
var StructHeight = 11;
var startCoord = $zeroPos;
var eTableExons = new Object();
$etableJscript
/* ]]> */
</script>
<table class='preview_struct'>
<tr><td height='5'><img src='".$GV->{IMAGEDIR}."tln_start.gif' id='tlnStart' alt='' class='previewImage'><img src='".$GV->{IMAGEDIR}."tln_stop.gif' id='tlnStop' alt='' class='previewImage' /><\/td><\/tr>
<tr><td height='11' id='refCell'><img src='".$GV->{IMAGEDIR}."leftarrow.gif' id='leftarrow' alt='' class='previewImage' />";
for (my $i=0;$i<$maxAmt;$i++){
	$previewStruct .= '<img id="e'.$i.'" src="'.$GV->{IMAGEDIR}.'e.gif" alt="" class="previewImage">';
}

$previewStruct .= "<img src='".$GV->{IMAGEDIR}."i.gif' id='intron' class='previewIntron'><img src='".$GV->{IMAGEDIR}."rightarrow.gif' id='rightarrow' class='previewImage'><\/td><\/tr>";
$previewStruct .= "<tr><td><div id='gaevalScore'><\/div><\/td><\/tr><\/table>";

my $imgfn="tmp$$".'.png';

my $GAEVALtxt;
if ($GV->{GAEVAL}){
    $GAEVALtxt = "<input class='utButton' type='button' name='GAEVAL' value='GAEVAL for this annotation' onclick='goGAEVAL();'>";
}
my $TutorialTXT;
if ($GV->{Tutorial}){ # When does this ever get used? - dhrasmus
    $TutorialTXT = '<input class="utButton" type="button" value="Tutorial" onclick="tutorial();">';
}

#my $GenomePlotSelection = "<span class='smaller'> change to ".(($PRM->{largeImage}) ? "<a href=\"javascript:changeImageSize(400);\">small image</a>" : "<a href=\"javascript:changeImageSize(800);\">large image</a>")."</span>";
my $GenomePlotSelection = "<span class='s3'>Change plot width to </span>
<select name='imgWidthSel' onchange='changeImageSize();'>
<option value='425' ".(($PRM->{imgWidth} eq '425') ? 'selected': '')."  >425</option>
<option value='850' ".(($PRM->{imgWidth} eq '850') ? 'selected': '')." >850</option>
<option value='1200' ".(($PRM->{imgWidth} eq '1200') ? 'selected': '')." >1200</option>
<option value='3000' ".(($PRM->{imgWidth} eq '3000') ? 'selected': '')." >3000</option>
</select>
<span class='s3'>pixels</span>";


my $GPwidth = ($PRM->{imgWidth} + 2*$graphicMargin);
my $GenomePlot =<<END_GP;
<table id='genomePlot'>
<tr><td>
	<div class="fieldspace"><span class='s0'>Evidence Plot <img id='yrgate_eplot_help' src='/XGDB/images/help-icon.png' alt='?' title='What is the evidence plot?' class='xgdb-help-button' /></span>
	$GenomePlotSelection &nbsp;<span><a title="Key to the Glyph Images used for Tracks" class="image-button help_link instructions" id="XGDB_Glyphs">Track Color Codes</a></span></div>
	<div class='instructions indent'>Click an evidence ID or a combination of exons to build structure</div>
	<div style='width:${GPwidth}px;height:750px;overflow:auto;border:1px solid #CCC; resize:vertical' id='ePlotDiv'>$imagelinkALL</div>
</td></tr>
<tr><td class='bold attention_text fieldpadd' style='padding-left:15px;'>Your Structure: <img id='yrgate_eplot_yourstructure' src='/XGDB/images/help-icon.png' alt='?' title='Help with Your Structure' class='xgdb-help-button' /></td></tr>
<tr><td id='your_structure'>$previewStruct</td></tr>
<tr><td class='bold attention_text fieldpadd' style='padding-left:15px;'>GAEVAL score: <img id='yrgate_eplot_integrity' src='/XGDB/images/help-icon.png' alt='?' title='Help with the GAEVAL integrity score' class='xgdb-help-button' /></td></tr>
<tr id='your_score'></tr>
</table>
END_GP

###################
## Function Buttons 
###################

###- Admin: ACCEPT REJECT RELOAD DELETE
my $functionButtons;
if (($isAdmin or $isGroupAdmin) and $ownedByThisAdmin){
    $functionButtons = "<span class='bold' style='font-size:24px'>Administration Tool</span><br /><br />";
  if ( $GV->{email} ){
    $functionButtons .= "<span style='background-color:yellow;'>Email Message:</span> (Auto-inserted: \"Your annotation was ____.\") Add explanatory comments/suggestions below:
  <img id='admin_curator_comments' src='/XGDB/images/help-icon.png' alt='?' title='[click for details]' class='xgdb-help-button' style='margin:0 0 -2px 4px' />
	<textarea name='emailTXT' id='emailTXT' rows='5' cols='100'>$PRM->{emailTXT}<\/textarea>";
 }
$functionButtons .= "<input class='funcButton' type='button' name='UCAaccept' value='ACCEPT' onclick=\"formSubmit('UCAaccept','Accepting Annotation into $GV->{dbTitle}','_self');\" /><input class='funcButton' type='button' name='UCAreject' value='REJECT' onclick=\"formSubmit('UCAreject','Rejecting Annotation','_self');\" />";

$functionButtons .= "<input class='funcButton' type='button' name='UCAreload' value='RELOAD' onclick=\"formSubmit('UCAreload','Reloading Annotation','_self');\" />";

my $status;  ### $status from UCAload
if ($ownedByThisAdminAnnotator){
    $functionButtons .= "<input class='funcButton' type='button' name='UCAdelete' value='DELETE' onclick=\"formSubmit('UCAdelete','Removing Annotation');\" />";
    # remove function for accepted annotations
}


### User: Submit Remove Annotation  Save for Editing  Export Text  Export to GFF  Reset
$functionButtons .= "<br /><br /><br />";
$functionButtons .= "$reject_txt_admin <br /><br />";

}elsif($GV->{login_required}==1 && $PRM->{USERid} ne ""){
$functionButtons = <<END_OF_FB;
<input class="funcButton" type="button" name="UCAsubmit" value="Submit" onclick="formSubmit('UCAsubmit','Submitting Annotation for Review','_self');" />
<input class="funcButton" type="button" name="UCAdelete" value="Remove Annotation" onclick="formSubmit('UCAdelete','Removing Annotation','_self');" />
<input class="funcButton" type="button" name="UCAsave" value="Save for Editing" onclick="formSubmit('UCAsave','Saving Annotation','_self');" />
END_OF_FB
}
$functionButtons .= "<input class='funcButton nbsp' type='button' name='UCAprint' value='Export to Text' onclick=\"formSubmit('UCAprint','','_blank');\" />";
$functionButtons .= "<input class='funcButton nbsp' type='button' name='UCAprint' value='Export to GFF' onclick=\"formSubmit('UCAgff','','_blank');\" />";
$functionButtons .= "<input class='funcButton nbsp' type='button' value='Reset' onclick='resetAll();' />
	<span class='citation'>Please cite Wilkerson et al. (2006) <i>Genome Biol.</i> <b>7</b>, R58.
	[<a href='http://www.ncbi.nlm.nih.gov/pmc/articles/PMC1779557/?tool=pubmed'>PMC1779557</a>]
	</span>";

#######################
## end Function Buttons
#######################

my ($FIELD_HTML1, $FIELD_HTML2);

#$FIELD_HTML1 = "<div class='fieldspace'><s1 title='Unique yrGATE ID'>$FEorder1[0]</s1>$FE{$FEorder1[0]}&nbsp;<img id='yrgate_id_help' src='/XGDB/images/help-icon.png' alt='?' title='yrGATE ID Help' class='xgdb-help-button' /></div>";
#$FIELD_HTML1 .= "<div class='fieldspace'><s1 title='Change Location'>$FEorder1[1]</s1>$FE{$FEorder1[1]}</div>";
#$FIELD_HTML1 .= "<div class='fieldspace'><s1 title='Change strand to reverse direction of transcription'>$FEorder1[2]</s1>$FE{$FEorder1[2]}";

for(my $i=0;$i<scalar(@FEorder1);$i++){ # PRINTFIELDS
  if (($i == 2) || ($i == 3) || ($i == 4)){ # Array ids of elements we want to make disappear. "locus_id","transcript_id","new_locus_id" # $i == 0) || 
    $FIELD_HTML1 .= "<div class='fieldspace noshow' id='$FEorder1_ids[$i]'>$FE{$FEorder1_ids[$i]}";
  }else{
    $FIELD_HTML1 .= "<div class='fieldspace' id='$FEorder1_ids[$i]'>$FE{$FEorder1_ids[$i]}";
  }
  $FIELD_HTML1 .= "<s1>$FEorder1[$i]</s1>$FE{$FEorder1[$i]}</div>\n";
}

for(my $i=0;$i<scalar(@FEorder2);$i++){
  $FIELD_HTML2 .= "<div class='fieldspace'><s1>$FEorder2[$i]</s1>$FE{$FEorder2[$i]}</div>\n";
}

# my $getAdminEmail=getAdminEmail(); # DEBUG ONLY
# my $USERid=getUserId(); # DEBUG ONLY 

my $PAGE_CONTENTS = <<END_OF_PAGE;
<div class="bottommargin1">
	$functionButtons
	$GAEVALtxt $TutorialTXT
	<br />
	<br />
	<s1>Annotation Owned By:</s1>
	<span class="anno_property">$PRM->{owner}</span> 
	<s1>Annotation Record Status:</s1>
	<span class="anno_property $PRM->{status}">$PRM->{status} $PRM->{modDate} $PRM->{modTime}</span>
</div>
    <div id="quickstart" class="description showhide topmargin1"><a title="Show yrGATE help information directly below this link" class="label" style="cursor:pointer">Quick Start Guide (click to show/hide)</a>
	<div class="hidden">
	<p>To contribute a Community Gene Structure Annotation:</p>
	<ul class="menulist">
	   <li>1. <b>Log in</b> using the button above, or <b>register</b> for an annotation account if you don't have one.</li>
	   <li>2. Start with the <b>Evidence Plot</b> at right: Click on a <u>cDNA</u> (<span style="font-weight: bold; color:lightblue">light blue</span>), <u>EST</u> (<span style="font-weight: bold; color:red">red</span>) or <u>protein</u> (<span style="font-weight: bold; color:brown">brown</span>/<span style="font-weight: bold; color:black">black</span>) glyph to build "Your Structure"
		   <ul>
		   <li>-click the <b>Sequence ID</b> to add <u>all exons</u></li>
		   <li>-click an <b>exon</b> to add <u>only that exon</u></li>
		   </ul>
	   <li>3. Use <b>Evidence Table</b> to check quality score of the exons in "Your Structure"</li>
	   <li>4. Find the best open reading frame for "Your Structure" using the <b>ORF Finder</b> tool</li>
	   <li>5. Run Protein <b>blastp</b> to confirm that ORF is full-length compared to similar proteins</li>
	   <li>6. Enter <b>Description</b> information, <b>Gene/Protein Aliases</b> (if any)</li>
	   <li>7. Back at the top: Enter <b>Annotation Class</b> (Correct/Improve, Confirm, New Isoform, New Locus, Recommend Delete)</li>
	   <li>8. Select <b>Locus ID</b> and/or <b>Transcript ID</b> that you are annotating against (unless New Locus selected)</li>
	   <li>9. Enter <b>Project</b> and <b>Working Group</b> (if appropriate)</li>
	   <li>10. Click <b>Submit</b> to send for curation; you will be notified by email when your gene model has been reviewed (ACCEPT or REJECT)</li>
	   <li>11. Alternatively, click <b>Save</b> to SAVE your annotation for later editing, or to keep it private (only the owner can view SAVED annotations)</li>
	   <li>12. If your model is REJECTED, the curator will provide suggestions for improving your model if possible.</li>
	   <li>13. If your model is ACCEPTED, it will be published online on the genome browser. You will no longer be able to edit or delete the annotation.</li>
	  </ul>
	  <p class="bold">NOTES</p>
<p>- You can view your own saved/submitted models in the <b>genome browser window</b> (others will not see it until it is ACCEPTED).
<br /> - Curated, ACCEPTED models are displayed to all users and also published via DAS (Distributed Annotation Sevice)<br />
- To view your annotations or to <b>edit and resubmit</b>, visit the <b>My Annotation Account</b> page. Click the <b>edit</b> link to open an editable annotation record.<br />
- Working Group members can visit <b>My Annotation Group</b> to view other group members annotations in progress.<br />
	 <span class="attention_text">Hint:</span> Hover over or click any "<img title="help icon" style="margin-bottom: -3px;" src="/XGDB/images/help-icon.png" alt="?">" icon for contextual help. See also <a href="/help/" target="_blank">PlantGDB Help</a> portal for tutorials, video demos, and comprehensive help.</p>

	</div><!--end of hidden div-->
	</div><!--end showhide div-->
<table class='mainTable'>
<tr>
END_OF_PAGE

$PAGE_CONTENTS .= (!$PRM->{largeImage}) ? "</tr>
	<td valign='top' id='dataColumn'><div style='width:400px; height:100%; overflow:hidden'>$FIELD_HTML1 $FIELD_HTML2</div></td>
	<td valign='top' width='450px' height='30' class='mainTable' id='EvidenceCell'>$GenomePlot 
" : "
<td colspan='2'>
$FIELD_HTML1
$GenomePlot</td>
</tr>
<tr>
	<td>$FIELD_HTML2</td>
	<td width='450px' class='mainTable' id='EvidenceCell'>
";

$PAGE_CONTENTS .= "
$eTable</td>
</tr>
</table>
";


PRINT_PAGE_CONTENTS: # TODO: Make this jump unnecessary


# TODO: Work one of the following DOCTYPES into this. Without breaking Javascript!
# <!DOCTYPE HTML PUBLIC '-//W3C//DTD HTML 4.01//EN' 'http://www.w3.org/TR/html4/strict.dtd'>
# <!DOCTYPE html PUBLIC '-//W3C//DTD XHTML 1.0 Transitional//EN' 'http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd'>
#       <html xmlns='http://www.w3.org/1999/xhtml' xml:lang='en'>
my $main_page =<<END_MAIN_PAGE;
<html lang='en'>
  <head><title>yrGATE @ $GV->{dbTitle}</title>
	<link href="/XGDB/javascripts/jquery/themes/base/ui.all.css" type="text/css" rel="stylesheet" />
	<link href="/XGDB/css/plantgdb.css" type="text/css" rel="stylesheet" />
	<link type='text/css' rel='stylesheet' href='$GV->{HTMLPATH}yrGATE.css' />
	<script type='text/javascript' src='$GV->{JSPATH}AnnotationTool.js'></script>
	<script type='text/javascript' src='$GV->{JSPATH}utility.js'></script>
	<script type='text/javascript' src='$GV->{JSPATH}popup.js'></script>

	<script type="text/javascript" src="/XGDB/javascripts/jquery/jquery-1.3.2.js"></script>
	<script type="text/javascript" src="/XGDB/javascripts/jquery/ui/ui.core.js"></script>
	<script type="text/javascript" src="/XGDB/javascripts/jquery/ui/ui.sortable.js"></script>
	<script type="text/javascript" src="/XGDB/javascripts/jquery/ui/ui.draggable.js"></script>
	<script type="text/javascript" src="/XGDB/javascripts/jquery/ui/ui.resizable.js"></script>
	<script type="text/javascript" src="/XGDB/javascripts/jquery/ui/ui.dialog.js"></script>
	<script type="text/javascript" src="/XGDB/javascripts/jquery/ui/effects.core.js"></script>
	<script type="text/javascript" src="/XGDB/javascripts/jquery/ui/effects.highlight.js"></script>
	<script type="text/javascript" src="/XGDB/javascripts/jquery/external/bgiframe/jquery.bgiframe.js"></script>
	<script type="text/javascript" src="/XGDB/javascripts/default_xgdb.js"></script>
	<script type="text/javascript" src='$GV->{JSPATH}AuthenticationDialog.js'></script>
  </head>

  <body style="margin-left:${leftMargin}px;padding:0">
		<div onclick='event.cancelBubble = true;' class='Loadingpopup' id='LoadingPopUp'>
			<span id='message' class='center'>Loading.... Please wait</span>
			<br /><br /><br /><br /><br /><br /><br /><br /><br /><br /><br /><br /><br /><br /> <br /><br /><br /><br /><br /><br /><br /><br /><br /><br />
			Loading.... Please wait
		</div>

<form name='$GV->{formName}' method='post' action='AnnotationTool.pl'><!-- What is the purpose of this section? DHR? -->
<input type='hidden' name='owner' value ='$PRM->{owner}'>
<input type='hidden' name='start' value='$PRM->{start}'>
<input type='hidden' name='end' value='$PRM->{end}'>
<input type='hidden' name='comment' value='$PRM->{comment}'>
<input type='hidden' name='seqUID' value='$PRM->{seqUID}'>
<input type='hidden' name='USERid' value='$PRM->{USERid}'>
<input type='hidden' name='dbVer' value='$PRM->{dbVer}'>
<input type='hidden' name='uid' value='$PRM->{uid}'>
<input type='hidden' name='UDEsource' value='$PRM->{UDEsource}'>
<input type='hidden' name='Esource' value=''>
<input type='hidden' name='Elist' value='$PRM->{Elist}'>
<input type='hidden' name='createTime' value='$localTime'>
<input type='hidden' name='imgWidth' value='$PRM->{imgWidth}'>
<input type='hidden' name='status' value='$PRM->{status}'>
<input type='hidden' name='GenomeSequence'> <!--portal-->
<input type='hidden' name='UCAname'>
<input type='hidden' name='OriginalGenomeSequence' value='$PRM->{GenomeSequence}'>
<input type='hidden' name='gdb' value='$GV->{dbTitle}'>
<input type='hidden' name='cdsstart' value='$PRM->{cds_start}'>
<input type='hidden' name='cdsend' value='$PRM->{cds_end}'>
<input type='hidden' name='orfsel' value="">
<script type="text/javascript">
/* <![CDATA[ */
var GenomeSequence;
var imagePATH = '$GV->{IMAGEDIR}';
var cgiPATH = '$GV->{CGIPATH}';
var formName = '$GV->{formName}';
var logoPath = '$GV->{logoimagePath}';
var dbTitle = '$GV->{dbTitle}';
/* ]]> */
</script>
<input type='hidden' name='modifyState' value='1'>
<input type='hidden' name='mode' value=''>
<span class='annoToolContainer'>
<div id="maincontents">
<h1 class='bottommargin1'>yrGATE : Gene Structure Annotation Tool <span class="instructions indent nbsp">What's yrGATE? <img id='yrgate_tool_help' src='/XGDB/images/help-icon.png' alt='?' title='yrGATE is a Web-based tool that allows you to create gene annotations that correct or amend existing transcript structures  [click for details]' class='xgdb-help-button' style='margin:0 0 -2px 4px' /></span><span class="instructions indent">Annotation Tips:</span><img id='yrgate_annotation_mistakes' src='/XGDB/images/help-icon.png' alt='?' title='Click for tips on avoiding common annotation mistakes' class='xgdb-help-button' style='margin:0 0 -2px 4px'/></h1>
<h2 class="bottommargin1 species">Database: &nbsp;&nbsp;$GV->{dbTitle}</h2>
<table><tr><td class='$MSGclass'>$MSG1</td></tr></table></span>
$PAGE_CONTENTS
<script type="text/javascript">
/* <![CDATA[ */
first_load();
/* ]]> */
</script>
</form>

</div>
</body>
END_MAIN_PAGE

# Ideal: print header(-type=>'application/xhtml+xml', -charset=>'utf-8', -expires=>'now'); # Have to settle for line below:
print header(-expires=>'now');
print $main_page;
print printFooter();
print end_html();

disconnectDB();

