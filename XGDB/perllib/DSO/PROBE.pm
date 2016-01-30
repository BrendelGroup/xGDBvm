package PROBE;
use base "SequenceTrack";

do 'SITEDEF.pl';

sub _init{
  my $self = shift;

  $self->SUPER::_init(@_);

  $self->{sequenceTYPE}  = 'Probe';

  $self->{db_table}  = (exists($self->{db_table})) ? $self->{db_table} : 'probe';
  $self->{trackname} = (exists($self->{trackname}))? $self->{trackname}: 'Probe';

  my $DB_TABLE = $self->{db_table};

  $self->{seqQUERY}    = qq{SELECT c.gi,c.acc,c.version,c.description,c.seq FROM ${DB_TABLE} as c WHERE (?) IN (c.gi,c.acc) };

  if(exists($self->{chrVIEWABLE}) && $self->{chrVIEWABLE}){
    $self->{SQL_BASE}         = qq{SELECT c.gi,c.description,p.uid,p.gseg_uid,p.E_O,p.sim,p.cov,p.G_O,p.chr,p.l_pos,p.r_pos,p.pgs,p.isCognate,c.acc,c.seq,c.version,p.mlength,p.pgs_lpos,p.pgs_rpos,p.gseg_gaps,p.pgs_gaps FROM ${DB_TABLE}_good_pgs as p INNER JOIN ${DB_TABLE} as c USING (gi) };

    $self->{chrREGION_QUERY}  = qq{$self->{SQL_BASE} WHERE (p.chr=?)&&(p.r_pos>=?)&&(p.l_pos<=?) };
    $self->{chrDESC_QUERY}    = qq{$self->{SQL_BASE} WHERE MATCH (description) AGAINST ( ? IN BOOLEAN MODE) };
    $self->{chrUID_QUERY}     = qq{SELECT p.gi FROM ${DB_TABLE}_good_pgs as p WHERE (p.uid=?) };
    $self->{chrQUERY}    = qq{SELECT p.uid,p.gseg_uid,p.E_O,p.sim,p.cov,p.G_O,p.chr,p.l_pos,p.r_pos,p.pgs,p.isCognate,p.gi FROM ${DB_TABLE}_good_pgs as p WHERE (p.gi=?) };
  }

  if((exists($self->{BACVIEWABLE}) && $self->{BACVIEWABLE}) || $self->{gsegSRC}){
    $self->{gsegSQL_BASE}     = qq{SELECT c.gi,c.description,gp.uid,gp.E_O,gp.sim,gp.cov,gp.gseg_gi,gp.G_O,gp.l_pos,gp.r_pos,gp.pgs,gp.isCognate,c.acc,c.seq,c.version,gp.mlength,gp.pgs_lpos,gp.pgs_rpos,gp.gseg_gaps,gp.pgs_gaps FROM gseg_${DB_TABLE}_good_pgs as gp INNER JOIN ${DB_TABLE} as c USING (gi) };

    $self->{gsegREGION_QUERY} = qq{$self->{gsegSQL_BASE} WHERE (gp.gseg_gi=?)&&(gp.r_pos>=?)&&(gp.l_pos<=?) };
    $self->{gsegDESC_QUERY}   = qq{$self->{gsegSQL_BASE} WHERE MATCH (description) AGAINST ( ? IN BOOLEAN MODE) };
    $self->{gsegUID_QUERY}    = qq{SELECT gp.gi FROM gseg_${DB_TABLE}_good_pgs as gp WHERE (gp.uid=?) };
    $self->{gsegQUERY}   = qq{SELECT gp.uid,gp.E_O,gp.sim,gp.cov,gp.gseg_gi,gp.G_O,gp.l_pos,gp.r_pos,gp.pgs,gp.isCognate,gp.gi FROM gseg_${DB_TABLE}_good_pgs as gp WHERE (gp.gi=?) };
  }

  $self->{MULTI_ID_QUERY} = sub {
    my ($BASE,$idlist) = @_;
    return $BASE . "WHERE (c.gi IN ($idlist))||(acc IN ($idlist))||(clone IN ($idlist))";
  };

}

sub getDASTYPES{
  my ($self,$typesAR,$segmentsAR) = @_;

  my $method = (exists($self->{DASmethod})) ? $self->{DASmethod} : 'unknown';
  my $category = (exists($self->{DAScategory})) ? $self->{DAScategory} : 'miscellaneous';
  my $source = (exists($self->{DASsource})) ? $self->{DASsource} : 'unknown';
  my $typeID = (exists($self->{DAStype})) ? $self->{DAStype} . ":$method" : "region:$method";

  if(!$xDAS_always_show_type_count && (!defined($segmentAR) || !scalar(@$segmentAR))){
    return {$typeID => {'category'=>$category,'method'=>$method,'source'=>$source}};
  }elsif(!defined($segmentAR) || !scalar(@$segmentAR)){
## need to make counts available (both chr and gseg)
  }else{
## need to deal with chr ids (possibly use an id hash lookup)

  }

}
1;
