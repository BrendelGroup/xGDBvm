//Constants
var WSIZES   = new Array(1000,2000,5000,10000,20000,50000,100000,150000);

function showCTXT(chr,start,end,WsizeINDX){

  var mySIZE = 4;
  if((end - start) >= 149999){
    mySIZE = 7;
  }else if((end - start) >= 99999){
    mySIZE = 6;
  }else if((end - start) >= 49999){
    mySIZE = 5;
  }else if((end - start) >= 19999){
    mySIZE = 4;
  }else if((end - start) >= 9999){
    mySIZE = 3;
  }else if((end - start) >= 4999){
    mySIZE = 2;
  }else if((end - start) >= 1999){
    mySIZE = 1;
  }else{
    mySIZE = 0;
  }

  l_pos =Math.max(start-250,1);
  r_pos = Math.min(end+250,ChrLen[chr-1]);

  document.guiFORM.chr.selectedIndex = chr - 1;
  document.guiFORM.wsize.value = mySIZE;
  document.guiFORM.l_pos.value = l_pos;
  document.guiFORM.end.value = r_pos;

  submitTYPE(2);
  return 1;
}

function getRECORD(resid,SeqID,CHR,LPOS,RPOS){
  document.guiFORM.resid.value = resid;
  document.guiFORM.seqUID.value = SeqID;
  document.guiFORM.chr.selectedIndex = CHR - 1;
  document.guiFORM.l_pos.value = LPOS;
  document.guiFORM.end.value = RPOS;

  submitTYPE(3);
  return 1;
}

function getGBK(resid,SeqID){
  document.guiFORM.dbid.value = resid;
  document.guiFORM.seqUID.value = SeqID;

  submitTYPE(3);
  return 1;
}
