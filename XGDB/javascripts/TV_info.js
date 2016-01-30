function mo(element,pgsID,num){
  if(element == -1){
    document.infoFORM.seqName.value = '';
    document.infoFORM.seqSim.value  = '';
    document.infoFORM.seqCov.value  = '';
    document.infoFORM.regLFT.value  = '';
    document.infoFORM.regRGT.value  = '';
    document.infoFORM.seqDesc.value = '';
  }else{
    seqInfo = eval('top.GSQ' + pgsID);
    document.infoFORM.seqName.value = seqInfo[0];
    document.infoFORM.seqSim.value  = seqInfo[1];
    document.infoFORM.seqCov.value  = seqInfo[3];
    document.infoFORM.regLFT.value  = seqInfo[4];
    document.infoFORM.regRGT.value  = seqInfo[5];
    document.infoFORM.seqDesc.value = seqInfo[6];
  }
  return 1;
}     
