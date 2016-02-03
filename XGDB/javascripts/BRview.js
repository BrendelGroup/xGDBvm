
function getRECORD(resid,SeqID,CHR,LPOS,RPOS){
  document.guiFORM.resid.value = resid;
  document.guiFORM.seqUID.value = SeqID;
  document.guiFORM.chr.selectedIndex = CHR - 1;
  document.guiFORM.l_pos.value = LPOS;
  document.guiFORM.end.value = RPOS;

  submitTYPE(3);
  return 1;
}
