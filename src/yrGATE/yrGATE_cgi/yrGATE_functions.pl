#!/usr/bin/perl

use CGI::Session::ID::md5;
use strict vars;
use vars qw(
$GV
$GVportal
$PRM
@modes
$DBH
$zeroPos
$GENEMARK_speciesModel
$GENSCAN_speciesModel
%EV
);
use Data::Dumper;
use HTML::Entities;


########################################
### main
########################################
$PRM->{USERid} = &{$GV->{getUserIdFunction}};


########################################
### Source Data Functions
########################################


# init function

sub init_das{
    require 'das_scripts/dasFunctions.pl';
    dasParam(); # function to set chr, start and stop from cookie
    return;
}


# get evidence functions

sub getEvidence_db{
    # this function queries the local evidence database for the following information and the results are returned as an array
    # [database name],[method of generation],[evidence name],[unique id],[genome start position],[genome end position],[score],[exon number],[evidence reference],[strand (1,0)],[color]
    # The evidence reference is a url to the primary data of the evidence, such as an alignment, program output,
    #
    # This example has two queries for two tables that contain different types of evidence
    # The query results are added to $evidenceHashRef using the getExons function
    # this evidenceHashRef is returned
    my %evidenceHash;
    my $evidenceHashRef = \%evidenceHash;


    for my $r ( @{&{$GV->{evidenceSources}}} ){
        my $ref2=$GV->{DBH}->selectall_arrayref($r->[2]);
        $evidenceHashRef = getExons($ref2,$r->[0],$r->[1],$evidenceHashRef);
    }

  return $evidenceHashRef;
}

sub getEvidence_das{
    my $evidenceHasRef = &queryDASevidence_genomeSequence();
    return $evidenceHasRef;
}

# get genome sequence functions

sub getGenomeSequence_das{
    return $PRM->{GenomeSequence}; # already defined and set in getEvidence_das
}

sub getGenomeSequence_ex{
    # this example uses a fasta formatted file as genome sequence and takes a simple perl substring
    # larger implementations should replace this with fastacmd, or an alternative function
    my $seq = `more ../db/zm.fsa`;
    $seq =~ s/^.+?\n.+?\n.+?\n.+?\n//s;
    $seq =~ s/\n//sg;
    $seq = substr($seq,$PRM->{start}-1,($PRM->{end} - $PRM->{start}) +1);
    return $seq;
}

sub getImageMap{
    require 'makeImage.pl';
    my $imagelinkALL = &returnImageMap();
    $imagelinkALL .= "<script type=\"text/javascript\">var GenomeSequence = '$PRM->{GenomeSequence}';</script>";
    return $imagelinkALL;
}

# get scale

sub getScale{
my $zeroPos = int($PRM->{start});
my $StartX=10;
my $Margin=10;

my $imgWidth = $PRM->{imgWidth};

my $scale = ($PRM->{end} - $zeroPos + 1) / ($PRM->{imgWidth} - 2*$Margin);

#my $scale = $seqLen / $rulerLen;

$scale = sprintf("%.4f", $scale);

return ($scale,$zeroPos,$StartX,$Margin); # [base to pixel scale] , [base position of start of graphic], [left padding white space in graphic

}

########################################
### End Source Data Functions
########################################

########################################
### Database
########################################

# source database
my %attr = (PrintError=>1,RaiseError=>1);

sub getUserId{
  my @sessionCookie = cookie($GV->{SessCookieName}); # reads session id from cookie and accesses php session variables
  my $id = param("ssisession")?param("ssisession"):$sessionCookie[0];
  if ($id ne ""){
    my $session = PHP::Session->new($id, { create => 1,save_path => $GV->{session_path} });
    if ($session->is_registered($GV->{SessLoginParam})){
      my $USERid = $session->get($GV->{SessLoginParam});
      return $USERid;
    }else{
      $session->destroy;
      return;
    }
  }
  return;
}

sub logout{
  my @sessionCookie = cookie($GV->{SessCookieName}); # reads session id from cookie and accesses php session variables
  my $id = $sessionCookie[0];
  my $cookie;
  if ($id ne ""){
    my $session = PHP::Session->new($id, { create => 1, save_path => $GV->{session_path} });
    $session->destroy;
    $cookie = cookie(-name=>$GV->{SessCookieName},-value=>$session->id,-expires=>'-1d');
  }
  return $cookie;
}

sub login{
  # simple user verification (not secure)
  my ($username,$passwd,$expire) = @_;
  if ($username eq "" && $passwd eq ""){
      return 0;
  }
  my $sql_username = $GV->{LDBH}->quote($username);
  my $sql_passwd = $GV->{LDBH}->quote($passwd);
  my $sql = sprintf("SELECT user_name, user_cgi_session FROM users WHERE user_name = %s AND account_type !='INACTIVE' AND pword = password(%s) ", $sql_username, $sql_passwd);
  my @arr = $GV->{LDBH}->selectrow_array($sql);
  if ($arr[0] eq $username && $arr[0] ne ""){
    srand;
    my $session = PHP::Session->new(int(rand()*10000000000),{ create => 1,save_path => $GV->{session_path},auto_save => 1 });
    $session->set($GV->{SessLoginParam} => $username);

    my $CGIsessionid = $arr[1];
    if($CGIsessionid eq ''){
      $CGIsessionid = create_unique_CGI_session_user_id();
      $sql = "UPDATE users SET user_cgi_session = '$CGIsessionid' WHERE user_name = '$username' AND pword = password('$passwd') ";
      my $sth = $GV->{LDBH}->do($sql);
    }
    $session->set('USERsessionCGI' => $CGIsessionid);

    my $scookie = (defined($expire))? cookie(-name=>$GV->{SessCookieName},-value=>$session->id,-expires=>$expire):cookie(-name=>$GV->{SessCookieName},-value=>$session->id);
    return $scookie;
  }
  return 0;
}

sub user_register{
    my ($username,$passwd,$fullname,$phone,$email) = @_;
    my $account_type = 'USER';
    my $CGISESSID = create_unique_CGI_session_user_id();
    my $sql = "INSERT INTO users (user_name,pword,fullname,phone,email,user_cgi_session) VALUES ('$username',password('$passwd'),'$fullname','$phone','$email','$CGISESSID')";
    my $sth = $GV->{LDBH}->do($sql) || return 0; # returns false if insert failed; unique keys in users table determine valid record
    return 1;
}

sub create_unique_CGI_session_user_id{
## SDS: This is used for interoperability with xGDB and creates a value 'user_cgi_session'
## This sessionID is persisted under the USERsessionCGI session parameter

     return CGI::Session::ID::md5::generate_id();
}

sub getAdminOwnership{
  # not checked
  # find annotations currently checked out by administrator, returns hash{geneid} = admin who checked it out

  my $sql = "SELECT uid, max(checked_out_date) AS maxDate FROM admin_session WHERE dbName='$GV->{dbTitle}' GROUP BY uid";
  my $latestREF = $GV->{LDBH}->selectall_hashref($sql,'uid');

  my $expire_secs = 60*30;

  my %ownedHash = ();

  for my $k (keys %$latestREF){
    my $sql = "SELECT uid,USERid,geneName FROM admin_session WHERE uid = '$k' AND checked_out_date = '$$latestREF{$k}{'maxDate'}' AND (UNIX_TIMESTAMP(now()) - UNIX_TIMESTAMP(checked_out_date))  < $expire_secs and dbName = '$GV->{dbTitle}' AND returned = 0";
    my $oREF = $GV->{LDBH}->selectall_hashref($sql,'uid');
    if (keys(%$oREF)){
      $ownedHash{$k} = $$oREF{$k}{'USERid'};
    }
  }
  return \%ownedHash;
}


sub getUserGroup{
    # Determine if user has ADMIN status in yrgate.users table (NOTE: here "Group" means ADMIN vs USER, does not refer to private groups. Legacy function name!!!)
    
    my $id = int(substr($GV->{dbTitle}, -3));
    my $account_sql = "SELECT account_type FROM users WHERE user_name = '$PRM->{USERid}'"; # Is this person an ADMIN or a USER?
    my @account = $GV->{LDBH}->selectrow_array($account_sql);    
    if ($account[0] eq "ADMIN"){ 
		return 1;
    }else{
		return 0;
    }
}

sub getWorkingGroupAdmin{
    # Determine if user has working group ADMIN status for this or all GDB (able to administer annotations in a private group)
    my $sql = "SELECT status FROM user_group WHERE user = '$PRM->{USERid}' AND (gdb='$GV->{dbTitle}' OR gdb='ALL') and status='ADMIN'"; # Does this user have Group ADMIN status for this (or all) GDB?
    my @ref = $GV->{LDBH}->selectrow_array($sql);
    if ($ref[0]){
		return 1;
    }else{
		return 0;
    }
}

sub getWorkingGroupUser{
    #  Determine if user is working group USER or ADMIN for this or all GDB (Allows My Annotation Groups page)
    my $sql = "SELECT status FROM user_group WHERE user = '$PRM->{USERid}' AND (gdb ='$GV->{dbTitle}' OR gdb='ALL') AND (status='USER' OR status='ADMIN')"; 
    my @ref = $GV->{LDBH}->selectrow_array($sql);
    if ($ref[0]){ #if member of private group (either as USER or ADMIN)
		return 1;
    }else{
		return 0;
    }
}

sub getWorkingGroupAnno{
    # Distingish group ADMIN with permission for this working group (Allows successful messages)
    if (!$PRM->{working_group}){
    return 0;
    }else{
 my $sql = "SELECT private_group FROM user_group where user='$PRM->{USERid}' AND (gdb='$GV->{dbTitle}' OR gdb='ALL') AND private_group = '$PRM->{working_group}' AND status='ADMIN'";

    # Checks if the owner (annotator) has chosen a private working group for this annotation (for sendmail)
    # my $sql = "SELECT private_group FROM user_group WHERE private_group='PRM->{working_group}'";
	#my $sql = "SELECT status FROM user_group where user='$PRM->{USERid}' and private_group='$PRM->{working_group}' AND (gdb='$GV->{dbTitle}' OR gdb='ALL') AND (status='ADMIN' or status='USER')";
	my $sql = "SELECT private_group FROM user_group where user='$PRM->{owner}' AND (gdb='$GV->{dbTitle}' OR gdb='ALL') AND (status='ADMIN' or status='USER')";
    my @ref = $GV->{LDBH}->selectrow_array($sql);
    if ($ref[0]){ #if private group
		return 1;
    }else{
		return 0;
    }
   }
}


####################
# Save Admin Comments
####################

sub save_accept_msg(){ # Appended to Description along with date stamp.
    my $emailTXT = $PRM->{emailTXT};
    my $table=$GV->{dbTitle};
    my $user=$PRM->{USERid};
    my $placeholder=$emailTXT;
    my $uid=$PRM->{uid};
#    my $sql = "UPDATE $GV->{dbTitle}.user_gene_annotation set description =concat(IFNULL(concat(description, '\n\n-------\n\n'), ''), 'Curated by ', '$PRM->{USERid}', ' on ', now(), ': ', '$emailTXT')  WHERE uid = $PRM->{uid}";
    my $dbh =  $GV->{LDBH};
	my $sth = $dbh->prepare("UPDATE $table.user_gene_annotation set description =concat(IFNULL(concat(description, '\n\n-------\n\n'), ''), 'Curated by ', '$user', ' on ', now(), ': ', ?)  WHERE uid = $uid");
	$sth->execute($placeholder) || return 0; # returns false if UPDATE failed;


#    my $sth = $GV->{LDBH}->do($sql) || return 0; # returns false if UPDATE failed;
    return $sth;
}

sub save_reject_msg(){
    my $emailTXT = $PRM->{emailTXT}; # Appended to comment along with date stamp.
    
    my $table=$GV->{dbTitle};
    my $user=$PRM->{USERid};
    my $placeholder=$emailTXT;
    my $uid=$PRM->{uid};

 #  my $sql = "UPDATE $GV->{dbTitle}.user_gene_annotation set comment =concat(IFNULL(concat(comment,'\n\n-------\n\n') , ''), 'Curated by ', '$PRM->{USERid}', ' on ', now(), ': ', '$emailTXT')  WHERE uid = $PRM->{uid} ";
    my $dbh =  $GV->{LDBH};
	my $sth = $dbh->prepare("UPDATE $table.user_gene_annotation set comment =concat(IFNULL(concat(comment, '\n\n-------\n\n'), ''), 'Curated by ', '$user', ' on ', now(), ': ', ?)  WHERE uid = $uid");
	$sth->execute($placeholder) || return 0; # returns false if UPDATE failed;
#    my $sth = $GV->{LDBH}->do($sql) || return 0; # returns false if UPDATE failed;
    return $sth; 
}


#####################
# End Save Annotator Comments
#####################

###############################  Email query subroutines  ################################
###########
#JPD: get email(s) that correspond to group ADMIN for this working group.
###########

sub getID(){
my $ID=$GV->{dbTitle};
$ID = substr($ID, 4, 3) + 0;  # gets "3"
return $ID;
}


sub getAdminEmail{  # Returns Admin email string (possibly multiple, comma-separated)
	# 1) Get all emails for admins ; 2)Check their syntax one by one; 3) create a string variable of the email(s) separated by '.'
	my @admin_email_array;
	my $sql = "SELECT email FROM users where account_type='ADMIN'";
	my $admin_email = $GV->{LDBH}->selectall_arrayref($sql);
     for (my $i=0;$i<scalar(@$admin_email);$i++){ 
 		my ($email) = @{$admin_email->[$i]};
		if ( $email =~ /(.+?)@(.+)/){ #check syntax for email address(es)
			push @admin_email_array, $email;
		 }
 	}
   local $" =','; # comma separate array members
   my $admin_email_checked;
   $admin_email_checked =  "@admin_email_array"; # separate with commas for sendmail
 	return $admin_email_checked; #uncomment after debugged.
}

sub getGroupAdminEmail{
	# 1) Get all emails for admins of this working group; 2)Check their syntax one by one; 3) create a string variable of the email(s) separated by '.'
	my @groupadmin_email_array;
	my $sql = "SELECT email FROM users AS a LEFT JOIN user_group AS b ON a.user_name=b.user WHERE b.private_group='$PRM->{working_group}' AND (b.gdb='$GV->{dbTitle}' OR b.gdb='ALL') AND b.status='ADMIN'";
	my $groupadmin_email = $GV->{LDBH}->selectall_arrayref($sql);
     for (my $i=0;$i<scalar(@$groupadmin_email);$i++){ 
 		my ($email) = @{$groupadmin_email->[$i]};
		if ( $email =~ /(.+?)@(.+)/){ #check syntax for email address(es)
			push @groupadmin_email_array, $email;
		 }
 	}
   local $" =','; # comma separate array members
   my $groupadmin_email_checked;
   $groupadmin_email_checked =  "@groupadmin_email_array"; # separate with commas for sendmail
 	return $groupadmin_email_checked; #uncomment after debugged.
}
# now go to GroupAdminNotify and create an email message to (or cc to) $groupadmin_emailchecked

###########################end test subs ########################


############################ AnnotationTool.pm: write the annotation data to the database. Make a unique annotation ID from the prefix ########################
sub addUserAnnotation{
  my ($stat) = @_;
  my $info = $PRM->{info};
  my $strand = ($info =~ /^comp/)? 'r': 'f';
  my ($UAstart) = $info =~ /^[^\d]+(\d+)/;
  my ($UAend) = $info =~ /(\d+)\)+$/;
  $PRM->{mRNAseq} =~ s/\s//g; # no whitespace for sequence entries
  $PRM->{proteinseq} =~ s/\s//g;

  #SELECT LPAD(COUNT(*), 5, '0') FROM user_gene_annotation WHERE dbName='AtGDB' AND dbVer='4';

  my $sth = 0;
  my $sql = "";
  my $gdb_id;
  my $attempt_count = 1;

#   open(DEBUG_FILE, "> /Product/tmp/sql_debug.txt") or die("can't open logfile: $!");

  while ($sth == 0 && $attempt_count < 500) { # in order to arrive at a unique ID that is consecutive and isn't tied to UID, we count rows and test successive additions to that number for uniqueness before we do an INSERT.
    $sql = "SELECT LPAD(COUNT(*) + $attempt_count, 5, '0') FROM $GV->{dbTitle}.user_gene_annotation WHERE dbName=\"$GV->{dbTitle}\" AND dbVer=\"$PRM->{dbVer}\""; # retrieves padded ID, e.g. 00007
    $gdb_id = $GV->{ADBH}->selectrow_array($sql); # e.g. 00007

#sanitize input  12-28-12 JPD
  my $desc = $PRM->{desc};
   $desc =~ s/[']/\\'/g;
   $desc =~ s/["]/\\"/g;
   $desc =~ s/&/\\&/g;
   $desc =~ s/>/\\>/g;
   $desc =~ s/</\\</g;
   
#modifications for xGDBvm have been made to the following (JD):

    $sql = "INSERT INTO $GV->{dbTitle}.user_gene_annotation (USERid,geneId,chr,strand,l_pos,r_pos,gene_structure,description,CDSstart,CDSstop,proteinId,geneAliases,proteinAliases,status,modDate,evidence,annotation_type,mRNAseq,proteinseq,GSeqEdits,organism,dbName,dasCookie,dbVer,annotation_class,locusId,transcriptId,category,working_group, rangeStart, rangeEnd)";
    $sql .= " VALUES (\"$PRM->{USERid}\",CONCAT(\"$PRM->{UCAannid}\", \"$gdb_id\"),\"$PRM->{chr}\",'$strand',$UAstart,$UAend,\"$PRM->{info}\",\"$desc\",'$PRM->{cds_start}','$PRM->{cds_end}',\"$PRM->{prod}\",\"$PRM->{geneAlias}\",\"$PRM->{protAlias}\",'$stat',NOW(),\"$PRM->{Esource}\",\"$PRM->{annotation_type}\",\"$PRM->{mRNAseq}\",\"$PRM->{proteinseq}\",\"$PRM->{GSeqEdits}\",\"$GV->{speciesName}\",\"$GV->{dbTitle}\",\"".cookie("DASsel")."\",\"$PRM->{dbVer}\",\"$PRM->{annotation_class}\",\"$PRM->{locusId}\",\"$PRM->{transcriptId}\",\"$PRM->{category}\",\"$PRM->{working_group}\",$PRM->{start},$PRM->{end});";

#     print STDERR "Trying, attempt count: $attempt_count, \$gdb_id: $gdb_id, geneId: $PRM->{UCAannid}$gdb_id";
#     print DEBUG_FILE "Attempt count: $attempt_count, \$gdb_id: $gdb_id, geneId: $PRM->{UCAannid}$gdb_id";
#     print DEBUG_FILE $sql;
    $sth = $GV->{ADBH}->do($sql); 
    if ($sth == 0) { # INSERT query failed (geneId not unique) 
      $attempt_count++; # in order to increment geneId 
    }
    # print STDERR "\$sth: $sth";
  }

#   close(DEBUG_FILE);

  if ($sth == 0) { # DB Insert failed.
    print STDERR "Failed at annotation insert, attempt count: $attempt_count";
    return 0; # unsuccessful
  }

  # Recalculate Annotation ID name
  $PRM->{UCAannid} .= $gdb_id;

#   $sql = "INSERT INTO user_gene_annotation (USERid,geneId,chr,strand,l_pos,r_pos,gene_structure,description,CDSstart,CDSstop,proteinId,geneAliases,proteinAliases,status,modDate,evidence,annotation_type,mRNAseq,proteinseq,GSeqEdits,organism,dbName,dasCookie,dbVer,annotation_class,locusId,transcriptId,category,working_group)";
#   $sql .= " VALUES (\"$PRM->{USERid}\",\"$PRM->{UCAannid}\",\"$PRM->{chr}\",'$strand',$UAstart,$UAend,\"$PRM->{info}\",\"$PRM->{desc}\",'$PRM->{cds_start}','$PRM->{cds_end}',\"$PRM->{prod}\",\"$PRM->{geneAlias}\",\"$PRM->{protAlias}\",'$stat',NOW(),\"$PRM->{Esource}\",\"$PRM->{annotation_type}\",\"$PRM->{mRNAseq}\",\"$PRM->{proteinseq}\",\"$PRM->{GSeqEdits}\",\"$GV->{speciesName}\",\"$GV->{dbTitle}\",\"".cookie("DASsel")."\",\"$PRM->{dbVer}\",\"$PRM->{annotation_class}\",\"$PRM->{locusId}\",\"$PRM->{transcriptId}\",\"$PRM->{category}\",\"$PRM->{working_group}\");";

#   my $sth = $GV->{ADBH}->do($sql) || return 0; # returns 1 if successful update, 0 if unsuccessful, # geneId is unique index in database
  $sql = "SELECT last_insert_id();";
  my ($id) = $GV->{ADBH}->selectrow_array($sql);
  #print STDERR "SUCCEEDED, uid: $id, attempt count: $attempt_count";
  $PRM->{uid} = $id;
  if ($stat eq "SUBMITTED_FOR_REVIEW"){
  if (getWorkingGroupUser($PRM->{USERid}) && getWorkingGroupAnno()){   ######if user is part of working group and this annotation has been assigned to a working group
    GroupAdminNotify(); # Send email to group admin(s)
    }else{
    AdminNotify();
    }
  }
  return 1; # successful update
}


sub removeAnnotation{
  my ($USERid, $uid) = @_;

  if (($PRM->{owner} eq $PRM->{USERid})||( getUserGroup($PRM->{USERid}) )){ # if owned or isAdmin
    my $sql = "DELETE FROM $GV->{dbTitle}.user_gene_annotation WHERE uid = '$PRM->{uid}'";
    my $sth = $GV->{ADBH}->do($sql) || bailOut("mysql error: $sql");
    return 1;
  }
  bailOut("Delete action not permitted");
}

sub updateAnnotation{
  my ($stat) = @_;
  my $strand = ($PRM->{info} =~ /^comp/)? 'r': 'f';
  my $info = $PRM->{info};
  my ($UAstart) = $info =~ /^[^\d]+(\d+)/;
  my ($UAend) = $info =~ /(\d+)\)+$/;
  $PRM->{mRNAseq} =~ s/\s//g; # no whitespace for sequence entries
  $PRM->{proteinseq} =~ s/\s//g;
  

#sanitize input  12-28-12 JPD
  my $desc = $PRM->{desc};
   $desc =~ s/[']/\\'/g;
   $desc =~ s/["]/\\"/g;
   $desc =~ s/&/\\&/g;
   $desc =~ s/>/\\>/g;
   $desc =~ s/</\\</g;

#modifications for xGDBvm have been made to the following (JD):
  my $sql = "UPDATE $GV->{dbTitle}.user_gene_annotation SET USERid = \"".(($PRM->{owner})?$PRM->{owner}:$PRM->{USERid})."\" ,geneId = \"$PRM->{UCAannid}\", chr =\"$PRM->{chr}\", strand = \"$strand\",l_pos = $UAstart, r_pos = $UAend, gene_structure = \"$PRM->{info}\", description = \"$desc\", CDSstart = \"$PRM->{cds_start}\", CDSstop = \"$PRM->{cds_end}\", proteinId = \"$PRM->{prod}\", geneAliases = \"$PRM->{geneAlias}\", proteinAliases = \"$PRM->{protAlias}\", status = \"$stat\", annotation_type = \"$PRM->{annotation_type}\", mRNAseq = \"$PRM->{mRNAseq}\", proteinseq =\"$PRM->{proteinseq}\", modDate = NOW(), GSeqEdits = \"$PRM->{GSeqEdits}\",evidence = \"$PRM->{Esource}\", dasCookie=\"$PRM->{dasCookie}\", dbVer=\"$PRM->{dbVer}\", annotation_class=\"$PRM->{annotation_class}\", locusId=\"$PRM->{locusId}\", transcriptId=\"$PRM->{transcriptId}\", category=\"$PRM->{category}\", working_group=\"$PRM->{working_group}\", rangeStart = $PRM->{start}, rangeEnd=$PRM->{end} WHERE uid = $PRM->{uid}";
  #$GV->{ADBH}->{RaiseError} = 1;

#   my $debug_sql = "UPDATE user_gene_annotation SET USERid = \"".(($PRM->{owner})?$PRM->{owner}:$PRM->{USERid})."\" ,geneId = \"$PRM->{UCAannid}\", chr =\"$PRM->{chr}\", strand = \"$strand\",l_pos = $UAstart, r_pos = $UAend, gene_structure = \"$PRM->{info}\", description = \"$PRM->{desc}\", CDSstart = \"$PRM->{cds_start}\", CDSstop = \"$PRM->{cds_end}\",\n proteinId = \"$PRM->{prod}\", geneAliases = \"$PRM->{geneAlias}\", proteinAliases = \"$PRM->{protAlias}\", status = \"$stat\", annotation_type = \"$PRM->{annotation_type}\", mRNAseq = \"SHORTENED MRNA SEQUENCE\", proteinseq =\"$PRM->{proteinseq}\", modDate = NOW(), GSeqEdits = \"$PRM->{GSeqEdits}\",evidence = \"SHORTENED EVIDENCE\", dasCookie=\"$PRM->{dasCookie}\", dbVer=\"$PRM->{dbVer}\",\n annotation_class=\"$PRM->{annotation_class}\", locusId=\"$PRM->{locusId}\", transcriptId=\"$PRM->{transcriptId}\", category=\"$PRM->{category}\", working_group=\"$PRM->{working_group}\" WHERE uid = $PRM->{uid}";

# 	open(DEBUG_FILE, "> /Product/tmp/sql_debug.txt") or die("can't open logfile: $!");
#     print STDERR "Trying, geneId: $PRM->{UCAannid}";
#     print DEBUG_FILE "geneId: $PRM->{UCAannid}\n";
#     print DEBUG_FILE $debug_sql; #$sql;
#     print STDERR "\$sth: $sth";

  my $sth = $GV->{ADBH}->do($sql) || return 0;
  
# In development: update project in gdb_projects;
# if ($stat eq "ACCEPTED" && $PRM->{category} != ""){
# my $sql = select uid from yrgate.projects where project_name=\"$PRM->{category}\";
# my $sth = $GV->{DBH}->do($sql) || return 0;
# my @arr = $GV->{DBH}->selectrow_array($sql);
# my $uid = $arr[0];
# my $sql = UPDATE project_names SET project_uid=$uid where project=\"$PRM->{category}\";
# my $sth = $GV->{DBH}->do($sql) || return 0;
  if ($stat eq "SUBMITTED_FOR_REVIEW"){
  if (getWorkingGroupUser($PRM->{USERid}) && getWorkingGroupAnno()){     ######if user is part of working group and this annotation has been assigned to a working group
    GroupAdminNotify(); #email group admin
    }else{
    AdminNotify(); #default - email admin
    }
  }

  return 1; # returns 1 if successful update, 0 if unsuccessful, # geneId is unique index in database
}

sub loadUCA {
# loads UCA values from database
# Changing this list of variables? Need to change individual GDB yrgate config files accordingly! (/yrGATE/conf_XxGDB/yrGATE_conf.pl)

#modifications for xGDBvm have been made to the following (JD):
  my $ucaQuery=qq{
		  SELECT uid,USERid,geneId,proteinId,chr,strand,l_pos,r_pos,gene_structure,description,comment,geneAliases,proteinAliases,CDSstart,CDSstop,status,DATE_FORMAT(modDate,'\%W, \%M \%d, \%Y'),DATE_FORMAT(modDate,'\%r'),evidence,mRNAseq,proteinseq,GSeqEdits,organism,dasCookie,dbVer,annotation_class,locusId,transcriptId,category,working_group, rangeStart, rangeEnd
		  FROM $GV->{dbTitle}.user_gene_annotation
		  WHERE uid = "$PRM->{uid}"
		 };
  my @arr = $GV->{ADBH}->selectrow_array($ucaQuery);
  if ( $#arr < 0 ){
      return 0;
  }

  my ($uid,$USERid,$geneId,$proteinId,$chr,$strand,$l_pos,$r_pos,$gene_structure,$desc,$comment,$geneAliases,$proteinAliases,$cds_start,$cds_end,$status,$modDate,$modTime,$Esource,$mRNA,$protein,$GSeqEdits,$organism,$dasCookie,$dbVer,$annotation_class,$locusId,$transcriptId,$category,$working_group, $rangeStart, $rangeEnd) = @arr;

  $PRM->{owner} = $USERid;
  $PRM->{uid} = $uid;
  $PRM->{UCAannid} = $geneId;
  $PRM->{chr} = $chr;
  $PRM->{strand} = $strand;
  $PRM->{info} = $gene_structure;
  $PRM->{desc} = $desc;
  $PRM->{comment}=$comment;
  $PRM->{Esource} = $Esource;
  $PRM->{geneAlias} = $geneAliases;
  $PRM->{protAlias} = $proteinAliases;
  $PRM->{prod} = $proteinId;
  $PRM->{modifyState} = $status;
  $PRM->{modDate} = $modDate;
  $PRM->{modTime} = $modTime;
  $PRM->{status} = $status;
  #($PRM->{start},$PRM->{end}) = $gene_structure =~ /\((\d+).+?(\d+)\)/; #jd ahah! I think if I change this I can effect a load of a region defined gy rangeStart and rangeEnd.

  $PRM->{cds_start} = $cds_start;
  $PRM->{cds_end} = $cds_end;
  $PRM->{mRNAseq} = $mRNA;
  $PRM->{proteinseq} = $protein;
  $PRM->{GSeqEdits} = $GSeqEdits;
  $PRM->{organism} = $organism;
  $PRM->{dasCookie} = $dasCookie;  # only for das input
  $PRM->{dbVer} = $dbVer;
  $PRM->{annotation_class} = $annotation_class;
  $PRM->{locusId} = $locusId;
  $PRM->{transcriptId} = $transcriptId;
  $PRM->{category} = $category;
  $PRM->{working_group} = $working_group;
  $PRM->{rangeStart} = $rangeStart;
  $PRM->{rangeEnd} = $rangeEnd;
  $PRM->{start} = $rangeStart; #jd test
  $PRM->{end} = $rangeEnd; #jd test
# Changing this list of variables? Need to change individual GDB yrgate config files accordingly! (/yrGATE/conf_XxGDB/yrGATE_conf.pl)

  return 1;
}

########################################
### end Database
########################################

####################################################################
# General Functions
####################################################################

    #############################################################################################
    # USER (NO GROUP) CURATION OUTCOME: sends email From: Curator To: Annotator and Cc: Administrators indicating the curation result (ACCEPT or REJECT)
    ############################################################################################# 
sub extraAdminSubmit{
#    if (!$GV->{email}){ # no longer global variable; mysql instead
#		return;
 #   }
    
#  my $AdminEmail = $GV->{AdminEmail}; deprecated; this is now in MySQL tables: Admin.admin (overall admin)
#### get global admin email####
#    my $sql = "SELECT GROUP_CONCAT(yrgate_email) FROM admin";
#    my @ref = $GV->{ADMDBH}->selectrow_array($sql);
#    my $AdminEmail=$ref[0];

# the following is work in progress 4-11-13
	my $USERid=getUserId();
    my $sql = "SELECT fullname,email FROM users WHERE user_name = '$USERid' ";
    my $ref = $GV->{LDBH}->selectall_arrayref($sql);
    my $curatorName = $ref->[0]->[0];
    my $curatorEmail = $ref->[0]->[1];   
    my $AdminEmail = getAdminEmail(); # one or more (comma separated) admin emails, local to GDB or global
# end work in progresss	
#### get other data and construct email #####
    my $emailTXT = $PRM->{emailTXT};
    my $sql = "SELECT fullname,email FROM users WHERE user_name = '$PRM->{owner}' ";
    my $ref = $GV->{LDBH}->selectall_arrayref($sql);
    my $userName = $ref->[0]->[0]; #fullname
    my $userEmail = $ref->[0]->[1];  #email
    if ( ($userEmail =~ /(.+?)\@(.+)/) && ($AdminEmail =~ /(.+?)\@(.+)/ ) ){ # email address check, send will crash if email address is not in correct format. Group Admin email(s) already checked
    open(MAIL, "| /usr/sbin/sendmail -t");
    my $mailTXT .= "To: $userEmail\n";
    $mailTXT .= "From: \n";
	$mailTXT .= "Cc: $AdminEmail\n"; # send copies to all Admins
    $mailTXT .= "Subject:";
    $mailTXT .= ($PRM->{status} eq "ACCEPTED") ? "Accepted" : "Rejected";
    $mailTXT .= " Community Annotation at $GV->{dbTitle}\n\n";
    $mailTXT .= "Dear $userName, \n\n";
    $mailTXT .= "Your annotation $PRM->{UCAannid} has been ";
    $mailTXT .= ($PRM->{status} eq "ACCEPTED") ? "accepted.\n\n" : "rejected.  \n\n";
    $mailTXT .= "Administrator comments:\n-------------------------------\n $emailTXT \n-------------------------------\n";
    $mailTXT .= "Please address any questions to $curatorName, yrGATE Administrator ($curatorEmail) \n\n";
#    $mailTXT .= "Gene Annotation: <a href=''>$PRM->{UCAannid}</a>\n";
    $mailTXT .= "$GV->{dbTitle} Region: ".(&{$GV->{GenomeContextLinkFunction}}($PRM->{chr},$PRM->{start},$PRM->{end},$PRM->{dbVer}))."\n\n";
    $mailTXT .= "Thank you for submitting a gene annotation to the $GV->{dbTitle} Community Annotation Project.\n\n\n";

    print MAIL $mailTXT;
    close(MAIL);

    } # end if valid email address
    return;

}

    #############################################################################################
    # USER (USING GROUP) CURATION OUTCOME: sends email From: Curator To: Annotator (Group Member) and Cc to Group Admin indicating the curation result (ACCEPT or REJECT)
    ############################################################################################# 

sub extraGroupAdminSubmit{
#    if (!$GV->{email}){ # no longer global variable; mysql instead
#		return;
 #   }
    if (!getGroupAdminEmail()){
   	return;
    }
#### get contact data and construct email #####

	my $USERid=getUserId(); # The admin curator using this form
    my $sql = "SELECT fullname,email FROM users WHERE user_name = '$USERid' ";
    my $ref = $GV->{LDBH}->selectall_arrayref($sql);
    my $curatorName = $ref->[0]->[0];
    my $curatorEmail = $ref->[0]->[1];   
	my $GroupAdminEmail = getGroupAdminEmail(); # one or more (comma separated) admin emails, local to GDB or global (if only one, then GroupAdminEmail=curatorEmail)
    my $emailTXT = $PRM->{emailTXT};
    my $sql = "SELECT fullname,email FROM users WHERE user_name = '$PRM->{owner}' "; # the user who submitted the annotation
    my $ref = $GV->{LDBH}->selectall_arrayref($sql);
    my $userName = $ref->[0]->[0]; #fullname
    my $userEmail = $ref->[0]->[1];  #email
    if ($userEmail =~ /(.+?)\@(.+)/){ # email address check, send will crash if email address is not in correct format. Group Admin email(s) already checked in the function getGroupAdminEmail
    open(MAIL, "| /usr/sbin/sendmail -t");
    my $mailTXT .= "To: $userEmail\n";
    $mailTXT .= "Cc: $GroupAdminEmail\n";
    $mailTXT .= "From: \n";
    $mailTXT .= "Subject:";
    $mailTXT .= ($PRM->{status} eq "ACCEPTED") ? "Accepted" : "Rejected";
    $mailTXT .= " Community Annotation at $GV->{dbTitle}\n\n";
    $mailTXT .= "Dear $userName, \n\n";
    $mailTXT .= "Your annotation $PRM->{UCAannid} has been ";
    $mailTXT .= ($PRM->{status} eq "ACCEPTED") ? "accepted.\n\n" : "rejected.  \n\n";
    $mailTXT .= "Administrator comments:\n-------------------------------\n $emailTXT \n-------------------------------\n";
    $mailTXT .= "Please address any questions to $curatorName, yrGATE Group Administrator ($curatorEmail) \n\n";
#    $mailTXT .= "Gene Annotation: <a href=''>$PRM->{UCAannid}</a>\n";
    $mailTXT .= "$GV->{dbTitle} Region: ".(&{$GV->{GenomeContextLinkFunction}}($PRM->{chr},$PRM->{start},$PRM->{end},$PRM->{dbVer}))."\n\n";
    $mailTXT .= "Thank you for submitting a gene annotation to the $GV->{dbTitle} Community Annotation Project.\n\n\n";

    print MAIL $mailTXT;
    close(MAIL);

    } # end if valid email address
    return;

}


   ######################################################################################################################################## 
    # ADMIN NOTIFY IF SUBMITTED ANNO: (default) sends email to Administrator(s) notifying them of the submitted annotation and providing separate links for curation.
   ########################################################################################################################################
   
   sub AdminNotify{
	my $AdminEmail = getAdminEmail(); # one or more email addresses, comma separated (checked within the function for validity)
    my $emailTXT = $PRM->{emailTXT};
    if ($AdminEmail){ # admin email address exists
    open(MAIL, "| /usr/sbin/sendmail -t");
    my $mailTXT .= "To: $AdminEmail\n";
    $mailTXT .= "From: \n";
    $mailTXT .= "Subject: New User Contributed Annotation at $GV->{dbTitle} to be Reviewed\n\n";
    $mailTXT .= "Administrators,\n\n ";
    $mailTXT .= "Please review this new User Contributed Annotation, $PRM->{UCAannid} (uid=$PRM->{uid}), at $GV->{dbTitle}, submitted by $PRM->{USERid}.\n\n";
    $mailTXT .= "$GV->{dbTitle} Region: ".(&{$GV->{GenomeContextLinkFunction}}($PRM->{chr},$PRM->{start},$PRM->{end},$PRM->{dbVer}))."\n\n";
    $mailTXT .= "Administration Checkout (login required) ".$GV->{rootPATH}.$GV->{CGIPATH}."AdminAnnotation.pl\n\n";
    print MAIL $mailTXT;
    close(MAIL);

    } # end if valid email address
    return;

}

   ######################################################################################################################################## 
    # GROUP ADMIN NOTIFY: If submitted under a private group, sends email to Group Admin and Cc to Administrator(s) notifying them of the submitted annotation and providing separate links for curation.
   ########################################################################################################################################

sub GroupAdminNotify{
     if (!$GV->{email}){
 		return;
     }
    if (!getGroupAdminEmail()){
   		 return;
    }
	my $AdminEmail = getAdminEmail();
	my $GroupAdminEmail = getGroupAdminEmail();
    my $emailTXT = $PRM->{emailTXT};
    if ($AdminEmail){ # IF admin email address present (format for GroupAdminEmail has already been checked in the function).
     open(MAIL, "| /usr/sbin/sendmail -t");
     my $mailTXT .= "To: $GroupAdminEmail\n";
     $mailTXT .= "From: \n";
     $mailTXT .= "Subject: New User Contributed Annotation at $GV->{dbTitle} (Group: $PRM->{working_group}) to be Reviewed\n\n";
     $mailTXT .= "Group Administrators,\n\n";
     $mailTXT .= "Please review this new User Contributed Annotation $PRM->{UCAannid} (uid=$PRM->{uid}), at $GV->{dbTitle}, submitted by $PRM->{USERid} from Working Group \"$PRM->{working_group}\".\n\n";
     $mailTXT .= "$GV->{dbTitle} Region: ".(&{$GV->{GenomeContextLinkFunction}}($PRM->{chr},$PRM->{start},$PRM->{end},$PRM->{dbVer}))."\n\n";
     $mailTXT .= "Group Administration Checkout (login required) ".$GV->{rootPATH}.$GV->{CGIPATH}."AdminAnnotationGroup.pl\n\n";
     print MAIL $mailTXT;
     close(MAIL);

     } # end if valid email address
     return;
 }




sub PasswordNotify{

   my ($submitted_email,$new_passwd) = @_;
   if ($submitted_email eq "" || $new_passwd eq ""){ # Bad input
       return 0;
   }

   my $reset_passwd_sql = "SELECT uid, email, user_name, fullname FROM users WHERE email = '$submitted_email'";
   my $reset_passwd_ref = $GV->{LDBH}->selectall_arrayref($reset_passwd_sql);

   my ($uid,$email,$user_name,$fullname) = @{$reset_passwd_ref->[0]};
   if ($email ne $submitted_email) { # Email not in database
      return 0;
   }

   my $range = 1000000000;
   my $random_number = int(rand($range));

   $reset_passwd_sql = "UPDATE users SET pword_new = password('$new_passwd'), pword_confirm_key = '$random_number' WHERE uid = '$uid';";
   my $sth = $GV->{LDBH}->do($reset_passwd_sql);

    if ( ($email =~ /(.+?)\@(.+)/ ) ){ # email address check, send will crash if email address is not in correct format

    open(MAIL, "| /usr/sbin/sendmail -t");

    my $mailTXT .= "To: $email\n";
    $mailTXT .= "From:\n";
    $mailTXT .= "Subject: yrGATE Password Reset Confirmation\n\n";

    $mailTXT .= "Somebody, hopefully you, has requested a new yrGATE password for your email address ($email).\n";
    $mailTXT .= "The user name for this account, used to log in, is \"$user_name\". If you want your new password to be \"$new_passwd\", please follow this link: http://$ENV{SERVER_NAME}$GV->{CGIPATH}loginReset.pl?mode=confirm_reset&email=$email&confirm_key=$random_number\n\n";
    $mailTXT .= "Alternatively, you can fill in your email address and use this confirmation number: $random_number\nThen, click the \"Confirm Password Reset\" button.\n\n";

    $mailTXT .= "If you did not request a password reset, you can safely ignore this message. Please contact us if this happens repeatedly.";

    print MAIL $mailTXT;
    close(MAIL);
    }
    return 1;
}

sub PasswordConfirm{

   my ($submitted_email,$confirm_key) = @_;
   if ($submitted_email eq "" || $confirm_key eq ""){ # Bad input
       return 0;
   }

   my $reset_passwd_sql = "SELECT uid, email, user_name, fullname FROM users WHERE email = '$submitted_email' AND pword_confirm_key = '$confirm_key'";
   my $reset_passwd_ref = $GV->{LDBH}->selectall_arrayref($reset_passwd_sql);

   my ($uid,$email,$user_name,$fullname) = @{$reset_passwd_ref->[0]};
   if ($email ne $submitted_email) { # Email not in database
      return 0;
   }


   $reset_passwd_sql = "UPDATE users SET pword = pword_new, pword_new = NULL, pword_confirm_key = NULL, pword_reset_attempts = pword_reset_attempts + 1 WHERE email = '$email' AND pword_confirm_key = '$confirm_key'";
   my $sth = $GV->{LDBH}->do($reset_passwd_sql);

    if ( ($email =~ /(.+?)\@(.+)/ ) ){ # email address check, send will crash if email address is not in correct format

    open(MAIL, "| /usr/sbin/sendmail -t");

    my $mailTXT .= "To: $email\n";
    $mailTXT .= "From:\n";
    $mailTXT .= "Subject: yrGATE Password Updated\n\n";

    $mailTXT .= "Your yrGATE password for the email address ($email) has been changed.\n";
    $mailTXT .= "Your user name, which you'll use to log in, is \"$user_name\". Please refer to our previous email for your password. Thank you for using yrGATE!\n\n";

    $mailTXT .= "Follow this link to get back to yrGATE: http://$ENV{SERVER_NAME}$GV->{CGIPATH}login.pl\n\n";

    $mailTXT .= "PlantGDB\n";

    print MAIL $mailTXT;
    close(MAIL);
    }
    return 1;
}

sub printToFile{
  my ($content, $location) = @_;
  open (MYFILE, '>'.$location);
  print MYFILE $content;
  close(MYFILE);
}

sub printEditLink{
  # add init function to establish global log in parameters?
  my $link = ($PRM->{USERid} eq $PRM->{owner} || $PRM->{status} ne "ACCEPTED") ? "<a href='$GV->{CGIPATH}AnnotationTool.pl?uid=$PRM->{uid}$GV->{tmpLinkParam}' target='_blank'>edit</a>" : "";
}

sub printAnnotation{
  my $info = $PRM->{info};
  my $strand = ($info =~ /^comp/)? 'r': 'f';
  my ($UAstart) = $info =~ /^[^\d]+(\d+)/;
  my ($UAend) = $info =~ /(\d+)\)+$/;
  my $modifyDate = ($PRM->{modDate}) ? $PRM->{modDate} : localtime(time);
  my $pcr = ($PRM->{cds_start}) ? "$PRM->{cds_start}-$PRM->{cds_end}" : "";
  my $org = $PRM->{organism} || $GV->{speciesName};
  my $ps = $PRM->{proteinseq}; # removes line breaks when called from AnnotationTool.pl
  $ps =~ s/\W//g;
  my $ns = $PRM->{mRNAseq};
  $ns =~ s/\W//g;

  my $txt =<<END_TXT;
Gene Name\t$PRM->{UCAannid}
Annotator\t$PRM->{USERid}
Modify Date\t$modifyDate
Organism\t$org
Chromosome/Genome Segment\t$PRM->{chr}
Strand\t$strand
Left Position\t$UAstart
Right Position\t$UAend
Gene Structure\t$PRM->{info}
Protein Coding Region\t$pcr
mRNA sequence\t$ns
Protein Sequence\t$ps
Description\t$PRM->{desc}
Exon Origins\t$PRM->{Esource}
Putative Protein Product\t$PRM->{prod}
Gene Aliases\t$PRM->{geneAlias}
Protein Aliases\t$PRM->{protAlias}
Genome Sequence Edits\t$PRM->{GSeqEdits}

END_TXT

    return $txt;
}

sub printDetail{
  my $info = $PRM->{info};
  my $strand = ($info =~ /^comp/)? 'r': 'f';
  my ($UAstart) = $info =~ /^[^\d]+(\d+)/;
  my $UAstart_pad = $UAstart -1000;
  my ($UAend) = $info =~ /(\d+)\)+$/;
  my $UAend_pad = $UAend + 1000;
  my $modifyDate = ($PRM->{modDate}) ? "$PRM->{modDate} $PRM->{modTime}": strftime( "%A, %B %d, %Y",localtime(time));
  my $pcr = ($PRM->{cds_start} > 0) ? "$PRM->{cds_start}-$PRM->{cds_end}" : "";
  my $esource_links = $PRM->{Esource};
  $esource_links =~ s/<newline>/\n/g;
  $esource_links = escapeHTML($esource_links);
#  $esource_links =~ s/(http:.+?)([<\s])/<a href="$1">$1<\/a>$2/g;
  $esource_links =~ s/(http:\S+)/<a class="hidelinkicon" href="$1">(View Parent Data)<\/a> /g;
  my $org = $PRM->{organism} || $GV->{speciesName};
  my $pf = strToFASTA($PRM->{proteinseq});
  my $nf = strToFASTA($PRM->{mRNAseq});
  my $gdblink = $PRM->{chr},$PRM->{start},$PRM->{end},$PRM->{dbVer};

  # Next section (4 lines) ripped from another part of this file. dhrasmus.
	#my @evidence = split /<newline>/, $PRM->{Esource};
	#for my $i (@evidence){
	#my ($start,$end,$method,$score,$dbName,$id1,$id2,$ref_url) = split /\s/, $evidence[0]; #$i;
	#}

  # Next 3 lines taken from xgdb_functions.pl . dhrasmus.
	my ($chr,$lp,$rp,$dbVer) = @_;
	my $link = "$GV->{rootPATH}$GV->{SSIpath}";
	$link .= ($GV->{CHR_SELECT_BOX} != 0) ? "getRegion.pl?dbid=$PRM->{dbVer}&amp;chr=$PRM->{chr}&amp;l_pos=$UAstart_pad&amp;r_pos=$UAend_pad" : "getGSEG_Region.pl?dbid=$PRM->{dbVer}&amp;gseg_gi=$PRM->{chr}&amp;bac_lpos=$UAstart&amp;bac_rpos=$UAend";

   # added JD
   my $seq_length = length($PRM->{mRNAseq});
   my $prot_length = length($PRM->{proteinseq})-1;

	#added JD - displays link to that region that this annotation maps to on a newer assembly  - based on chr_version_map table.
 my $sql = "SELECT dbName, new_dbVer, new_chr, new_l_pos, new_r_pos FROM chr_version_map WHERE geneId = '$PRM->{UCAannid}'";
 my @arr = $GV->{LDBH}->selectrow_array($sql);
 my $GDB = $arr[0];
 my $new_dbVer = $arr[1];
 my $new_chr = $arr[2];
 my $new_l_pos = $arr[3];
 my $new_l_pos_pad = $new_l_pos-1000;
 my $new_r_pos = $arr[4];
 my $new_r_pos_pad = $new_r_pos+1000;
 my $new_link = "";
 # added JD blast to GDB
 my $blast_rna = "<a class=\"indent normalfont\" href=\"/$GV->{dbTitle}/cgi-bin/blastGDB.pl?db=&amp;dbid=$PRM->{dbVer}&amp;query=yrGATE&amp;name=$PRM->{UCAannid}&amp;seq=$PRM->{mRNAseq}\"><span class=\"inverse_link\">Blast &#64;$GV->{dbTitle}</span></a>";
 my $blast_prot = "<a class=\"indent normalfont\" href=\"/$GV->{dbTitle}/cgi-bin/blastGDB.pl?db=&amp;dbid=$PRM->{dbVer}&amp;query=yrGATE&amp;name=$PRM->{UCAannid}&amp;seq=$PRM->{proteinseq}\"><span class=\"inverse_link\">Blast &#64;$GV->{dbTitle}</span></a>";


 if ( $new_chr != ""){
 $new_link = "<div class=\"annofeature\"><h2><span class=\"attention_text\">NOTE:</span> Outdated Genome Assembly!</h2><p style=\"margin-left:20px\">View / annotate this locus in the current genome assembly: <a title=\"Link to region in newer assembly\" target=\"_blank\" href= \"/$GDB/cgi-bin/getRegion.pl?dbid=$new_dbVer&amp;chr=$new_chr&amp;l_pos=$new_l_pos_pad&amp;r_pos=$new_r_pos_pad\"> $new_chr: $new_l_pos .. $new_r_pos</a><br />(the new locus coordinates were determined with blastn using the unspliced transcript sequence as query) </p></div>";
 }
 
   my $txt =<<END_TXT;
 <h2 class="topmargin2">$GV->{dbTitle} <span class="italic">($org)</span> ID: <span class="attention_text"> $PRM->{UCAannid} </span>  $PRM->{owner} <span class="$PRM->{status}"> $PRM->{status}</span> <span class="info"> Last modified: $PRM->{modDate}<a class="hidelinkicon indent normalfont" target="_blank" title="View this annotation in genome context" href="$link">[View at $GV->{dbTitle}]</a>
<a class=\"normalfont\" title='Download GFF3-formatted file of this annotation' target='_blank' href='$GV->{CGIPATH}AnnotationExport.pl?uid=$PRM->{uid}&amp;html=1&amp;format=gff3&amp;html=1'>[Download GFF3]</a>
</span></h2>

<div class="annofeature">

<table class='mainT'>
<col width='10%'/><col width='10%'/><col width='10%'/><col width='10%'/><col width='10%'/><col width='10%'/><col width='10%'/><col width='10%'/><col width='10%'/><col width='10%'/><col width='10%'/><col width='10%'/><col width='10%'/>
<tr class='headRow'>
<th title="Does the annotation correct, confirm, add splicing variant or suggest deletion of existing gene model?">Anno Class</th>
<th title="The ID of the locus being annotated (either existing or new locus)">Locus ID</th>
<th title="The ID of the transcript being annotated (if any)">Transcript ID</th>
<th title="If this locus corresponds to a known gene, the accepted gene alias or abbreviation">Gene Alias</th>
<th title="If this locus encodes a known protein, the accepted protein alias or abbreviation">Protein Alias</th>
<th title="If protein coding gene, name of putative protein product">Protein Product</th>
<th title="Chromosome or BAC/Scaffold and left-right coordinates">Genome Segment</th>
<th title="Strand of the annotation, either forward or reverse">Str</th>
<th title="Genome database version; 0 is earliest">DB Ver</th>
<th title="Location and type of any genome sequence edits associated with this annotation">Genome Edits</th>
<th title="User-assigned category for this annotation">Category</th>
<th title="User-assigned working group for this annotator">Working Group</th>
</tr>

<tr class='recordRow'>

<td>$PRM->{annotation_class}</td>
<td>$PRM->{locusId}</td>
<td>$PRM->{transcriptId}</td>
<td>$PRM->{geneAliases}</td>
<td>$PRM->{proteinAliases}</td>
<td>$PRM->{prod}</td>
<td><b>$PRM->{chr}: </b>$UAstart..$UAend</td>
<td>$strand</td>
<td>$PRM->{dbVer}</td>
<td><pre>$PRM->{GSeqEdits}</pre></td>
<td>$PRM->{category}</td>
<td>$PRM->{working_group}</td>
</tr>
</table>
</div>

 $new_link

<div class="annofeature" style="width:1000px;">
<h2 class="bottommargin1">Description</h2>
<div class="indent2">
<textarea rows='5' cols='100' style="padding:20px;" >$PRM->{desc}</textarea>
</div>
</div>

<div class="annofeature" style="width:1000px; overflow: auto">
<h2 class="bottommargin1">Gene Structure</h2>
<div class="indent2">
<textarea rows='5' cols='100' style="padding:20px;" >$PRM->{info}</textarea>
</div>
</div>

<div class="annofeature">
<h2 class="bottommargin1">Protein Coding Region</h2>
<span class="indent">$pcr</span>
</div>

<div class="annofeature">
<h2 class="bottommargin1">mRNA sequence <span class="info">($seq_length bp)</span> $blast_rna</h2>
<div class="indent2" id="protein_sequence">
<textarea rows='10' cols='100' style="padding:20px;" >$nf</textarea>
</div>
</div>

<div class="annofeature">
<h2 class="bottommargin1">Protein Sequence <span class="info">($prot_length aa)</span> $blast_prot</h2>
<div class="indent2" id="protein_sequence">
<textarea rows='10' cols='100' style="padding:20px;" >
$pf
</textarea>
</div>
</div>


<div class="annofeature">
<h2 class="bottommargin1">Exon Origins</h2>
<div class="indent2">
<pre>&nbsp;[start][stop][source of exon][score][database name][parent unique Id][parent name][link to parent]</pre>
<div style="height:100px; width:800px; overflow:auto; border: 1px solid #CCC; text-align:left" id="exon_origins">
<pre class="indent">$esource_links</pre>
</div>
</div>
</div>



END_TXT

return $txt;

}

sub seqToFASTA{
    my ($seqType) = @_;
    my $str .= ($seqType eq "p") ? strToFASTA($PRM->{proteinseq}) : strToFASTA($PRM->{mRNAseq});
    if ($str ne ""){
      $str = ">yrGATE|$PRM->{uid}|$PRM->{UCAannid}\n$str";
    }
    return $str;
}

sub strToFASTA{
    my ($seq) = @_;
    my $str;
    my $linelength = 60;
    for (my $i=0;$i<length($seq)/$linelength;$i++){
	$str .= substr($seq,$i*$linelength,$linelength)."\n";
    }
    #$str .= substr($seq,int(length($seq)/$linelength)*$linelength,length($seq))."\n";
    return $str;

}


sub yrgateToGFF3{
#GFF3 format defined at http://song.sourceforge.net/gff3.shtml
#[seqid] [source] [type] [start] [end] [score] [strand] [phase] [attributes]
#attributes = id,name,alias,parent,target,note,Dbxref,Evidence_for,Organism,Substituted_sequence,Inserted_sequence
#   Evidence_for,Organism is novel attribute for yrGATE GFF export
#types = gene,mRNA,exon,CDS,region,insertion,deletion,substitution

my ($local_uidRef) = @_;

my $fields_legal_regex = "[a-zA-Z0-9. :^*$@!+_?-]";
my $seqid_legal_regex = "[a-zA-Z0-9.:^*$@!+_?-|]";

my %local_uid = %$local_uidRef;
my @gff;
my $strand = ($PRM->{strand} eq "f") ? "+" : "-";

my $seq_id = $PRM->{chr};

# sequence edits
if ($PRM->{GSeqEdits}){
    # add note to GFF file
    $gff[++$#gff] = ["\#note: the genome segment for the following gene annotation has been edited"];
    $gff[++$#gff] = ["\#note: see /yrGATE/genome_edits.txt for further description"];


    my $region_id = "region".(($local_uid{'region'}) ? $local_uid{'region'}++ : 1);
    my $region_attrib = "ID=$region_id;Name=$region_id;Organism=$PRM->{organism};Submitted_by=$PRM->{USERid}";
    # start is always 1 of edited regions
    $gff[++$#gff] = [escape_fields($PRM->{chr},'yrGATE','region','1',$PRM->{end},'.',$strand,'.',$region_attrib)];
    $seq_id = $region_id;
    my @edits = split /\n/, $PRM->{GSeqEdits};
    for my $i (@edits){
	    #chop $i; # ^M character
	    my @f = split /\,/, $i;
	    $f[2] =~ s/\W//; # any trailing characters
	    my $edit_type = ($f[1] eq "change") ? "substitution" : ($f[1] eq "insert") ? "insertion" : "deletion";
	    # start = end,  except insertions greater than length 1
  	    my $edit_length = (length($f[2]) > 1 and $edit_type eq "substitution") ? length($f[2]) : 0;
	    my $edit_id = "sequence_edit".(($local_uid{'edit'}) ? $local_uid{'edit'}++ : 1);
	    my $edit_attrib = "ID=$edit_id;Name=$edit_id;Parent=$region_id;";
	    if ($edit_type eq "insertion"){
		$edit_attrib .= "Inserted_sequence=$f[2];";
	    }elsif($edit_type eq "substitution"){
		$edit_attrib .= "Substituted_sequence=$f[2];";
	    }
	    $gff[++$#gff] = [escape_fields($region_id,'yrGATE',$edit_type,$f[0],($f[0]+$edit_length),'.',$strand,'.',$edit_attrib)];
    }
}



my $gene_id = "gene".( ($local_uid{'gene'}++ == 0) ? 1 : $local_uid{'gene'});
my $gene_attrib = "ID=$gene_id;Name=$PRM->{UCAannid};Organism=$PRM->{organism};Submitted_by=$PRM->{owner}";

my $min = $PRM->{end};
my $max = $PRM->{start};
my @exons = $PRM->{info} =~ /\d+\.\.\d+/g;
for my $i (@exons){
    my ($start,$end) = split /\.\./, $i;
    if ($start < $min) {
        $min = $start;
    }
    if ($end > $max) {
        $max = $end;
    }
}

$gff[++$#gff] = [escape_fields($seq_id,'yrGATE','gene',$min,$max,'.',$strand,'.',$gene_attrib)];
#jfd commented the below, added the above to adjust gene start, stop
#$gff[++$#gff] = [escape_fields($seq_id,'yrGATE','gene',$PRM->{start},$PRM->{end},'.',$strand,'.',$gene_attrib)];

my %exon_idHash;
# add sequence edits


# for exons
my @exons = $PRM->{info} =~ /\d+\.\.\d+/g;

my @CDSgff;
my $extra = 0; # first CDS has phase 0
for my $i (@exons){
    my ($start,$end) = split /\.\./, $i;
    my $exon_id = "exon".( ($local_uid{'exon'}++ == 0) ? 1 : $local_uid{'exon'});
    $exon_idHash{"$start..$end"} = $exon_id;
    my $exon_attrib = "ID=$exon_id;Parent=$gene_id";
    $gff[++$#gff] = [escape_fields($seq_id,'yrGATE','exon',$start,$end,'.',$strand,'.',$exon_attrib)];
    # if CDS overlap
    if (min($PRM->{cds_start},$PRM->{cds_end}) <= $end && max($PRM->{cds_start},$PRM->{cds_end}) >= $start){
        my $cds_id = "CDS".( ( $local_uid{'cds'}++ == 0 ) ? 1 : $local_uid{'cds'} );
	my $cds_attrib = "ID=$cds_id;Parent=$gene_id;Name=$PRM->{prod};";
	my $cds_start = (min($PRM->{cds_start},$PRM->{cds_end}) <= $start) ? $start : min($PRM->{cds_start},$PRM->{cds_end});
	my $cds_end = ( max($PRM->{cds_start},$PRM->{cds_end}) <= $end) ? max($PRM->{cds_start},$PRM->{cds_end}) :  $end;

	$CDSgff[++$#CDSgff] = [escape_fields($seq_id,'yrGATE','CDS',$cds_start,$cds_end,'.',$strand,$extra,$cds_attrib)];

        $extra =  3 - ( $cds_end - $cds_start + 1 - $extra) % 3;  # bases remaining for last codon

        if ($extra == 3){
	    $extra = 0;
	}
    }
}
push @gff,@CDSgff;

if (1){
# add exon_origins
my @evidence = split /<newline>/, $PRM->{Esource};
for my $i (@evidence){
    my ($start,$end,$method,$score,$dbName,$id1,$id2,$ref_url) = split /\s/, $i;
    my $ev_id = "evidence".(($local_uid{'ev'}++ == 0) ? $local_uid{'ev'}++: $local_uid{'ev'});
    my $ev_attrib = "ID=$ev_id;Evidence_for=".$exon_idHash{min($start,$end)."..".max($start,$end)}.";";
    #add Target, DBxref attributes
    $gff[++$#gff] = [escape_fields($seq_id,$dbName,$method,min($start,$end),max($start,$end),$score,$strand,'.',$ev_attrib)];
}
}

my $gff3;
for my $j (@gff){
    $gff3 .= join("\t",@$j)."\n";
}
return ($gff3,\%local_uid);
}

sub escape_fields{
    # escapes fields for gff3
    my @fields = @_;
    my @escaped_fields = @fields;
    return @fields;
}


my ($CHR_SELECT_BOX,$RangeChrFIELD);

sub getExons{
# adds array of evidence to eH and EV
# eH organizes data keyed by exon
# EV organizes data keyed by evidence type
#
# returns reference to eH

my ($ref,$seqType,$color,$evidenceHashRef) = @_; #[reference to array of evidence], [current evidenceHash reference], [type of evidence]
my %eH = %$evidenceHashRef;
for (my $i=0;$i<scalar(@{$ref});$i++){
  my ($dbName,$exon_method,$seqName,$seqId,$exon_start,$exon_stop,$exon_score,$exon_num,$exon_link,$seqStrand) = @{$ref->[$i]};

  #if ((min($exon_start,$exon_stop) >= $zeroPos)&&(max($exon_start,$exon_stop) <= $PRM->{end} )){ # exons within window
  if (1){
  my $eKey = "$exon_start  $exon_stop"; # two spaces for exon key

  if ($eH{$eKey}){
    $eH{$eKey}->{maxScore} = ($exon_score > $eH{$eKey}->{maxScore}) ? $exon_score :  $eH{$eKey}->{maxScore};
    $eH{$eKey}->{members}->{"$seqId"} = {
											name   => $seqName,
											score  => $exon_score,
											number => $exon_num,  # not used so far
											method => $exon_method,
											link   => $exon_link,
											dbName => $dbName
                                        };
  }else{
      $eH{$eKey} = {
		maxScore => $exon_score,
		members  => {
					"$seqId"=>{
						name   => $seqName,
						score  => $exon_score,
						number => $exon_num,
						method  => $exon_method,
						link   => $exon_link,
						dbName => $dbName,
						containedInRange => ((min($exon_start,$exon_stop) >= $zeroPos)&&(max($exon_start,$exon_stop) <= $PRM->{end} ))
					  }
					},
		    containedInRange => ((min($exon_start,$exon_stop) >= $PRM->{start})&&(max($exon_start,$exon_stop) <= $PRM->{end} ))
                 };

  }

## for drawing ambiguous strand from das data    $EV{$seqType}->{$seqId}->{strand} = ($seqStrand eq "+") ? 1 : ($seqStrand eq "-") ? -1 : 0;
    $EV{$seqType}->{$seqId}->{strand} = ($seqStrand eq "+") ? 1 : ($seqStrand eq "-") ? -1 : 0; # for image drawing
    $EV{$seqType}->{$seqId}->{exons}->{"${exon_start}..${exon_stop}"} = $exon_score;
    $EV{$seqType}->{$seqId}->{link} = $exon_link;
    $EV{$seqType}->{$seqId}->{db} = $GV->{dbTitle};
    $EV{$seqType}->{color} = $color;



  } # end if within window
} # end for

return \%eH;
}

sub getEvidenceList {
my ($evidenceHashref) = @_;
my %evidenceHash = %$evidenceHashref;
my %evidenceHashC = %evidenceHash;
my @evidenceList = sort by_coord keys %evidenceHash;
my $Elist = "";
my $evidenceNum = 0;
my %evidenceHashC = %evidenceHash;
 
foreach my $start_end (@evidenceList) {
  if ($evidenceHash{$start_end}) { 
     if ($evidenceHash{$start_end}->{containedInRange}==0){
          next;  # only include those exons fully contained in range
     }

   my @coord = split /  /,$start_end;
   my $min = $coord[0];
   my $max = $coord[1];
   my $direct = '+';
   if($min>$max) {
      $direct = '-';
      my $tmp = $min;
      $min = $max;
      $max = $tmp;
   }
   foreach my $name (keys %{$evidenceHash{$start_end}->{'members'}}) {
     if($Elist!="") { $Elist .= "<newline>"; }
     $Elist.= "$min $max $evidenceHash{$start_end}->{'members'}->{$name}->{'method'} $evidenceHash{$start_end}->{'members'}->{$name}->{'score'} $evidenceHash{$start_end}->{'members'}->{$name}->{'dbName'} $name $direct $evidenceHash{$start_end}->{'members'}->{$name}->{'link'}";
     $evidenceNum++;
   }
  }
 }
#my $ElistLoc = ">/xGDBvm/tmp/GDB001/elist";
#open (MYFILE, $ElistLoc);
#print MYFILE $Elist; 
#close(MYFILE);
return $Elist;
}

sub getEvidenceTable{
my ($evidenceHashref) = @_;
my %evidenceHash = %$evidenceHashref;
my $groupcount = 1;
my @evidencelist = sort by_coord keys %evidenceHash;

my @cellWidths = ('10px','140px','55px','225px');
my $etableJscript = "";
my $eTable = "<table style='border:gray solid thin; background:white; font-family:Arial;margin-left:15px; padding:0 0 10px 0;spacing:0;empty-cells:hide' width='495px' class='smaller'>
<tr><td colspan='4'><br /><span class='s0' style='padding-left:15px'>Evidence Table <img id='yrgate_etable_help' src='/XGDB/images/help-icon.png' alt='?' title='yrGATE Tool Help' class='xgdb-help-button' /><\/span><input class='utButton indent' type='button' onclick='clickHideExons();' value='only display selected exons' id='hideButton'><div><br /><span class='instructions indent'>Select or verify coordinate range for each exon. Click ID to view alignment.</span></td></tr>
<tr><td width=\"$cellWidths[0]\" align='right'><s1 class='indent'>#</s1><\/td><td align='left' width=\"$cellWidths[1]\"><s1>Exon Coordinates</s1></td><td align='left'width='$cellWidths[2]'><s1>Score</si><\/td><td width=\"$cellWidths[3]\" align='left'><s1>Evidence supporting exon</s1><\/td><\/tr>
<tr><td colspan='4' style='padding-left:10px'>
<div id='eTable' style='position=relative;top:0;left:0;width:473px;height:auto;overflow:auto'>
<table width='450px' class='mainTable evidenceTable' style='spacing:0;padding:10px 0 10px 0;border:0;margin:0'>";
my $memberseqs = "";
my %evidenceHashC = %evidenceHash;

foreach my $k (@evidencelist){ # each group of evidence table
  my ($groupMin, $groupMax);
  if ($evidenceHash{$k}){ 
      if ($evidenceHash{$k}->{containedInRange}==0){
	  next;  # only include those exons fully contained in range
      }
    my @coord = split /  /, $k;
    my $rowcolor = ($groupcount % 2) ? "#ededb1":"#CCCC99";
    $groupMin = min($coord[0],$coord[1]);
    $groupMax = max($coord[0],$coord[1]);

    $eTable .= "\n\n\n<tr style=\"padding:0;spacing:0;\" id=\"frow".min($coord[0],$coord[1])."  ".max($coord[0],$coord[1])."\">
<td valign=\"middle\" style=\"width:$cellWidths[0];\" class=\"smaller\">$groupcount</td><td>
<table id=\"table".min($coord[0],$coord[1])."  ".max($coord[0],$coord[1])."\" style=\"background:#DBF3F9;padding:0;spacing:0;text-align;left;font-family:Arial;border:thin gray solid;width:".($cellWidths[1] + $cellWidths[2] + $cellWidths[3])."\" class=\"smaller\">
<tr id=\"".min($coord[0],$coord[1])."  ".max($coord[0],$coord[1])."\">
<td width=\"$cellWidths[1]\">
  <input type=\"radio\" name='e$groupcount' value='".min($coord[0],$coord[1])."  ".max($coord[0],$coord[1])."' onclick='selectradio($groupcount,\"".min($coord[0],$coord[1])."  ".max($coord[0],$coord[1])."\",1);'";
    $eTable .= ($PRM->{info} =~ /$coord[1]\.\.$coord[0]/ || $PRM->{info} =~ /$coord[0]\.\.$coord[1]/) ? " checked=\"checked\" " : "";
    $eTable .= ">".min($coord[0],$coord[1])."  ".max($coord[0],$coord[1])."<\/td>
<td width='$cellWidths[2]'>".$evidenceHash{$k}->{maxScore}.'</td>
<td width="$cellWidths[3]">'.&evidence_links($evidenceHash{$k}->{members})."<\/td><\/tr>";

    #$etableJscript .= "eTableExons['".min($coord[0],$coord[1])."  ".max($coord[0],$coord[1])."'] = '".&TypeList(\%evidenceHash,$k)."';\n";
    $etableJscript .= &TypeList(\%evidenceHash,$k);
    my $InmembersHR = $evidenceHash{$k}->{members};
    delete $evidenceHash{$k};
    delete $evidenceHashC{$k};
    my ($InmembersHR2) ; # tmp variable should be deleted!
    ($groupMin,$groupMax,$InmembersHR2) = GroupExon(min($coord[0],$coord[1]),max($coord[0],$coord[1]),$InmembersHR2,\%evidenceHashC); # gets min and max coordinates for exon group
## if exons have same start position, merge them together
    my @evidencelist2 = sort by_coord keys %evidenceHash;
    foreach my $k2 (@evidencelist2){
     if ($evidenceHash{$k2}){
      if ($evidenceHash{$k2}->{containedInRange}==0){
	  next;  # only include those exons fully contained in range
      }
      my @coord2 = split /  /, $k2;
      if ( ($groupMin <= max($coord2[0],$coord2[1])) and ($groupMax >= min($coord2[0],$coord2[1])) and ( SeqShare($InmembersHR,$evidenceHash{$k2}->{members}) )  ){
        $eTable .= "<tr id=\"".min($coord2[0],$coord2[1])."  ".max($coord2[0],$coord2[1])."\">
	<td width='$cellWidths[1]'>
	<input type='radio' name='e$groupcount' value='".min($coord2[0],$coord2[1])."  ".max($coord2[0],$coord2[1])."' onclick='selectradio($groupcount,\"".min($coord2[0],$coord2[1])."  ".max($coord2[0],$coord2[1])."\",1);'";
        $eTable .= ">".min($coord2[0],$coord2[1])."  ".max($coord2[0],$coord2[1])."<\/td>
	<td width='$cellWidths[2]'>".$evidenceHash{$k2}->{maxScore}.'</td>
	<td width="$cellWidths[3]">'.&evidence_links($evidenceHash{$k2}->{members})."<\/td><\/tr>";

        #test line for above # $eTable .= ">"."keys ".keys(%$InmembersHR)." $InmembersHR ".join(",",keys(%{$InmembersHR}))."<br /> ".min($coord2[0],$coord2[1])."  ".max($coord2[0],$coord2[1])."<\/td><td>".$evidenceHash{$k2}->{maxScore}.'</td><td>'.&evidence_links($evidenceHash{$k2}->{members})."<\/td><\/tr>";
        AddSeqs($InmembersHR,$evidenceHash{$k2}->{members});
        #$etableJscript .= "eTableExons['".min($coord2[0],$coord2[1])."  ".max($coord2[0],$coord2[1])."'] = '".&TypeList(\%evidenceHash,$k2)."';\n";
        $etableJscript .= &TypeList(\%evidenceHash,$k2);
        delete $evidenceHash{$k2};
        delete $evidenceHashC{$k2};
      }
     }
    }
    $eTable .= "<\/table><\/td><\/tr>";
    $groupMin = $groupMax = "";
    $groupcount++;
  }
}

$eTable .= '</table></div></td></tr></table>';
$eTable .= "<script type=\"text/javascript\">var groupAmt = $groupcount;<\/script>";
return ($eTable,$etableJscript);
}


sub GroupExon{
    # tiles out boundaries of exon group, returns members of group and boundaries
    my ($groupMin, $groupMax, $membersHR, $eHashRefT) = @_;  #,$evidenceHashRef) = @_;
    my %eHashT = %{$eHashRefT};
    for my $k (keys %eHashT){
      my @coord = split /  /, $k;

      if ( ($groupMin <= max($coord[0],$coord[1])) and ($groupMax >= min($coord[0],$coord[1])) and &SeqShare($membersHR,$eHashT{$k}->{members})   ){
        AddSeqs($membersHR,$eHashT{$k}->{members});
        $groupMin = min($groupMin,min($coord[0],$coord[1]));
        $groupMax = max($groupMax,max($coord[0],$coord[1]));
        delete $eHashT{$k};
      }
    }
    if ( keys(%eHashT) == keys(%$eHashRefT) ){  # return if range gets all overlapping exons
      return ($groupMin,$groupMax,$membersHR);
    }else{ # recurse to expand range
      ($groupMin,$groupMax,$membersHR) = GroupExon($groupMin,$groupMax,$membersHR,\%eHashT);
    }
}

sub evidence_links{
    # links for evidence, in evidence table
    my ($membersHR) = @_;
    my $link_str;
    for my $k (keys %$membersHR){
		$link_str .= ($membersHR->{$k}->{link} ne "") ? "<a class='hidelinkicon nbsp' href='" . encode_entities($membersHR->{$k}->{link}) . "' target='_blank'>$k</a>\n" : "$k&nbsp;\n";
    }
    return $link_str;
}


sub SeqShare{
  # checks for member duplicity within an exon variant group, else returns list of merged members
  my ($membersHR,$newmembersHR) = @_;
  for my $k (keys %$newmembersHR){
      if ($membersHR->{$k}){
          my %tmp = ();
	  return 0;
      }
  }
  return 1;
}

sub AddSeqs{
  my ($membersHR,$newmembersHR) = @_;
  for my $k (keys %$newmembersHR){
      $membersHR->{$k} = $newmembersHR->{$k};
  }
  return;
}

sub TypeList(){
  # format of Esource; returns Esource line for an exon
  my ($evidenceHR,$exon) = @_;
  my @coord = split /  /,$exon;
  my $linkstr;
  my $membersHR = $evidenceHR->{$exon}->{members};
  for my $k (keys %{$membersHR}){
    $linkstr .= ( ($linkstr ne "") ? "<newline>" : "").min($coord[0],$coord[1])." ".max($coord[0],$coord[1])." $membersHR->{$k}->{method} $membersHR->{$k}->{score} $membersHR->{$k}->{dbName} $k $membersHR->{$k}->{name} $membersHR->{$k}->{link}";
  }
  $linkstr = "eTableExons['".min($coord[0],$coord[1])."  ".max($coord[0],$coord[1])."'] = \"$linkstr\";\n";
  return $linkstr;
}

sub recordTable{
    my ($UCAref,$statusArrRef,$s,$url,$table_class,$db_ver) = @_;
    my %statusHash;
    my $ownedRef = getAdminOwnership();
	my $limit_db_ver = "?";
	if ($db_ver ne ""){
		$limit_db_ver .= "db_ver=$db_ver&amp;";
	}

    #title row
    my $page ="";
#    $page .= "<div class=\"indent description showhide\" style=\"width:1200px\"><a title=\"Show additional information directly below this link\" class=\"label\" style=\"cursor:pointer\">Annotation News [click to show/hide]</a>
    
#	 <div class=\"more_hidden hidden\"> 
#     </div></div>\n";

    $page .= "<div style='clear:both; overflow:auto'><table class='mainT $table_class'>";
    $page .= "<col width=\"1*\"/><col width=\"1*\"/><col width=\"1*\"/><col width=\"1*\"/><col width=\"1*\"/><col width=\"1*\"/><col width=\"1*\"/><col width=\"1*\"/><col width=\"1*\"/><col width=\"1*\"/><col width=\"1*\"/><col width=\"1*\"/><col width=\"1*\"/>\n";
    $page .= "<tr class='headRow'>";
	$page .= ($s =~ /geneId desc/) ? "<th title=\"The ID of the annotation. Click ID to view annotation record; click header to sort \"><a href=\"${url}${limit_db_ver}sort=geneId\">Annotation ID</a></th>" : "<th title=\"The ID of the annotation. Click ID to view annotation record; click header to sort\"><a href=\"${url}${limit_db_ver}sort=geneId!\">Annotation ID</a></th>\n";
 	$page .= "<th style=\"cursor:pointer\" title=\"View in genome context (opens a new window)\">View\@ $GV->{dbTitle}</th>";
   $page .= ($s =~ /annotation_class desc/) ? "<th title=\"Does the annotation correct, confirm, add splicing variant or suggest deletion of existing gene model? (click to sort)\"><a href=\"${url}${limit_db_ver}sort=annotation_class\">Annotation Type</a></th>" : "<th title=\"Does the annotation correct, confirm, add splicing variant or suggest deletion of existing gene model? (click to sort)\"><a href=\"${url}${limit_db_ver}sort=annotation_class!\">Anno Class</a></th>";
    $page .= ($s =~ /locusId desc/) ? "<th title=\"The ID of the locus being annotated (either existing or new locus) (click to sort)\"><a href=\"${url}${limit_db_ver}sort=locusId\">Locus ID</a></th>" : "<th title=\"The ID of the locus being annotated (either existing or new locus) (click to sort)\"><a href=\"${url}${limit_db_ver}sort=locusId!\">Locus ID</a></th>\n";
	 $page .= ($s =~ /transcriptId desc/) ? "<th title=\"The ID of the transcript being re-annotated (if any) (click to sort)\"><a href=\"${url}${limit_db_ver}sort=transcriptId\">Transcript ID</a></th>" : "<th title=\"The ID of the transcript being re-annotated (if any) (click to sort)\"><a href=\"${url}${limit_db_ver}sort=transcriptId!\">Transcript ID</a></th>\n";

	$page .= ($s =~ /geneAliases desc/) ? "<th title=\"If this locus corresponds to a known gene, the accepted gene alias or abbreviation (click to sort)\"><a href=\"${url}${limit_db_ver}sort=geneAliases\">Gene Alias</a></th>" : "<th title=\"If this locus corresponds to a known gene, the accepted gene alias or abbreviation (click to sort)\"><a href=\"${url}${limit_db_ver}sort=geneAliases!\">Gene Alias</a></th>";
	$page .= ($s =~ /proteinId desc/) ? "<th title=\"If protein coding gene, name of putative protein product (click to sort)\"><a href=\"${url}${limit_db_ver}sort=proteinId\">Protein Product</a></th>" : "<th title=\"If protein coding gene, name of putative protein product (click to sort)\"><a href=\"${url}${limit_db_ver}sort=proteinId!\">Protein Product</a></th>";
    $page .= ($s =~ /r_pos desc/) ? "<th title=\"Chromosome or BAC/Scaffold and left-right coordinates (click to sort)\"><a href=\"${url}${limit_db_ver}sort=region\">Genome Segment</a></th>" : "<th title=\"Chromosome or BAC/Scaffold and left-right coordinates (click to sort)\"><a href=\"${url}${limit_db_ver}sort=region!\">Genome Segment</a></th>\n";

	$page .= ($s =~ /dbVer desc/) ? "<th title='Genome Database Version (0 is earlist) (click to sort)'><a href=\"${url}${limit_db_ver}sort=dbVer\">Ver.</a></th>" : "<th title='Genome Database Version (0 is earliest) (click to sort)'><a href=\"${url}${limit_db_ver}sort=dbVer!\">DB Ver</a></th>";
	$page .= "<th style=\"cursor:pointer\" title=\"If genome sequence was edited for this annotation\">Gnm Edits</th>";
    $page .= "<th style=\"cursor:pointer\" title=\"Click to download mRNA (M) or protein (P) FASTA, or GFF3 (G) file for this annotation\">Download</th>";
    $page .= ($s =~ /modDate desc/) ? "<th title=\"Date this annotation was last modified by the annotator (click to sort)\"><a href=\"${url}${limit_db_ver}sort=modDate\">Last Modified</a></th>" : "<th title=\"Date this annotation was last modified by the annotator (click to sort)\"><a href=\"${url}${limit_db_ver}sort=modDate!\">Last Modified</a></th>\n";

    $page .= ($s =~ /category desc/) ? "<th title=\"User-assigned project for this annotation\"><a href=\"${url}${limit_db_ver}sort=category\">Project</a></th>" : "<th title=\"User-assigned project for this annotation\"><a href=\"${url}${limit_db_ver}sort=category!\">Project</a></th>";
    $page .= ($s =~ /working_group desc/) ? "<th title=\"User-assigned working group for this annotator\"><a href=\"${url}${limit_db_ver}sort=working_group\">Working Group</a></th>" : "<th title=\"User-assigned working group for this annotator\"><a href=\"${url}${limit_db_ver}sort=working_group!\">Working Group</a></th>";
    $page .= ($s =~ /USERid desc/) ? "<th title=\"Username of the person who submitted this annotation\"><a href=\"${url}${limit_db_ver}sort=USERid\">Annotator</a></th>" : "<th title=\"Username of the person who submitted this annotation\"><a href=\"${url}${limit_db_ver}sort=USERid!\">Annotator</a></th>\n";
	$page .= "</tr>";

    my $tablePage = "";
    for (my $i=0;$i<scalar(@$UCAref);$i++){
	# Changing next line? Might need to change: AdminAnnotation.pl / AnnotationAccount.pl / CommunityCentral.pl
	my ($uid,$geneId,$locusId,$transcriptId,$modDate,$status,$owner,$chr,$l_pos,$r_pos,$proteinSeq,$GSeqEdits,$organism,$dbName,$dbVer,$geneAliases,$proteinId,$annotation_class,$category,$working_group, $description, $rangeStart, $rangeEnd) = @{$UCAref->[$i]}; # See note immediately above.

	#the following is used to highlight annotation records modified in the last 7 days - JPD.
	use Time::Local;
	my $time = timelocal(localtime);
	my @mt = $modDate =~ /(\d+)-(\d+)-(\d+)\s(\d+):(\d+):(\d+)/;
	use POSIX qw(strtod);
	my $sec= strtod($mt[5]);
	my $min = strtod($mt[4]);
	my $hours = strtod($mt[3]);
	my $day = strtod($mt[2]);
	my $month = strtod($mt[1])-1;
	my $year = strtod($mt[0]);
	my $mod_time = timelocal($sec, $min, $hours, $day, $month, $year);
	my $diff=$time-$mod_time;
	my $recentClass="";
	if ($diff < 60*60*24*7){ # 7 days expressed in seconds
	$recentClass="recent_anno $status";
	}
	else
	{
	$recentClass="old_anno $status";
	}
	if ($statusHash{$status}==0){
	    my $trClass = 'catRow'.$status;
	    $tablePage .= "<tr class='catRow bold hover_pointer $trClass'><td colspan='15' id=\"$status\">$status ($table_class)</td></tr>\n";
	    $statusHash{$status} = 1;
	}
   $description =~ s/'//g;
   $description =~ s/"//g;
   $description =~ s/&/&amp;/g;
   $description =~ s/>/&gt;/g;
   $description =~ s/</&lt;/g;
   my $description_trunc = substr $description, 0, 300;
   if(length($description) > 300){
   $description_trunc .= ' ... (more)';
   }
   
   
  if ( !$$ownedRef{$uid} || ($$ownedRef{$uid} eq $PRM->{USERid})){ # check to see if under review
    $tablePage .= "<tr class=\"$recentClass\"><td><a target='_blank' title='$description_trunc' href='$GV->{CGIPATH}AnnotationDetail.pl?uid=$uid' onclick=\"checkout('$uid');\" class='nbsp'>$geneId</a>";
    $tablePage .=  ($url ne 'AnnotationGroup.pl' && $status ne "ACCEPTED") ? "<a  target='_blank' title='Edit this yrGATE annotation' href='$GV->{CGIPATH}AnnotationTool.pl?uid=$uid'><span class=\"$status\">edit</span></a>" : "";
    $tablePage .= "</td>";
  }else{
    $tablePage .= "<tr class='checked_row'><td><a target='_blank' title='View Record' href='$GV->{CGIPATH}AnnotationDetail.pl?uid=$uid'>$geneId</a></td>";
  }

  my $firstTwo = substr($dbName, 0, 2); # Grab first 2 letters from GDB name

  my $bool_has_GSeqEdits = "";
  if ($GSeqEdits != ""){
    $bool_has_GSeqEdits = "YES";
  }
   $tablePage .= "<td class='contextview' align='center'><a class='hidelinkicon' title='View this annotation in Genome Context' href='".encode_entities((&{$GV->{GenomeContextLinkFunction}}($chr,$l_pos,$r_pos,$dbVer)))."' target='_blank'></a></td>\n"; $tablePage .= "<td>$annotation_class</td>";
  $tablePage .= "<td>$locusId</td>";
  $tablePage .= "<td>$transcriptId</td>";
  $tablePage .= "<td>$geneAliases</td><td>$proteinId</td>";
  $tablePage .= "<td><b>$chr:</b>$l_pos..$r_pos</td>";
  $tablePage .= "<td><a href='/XGDB/phplib/resource.php?GDB=$firstTwo$dbVer' title='info about this database version' target='_blank'>$dbVer</a></td>";
#  $tablePage .= "<td><a title='View Annotation Details for this Record' target='_blank' href='$GV->{CGIPATH}AnnotationDetail.pl?uid=$uid'>Record</a></td>";
  $tablePage .= "<td style=\"cursor:pointer\" title=\"$GSeqEdits\">$bool_has_GSeqEdits</td>";
  $tablePage .= "<td><a title='Download mRNA FASTA of this annotation' target='_blank' href='$GV->{CGIPATH}AnnotationExport.pl?uid=$uid&amp;html=1&amp;format=fasta&amp;html=1&amp;seqType=n'>M</a> | ";
  $tablePage .= ($proteinSeq ne "") ? "<a title='Download Protein FASTA of this annotation' target='_blank' href='$GV->{CGIPATH}AnnotationExport.pl?uid=$uid&amp;html=1&amp;format=fasta&amp;html=1&amp;seqType=p'>P</a> | " : "";
  $tablePage .= "<a title='Download GFF3-formatted file of this annotation' target='_blank' href='$GV->{CGIPATH}AnnotationExport.pl?uid=$uid&amp;html=1&amp;format=gff3&amp;html=1'>G</a></td>\n";
  $tablePage .= "<td>$modDate</td>";
  $tablePage .= "<td>$category</td><td>$working_group</td>";
  $tablePage .= "<td>$owner</td>";
  $tablePage .= "</tr>\n";
}

# for empty status
for my $k (@$statusArrRef){
    if ($statusHash{$k} == 0){
      $tablePage .= "<tr class=\"catRow\"><td id=\"$k\" colspan=\"15\">$k ($table_class) (no records) </td></tr>\n";
      $statusHash{$k} = 1;
    }
}
$tablePage .= "</table></div><br />";
$page .= $tablePage;

return $page;
}

sub recordTranscriptId{
  my @optionarray;
  my $current_transcript_id;

  if (!$PRM->{uid}){
    $current_transcript_id = "[Select...]";
  } else { # If this is a saved annotation, get transcript ID so it's auto-selected in dropdown.
    my $current_transcript_id_sql = "SELECT transcriptId FROM $GV->{dbTitle}.user_gene_annotation WHERE uid = '$PRM->{uid}'";
    $current_transcript_id = $GV->{ADBH}->selectrow_array($current_transcript_id_sql);
  $PRM->{category} = $current_transcript_id;
  }
  push @optionarray, $current_transcript_id;

    my $id = int(substr($GV->{dbTitle}, -3));
    my $yrgate_ref_sql = "SELECT yrGATE_Reference FROM Genomes.xGDB_Log where ID=$id"; # which track to use as reference
    my @yrgate_ref = $GV->{LDBH}->selectrow_array($yrgate_ref_sql);
    

  my $ti_sql = "SELECT DISTINCT transcript_id FROM ";
  if ($yrgate_ref[0] eq 'CpGAT'){
    $ti_sql .= "gseg_cpgat_gene_annotation WHERE gseg_gi = '$PRM->{chr}' AND l_pos >= '$PRM->{start}' AND r_pos <= '$PRM->{end}'";
  } else {
   $ti_sql .= "gseg_gene_annotation WHERE gseg_gi = '$PRM->{chr}' AND l_pos >= '$PRM->{start}' AND r_pos <= '$PRM->{end}'";
  }
#   print STDERR $ti_sql;
  my $transcript_id_Count = $GV->{DBH}->selectall_arrayref($ti_sql);

  for (my $i=0;$i<scalar(@$transcript_id_Count);$i++){
  my ($transcript_id) = @{$transcript_id_Count->[$i]};
    push @optionarray, $transcript_id;
  }

  return @optionarray;
}

sub recordLocusId{
  my @optionarray;
  my $current_locus_id;

  if (!$PRM->{uid}){
    $current_locus_id = "[Select...]";
  } else { # If this is a saved annotation, get locus ID so it's auto-selected in dropdown.
    my $current_locus_id_sql = "SELECT locusId FROM $GV->{dbTitle}.user_gene_annotation WHERE uid = '$PRM->{uid}'";
    $current_locus_id = $GV->{ADBH}->selectrow_array($current_locus_id_sql);
    $PRM->{category} = $current_locus_id;
  }
  push @optionarray, $current_locus_id;

    my $id = int(substr($GV->{dbTitle}, -3));
    my $yrgate_ref_sql = "SELECT yrGATE_Reference FROM Genomes.xGDB_Log where ID=$id"; # which track to use as reference
    my @yrgate_ref = $GV->{LDBH}->selectrow_array($yrgate_ref_sql);

  my $ti_sql = "SELECT DISTINCT locus_id FROM ";
  if ($yrgate_ref[0] eq 'CpGAT'){
    $ti_sql .= "gseg_cpgat_gene_annotation WHERE gseg_gi = '$PRM->{chr}' AND l_pos >= '$PRM->{start}' AND r_pos <= '$PRM->{end}'";
  } else {
    $ti_sql .= "gseg_gene_annotation WHERE gseg_gi = '$PRM->{chr}' AND l_pos >= '$PRM->{start}' AND r_pos <= '$PRM->{end}'";
  }
  my $locus_id_Count = $GV->{DBH}->selectall_arrayref($ti_sql);

  for (my $i=0;$i<scalar(@$locus_id_Count);$i++){
  my ($locus_id) = @{$locus_id_Count->[$i]};
    push @optionarray, $locus_id;
  }

  return @optionarray;
}

sub recordCategory{
  my @optionarray; #("Other...");
  my $current_category_sql = "SELECT category FROM $GV->{dbTitle}.user_gene_annotation WHERE uid = '$PRM->{uid}'";
  my ($current_category) = $GV->{ADBH}->selectrow_array($current_category_sql); # Need parenthesis around declared variable?
  $PRM->{category} = $current_category;
  if ($current_category == ""){
    $current_category = "[Select...]";
  }

  push @optionarray, $current_category;
  push @optionarray, "none";
 # push @optionarray, "[Other...]"; JD 2/28/10 turning off this option; see also AnnotationTool.js togglefield

#  my $c_sql = "SELECT DISTINCT category FROM user_gene_annotation WHERE dbName = '$GV->{dbTitle}' AND category <> '$current_category' ORDER BY category";
   my $c_sql = "SELECT DISTINCT category FROM $GV->{dbTitle}.user_gene_annotation WHERE dbName = '$GV->{dbTitle}' AND category <> '$current_category' 
   UNION SELECT DISTINCT project FROM projects WHERE db_name = '$GV->{dbTitle}' AND project <> '$current_category'
   ORDER BY category"; # gets all categories, both currently used and stored in projects table.

  my $categoryCount = $GV->{ADBH}->selectall_arrayref($c_sql);

  for (my $i=1;$i<scalar(@$categoryCount);$i++){ # Change 1 to 0 if we want to allow them to choose nothing
    my ($category) = @{$categoryCount->[$i]};
    push @optionarray, $category;
    
  }

  return @optionarray;
}

#JPD - Used by recordWorkingGroup sub which populates the AnnotationTool.pl dropdown for Working Group. Finds the current user's most recently saved working_group, or falls back to their private group (if any).

#sub findSuggestCategory {
#  my $category_sql = "SELECT category FROM user_gene_annotation WHERE USERid = '$PRM->{USERid}' and working_group is not null order by modDate DESC limit 1";
#    my $category = $GV->{ADBH}->selectrow_array($category_sql);
#    my $suggest_category = "$category";
#  if ($category eq ""){
#      $suggest_category = "[Select...]";
#      }
#  return $suggest_category;
#}


#Use current working group for this record and present options for user input, including Other. See also findSuggestGroup
sub recordWorkingGroup{
  #my @optionarray = ("cat1","cat2","cat3","cat4","cat5","cat6","cat7");
  my @optionarray; #("Other...");

  my $current_wg_sql = "SELECT working_group FROM $GV->{dbTitle}.user_gene_annotation WHERE uid = '$PRM->{uid}'";
  my ($current_wg) = $GV->{ADBH}->selectrow_array($current_wg_sql);
  $PRM->{working_group} = $current_wg;
  if ($current_wg eq ""){
   $current_wg = "[Select...]"; 
  }
  push @optionarray, $current_wg;
  #push @optionarray, "-none-";
  #push @optionarray, "[Other...]";

 # my $wg_sql = "SELECT DISTINCT working_group FROM user_gene_annotation WHERE working_group !='' AND dbName = '$GV->{dbTitle}' AND uid <> '$PRM->{uid}' ORDER BY working_group";
  my $wg_sql = "SELECT DISTINCT private_group FROM yrgate.user_group WHERE user='$PRM->{USERid}' AND private_group IS NOT NULL AND (gdb = '$GV->{dbTitle}' or gdb='ALL') and private_group <> '$current_wg' ORDER BY private_group"; #fixed 9-26-12
  my $workingGroupCount = $GV->{ADBH}->selectall_arrayref($wg_sql);

  for (my $i=0;$i<scalar(@$workingGroupCount);$i++){ # load the existing private_groups
	my ($working_group) = @{$workingGroupCount->[$i]};
	push @optionarray, $working_group;
  }

  return @optionarray;
}
#JPD - Used by recordWorkingGroup sub which populates the AnnotationTool.pl dropdown for Working Group. Finds the current user's most recently saved working_group, or falls back to their private group (if any).
#sub findSuggestGroup {
#  my $working_sql = "SELECT working_group FROM user_gene_annotation WHERE USERid = '$PRM->{USERid}' and working_group is not null order by modDate DESC limit 1";
#    my $working_group = $GV->{ADBH}->selectrow_array($working_sql);
#  my $private_sql = "SELECT private_group FROM user_group WHERE user = '$PRM->{USERid}' order by uid DESC limit 1";
#    my $private_group = $GV->{ADBH}->selectrow_array($private_sql);
#    my $suggest_group = "$working_group";
#  if ($working_group eq "" && $private_group ne "" ){
#      $suggest_group = "[Select...]"; #Allow user to select from dropdown
#   }elsif($private_group eq ""){
#    $suggest_group = "[None Available]"; #The user does not belong to any private groups
#   }elsif($working_group eq ""){
#    $suggest_group = "$private_group"; #provide most recent group as default
#    }
#  return $suggest_group;
#}
	
sub bailOut{
  my ($txt) = @_;
  $txt = ($txt eq "") ? "Improper parameters. Please enter the Gene Annotation Tool from a legitimate link." : $txt;

    print header();
    print '<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">';
    print '<html xmlns="http://www.w3.org/1999/xhtml">';
    print '<head><meta http-equiv="content-type" content="text/html;charset=iso-8859-1" />';
    print '<title>yrGATE: Error</title>';
    print '<link type="text/css" rel="stylesheet" href="$GV->{HTMLPATH}yrGATE.css" />';
    print '<link type="text/css" rel="stylesheet" href="$GV->{/css/plantgdb.css" />';
    print '</head><body>';
    print printTitle("error",0,1);
    print "<p class=\"warning\">$txt</p>";
    print printFooter() . "</body></html>";
    exit();
}

sub min{
  my ($a,$b) = @_;
  if ($a > $b){
    return $b;
  }else{
    return $a;
  }
}

sub max{
  my ($a,$b) = @_;
  if ($a < $b){
    return $b;
  }else{
    return $a;
  }
}

sub by_coord{
  my @s1 = split /  /,$a;
  my @s2 = split /  /,$b;
  $s1[0] <=> $s2[0]
    ||
  $s1[1] <=> $s2[1]
}

sub printTitle{
  my ($title,$helpfile,$hints, $lines,$nav, $table_link) = @_;
  my $titleText;

# if ($helpfile == 0){ # Prevent non-validating page. # Doesn't work. Commented out JD 8-5-10.
#   $helpfile = "placeholder";
# }


  if ($nav){
      my $space = "";
      $titleText .= "<div class='topmargin1 navlink bottommargin1'>";
     $titleText .= "<span class=\"largerfont\"><b>yrGATE: </b></span>";

# note - ccs for id-based nav highlighting is hard-coded in the <head> of the respective scripts referred to in the link
	  $titleText .= "<a title='List all curated yrGATE gene models for this genome' id='comm_central' href='$GV->{CGIPATH}CommunityCentral.pl'>Community Central</a>\n";
      $titleText .= ($GV->{login_required}) ? (($PRM->{USERid}) ? "<a title='A list of your yrGATE annotations for this genome' id='anno_account' href='$GV->{CGIPATH}AnnotationAccount.pl?sort=modDate!'>My Account</a>\n
      <a href='$GV->{CGIPATH}logout.pl'>Log Out</a>" : "<a style='text-decoration:none;' href='$GV->{CGIPATH}login.pl'>Log In</a><a style='text-decoration:none;' href='$GV->{CGIPATH}userRegister.pl'>Sign up for an Account</a>" ): "";
      if (getWorkingGroupUser($PRM->{USERid}))
      {      
      $titleText .= "<a title='Annotations from members  of $PRM->{USERid}`s private working group(s)' id='anno_group' href='$GV->{CGIPATH}AnnotationGroup.pl?sort=modDate!'>My Groups</a>\n";
      }
      $titleText .= (&{$GV->{getUserGroupFunction}}($PRM->{USERid})) ? "<a title='Admin page for approving/rejecting annotations' id='admin_anno' href='$GV->{CGIPATH}AdminAnnotation.pl'>Admin</a>": "";
      if (getWorkingGroupAdmin($PRM->{USERid}))
      {
      $titleText .= "<a title='Admin page for approving/rejecting group annotations' id='group_admin_anno' href='$GV->{CGIPATH}AdminAnnotationGroup.pl'>Group Admin</a>";
      }
      $titleText .= "<a href='/XGDB/help/community_central.php/'>Help</a>";
      $titleText .= "<!-- a href='/site/yrgate_rankings.php?GDB=$GV->{dbTitle}'>Rankings</a -->";
     $titleText .= "<span class=\"largerfont indent1\"><b>xGDBvm: </b></span>";
     $titleText .= "<a href='/'>Home</a>";
     $titleText .= "<a title='Click to go to GDB Home Page' href= '/$GV->{dbTitle}/'>$GV->{dbTitle}</a>";
      $titleText .= "</div>\n";
     
     ######Ann comment out the next line for working around the register function 7/5/07#####
      #$titleText .= (exists($GV->{headerExtraFunction})) ? "<br /><br />".&{$GV->{headerExtraFunction}}."<br />" : "";
  }

    $titleText .= "\n";


  $titleText .= "<div class='smaller'><h1 class='topmargin2 bottommargin1 anno'>$title <img id='$helpfile' src='/XGDB/images/help-icon.png' alt='?' title='What is this page all about?' class='xgdb-help-button' style='margin-bottom:1px' /></h1>\n";

  $titleText .= "</div>";

    if ($lines){
    $titleText .= "<div class='topmargin2 bottommargin1'> ";
    $titleText .= ($GV->{speciesName}) ? "<b class='indent'>Organism</b>: <span class='info'>$GV->{speciesName}</span>" : "";
    $titleText .= ($PRM->{USERid}) ? "<b class='indent'>Username</b>: <span class='info'>$PRM->{USERid}</span>" : "";
    $titleText .= $hints;
    $titleText .= "</div>\n";
  }

  return $titleText;
}

sub printFooter{
    my $text;
    $text = "<br /><br />";
    $text .= "yrGATE (c) 2006-2013";
	$text .='
		<div id="footer">
			<ul><!-- Modifying this menu? Sync it with our other footer menus. See the notes in /phplib/footer.php (reference copy). -->
				<li id="acknowledgments"><a href="/XGDB/help/acknowledgments.php">Acknowledgments</a></li>
				<li id="brendelgroup"><a href="http://brendelgroup.org/">Brendel Group</a></li>
			</ul>
			<!--p id="validation" class="center"><a id="valid_xhtml" href="http://validator.w3.org/check?uri=referer">Valid XHTML</a> and <a id="valid_css" href="http://jigsaw.w3.org/css-validator/check/referer">CSS</a></p-->
		</div>
		<div id="blankDiv" style="position: absolute; left: 0; top: 0; visibility: hidden"></div>
		<div id="image_dialog"><h2>Loading Image</h2></div>
		<div id="help_dialog"><h2>Loading Help Page</h2></div>
		';
    return $text;
}

sub disconnectDB{
    if ($GV->{LDBH}) {$GV->{LDBH}->disconnect;}
    if ($GV->{ADBH}) {$GV->{ADBH}->disconnect;}
    if ($GV->{DBH}) {$GV->{DBH}->disconnect;}
}

	# testing 10-30-12

sub getDbpass {
	my $dbpass='';
	open FILE, "/xGDBvm/admin/dbpass";
	while (my $line=<FILE>){
	$dbpass= $line;
	}
return $dbpass;
}

return 1;
