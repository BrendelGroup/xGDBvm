//var seqMenuArr = new Array();

var seqMenuArr = new Object();
var highlightedRow = "";
function seqMenu(id,event){
    var smHeight = 30;

    document.getElementById("seqMenuTitle").innerHTML = "&nbsp;" + seqMenuArr[id][0] + " Menu";

    for (var i = 2; i< seqMenuArr[id].length; i++){
      document.getElementById("seqMenuRow" + i).innerHTML = "<a href='" + seqMenuArr[id][i][0] +"' onClick='hideCurrentPopup();' target='_blank'>" + seqMenuArr[id][i][1] + "</a>";
      smHeight = smHeight + 20;
    }

    if (seqMenuArr[id][1] == 1){
	document.getElementById("seqMenuRow" + i).innerHTML = "<a href=\"javascript:toggleSeq('" + id + "',0);\" onClick='hideCurrentPopup();' >Hide in Alignment</a>";
        seqMenuArr[id][1] = 0;
        smHeight = smHeight + 20;
    }else if(seqMenuArr[id][1] != 2){
	document.getElementById("seqMenuRow" + i).innerHTML = "<a href=\"javascript:toggleSeq('" + id + "',1);\" onClick='hideCurrentPopup();' >Show in Alignment</a>";
        seqMenuArr[id][1] = 1;
        smHeight = smHeight + 20;
    }
var gFRAME = parent.frames["clgraph"];
var imgw = (gFRAME.innerWidth)?gFRAME.innerWidth:(gFRAME.document.documentElement && gFRAME.document.documentElement.clientWidth)?gFRAME.document.documentElement.clientWidth:gFRAME.document.body.clientWidth;

    
    if (imgw - event.clientX < 150){
      xOffset = -150;  
    }else{   
      xOffset = 2;
    }

    if (event.clientY > 300- smHeight){ // 200 = 300 - 100 (size of menu)
      yOffset = -(smHeight - (300 - event.clientY));  
    }else{   
      yOffset = 2;
    }
    
    if (highlightedRow != ""){
        myHide();
    }

    showPopup('seqMenu',event);
    highlightedRow = id + "s";
    top.frames[5].document.getElementById(id + "s").style.background = "yellow";
    
    return;
    
}

function myHide(){
  top.frames[5].document.getElementById(highlightedRow).style.background = "white";
  return;
}

function focusStruct(id){
    
    changeObjectVisibility('seqHL', 'visible');
    document.getElementById('seqHL').style.width = structWid[id];
    moveObject('seqHL',structXPosL[id], findPosY(document.getElementById('tview')) + structYPos[id] - document.getElementById('tview_div').scrollTop - 5);
   
}

function unfocusStruct(id){
   changeObjectVisibility('seqHL', 'hidden');
}

function findPosY(obj)
{
	var curtop = 0;
	if (obj.offsetParent)
	{
		while (obj.offsetParent)
		{
			curtop += obj.offsetTop
			obj = obj.offsetParent;
		}
	}
	else if (obj.y)
		curtop += obj.y;
	return curtop;
}

function toggleSeq(id,turn){
  isIE = navigator.userAgent.toLowerCase().indexOf("msie") ? 1 : 0;

  top.frames[5].document.getElementById(id + "s").style.display = (turn == 0) ? "none" : (isIE) ? "block" : "table-row";
  top.frames[6].document.getElementById(id).style.display = (turn == 0) ? "none" : (isIE) ? "block" : "table-row";
  return;
}

function smAddMenu(id,title,on){
  seqMenuArr[id] = new Array();
  seqMenuArr[id][0] = title;
  seqMenuArr[id][1] = on;
  return;
}

function smAddRow(id,linkName,link){
  seqMenuArr[id][seqMenuArr[id].length] = new Array();
  seqMenuArr[id][seqMenuArr[id].length-1][0] = link;
  seqMenuArr[id][seqMenuArr[id].length-1][1] = linkName;
  return;
}


