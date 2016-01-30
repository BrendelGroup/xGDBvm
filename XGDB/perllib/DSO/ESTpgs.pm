package ESTpgs;
use base "SequenceTrack";
use base "GeneSeqerSequence";

do 'SITEDEF.pl';

sub _init {
  my $self = shift;

  $self->{'MOD_DAS_SET_FeatureTypeCategory'} = $self->_makeClosure('_DAS_SET_FeatureTypeCategory');

  $self->SUPER::_init(@_);

  $self->{sequenceTYPE} = 'EST';
  $self->{gsqATYPE}     = 'C';

  $self->{db_table}  = ( exists( $self->{db_table} ) )  ? $self->{db_table}  : 'est';
  $self->{trackname} = ( exists( $self->{trackname} ) ) ? $self->{trackname} : 'EST';
  $self->{'das_supported_types'} = ( exists( $self->{'das_supported_types'} ) ) ? $self->{'das_supported_types'} : 
	{ 'expressed_sequence_match' => {typelist=>1,method=>$self->{'trackname'}}};
	##{ 'expressed_sequence_match' => {typelist=>1}, 'five_prime_splice_site' => {typelist=>1}, 'three_prime_splice_site' => {typelist=>1} };

  my $DB_TABLE = $self->{db_table};

  $self->{seqQUERY} = qq{SELECT e.gi,e.acc,e.version,e.description,e.seq,e.type FROM ${DB_TABLE} as e WHERE (?) IN (e.gi,e.acc)	};

  if ( exists( $self->{chrVIEWABLE} ) && $self->{chrVIEWABLE} ) {
    $self->{SQL_BASE} = qq{SELECT e.gi,e.type,e.description,p.uid,p.gseg_uid,p.E_O,p.sim,p.cov,p.G_O,p.chr,p.l_pos,p.r_pos,p.pgs,p.isCognate,p.pairUID,e.acc,e.version,e.seq,p.mlength,p.pgs_lpos,p.pgs_rpos,p.gseg_gaps,p.pgs_gaps FROM ${DB_TABLE}_good_pgs AS p INNER JOIN ${DB_TABLE} as e USING (gi) };

    $self->{gsqPGS_QUERY}    = qq{$self->{SQL_BASE} WHERE (p.uid=?) };
    $self->{gsqPGS_EX_QUERY} = qq{SELECT num,gseg_start,gseg_stop,pgs_start,pgs_stop,score,pgs_uid FROM ${DB_TABLE}_good_pgs_exons WHERE (pgs_uid=?) };
    $self->{gsqPGS_IN_QUERY} = qq{SELECT num,gseg_start,gseg_stop,Dscore,Dsim,Ascore,Asim,pgs_uid FROM ${DB_TABLE}_good_pgs_introns WHERE (pgs_uid=?) };

    $self->{chrREGION_QUERY} = qq{$self->{SQL_BASE} WHERE (p.chr=?)&&(p.r_pos>=?)&&(p.l_pos<=?) };
    $self->{chrDESC_QUERY}   = qq{$self->{SQL_BASE} WHERE MATCH (description) AGAINST ( ? IN BOOLEAN MODE) };
    $self->{chrUID_QUERY}    = qq{SELECT p.gi FROM ${DB_TABLE}_good_pgs as p WHERE (p.uid=?) };
    $self->{chrQUERY}        = qq{SELECT p.uid,p.gseg_uid,p.E_O,p.sim,p.cov,p.G_O,p.chr,p.l_pos,p.r_pos,p.pgs,p.isCognate,p.pairUID FROM ${DB_TABLE}_good_pgs as p WHERE (p.gi=?) };
  }

  if ( ( exists( $self->{BACVIEWABLE} ) && $self->{BACVIEWABLE} ) || $self->{gsegSRC} ) {
    $self->{gsegSQL_BASE} =
qq{SELECT e.gi,e.type,e.description,gp.uid,gp.E_O,gp.sim,gp.cov,gp.gseg_gi,gp.G_O,gp.l_pos,gp.r_pos,gp.pgs,gp.isCognate,gp.pairUID,gp.mergeNOTE,e.acc,e.version,e.seq,gp.mlength,gp.pgs_lpos,gp.pgs_rpos,gp.gseg_gaps,gp.pgs_gaps FROM gseg_${DB_TABLE}_good_pgs AS gp INNER JOIN ${DB_TABLE} AS e USING (gi) };

    $self->{gseggsqPGS_QUERY}    = qq{$self->{gsegSQL_BASE} WHERE (gp.uid=?) };
    $self->{gseggsqPGS_EX_QUERY} = qq{SELECT num,gseg_start,gseg_stop,pgs_start,pgs_stop,score,pgs_uid FROM gseg_${DB_TABLE}_good_pgs_exons WHERE (pgs_uid=?) };
    $self->{gseggsqPGS_IN_QUERY} = qq{SELECT num,gseg_start,gseg_stop,Dscore,Dsim,Ascore,Asim,pgs_uid FROM gseg_${DB_TABLE}_good_pgs_introns WHERE (pgs_uid=?) };

    $self->{gsegREGION_QUERY} = qq{$self->{gsegSQL_BASE} WHERE (gp.gseg_gi=?)&&(gp.r_pos>=?)&&(gp.l_pos<=?) };
    $self->{gsegDESC_QUERY}   = qq{$self->{gsegSQL_BASE} WHERE MATCH (description) AGAINST ( ? IN BOOLEAN MODE) };
    $self->{gsegUID_QUERY}    = qq{SELECT gp.gi FROM gseg_${DB_TABLE}_good_pgs as gp WHERE (gp.uid=?) };
    $self->{gsegQUERY}        = qq{SELECT gp.uid,gp.E_O,gp.sim,gp.cov,gp.gseg_gi,gp.G_O,gp.l_pos,gp.r_pos,gp.pgs,gp.isCognate,gp.mergeNOTE FROM gseg_${DB_TABLE}_good_pgs as gp WHERE (gp.gi=?) };
  }

  $self->{MULTI_ID_QUERY} = sub {
    my ( $BASE, $idlist ) = @_;
    return $BASE . " WHERE (e.gi IN ($idlist))||(acc IN ($idlist))||(clone IN ($idlist))";
  };

  $self->{'das_QUERY'} = [
                           "SELECT e.gi as gi, ex.num as exon_num, ex.gseg_start as exon_start, ex.pgs_start as target_start, ex.gseg_stop as exon_stop, ex.pgs_stop as target_stop, ex.score as score, ex.pgs_uid as pgs_uid, e.isCognate FROM ${DB_TABLE}_good_pgs_exons as ex JOIN ${DB_TABLE}_good_pgs as e WHERE (ex.pgs_uid = e.uid)",
                           "SELECT e.gi as gi, i.num as intron_num, i.gseg_start as intron_start, i.gseg_stop as intron_stop, i.Dscore as donor_score, i.Ascore as acceptor_score, i.pgs_uid as pgs_uid, e.isCognate FROM ${DB_TABLE}_good_pgs_introns as i JOIN ${DB_TABLE}_good_pgs as e WHERE (i.pgs_uid = e.uid)"
  ] if(!exists($self->{'das_QUERY'}));
  $self->{'dasSEGMENT_QUERY'} = [ $self->{'das_QUERY'}->[0] . "&&(e.chr = ?)", $self->{'das_QUERY'}->[1] . "&&(e.chr = ?)" ] if(!exists($self->{'dasSEGMENT_QUERY'}));
  $self->{'dasREGION_QUERY'} = [ $self->{'dasSEGMENT_QUERY'}->[0] . "&&(e.r_pos >= ?)&&(e.l_pos <= ?)", $self->{'dasSEGMENT_QUERY'}->[1] . "&&(e.r_pos >= ?)&&(e.l_pos <= ?)" ] if(!exists($self->{'dasREGION_QUERY'}));

}

sub _DAS_SET_FeatureTypeCategory {
  my ($DSOobj,$pgsHR) = @_;
  return ($pgsHR->{'iscognate'} eq 'True')?"CognateEST":"NoncognateEST";
}

1;    

