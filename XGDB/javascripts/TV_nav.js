function mo(element,pgsID,num){
  var displayVALUE = (document.all)?'block':'table-row';
  if((element == -1)||(num == -1)){
    document.getElementById('exonDESC').style.display   = 'none';
    document.getElementById('intronDESC').style.display = 'none';
  }else if(element == 0){
    seqInfo = eval('top.GSQex' + pgsID + '_' + num);
    document.infoFORM.exNUM.value  = seqInfo[0];
    document.infoFORM.exgLFT.value = seqInfo[1];
    document.infoFORM.exgRGT.value = seqInfo[2];
    document.infoFORM.exeLFT.value = seqInfo[3];
    document.infoFORM.exeRGT.value = seqInfo[4];
    document.infoFORM.exSim.value  = seqInfo[5];
    document.getElementById('intronDESC').style.display = 'none';
    document.getElementById('exonDESC').style.display   = displayVALUE;
  }else if(element == 1){
    seqInfo = eval('top.GSQin' + pgsID + '_' + num);
    document.infoFORM.inNUM.value  = seqInfo[0];
    document.infoFORM.inLFT.value  = seqInfo[1];
    document.infoFORM.inRGT.value  = seqInfo[2];
    document.infoFORM.dSCORE.value  = seqInfo[3];
    document.infoFORM.dSim.value  = seqInfo[4];
    document.infoFORM.acSCORE.value  = seqInfo[5];
    document.infoFORM.acSim.value  = seqInfo[6];
    document.getElementById('intronDESC').style.display = displayVALUE;
    document.getElementById('exonDESC').style.display   = 'none';
  }
  return 1;
}     
