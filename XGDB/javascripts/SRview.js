
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

var checkflag = "false";
function checkAll(field) {
  if (checkflag == "false") {
    for (i = 0; i < field.length; i++) {
        field[i].checked = true;
    }
    checkflag = "true";
  }
  else {
    for (i = 0; i < field.length; i++) {
        field[i].checked = false;
    }
    checkflag = "false";
  }
}

var trackflag = "true";
function checkTrack(trackList) {
  trackArray = trackList.split(",");
  var y=document.getElementById('CheckTrackControl');
  if (trackflag == "false") {
    for (i = 0; i < trackArray.length; i++) {
        trackId = "track" + trackArray[i];
        x = document.getElementsByName(trackId);
        for (j = 0; j < x.length; j++) {
          x[j].checked = true;
        }
    }
    trackflag = "true";
    y.value   = "Uncheck All";
  }
  else {
    for (i = 0; i < trackArray.length; i++) {
        trackId = "track" + trackArray[i];
        x = document.getElementsByName(trackId);
        for (j = 0; j < x.length; j++) {
          x[j].checked = false;
        }
    }
    trackflag = "false";
    y.value   = "Check All";
  }
}

function multiRev(revURL) {
  y = document.getElementsByName("CheckAll");
  var inputData = "";
  for (i = 0; i < y.length; i++) {
    if (y[i].checked == true) {
      if (y[i].value == "on") {
      }
      else {
        if (inputData == "") {
          inputData = y[i].value;
        }
        else {
          inputData = inputData + "(A)" + y[i].value;
        }
      }
    }
  }
  
  document.guiFORM.seqId.value = inputData;
  document.guiFORM.action = revURL;
  document.guiFORM.name   = 'contigForm';
  document.guiFORM.method = 'get';
  document.guiFORM.target = 'Sequence Retrieval System';
  document.guiFORM.submit();
}

