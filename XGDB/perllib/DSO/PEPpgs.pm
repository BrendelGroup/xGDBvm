package PEPpgs;
use base "SequenceTrack";
use base "GeneSeqerSequence";

do 'SITEDEF.pl';

sub _init{
  my $self = shift;

  $self->SUPER::_init(@_);

  $self->{sequenceTYPE}  = 'Protein';
  $self->{gsqATYPE} = 'P';

  $self->{db_table}  = (exists($self->{db_table})) ? $self->{db_table} : 'pep';
  $self->{trackname} = (exists($self->{trackname}))? $self->{trackname}: 'Pep';

  my $DB_TABLE = $self->{db_table};
  my $DISPLAY_LIMITS = (exists($self->{QUERYLIMIT}))? $self->{QUERYLIMIT} : '';

  $self->{seqQUERY}    = qq{SELECT c.gi,c.acc,c.version,c.description,c.seq FROM ${DB_TABLE} AS c WHERE (?) IN (c.gi,c.acc) };

if(exists($self->{chrVIEWABLE}) && $self->{chrVIEWABLE}){
  $self->{SQL_BASE}         = qq{SELECT c.gi,c.description,p.uid,p.gseg_uid,p.E_O,p.sim,p.cov,p.G_O,p.chr,p.l_pos,p.r_pos,p.pgs,p.isCognate,c.acc,c.seq,c.version,p.mlength,p.pgs_lpos,p.pgs_rpos,p.gseg_gaps,p.pgs_gaps FROM ${DB_TABLE}_good_pgs AS p INNER JOIN ${DB_TABLE} AS c USING (gi) };

  $self->{gsqPGS_QUERY}     = qq{$self->{SQL_BASE} WHERE (p.uid=?) };
  $self->{gsqPGS_EX_QUERY}  = qq{SELECT num,gseg_start,gseg_stop,pgs_start,pgs_stop,score,pgs_uid FROM ${DB_TABLE}_good_pgs_exons WHERE (pgs_uid=?) };
  $self->{gsqPGS_IN_QUERY}  = qq{SELECT num,gseg_start,gseg_stop,Dscore,Dsim,Ascore,Asim,pgs_uid FROM ${DB_TABLE}_good_pgs_introns WHERE (pgs_uid=?) };

  $self->{chrREGION_QUERY}  = qq{$self->{SQL_BASE} WHERE (p.chr=?)&&(p.r_pos>=?)&&(p.l_pos<=?) ${DISPLAY_LIMITS} };
  $self->{chrDESC_QUERY}    = qq{$self->{SQL_BASE} WHERE MATCH (description) AGAINST ( ? IN BOOLEAN MODE) };
  $self->{chrUID_QUERY}     = qq{SELECT p.gi FROM ${DB_TABLE}_good_pgs as p WHERE (p.uid=?) };
  $self->{chrQUERY}    = qq{SELECT p.uid,p.gseg_uid,p.E_O,p.sim,p.cov,p.G_O,p.chr,p.l_pos,p.r_pos,p.pgs,p.isCognate,p.gi FROM ${DB_TABLE}_good_pgs AS p WHERE (p.gi=?) };
}

if(exists($self->{BACVIEWABLE}) && $self->{BACVIEWABLE}){
  $self->{gsegSQL_BASE}     = qq{SELECT c.gi,c.description,gp.uid,gp.E_O,gp.sim,gp.cov,gp.gseg_gi,gp.G_O,gp.l_pos,gp.r_pos,gp.pgs,gp.isCognate,gp.mergeNOTE,c.acc,c.seq,c.version,gp.mlength,gp.pgs_lpos,gp.pgs_rpos,gp.gseg_gaps,gp.pgs_gaps FROM gseg_${DB_TABLE}_good_pgs AS gp INNER JOIN ${DB_TABLE} AS c USING (gi) };

  $self->{gseggsqPGS_QUERY}     = qq{$self->{gsegSQL_BASE} WHERE (gp.uid=?) };
  $self->{gseggsqPGS_EX_QUERY}  = qq{SELECT num,gseg_start,gseg_stop,pgs_start,pgs_stop,score,pgs_uid FROM gseg_${DB_TABLE}_good_pgs_exons WHERE (pgs_uid=?) };
  $self->{gseggsqPGS_IN_QUERY}  = qq{SELECT num,gseg_start,gseg_stop,Dscore,Dsim,Ascore,Asim,pgs_uid FROM gseg_${DB_TABLE}_good_pgs_introns WHERE (pgs_uid=?) };

  $self->{gsegREGION_QUERY} = qq{$self->{gsegSQL_BASE} WHERE (gp.gseg_gi=?)&&(gp.r_pos>=?)&&(gp.l_pos<=?) ${DISPLAY_LIMITS} };
  $self->{gsegDESC_QUERY}   = qq{$self->{gsegSQL_BASE} WHERE MATCH (description) AGAINST ( ? IN BOOLEAN MODE) };
  $self->{gsegUID_QUERY}    = qq{SELECT gp.gi FROM gseg_${DB_TABLE}_good_pgs as gp WHERE (gp.uid=?) };
  $self->{gsegQUERY}   = qq{SELECT gp.uid,gp.E_O,gp.sim,gp.cov,gp.gseg_gi,gp.G_O,gp.l_pos,gp.r_pos,gp.pgs,gp.isCognate,gp.mergeNOTE,gp.gi FROM gseg_${DB_TABLE}_good_pgs AS gp WHERE (gp.gi=?) };
}

  $self->{MULTI_ID_QUERY} = sub {
    my ($BASE,$idlist) = @_;
    return $BASE . "WHERE (c.gi IN ($idlist))||(acc IN ($idlist))||(clone IN ($idlist))";
  };

}

1;
