function toggleSELECT(id){
  if(document.getElementById(id).className == "selected"){
    document.getElementById(id).className = "unselected";
  }else{
    document.getElementById(id).className = "selected";
  }
}
function nosort(id){
  document.getElementById(id + 'desc').style.display = 'none';
  document.getElementById(id + 'asc').style.display = 'none';
  document.getElementById(id + 'none').style.display = 'inline';
  update_sortORT();
}
function ascend(id){
  document.getElementById(id + 'none').style.display = 'none';
  document.getElementById(id + 'desc').style.display = 'none';
  document.getElementById(id + 'asc').style.display = 'inline';
  update_sortORT();
}
function descend(id){
  document.getElementById(id + 'none').style.display = 'none';
  document.getElementById(id + 'asc').style.display = 'none';
  document.getElementById(id + 'desc').style.display = 'inline';
  update_sortORT();
}
function update_sortORT(){
  document.getElementById('sort_ort').value = '';
  for(var key in sortORT){
    document.getElementById('sort_ort').value += key + "=>" + sortORT[key] + ",";	
  }
}
function DISup(col){
  if(colOrder[col] > 1){
    var curRow = colOrder[col];
    var swpCol = colRow[(curRow - 1)];
    swap_innerHTML('row_' + (curRow - 1), 'row_' + curRow);
    colOrder[swpCol]++;
    colOrder[col]--;
    colRow[curRow-1]=col;
    colRow[curRow]=swpCol;
  }
  update_col();
}
function DISdown(col){
  if(colOrder[col] < colRowCNT){
    var curRow = colOrder[col];
    var swpCol = colRow[(curRow + 1)];
    swap_innerHTML('row_' + (curRow + 1), 'row_' + curRow);
    colOrder[swpCol]--;
    colOrder[col]++;
    colRow[curRow+1]=col;
    colRow[curRow]=swpCol;
  }
  update_col();
}
function swap_innerHTML(id1,id2){
  var newHTML =  document.getElementById(id1).innerHTML;
  document.getElementById(id1).innerHTML = document.getElementById(id2).innerHTML;
  document.getElementById(id2).innerHTML = newHTML;
}
function update_col(){
  document.getElementById('col_order').value = '';
  for(var key in colOrder){
    document.getElementById('col_order').value += key + "=>" + colOrder[key] + ",";	
  }
}
function changeSortOrder(col,newINDEX){
  var curINDEX = sortOrder[col];
  var minINDEX = Math.min(sortOrder[col],newINDEX);
  var maxINDEX = Math.max(sortOrder[col],newINDEX);
  document.getElementById('sort_order').value = '';
  for(var soCol in sortOrder){
    if(soCol == col){
      sortOrder[soCol] = newINDEX;
    }else if((sortOrder[soCol] >= minINDEX)&&(sortOrder[soCol] <= maxINDEX)){
      if(newINDEX < curINDEX){
        sortOrder[soCol]++;
      }else{
        sortOrder[soCol]--;
      }
      updateSOselect(soCol);
    }
    document.getElementById('sort_order').value += soCol + "=>" + sortOrder[soCol] + ",";	
  }
  return 1;
}
function updateSOselect(col){
  document.getElementById('sortOrder_' + col).selectedIndex = sortOrder[col] - 1;
  return 1;
}
function openMENU(IDpre){
  document.getElementById(IDpre + 'open').style.display = 'inline';
  document.getElementById(IDpre + 'closed').style.display = 'none';  
  document.getElementById(IDpre + 'options').style.display = 'block';  
  return 1;
}
function closeMENU(IDpre){
  document.getElementById(IDpre + 'closed').style.display = 'inline';
  document.getElementById(IDpre + 'open').style.display = 'none';  
  document.getElementById(IDpre + 'options').style.display = 'none';  
  return 1;
}
function AIenable (grp){
  document.getElementById('AIscore1').disabled = true;
  document.getElementById('AIscore2').disabled = true;
  document.getElementById('AICscore1').disabled = true;
  document.getElementById('AICscore2').disabled = true;
  document.getElementById('AICparam1').disabled = true;
  document.getElementById('AICparam2').disabled = true;
  document.getElementById('AICparam3').disabled = true;
  document.getElementById('AICparam4').disabled = true;
  
  if(grp == 1){
    document.getElementById('AIscore1').disabled = false;
    document.getElementById('AIscore2').disabled = false;
    document.getElementById('AIscore1').focus();
    document.getElementById('AIscore1').select();
  }else if(grp == 2){
    document.getElementById('AICscore1').disabled = false;
    document.getElementById('AICscore2').disabled = false;
    document.getElementById('AICparam1').disabled = false;
    document.getElementById('AICparam2').disabled = false;
    document.getElementById('AICparam3').disabled = false;
    document.getElementById('AICparam4').disabled = false;
    document.getElementById('AICscore1').focus();
    document.getElementById('AICscore1').select();
  }
  return 1;
}
function ISenable (grp){
  document.getElementById('ISpct1').disabled = true;
  document.getElementById('ISpct2').disabled = true;
  document.getElementById('ISconf1').disabled = true;
  document.getElementById('ISconf2').disabled = true;
  document.getElementById('ISuns1').disabled = true;
  document.getElementById('ISuns2').disabled = true;

  if(grp == 1){
    document.getElementById('ISpct1').disabled = false;
    document.getElementById('ISpct2').disabled = false;
    document.getElementById('ISpct1').focus();    
    document.getElementById('ISpct1').select();    
  }else if(grp == 2){
    document.getElementById('ISconf1').disabled = false;
    document.getElementById('ISconf2').disabled = false;
    document.getElementById('ISuns1').disabled = false;
    document.getElementById('ISuns2').disabled = false;
    document.getElementById('ISconf1').focus();    
    document.getElementById('ISconf1').select();    
  }
  return 1;
}
function SCSenable (grp){
  document.getElementById('SCSpct1').disabled = true;
  document.getElementById('SCSpct2').disabled = true;

  if(grp == 1){
    document.getElementById('SCSpct1').disabled = false;
    document.getElementById('SCSpct2').disabled = false;
    document.getElementById('SCSpct1').focus();    
    document.getElementById('SCSpct1').select();    
  }
  return 1;
}
function BSenable(opid,obj){
  if(obj.value == 1){
    obj.value = 0;
    document.getElementById(opid).disabled = true;
    document.getElementById(opid + '_between_0').disabled = true;
    document.getElementById(opid + '_between_1').disabled = true;
    document.getElementById(opid + '_equal').disabled = true;
    document.getElementById(opid + '_greater').disabled = true;
    document.getElementById(opid + '_less').disabled = true;
  }else{
    obj.value = 1;
    document.getElementById(opid).disabled = false;
    document.getElementById(opid + '_between_0').disabled = false;
    document.getElementById(opid + '_between_1').disabled = false;
    document.getElementById(opid + '_equal').disabled = false;
    document.getElementById(opid + '_greater').disabled = false;
    document.getElementById(opid + '_less').disabled = false;
  }
}
function BSopSelect(opid,op){
  document.getElementById(opid + 'span_between').className = 'unselected';
  document.getElementById(opid + 'span_equal').className = 'unselected';
  document.getElementById(opid + 'span_greater').className = 'unselected';
  document.getElementById(opid + 'span_less').className = 'unselected';
  document.getElementById(opid + 'span_' + op).className = 'selected';  
}
function goto_page (sellist){
  document.getElementById('resultOFFSET').value = (sellist.value * document.getElementById('returnLIMIT').value);
  document.guiFORM.submit();
}
