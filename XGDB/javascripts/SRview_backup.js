
function getRECORD(resid,SeqID,CHR,LPOS,RPOS){
  document.guiFORM.resid.value = resid;
  document.guiFORM.seqUID.value = SeqID;
  document.guiFORM.chr.selectedIndex = CHR - 1;
  document.guiFORM.l_pos.value = LPOS;
  document.guiFORM.end.value = RPOS;

  submitTYPE(3);
  return 1;
}

function getCONTEXT(resid,SeqID,CHR,LPOS,RPOS){
  document.guiFORM.resid.value = resid;
  document.guiFORM.seqUID.value = SeqID;
  document.guiFORM.chr.selectedIndex = CHR - 1;
  document.guiFORM.l_pos.value = LPOS;
  document.guiFORM.end.value = RPOS;

  part1 = document.guiFORM.tracksvar.value.split("|");
  tracksArr = part1[0].substring(0,part1[0].length-1).split(",");
  openArr = part1[1].substring(0,part1[1].length-1).split(",");

  newtracksvar = part1[0] + "|";
  for (i=0;i<openArr.length;i++){
    if (tracksArr[i] != "2"){
      newtracksvar = newtracksvar + openArr[i] + ",";
    }else{
      newtracksvar = newtracksvar + "1,";
    }

  }
  document.guiFORM.tracksvar.value = newtracksvar;
  submitTYPE(2);
  return 1;
}
