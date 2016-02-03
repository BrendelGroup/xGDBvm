//Constants
var WSIZES   = new Array(1000,2000,5000,10000,20000,50000,100000,150000);

function changeVersion(){
  submitTYPE(1);
  return 0;
}

function showCTXT(chr,start,end){
  l_pos = Math.max((start - 500),1);
  r_pos = Math.min((end + 500),ChrLen[chr-1]);

  document.guiFORM.chr.selectedIndex = chr - 1;
  document.guiFORM.l_pos.value = l_pos;
  document.guiFORM.r_pos.value = r_pos;

  submitTYPE(2);
  return 1;
}
