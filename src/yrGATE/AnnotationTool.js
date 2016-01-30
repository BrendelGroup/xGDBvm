// yrGATE
// (c) 2006

//--variables and containers--//
radioArr         = Array();
var newModel 	 = new Array();
var exonLIST     = new Array();
var intronLIST   = new Array();
var CODRFeatLIST = new Array();
var UserDefinedSources = new Object();
var UserDefinedExons   = new Object();
var SortedUserExonsArr = new Array();
var lastclicked;
var lastEXON = "";
var lastID = "";
var last_action  = "";
var scrollGlobal = 0;
var Cstrand      = 0;  // forward = 1, reverse=0
var SFeatures    = 1;
var CODRFeatures = 1;
var FStart       = 0;
var FStop        = 0;
var Jdirection   = 1;
var hideB        = 0; // 0 show all, 1 hide unselected
var browser_type = navigator.appName;
var agt=navigator.userAgent.toLowerCase();
var is_major = parseInt(navigator.appVersion);
var hasBegan = false;
window.name = "UCAwindow";

function scoreStructure() {
    efield = "";
        chr = document.forms[formName].chr.value;
        exonString = document.forms[formName].UCAstruct.value;        
        end = document.forms[formName].end.value;
        start = document.forms[formName].start.value;
        strand = (document.forms[formName].UCAstrand[0].checked)? 1:0;
	gseqedits = document.forms[formName].GSeqEdits.value;
        elist = document.forms[formName].Elist.value;
        cds_start = document.forms[formName].UCAcdsstart.value;
        cds_end = document.forms[formName].UCAcdsend.value;
        owner = document.forms[formName].owner.value;
        createTime = document.forms[formName].createTime.value;
        xmlhttp = new XMLHttpRequest();
        $.ajax({
            url: './makeGFF.pl',
            data: { 'createTime' : createTime, 'strand' : strand, 'exons' : exonString, 'end':end, 'start':start, 
                    'edits':gseqedits, 'cdsStart':cds_start, 'cdsEnd':cds_end, 'owner':owner, 'chr':chr
        },
        success: function(data, textStatus, jqXHR) {
          gaevalCall();
          },
        error: function() {
	  alert("makeGFF failed to execute");
	}
        });

}


function gaevalCall() {
        gdb = document.forms[formName].gdb.value;
	$.ajax({
		'type': 'GET',
		'url': 'makeGAEVAL.pl',
                'gdb': gdb,
		'async':false,
		'success': function(data) {
		data = '<td>&nbsp;&nbsp;&nbsp;&nbsp;' + data;
		data = data.replace("\n",'<br />&nbsp;&nbsp;&nbsp;&nbsp;');
		data = data + '</td>';
		//alert(data);
		$('#your_score').html(data); }
		});
         hasBegan = false;
}


//--Evidence Plot and Evidence Table Functions--//

//This function handles shift click on exon glyphs, it requires a glyph or id has been previously clicked.
function isShift(event, exon_start, exon_end, strand) {
	event.preventDefault();
	thisCoords = new Array(exon_start, exon_end);
	lastID = (isStructure)? document.forms[formName].UCAstruct.value : "";
        if (strand) {
          Cstrand = 1;
          document.forms[formName].UCAstrand[1].checked = 1;
	  //document.forms[formName].UCAstrand[1].checked = 0;  // still missing a way to get exon directionality from parent id
	} else { Cstrand = 0; }
        if (event.shiftKey) {
		if( last_action == "clickExon" && lastEXON !="" && lastID=="" ) {  // shift clicked a single exon, after clicking a single exon
			AddExonToExon(thisCoords);
		} else if (lastID!="" && lastEXON !="") {  // shift clicked a single exon, after clicking an ID
			AddExonToID(thisCoords);
		} else if (lastEXON == "" && lastEXON =='undefined') {
			GraphicExonSelect(exon_start, exon_end);
			last_action = "clickExon";
		}
	} else {
		GraphicExonSelect(exon_start, exon_end);  //regular click event calls previous functionality
		last_action = "clickExon";
	}
	lastEXON = exon_start + "  " + exon_end;
	return 0;
}

//This function handles the shift click on model IDs
function isShiftID(event, model, strand) {
	event.preventDefault();	
	lastID = (isStructure)? document.forms[formName].UCAstruct.value : "";  // allows multiple shift clicks
  	if (event.shiftKey) {
		if (lastID!="" && typeof lastID != 'undefined') {
		  AddIDtoID(model);
		} else if (lastID == 'undefined' && lastID == "") {
		  SelectStruct(model);
		  last_action = "clickID";
		}
	} else {
    	SelectStruct(model);
		last_action = "clickID";
  	}

}

function SelectExonGlyph(exonstart, exonend) {}  //null function necessary to make the exon glyphs links
function SelectID(model){ alert("SelectID");}  //null functions necessary to make model IDs links
	
function AddExonToExon(exon_coords) {
	thisCoords = exon_coords;
	thatCoords = lastEXON.split(/\s+/);
	adjacent = Adjacency(new Array(thisCoords[0] + '..' + thisCoords[1]), new Array(lastEXON) );
	yourStrux = document.forms[formName].UCAstruct.value;
	var strand = (yourStrux.match(RegExp("[cC]"))) ? 1:0;
	yourStrux = yourStrux.match(/\d+\D\D\d+/g);
	yourStrux.push(adjacent);
	yourStrux = SubtractOverlap(yourStrux);
	SelectStruct((strand)? 'complement(join(' + yourStrux.join() : 'join(' + yourStrux.join());
}

function AddExonToID(exon_coords) {
	newStruc = new Array();
	yourStrux = document.forms[formName].UCAstruct.value;  
	strand = (yourStrux.match(RegExp("[cC]"))) ? 1:0;
	yourStrux = yourStrux.replace(/\n/g,"");
	exonpairs = yourStrux.match(/\d+\D\D\d+/g);
	olap = false;	
	thisCoords = exon_coords;
	adjacent = Adjacency(exonpairs, new Array(exon_coords[0] + '..' + exon_coords[1]));
	if (exonpairs){
		for (var i=0;i<exonpairs.length;i++){
		   var coord = exonpairs[i].match(/\d+/g);
		   if (Overlap(thisCoords, coord) !=0) {    // if there is overlap, merge the structure
				olap = true;				
				minPoint = Math.min(Math.min(thisCoords[0],thisCoords[1]), Math.min(coord[0],coord[1]));
				maxPoint = Math.max(Math.max(thisCoords[0],thisCoords[1]), Math.max(coord[0],coord[1]));
				newStruc.push(minPoint + '..' + maxPoint);
			} else {
				newStruc.push(coord[0] + '..' + coord[1]);
			}
		}
		if (olap == false) {
			newStruc.push(adjacent);
			newStruc = SubtractOverlap(newStruc);	
			SelectStruct((strand) ? "complement(join(" + newStruc.join() : newStruc.join());
		} else {
			newStruc = SubtractOverlap(newStruc);
			SelectStruct((strand) ? "complement(join(" + newStruc.join() : newStruc.join());
		}
	}
}

function AddIDtoID(model_clicked) {
		yourStrux = document.forms[formName].UCAstruct.value;  	// Your Structure currently	
		strand = (yourStrux.match(RegExp("[cC]"))) ? 1:0;
		yourStrux = yourStrux.replace(/\n/g,"");
  		exonpairs = yourStrux.match(/\d+\D\D\d+/g);            // grab the exons from your structure
		shiftStrux = model_clicked.replace(/\n/g,"");
		shiftexons = shiftStrux.match(/\d+\D\D\d+/g);		   // grab the shift clicked exons
		newStrux = new Array();
		olap = false;
		adjacent = Adjacency(exonpairs, shiftexons);
		if (exonpairs) {
			olap = false;
    		for (var i=0;i<exonpairs.length;i++){
				for (var j=0;j<shiftexons.length;j++){
					var coords = shiftexons[j].match(/\d+/g);
      		   		var coord = exonpairs[i].match(/\d+/g);
						if (Overlap(coords, coord) !=0) {
							olap = true;

							minPoint = Math.min(Math.min(coord[0], coord[1]), Math.min(coords[0],coords[1]));
							maxPoint = Math.max(Math.max(coord[0], coord[1]), Math.max(coords[0],coords[1]));
							exonString = minPoint + '..' + maxPoint;
							if (!Within(newStrux, exonString)){

								newStrux.push(exonString);
							}
						} else {
							lastString = Math.min(parseInt(coord[0]), parseInt(coord[1])) + '..' + Math.max(parseInt(coord[0]), parseInt(coord[1]));
							exonString = Math.min(parseInt(coords[0]), parseInt(coords[1])) + '..' + Math.max(parseInt(coords[0]), parseInt(coords[1]));					
							if (!Within(newStrux, exonString)){
								newStrux.push(exonString);
							}
							if (!Within(newStrux, lastString)){
								newStrux.push(lastString);
							}
						}
					}
				}
			
			if (!olap) {	
				newStrux.push(adjacent);
				newStrux = SubtractOverlap(newStrux);
				SelectStruct((strand) ? "complement(join(" + newStrux.join() : newStrux.join());			
			} else {
				newStrux = SubtractOverlap(newStrux);
				SelectStruct((strand) ? "complement(join(" + newStrux.join() : newStrux.join());
			}
		}
	 	lastID = "";
		lastEXON = "";
}

// selects exon in evidence table if exists, else adds UDE
function eTableSelect(a,b){
  tStr = a + "  " + b;
  for (j=1;j<groupAmt;j++){
    if (!document.forms[formName].elements['e'+j].length){
      if (document.forms[formName].elements['e'+j].value == tStr){
	selectradio(j,tStr,0);
        return;
      }
    }else{
    for (i=0;i<document.forms[formName].elements['e'+j].length;i++){
      if (document.forms[formName].elements['e'+j][i].value == tStr){
	selectradio(j,tStr,0);
	return;
      }
    }
    }
  }
  return "addUDE";  //this only has meaning when called from User Defined Exon functions, and not when called from Graphic Exon Select
}

// This function is called everytime the user clicks on an exon glyph.
function GraphicExonSelect(a,b){
    newL = Math.min(a,b);
    newR = Math.max(a,b);
    if ( (newL < startCoord)||(newR > document.forms[formName].end.value)){
    if (confirm("Only exons in the current range " + startCoord + "-" + document.forms[formName].end.value + " can be entered.\n\n Would you like to expand the range to accomodate this exon, "+newL+ " " + newR + "?") ){
      document.forms[formName].RangeStart.value = Math.min(startCoord,newL);
      document.forms[formName].RangeEnd.value = Math.max(document.forms[formName].end.value,newR);
      EvidenceRangeSet();
      document.forms[formName].submit();
    }
    return;
    }
    response = eTableSelect(newL,newR);
    if (response == "addUDE") {
      addUDE(newL, newR, "Manual", "Manual");
    }
  return;
}

//This function is called by clicking radio buttons as well as clicking exon glyphs, it selects radio buttons (therefore adding exons to Your Strux)
function selectradio(r,clicked_exon,mouse_click){
  olapped = 0;
  var radioObj;
  var tradioObj;
  lastclicked=r;

  // check radio for mac
  if (!document.forms[formName].elements['e'+r].length){
    document.forms[formName].elements['e'+r].checked = true;
    radioObj = document.forms[formName].elements['e'+r];
    tradioObj = document.forms[formName].elements['e'+r];
  }else{
    for (j=0;j<document.forms[formName].elements['e'+r].length;j++){
      if (document.forms[formName].elements['e'+r][j].value == clicked_exon){
        document.forms[formName].elements['e'+r][j].checked = true;
	tradioObj = document.forms[formName].elements['e'+r][0];
        radioObj = document.forms[formName].elements['e'+r][j];
      }
    }
  }
  if (radioArr[r] != clicked_exon){ // add exon
    rArr = clicked_exon.split(/\s+/);
    for (var i in UserDefinedExons){
      tArr = i.split("  ");
      if ( (Math.min(tArr[0],tArr[1]) <= Math.max(rArr[0],rArr[1]))&&(Math.max(tArr[0],tArr[1]) >= Math.min(rArr[0],rArr[1])) ){
        UserDefinedExons[i] = "N";
      }
    }

    radioArr[r] = clicked_exon;
    for (i=0;i<radioArr.length;i++){
      if ((radioArr[i])&&(i!=r)){
      	tArr = radioArr[i].split(/\s+/);
        if ( (Math.min(tArr[0],tArr[1]) <= Math.max(rArr[0],rArr[1]))&&(Math.max(tArr[0],tArr[1]) >= Math.min(rArr[0],rArr[1])) ){ // substract overlapping
	  		if (!document.forms[formName].elements['e'+i].length){
            	document.forms[formName].elements['e'+i].checked = false;
	  		}else{
            	for (j=0;j<document.forms[formName].elements['e'+i].length;j++){
              	document.forms[formName].elements['e'+i][j].checked = false;
            	}
	  		}
	  radioArr[i] = 0;
        }
      }
    }

  }else{ // subtract exon
    if (!document.forms[formName].elements['e'+r].length){
      document.forms[formName].elements['e'+r].checked = false;  // for groups of 1
    }else{
    for (i=0;i<document.forms[formName].elements['e'+r].length;i++){
      document.forms[formName].elements['e'+r][i].checked = false;
    }
    }
    radioArr[r] = 0;
  }

  //// Scroll for evidence table not supported on mac ie
  t = document.getElementById('eTable');
  b = document.getElementById('bottomrow');

    if (!mouse_click){
      if ((findPosY(radioObj) - findPosY(tradioObj)) > 300){
        t.scrollTop = findPosY(radioObj)-findPosY(t);
      }else{
        t.scrollTop = findPosY(tradioObj)-findPosY(t);
      }
    }
  updateMRNA();
}

//--Select Gene Model by ID--//

//This is called every time the user clicks on an ID in the Evidence Plot Window
function SelectStruct(structure){
  document.forms[formName].UCAstruct.value = structure;
  structTextEnter();
}

//Called by the above function to enter the sequence of the structure, sets Your Structure = gene model chosen
function structTextEnter(){
  var enteredStruct = document.forms[formName].UCAstruct.value;
  enteredStruct = enteredStruct.replace(/\n/g,"");
  var exonpairs = enteredStruct.match(/\d+\D\D\d+/g);
  //GSQregexp = new RegExp("\(.+?\)");
  if (enteredStruct.match(/join/i) && exonpairs){
    for (var i=0;i<exonpairs.length;i++){
      var coord = exonpairs[i].match(/\d+/g);
      if (parseInt(coord[0]) > parseInt(coord[1])){
        resetMRNA();
	alert("Invalid structure.");
	return;
      }
    }
    tempCstrand = (enteredStruct.match(RegExp("[cC]"))) ? 1:0;
  }else if (exonpairs){
    var coord = exonpairs[0].match(/\d+/g);
    exonpairs[0] = Math.min(coord[0],coord[1]) + ".." + Math.max(coord[0],coord[1]);
    tempCstrand = ( parseInt(coord[0]) > parseInt(coord[1]) )  ? 1 : 0;
    for (var i=1;i<exonpairs.length;i++){
      coord = exonpairs[i].match(/\d+/g);
      if (((parseInt(coord[0]) < parseInt(coord[1]))&&(tempCstrand))||((parseInt(coord[0]) > parseInt(coord[1]))&&(!tempCstrand))){
        resetMRNA();
	alert("Invalid structure.");
	return;
      }
      exonpairs[i] = Math.min(coord[0],coord[1]) + ".." + Math.max(coord[0],coord[1]);
    }
  }else{
        resetMRNA();
	alert("No structure.");
	return;
  }
  newStruct = (tempCstrand) ? "complement(join(" + exonpairs.join(",") + "))":"join(" + exonpairs.join(",") + ")";

  resetMRNA();
  document.forms[formName].UCAstruct.value = newStruct;
  var rightCoord = newStruct.match(/\d+/g);
  rightCoord.sort(NumSort);
  if ((Math.min(rightCoord[0],rightCoord[rightCoord.length-1]) < parseInt(startCoord))||(Math.max(rightCoord[0],rightCoord[rightCoord.length-1]) > parseInt(document.forms[formName].end.value))){
    document.forms[formName].RangeStart.value = Math.min(parseInt(startCoord),parseInt(rightCoord[0]));
    document.forms[formName].RangeEnd.value = Math.max(parseInt(document.forms[formName].end.value),parseInt(rightCoord[rightCoord.length-1]));
    alert("Entered structure is larger than the current genomic range.\n The range will now be expanded.");
    EvidenceRangeSet('1');
  }else{
    first_load();
  }
}

function hideExons(){
  var showV;
  var showA;
  showV = (browser_type.match('Microsoft')) ? 'block' : 'table-row';
  showA = (hideB == 1) ? "none" : showV;
  var bcArr = new Array();
  var bcArr = ["green thick solid","yellow thick solid"];
  var backgroundColor = bcArr[0];
  var multChecked;
  // hides only selected exons
  for (j=1;j<groupAmt;j++){
    if (!document.forms[formName].elements['e'+j].length){
      if (document.forms[formName].elements['e'+j].checked == true){
	document.getElementById(document.forms[formName].elements['e'+j].value).style.display = showV;
	//document.getElementById('table'+document.forms[formName].elements['e'+j].value).style.border = "black thin solid";
	document.getElementById('frow'+document.forms[formName].elements['e'+j].value).style.display = showV;

        //backgroundColor = (hideB ==1) ? lastActiveColor : backgroundColor;
	//document.getElementById(document.forms[formName].elements['e'+j].value).style.background = backgroundColor;
        //lastActiveColor = (backgroundColor == bcArr[0]) ? bcArr[1] : bcArr[0];
      }else{
	document.getElementById(document.forms[formName].elements['e'+j].value).style.display = showA;
	//document.getElementById('table'+document.forms[formName].elements['e'+j].value).style.border = (hideB == 1) ? "none": "black thin solid";
	document.getElementById('frow'+document.forms[formName].elements['e'+j].value).style.display = showA;
	//document.getElementById(document.forms[formName].elements['e'+j].value).style.background = backgroundColor;
      }
      //	document.getElementById(document.forms[formName].elements['e'+j].value).style.border.left = document.getElementById(document.forms[formName].elements['e'+j].value).style.border.right = "black thick solid";

    }else{
    multChecked = 0;
    for (i=0;i<document.forms[formName].elements['e'+j].length;i++){
      if (document.forms[formName].elements['e'+j][i].checked == true){
	document.getElementById(document.forms[formName].elements['e'+j][i].value).style.display = showV;
	multChecked = 1;
        //backgroundColor = (hideB ==1) ? lastActiveColor : backgroundColor;
	//document.getElementById(document.forms[formName].elements['e'+j][i].value).style.background = backgroundColor;
	//lastActiveColor = (backgroundColor == bcArr[0]) ? bcArr[1] : bcArr[0];
      }else{
        document.getElementById(document.forms[formName].elements['e'+j][i].value).style.display = showA;
	//document.getElementById(document.forms[formName].elements['e'+j][i].value).style.background = backgroundColor;
      }
      //      	document.getElementById(document.forms[formName].elements['e'+j][i].value).style.border.left = document.getElementById(document.forms[formName].elements['e'+j][i].value).style.right = "black thick solid";
    }
    //document.getElementById('table'+document.forms[formName].elements['e'+j][0].value).style.border = (multChecked == 1 || hideB == 0) ? "black thin solid" : "none";
    document.getElementById('frow'+document.forms[formName].elements['e'+j][0].value).style.display = (multChecked == 1 || hideB == 0) ? showV : "none";
    }
    backgroundColor = (backgroundColor == bcArr[0]) ? bcArr[1] : bcArr[0];
  }

  return;
}


function clickHideExons(){
  hideB = (hideB == 1) ? 0 : 1;
  document.getElementById('hideButton').value = (hideB == 1) ? "display all exons" : "only display selected exons";
  hideExons();
  return;
}

//Loading function sets up the 3 parts of the page (left window, evidence plot, and evidence table)
var Sname;
function first_load(){
  set_dropdown_from_textbox('category_txt','category_options');
  set_dropdown_from_textbox('working_group_txt','working_group_options');
  var anno_class = document.getElementById('anno_class_txt');
  togglefield_annotype(anno_class.value);

  var gene_id = document.getElementById('UCAannid_txt');

  if (gene_id.value == ''){
    gene_id.value = document.getElementById('gene_id_prefix').value;
    document.getElementById('gene_annotation_id').style.display = 'none';
  } else {
    if ((gene_id.value.length == 11) && (gene_id.value.indexOf('yrGATE-') == 0)){ // Hide Gene ID field until after it is saved
      document.getElementById('gene_annotation_id').style.display = 'none';
   }
  }

  tUCAstruct = document.forms[formName].UCAstruct.value;
  clearStruct();
  if (tUCAstruct){
  if (tUCAstruct.match(/c/i)){
    document.forms[formName].UCAstrand[1].checked = true;
  }else{
    document.forms[formName].UCAstrand[0].checked = true;
  }

  tArr = Array();
  for (j=1;j<groupAmt;j++){
    if (!document.forms[formName].elements['e'+j].length){
      if (tUCAstruct.match(document.forms[formName].elements['e'+j].value.replace(/  /,"..")) ){
        document.forms[formName].elements['e'+j].checked = true;
        radioArr[j] = document.forms[formName].elements['e'+j].value;
	tArr = document.forms[formName].elements['e'+j].value.match(/(\d+)/g);
      }
    }else{
    for (i=0;i<document.forms[formName].elements['e'+j].length;i++){
      if (document.forms[formName].elements['e'+j][i].value){
      if (tUCAstruct.match(document.forms[formName].elements['e'+j][i].value.replace(/  /,"..")) ){
        radioArr[j] = document.forms[formName].elements['e'+j][i].value;
        document.forms[formName].elements['e'+j][i].checked = true;
	tArr = document.forms[formName].elements['e'+j][i].value.match(/(\d+)/g);
      }
      }
    }
    }
    if (tArr.length > 0){
      tval = new RegExp(tArr[0]+".."+tArr[1]);
      tUCAstruct = tUCAstruct.replace(tval,"");
    }
  }
  tUCAstruct = tUCAstruct.replace(/complement/,"");
  tUCAstruct = tUCAstruct.replace(/join/,"");
  tUCAstruct = tUCAstruct.replace(/\(/,"");
  tUCAstruct = tUCAstruct.replace(/\)/,"");
  novelExons = tUCAstruct.match(/\d+\.\.\d+/g);
  if (novelExons){
    for (var i=0;i<novelExons.length;i++){
      UserDefinedExons[novelExons[i].replace(/\.\./,"  ")] = "Y";
      //alert(novelExons[i].replace(/\.\./,"  ") + " novel");
    }
  }
  }
  // unselected UDE


  // User Defined Exons Origins parse
  if (document.forms[formName].UDEsource.value){
    UDEarr = document.forms[formName].UDEsource.value.split("<newline>");
    for (var i=0; i<UDEarr.length;i++){
      UDEfields = UDEarr[i].split(" ");
      var eKey = UDEfields[0] + "  " + UDEfields[1];
      if ((UDEfields.length > 1)&&( !(eTableExons[eKey]) )){
        if (!UserDefinedExons[eKey]){
  	  UserDefinedExons[eKey] = "N";  // do not select it
        }
        UDEfields2 = UDEfields.slice(3);
        sourceUDE(UDEfields[0],UDEfields[1],UDEfields[2],UDEfields2.join(" "));
      }
    }
  }

  // trap full paste
  for (var i in UserDefinedExons){
    if (!UserDefinedSources[i]){
          UserDefinedSources[i] = new Object();
          UserDefinedSources[i]["manual"] = "unknown";   
          //alert(i + "unknown");
    }
  }
  editGenomeSequence();
  reverseStrand();
  Sname = 'chr'+document.forms[formName].chr.value + 'x' + document.forms[formName].start.value + 't' + document.forms[formName].end.value;  // for portals
  illChar = new RegExp("[-_\s\.]","g");
  Sname = Sname.replace(illChar,"");
  //document.forms[formName].seq.value = GenomeSequence  // not used
  document.forms[formName].UCAname.value = Sname;
}

//Used to expand the size of the evidence plot window to show entire gene models
function EvidenceRangeSet(skipcheck){

  if (parseInt(document.forms[formName].RangeEnd.value) <= parseInt(document.forms[formName].RangeStart.value)){
    tempv = document.forms[formName].RangeStart.value;
    document.forms[formName].RangeStart.value = document.forms[formName].RangeEnd.value;
    document.forms[formName].RangeEnd.value = tempv;
  }
  if (skipcheck != 1){
  var coord = document.forms[formName].UCAstruct.value.match(/\d+/g);
  if (document.forms[formName].UCAstruct.value){
    if ((parseInt(document.forms[formName].RangeEnd.value) < parseInt(coord[coord.length-1]) )||(parseInt(document.forms[formName].RangeStart.value) > parseInt(coord[0]) )){
      alert("This range excludes one or more of the selected exons.\n Delete the exons before reducing the range");
      return;
    }
  }
  }

  if ( (Math.min(document.forms[formName].UCAcdsstart.value,document.forms[formName].UCAcdsend.value) < document.forms[formName].start.value ) || (Math.max(document.forms[formName].UCAcdsstart.value,document.forms[formName].UCAcdsend.value) > document.forms[formName].end.value)){
    document.forms[formName].UCAcdsstart.value = ""; document.forms[formName].UCAcdsend.value = "";

  }

  document.forms[formName].end.value = document.forms[formName].RangeEnd.value;
  document.forms[formName].start.value = document.forms[formName].RangeStart.value;

  var new_locus_range = document.getElementById('gene_id_prefix').value + "-" + document.forms[formName].start.value + "-" + document.forms[formName].end.value;
//   alert(new_locus_range);
  change_locus(new_locus_range);

  mess = "Retrieving evidence from new region  " + document.forms[formName].start.value + " " + document.forms[formName].end.value;
  formSubmit('',mess,'_self');
  //alert('ERS');

  return;
}

//--Display of Your Structure--//

function displayStruct(info){
  var exons = new Array();
  var exonpairs = new Array();
  var exonSizes = new Array();
  var introns = new Array();
  var intronSizes = new Array();
  var coords = new Array();
  var CDSstr = info;
  var exonpairs = CDSstr.match(/\d+\D\D\d+/g);
  var rightCoord = CDSstr.match(/(\d+)/);
  clearStruct();

  if (info){
  
  for (i=0;i<exonpairs.length-1;i++){
    coords = exonpairs[i].split(/\.\./);
    exonSizes[i] = Math.round((coords[1]-coords[0]+1)/baseScale);
    exons[i] = Math.round((coords[0] - startCoord+1) / baseScale);
    exons[i] = (exons[i] > 0) ? exons[i] : 0;
    ncoords = exonpairs[i+1].split(/\.\./);
    intronSizes[i] = Math.round((Math.abs(eval(ncoords[0]-coords[1]))+1)/baseScale)+1;
    introns[i] = Math.round((coords[1]-startCoord+1) / baseScale);
    introns[i] = (introns[i] > 0)  ? introns[i] : 0;
  }
  coords = exonpairs[exonpairs.length-1].split(/\.\./);
  exonSizes[exonSizes.length] = Math.round((coords[1]-coords[0]+1)/baseScale)+1;
  exons[exons.length] = Math.round((coords[0] - startCoord)/baseScale)+1;

  // display struct
   var s = 0;
   if (info.match(/comp/)){
     if ( (exonSizes[0]) > 1){
        moveImage('leftarrow',exons[0],6,StructHeight);
        moveImage('e0',exons[0]+6,exonSizes[0]-6,StructHeight);
     }else{
        moveImage('leftarrow',exons[0] - 6,6,StructHeight);
     }
     s = 1;
   }

for (i=s;i<exons.length-1;i++){
    if (exonSizes[i] < 1){
      moveImage('e'+i,exons[i],1,StructHeight);
    }else{
      moveImage('e'+i,exons[i],exonSizes[i],StructHeight);
    }

  }

// draw intron
  moveImage('intron',exons[0]+exonSizes[0],exons[exons.length-1]-(exons[0]+exonSizes[0])+2,StructHeight); // 2's are fraction of arrows


  i = exons.length - 1;
  if (!(info.match(/complement/)) ){
   if (exonSizes[i] > 6){
     moveImage('e'+i,exons[i],exonSizes[i]-6,StructHeight);
     moveImage('rightarrow',exons[i] + exonSizes[i] - 1 - 6,6,StructHeight);
   }else{
     moveImage('rightarrow',exons[i],6,StructHeight);
   }
  }else if(i > 0){
    moveImage('e' + i,exons[i],exonSizes[i],StructHeight);
  }
}
  // CDS triangle
  if ((document.forms[formName].UCAcdsstart.value > 0) && (document.forms[formName].UCAcdsend.value > 0)){
    moveImage('tlnStart',Math.round((document.forms[formName].UCAcdsstart.value - startCoord)/ baseScale) -3,5,5);
    moveImage('tlnStop',Math.round((document.forms[formName].UCAcdsend.value - startCoord)/ baseScale) -3,5,5);
  }
 //To avoid send update GAEVAL request frequently, use timeout 
  if(hasBegan==false) {
    hasBegan = true;
    setTimeout(function() { 
     scoreStructure()},50);
  }
}

function moveImage(imgName,left,width,height){
  left = (left > 0) ? left : 0; // for arrow
  imgObj = document.images[imgName];
  imgObj.width = width;
  imgObj.style.left = left + pad + findPosX(document.getElementById('refCell')) -1; // -1 is for ePlotDiv border width (correction added JD 4-16-13)
  imgObj.height = height;
}


function clearStruct(){
  //  alert(document.images['e'+1].width);
  for (var i=0;i<exonMaxsize;i++){
      document.images['e'+i].width  = 0;
      document.images['e'+i].height = 0;
      document.images['e'+i].src = imagePATH + 'e.gif';
  }

  document.images['intron'].width = 0;
  document.images['intron'].height = 0;
  document.images['leftarrow'].width = 0;
  document.images['rightarrow'].width = 0;
  document.images['leftarrow'].height = 0;
  document.images['rightarrow'].height = 0;
  document.images['tlnStart'].width = 0;
  document.images['tlnStop'].width = 0;
}

//--User Defined Exons--//

function sourceUDE(a,b,ExonSource,info){
  // add to UDEsource  
  a1 = Math.min(a,b);
  b1 = Math.max(a,b);
  exName = a1 + "  " + b1;
  var ESR =  new RegExp(info);
    if ((!UserDefinedSources[exName]) ){
      UserDefinedSources[exName] = new Object();
    }
      UserDefinedSources[exName][ExonSource] =  info;
}

function addUDE(a,b,ExonSource,info){
  // ?alert for range, add to UDE source, Graphic Exon Select or UserExonSelect; 
  var newL = Math.min(a,b);
  var newR = Math.max(a,b);
  if (newL == newR){
  	//alert("Exons must have length greater than 0.  Your entry was not added.");
	//return;
  }
  var title = newL + "  " + newR;
  if (title == "NaN  NaN"){
    alert("Invalid new exon");
    return;
  }
  if (newL == newR){
  	//alert("Exons must have length greater than 0.  Your entry was not added.");
	//return;
  }
  if ( (newL < startCoord)||(newR > document.forms[formName].end.value)){
    if (confirm("Only exons in the current range " + startCoord + "-" + document.forms[formName].end.value + " can be entered.\n\n Would you like to expand the range to include this exon, "+newL+ " " + newR + "?") ){
      sourceUDE(newL,newR,ExonSource,info);
      if (eTableSelect(newL,newR) == "addUDE"){
        UserExonSelect(title);
      }
      document.forms[formName].RangeStart.value = Math.min(startCoord,newL);
      document.forms[formName].RangeEnd.value = Math.max(document.forms[formName].end.value,newR);
      EvidenceRangeSet();
    }
    return;
  }
  sourceUDE(newL,newR,ExonSource,info);
  toAddUDE = eTableSelect(newL,newR);
  if ((!UserDefinedExons[title]) && (toAddUDE == "addUDE") ){
    UserDefinedExons[title] = "N";
  }
  if (toAddUDE == "addUDE"){
    UserExonSelect(title);
  }
  document.forms[formName].new5.value = "";  //new 5 prime init
  document.forms[formName].new3.value = "";  //new 3 prime init
  return;
}


function UserExonSelect(a){
  var olapped = 0;
  var rArr = a.split("  ");
  if (UserDefinedExons[a] == "Y"){
    UserDefinedExons[a] = "N";
  }else{
    for (i=0;i<radioArr.length;i++){
      //if ((radioArr[i] != undefined)&&(radioArr[i] != 0)){
      if (radioArr[i]){
      tArr = radioArr[i].split(/\s+/);
      if ( (Math.min(tArr[0],tArr[1]) <= Math.max(rArr[0],rArr[1]))&&(Math.max(tArr[0],tArr[1]) >= Math.min(rArr[0],rArr[1])) ){
        olapped = 1;
        c1 = tArr[0];
        c2 = tArr[1];
	eTableSelect(c1,c2);
	UserDefinedExons[a] = "Y";
      }
      }
    }

    if (olapped == 1){
      //alert("Exon conflicts with evidence supported exon("+Math.min(c1,c2)+ " " + Math.max(c1,c2) +").  \n You must delete that exon before this exon may be added.");
    }else{
      for (var i in UserDefinedExons){
        tArr = i.split(/\s+/);
        if ( (Math.min(tArr[0],tArr[1]) <= Math.max(rArr[0],rArr[1]))&&(Math.max(tArr[0],tArr[1]) >= Math.min(rArr[0],rArr[1])) && (i != a)){
          UserDefinedExons[i] = "N";
        }
      }
      UserDefinedExons[a] = "Y";
    }
  }
  WriteUserBox();
  updateMRNA();
}


function WriteUserBox(){
  var newTxt = "";
  var UDS = "";
  var newUserSource = "";
  SortedUserExonsArr = SortHash(UserDefinedExons);
  for (var i=0;i<SortedUserExonsArr.length;i++){
   var j = SortedUserExonsArr[i];
   //   newTxt = (UserDefinedExons[j] == "Y") ?  newTxt + "<a href='javascript:UserExonSelect(\""+j +"\");'><img src='"+imagePATH+"radioselect.gif' border='0'></a>" : newTxt + "<a href='javascript:UserExonSelect(\""+j +"\");'><img src='"+imagePATH+"radiounselect.gif' border='0'></a>";

   if (UserDefinedExons[j] == "Y"){
     newTxt = newTxt + "<a href='javascript:UserExonSelect(\""+j +"\");'><img src='"+imagePATH+"radioselect.gif' border='0'></a>";
     // newUserSource = newUserSource + j + " : " +  UserDefinedSources[j] + "\n";
   }else{
     newTxt = newTxt + "<a href='javascript:UserExonSelect(\""+j +"\");'><img src='"+imagePATH+"radiounselect.gif' border='0'></a>";
   }
   UDS = "";
   for (l in UserDefinedSources[j]){
     UDS = (UDS) ? UDS + "," + l : l;
     var js = j;
     js = js.replace(/  /," ");     
     newUserSource = newUserSource + ( (newUserSource == "") ? "" : "<newline>") + js + " " + l + " " + UserDefinedSources[j][l];
   }
   newTxt = newTxt + j + "<br><font class=grT>(" + UDS + ")</font><br>";
  }
  document.forms[formName].UDEsource.value = newUserSource ;
  document.getElementById('UserBox').innerHTML = newTxt;
  return 1;
}


function clearUserExons(){
  UserDefinedExons = new Array();
  UserDefinedSources = new Object();
  document.forms[formName].UDEsource.value = "";
  updateMRNA();
}

//--mRNA Functions--//

function resetMRNA(){
  document.forms[formName].UCAstruct.value = "";
  document.forms[formName].UDEsource.value = "";
  radioArr = Array();
  clearUserExons();
  for (j=1;j<groupAmt;j++){
    for (i=0;i<document.forms[formName].elements['e'+j].length;i++){
      document.forms[formName].elements['e'+j][i].checked = false;
    }
    if (!document.forms[formName].elements['e'+j].length){
      document.forms[formName].elements['e'+j].checked = false;
    }
  }
  updateMRNA();
}

function setCoords(a,b){
  var xcoord = new Array();
  exonLIST = document.forms[formName].UCAstruct.value.match(/\d+\D\D\d+/g);
  for (i=0;i<exonLIST.length;i++){
    coordp = exonLIST[i].split("..");
    for (j=parseInt(coordp[0]);j<=parseInt(coordp[1]);j++){
      xcoord[xcoord.length] = j;
    }
  }
  if (document.forms[formName].UCAstruct.value.match("complement")){
    document.forms[formName].UCAcdsstart.value = xcoord[xcoord.length-a];
    document.forms[formName].UCAcdsend.value = xcoord[xcoord.length-b];
  }else{
    document.forms[formName].UCAcdsstart.value = xcoord[a-1];
    document.forms[formName].UCAcdsend.value = xcoord[b-1];
  }
  updateMRNA();
}

var previewLength = 45;
function loadMRNA(){
  if (document.forms[formName].UCAstruct.value){
    exonLIST = document.forms[formName].UCAstruct.value.match(/\d+\.\.\d+/g);
    mRNAseq = mRNAseqf = "";
    for (i=0;i<exonLIST.length;i++){
      coordp = exonLIST[i].split(/\.\./);
      mRNAseq = mRNAseq + GenomeSequence.substring(coordp[0]-document.forms[formName].start.value,coordp[1]-document.forms[formName].start.value+1);
    }
    if (Cstrand){
      mRNAseq = revcomp(mRNAseq);
    }

    for (i=0;i<parseInt(mRNAseq.length /previewLength);i++){
      mRNAseqf = mRNAseqf + mRNAseq.substring(i*previewLength,(i+1)*previewLength) + "\n";
    }
    mRNAseqf = mRNAseqf + mRNAseq.substring(parseInt(mRNAseq.length/previewLength)*previewLength,mRNAseq.length);
    document.forms[formName].mRNAseq.value = mRNAseqf;
    document.forms[formName].mRNAlength.value = "(" + mRNAseq.length + " nucleotides)";
    loadProtein();
  }else{
    document.forms[formName].mRNAseq.value = "no structure entered";
    document.forms[formName].mRNAlength.value = "";
    document.forms[formName].protein.value = "";
    document.forms[formName].proteinlength.value = "";
  }
}

function updateMRNA(){
  var ExonsArr = new Array();
  for (var i in UserDefinedExons){
    if (UserDefinedExons[i] == "Y"){
      ExonsArr[ExonsArr.length] = i;
    }
  }
  for (var i=0;i<radioArr.length;i++){
    if ((radioArr[i] != 0) && (radioArr[i])){
    // if ((radioArr[i] != 0) && (radioArr[i] != undefined)){
      ExonsArr[ExonsArr.length] = radioArr[i];
    }
  }
  ExonsArr.sort(CoordSort);
  if (ExonsArr.length){
  var info = String("join(" + ExonsArr.join(',') + ")");
  if(Cstrand){
    info = "complement(" + info + ")";
  }
  info = info.replace(/  /g,"..");
  }else{
    info = "";
  }
  document.forms[formName].UCAstruct.value = info;
  WriteUserBox();
  displayStruct(info);
  loadMRNA();
  hideExons();
  return 1;
}

//--Manually Entered Orfs--//

function EnterORF(){
  if ((Math.min(document.forms[formName].UCAcdsstart.value,document.forms[formName].UCAcdsend.value) < startCoord)||(Math.max(document.forms[formName].UCAcdsstart.value,document.forms[formName].UCAcdsend.value) > document.forms[formName].end.value)){
    alert("Protein coding region is out of the evidence range.  Expand the range to accomodate.");
    document.forms[formName].UCAcdsstart.value = document.forms[formName].UCAcdsend.value = "";
    updateMRNA();
  }else{
    updateMRNA();
  }
}

//--Genome Sequence Edits--//

function addGenomeEdits(edits){
  document.forms[formName].GSeqEdits.value = edits;
  editGenomeSequence();
  updateMRNA();
}

function editGenomeSequence(){
  var tmpseq = "";
  if (document.forms[formName].GSeqEdits.value != ""){
  editsArr = document.forms[formName].GSeqEdits.value.split("\n"); // array is already sorted
  var currP = 0;
  for (i=0;i<editsArr.length;i++){
    fArr = editsArr[i].split(",");
    if ((parseInt(fArr[0]) >= document.forms[formName].start.value)&&(parseInt(fArr[0]) <= document.forms[formName].end.value)){
      fArr[0] = fArr[0] - document.forms[formName].start.value;  

      tmpseq = tmpseq + document.forms[formName].OriginalGenomeSequence.value.substring(currP,fArr[0]);
      if (fArr[1] == "delete"){
        currP = parseInt(fArr[0])+1;
      }else if(fArr[1] == "change"){
        currP = parseInt(fArr[0])+1;
        tmpseq = tmpseq + fArr[2];
      }else if(fArr[1] == "insert"){
        tmpseq = tmpseq + document.forms[formName].OriginalGenomeSequence.value.substring(parseInt(fArr[0]),parseInt(fArr[0])+1) + fArr[2];
        currP = parseInt(fArr[0])+1;
      }
    }else{
      alert("Genome Edit at base " + fArr[0] + " is no longer in the range of this window.");
    }
  }
  tmpseq = tmpseq + document.forms[formName].OriginalGenomeSequence.value.substring(currP,document.forms[formName].OriginalGenomeSequence.value.length);
  GenomeSequence = tmpseq;
  }else{
    GenomeSequence = document.forms[formName].OriginalGenomeSequence.value;
  }
  document.forms[formName].GenomeSequence.value = GenomeSequence;
}

//--Load Protein--//

function loadProtein(){
  exonLIST = document.forms[formName].UCAstruct.value.match(/\d+\.\.\d+/g);
  rxcoord = new Array();
  rcount = 0;
  if (Cstrand!=1){
  for (i=0;i<exonLIST.length;i++){
    coordp = exonLIST[i].split(/\.\./);

    for (j=parseInt(coordp[0]);j<=parseInt(coordp[1]);j++){  // parseInt required for digit amount, 999-1000.  ??
      rxcoord[j] = rcount;
      rcount = rcount + 1;
    }

  }
  }else{
  for (i=exonLIST.length-1;i>=0;i--){
    coordp = exonLIST[i].split(/\.\./);
    for (j=parseInt(coordp[1]);j>=parseInt(coordp[0]);j--){
      rxcoord[j] = rcount;
      rcount = rcount + 1;
    }
  }
  }

  if ((document.forms[formName].UCAcdsstart.value != "") && (document.forms[formName].UCAcdsend.value != "")&&(document.forms[formName].UCAcdsstart.value != 0) && (document.forms[formName].UCAcdsend.value != 0)){
    proteinseq = proteinseqf = "";
    a = rxcoord[document.forms[formName].UCAcdsstart.value];
    b = rxcoord[document.forms[formName].UCAcdsend.value];
    mRNAstring = document.forms[formName].mRNAseq.value;
    var nw = "\\W";
    var nlRegExp = new RegExp(nw,"g");
    var nullREP = "";
    mRNAstring = mRNAstring.replace(nlRegExp,nullREP);  // awkward regexp for IE
    if ((a < 0)||(b < 0)){
     document.forms[formName].protein.value = "translation coordinates are larger than current mRNA structure";
     document.forms[formName].proteinlength.value = "";
     return;
    }else if (a == b){
     document.forms[formName].protein.value = "zero translation length";
     document.forms[formName].proteinlength.value = "";
     return;
    }
    else if (a > b){
      for (var i=a+1;i>=b+3;i=i-3){
        proteinseq =  proteinseq + codonTranslate(revcomp(mRNAstring.substring(i-3,i)));
      }
    }else{
      for (var i=a;i<=b-2;i=i+3){
        proteinseq = proteinseq + codonTranslate(mRNAstring.substring(i,i+3));

      }
    }

    for (var i=0;i<parseInt(proteinseq.length /previewLength);i++){
      proteinseqf = proteinseqf + proteinseq.substring(i*previewLength,(i+1)*previewLength) + "\n";
    }
    proteinseqf = proteinseqf + proteinseq.substring(parseInt(proteinseq.length/previewLength)*previewLength,proteinseq.length);
    document.forms[formName].protein.value = proteinseqf;
    document.forms[formName].proteinlength.value = (proteinseq.length > 0) ? "(" + (proteinseq.length - 1) + " amino acids)" : "";
  }else{
    document.forms[formName].protein.value = "";
    document.forms[formName].proteinlength.value = "";
  }
}


function evidenceFormat(){
  // add evidence exons to Esource

  efield = "";
  for (j=1;j<groupAmt;j++){
    Ekey = "";
    if (!document.forms[formName].elements['e'+j].length){
      if (document.forms[formName].elements['e'+j].checked){
        Ekey =  document.forms[formName].elements['e'+j].value;
	//efield = efield + document.forms[formName].elements['e'+j].value + ":native cognate EST:" + eTableExons[document.forms[formName].elements['e'+j].value] + "\n";
      }
    }else{
    for (i=0;i<document.forms[formName].elements['e'+j].length;i++){
      if (document.forms[formName].elements['e'+j][i].checked){
        Ekey = document.forms[formName].elements['e'+j][i].value;
	//efield = efield + document.forms[formName].elements['e'+j][i].value + ":native cognate EST:" + eTableExons[document.forms[formName].elements['e'+j][i].value] + "\n";
      }
    }
    }


    if (Ekey){
      efield = efield + ( (efield == "") ? "" : "<newline>") + eTableExons[Ekey];
      //tVal = eTableExons[Ekey]; // object for etablexons
      //comArr = tVal.split(",");
    // for (i=0;i<comArr.length;i++){
    //  tArr = comArr[i].split("-"); // [name]-[type]-[uid]
    //  efield = efield + Ekey + ":" + "native "; // need evidence type
    //  efield = (tArr[1] == "E") ? efield + "EST alignment:" : efield + "cDNA alignment:"; // need evidence type
    //  efield = efield + dbTitle + " " + tArr[0] + " " + tArr[2] + "\n";
    // }
    }
  }
  document.forms[formName].Esource.value = efield;  // only write to Esource is on submit
  return true;
}

 function changeImageSize(){
   size = document.forms[formName].imgWidthSel.value;
   document.forms[formName].imgWidth.value = size;
   formSubmit("","Changing Genome Plot image size to " + size,'_self');
 }

//--Sequence Functions and Codon Table--//

function strrev(str) {
   if (!str) return '';
   var revstr='';
   for (var i = str.length-1; i>=0; i--)
       revstr+=str.charAt(i)
   return revstr;
}

function revcomp(str){
  newstr = "";
  newstr = strrev(str);
  newstr = newstr.replace(/A/g,"t");
  newstr = newstr.replace(/T/g,"a");
  newstr = newstr.replace(/G/g,"c");
  newstr = newstr.replace(/C/g,"g");
  newstr = newstr.toUpperCase();
  return newstr;
}
 
function reverseStrand(){
    Cstrand = (document.forms[formName].UCAstrand[0].checked)? 0:1;
    // reverse User Exons
    updateMRNA();
}

function codonTranslate(codon){
    var patt1= /^[YRWSKMDVHBNX].+$/i;
    var patt2= /^[A-Z][YRWSKMDVHBNX].+$/i;
    if (patt1.test(codon) || patt2.test(codon)) {
    translation='X'; 
    }else{
    translation=codonHash[codon]
    }
    if (typeof translation === "undefined") { // covers any combo not in codonHash table below
    translation='X';
    }
    return translation;
}


/*
7-21/14ambiguous bases:

Code 	Represents 	Complement 
A	Adenine 	T
G	Guanine 	C
C	Cytosine 	G
T	Thymine 	A

Y	Pyrimidine (C or T)	R
R	Purine (A or G)	Y
W	weak (A or T)	W
S	strong (G or C)	S
K	keto (T or G)	M
M	amino (C or A)	K


D	A, G, T (not C)	H
V	A, C, G (not T)	B
H	A, C, T (not G)	D
B	C, G, T (not A)	V
X/N 	any base 	X/N 
-	Gap	-

*/

codonHash = new Array();
codonHash['TCA'] = 'S';    // Serine
codonHash['TCC'] = 'S';    // Serine
codonHash['TCG'] = 'S';    // Serine
codonHash['TCT'] = 'S';    // Serine
codonHash['TCY'] = 'S';    // Serine (ambiguous base 3)
codonHash['TCR'] = 'S';    // Serine (ambiguous base 3)
codonHash['TCW'] = 'S';    // Serine (ambiguous base 3)
codonHash['TCS'] = 'S';    // Serine (ambiguous base 3)
codonHash['TCM'] = 'S';    // Serine (ambiguous base 3)
codonHash['TCK'] = 'S';    // Serine (ambiguous base 3)
codonHash['TCN'] = 'S';    // Serine (ambiguous base 3)
codonHash['TCX'] = 'S';    // Serine (ambiguous base 3)

codonHash['AGC'] = 'S';    // Serine
codonHash['AGT'] = 'S';    // Serine
codonHash['AGY'] = 'S';    // Serine (ambiguous base 3)
codonHash['AGA'] = 'R';    // Arginine
codonHash['AGG'] = 'R';    // Arginine
codonHash['AGR'] = 'R';    // Arginine (ambiguous base 3)


codonHash['TTC'] = 'F';    // Phenylalanine
codonHash['TTT'] = 'F';    // Phenylalanine
codonHash['TTY'] = 'F';    // Phenylalanine (ambiguous base 3) 

codonHash['TTA'] = 'L';    // Leucine
codonHash['TTG'] = 'L';    // Leucine
codonHash['TTR'] = 'L';    // Leucine (ambiguous base 3)

codonHash['TAC'] = 'Y';    // Tyrosine
codonHash['TAT'] = 'Y';    // Tyrosine
codonHash['TAY'] = 'Y';    // Tyrosine (ambiguous base 3)

codonHash['TAA'] = '*';    // Stop
codonHash['TAG'] = '*';    // Stop
codonHash['TAR'] = '*';    // Stop

codonHash['---'] = '-';    // In-frame gap
codonHash['...'] = '_';    // In-frame gap
codonHash['NNN'] = 'X';	 // UNK was: N (error 7/21/14)
codonHash['???'] = 'X';    // UNK

codonHash['TGC'] = 'C';    // Cysteine
codonHash['TGT'] = 'C';    // Cysteine
codonHash['TGY'] = 'C';    // Cysteine (ambiguous base 3)

codonHash['TGA'] = '*';    // Stop
codonHash['TGG'] = 'W';    // Tryptophan
codonHash['CTA'] = 'L';    // Leucine
codonHash['CTC'] = 'L';    // Leucine
codonHash['CTG'] = 'L';    // Leucine
codonHash['CTT'] = 'L';    // Leucine
codonHash['CTY'] = 'L';    // Leucine (ambiguous base 3)
codonHash['CTR'] = 'L';    // Leucine (ambiguous base 3)
codonHash['CTW'] = 'L';    // Leucine (ambiguous base 3)
codonHash['CTS'] = 'L';    // Leucine (ambiguous base 3)
codonHash['CTK'] = 'L';    // Leucine (ambiguous base 3)
codonHash['CTM'] = 'L';    // Leucine (ambiguous base 3)
codonHash['CTN'] = 'L';    // Leucine (ambiguous base 3)
codonHash['CTX'] = 'L';    // Leucine (ambiguous base 3)

codonHash['CCA'] = 'P';    // Proline
codonHash['CCC'] = 'P';    // Proline
codonHash['CCG'] = 'P';    // Proline
codonHash['CCT'] = 'P';    // Proline
codonHash['CCY'] = 'P';    // Proline (ambiguous base 3)
codonHash['CCR'] = 'P';    // Proline (ambiguous base 3)
codonHash['CCW'] = 'P';    // Proline (ambiguous base 3)
codonHash['CCS'] = 'P';    // Proline (ambiguous base 3)
codonHash['CCM'] = 'P';    // Proline (ambiguous base 3)
codonHash['CCK'] = 'P';    // Proline (ambiguous base 3)
codonHash['CCN'] = 'P';    // Proline (ambiguous base 3)
codonHash['CCX'] = 'P';    // Proline (ambiguous base 3)


codonHash['CAC'] = 'H';    // Histidine
codonHash['CAT'] = 'H';    // Histidine
codonHash['CAY'] = 'H';    // Histidine  (ambiguous base 3)

codonHash['CAA'] = 'Q';    // Glutamine
codonHash['CAG'] = 'Q';    // Glutamine
codonHash['CAR'] = 'Q';    // Glutamine (ambiguous base 3)

codonHash['CGA'] = 'R';    // Arginine
codonHash['CGC'] = 'R';    // Arginine
codonHash['CGG'] = 'R';    // Arginine
codonHash['CGT'] = 'R';    // Arginine
codonHash['CGY'] = 'R';    // Arginine (ambiguous base 3)
codonHash['CGR'] = 'R';    // Arginine (ambiguous base 3)
codonHash['CGW'] = 'R';    // Arginine (ambiguous base 3)
codonHash['CGS'] = 'R';    // Arginine (ambiguous base 3)
codonHash['CGM'] = 'R';    // Arginine (ambiguous base 3)
codonHash['CGK'] = 'R';    // Arginine (ambiguous base 3)
codonHash['CGN'] = 'R';    // Arginine (ambiguous base 3)
codonHash['CGX'] = 'R';    // Arginine (ambiguous base 3)

codonHash['ATA'] = 'I';    // Isoleucine
codonHash['ATC'] = 'I';    // Isoleucine
codonHash['ATT'] = 'I';    // Isoleucine
codonHash['ATM'] = 'I';    // Isoleucine (ambiguous base 3)
codonHash['ATY'] = 'I';    // Isoleucine (ambiguous base 3)
codonHash['ATH'] = 'I';    // Isoleucine (ambiguous base 3)
codonHash['ATW'] = 'I';    // Isoleucine (ambiguous base 3)

codonHash['ATG'] = 'M';    // Methionine
codonHash['ACA'] = 'T';    // Threonine
codonHash['ACC'] = 'T';    // Threonine
codonHash['ACG'] = 'T';    // Threonine
codonHash['ACT'] = 'T';    // Threonine
codonHash['ACY'] = 'T';    // Threonine (ambiguous base 3)
codonHash['ACR'] = 'T';    // Threonine (ambiguous base 3)
codonHash['ACW'] = 'T';    // Threonine (ambiguous base 3)
codonHash['ACS'] = 'T';    // Threonine (ambiguous base 3)
codonHash['ACK'] = 'T';    // Threonine (ambiguous base 3)
codonHash['ACM'] = 'T';    // Threonine (ambiguous base 3)
codonHash['ACN'] = 'T';    // Threonine (ambiguous base 3)
codonHash['ACX'] = 'T';    // Threonine (ambiguous base 3)

codonHash['AAC'] = 'N';    // Asparagine
codonHash['AAT'] = 'N';    // Asparagine
codonHash['AAY'] = 'N';    // Asparagine (ambiguous base 3)

codonHash['AAA'] = 'K';    // Lysine
codonHash['AAG'] = 'K';    // Lysine
codonHash['AAR'] = 'K';    // Lysine (ambiguous base 3)

codonHash['GTA'] = 'V';    // Valine
codonHash['GTC'] = 'V';    // Valine
codonHash['GTG'] = 'V';    // Valine
codonHash['GTT'] = 'V';    // Valine
codonHash['GTY'] = 'V';    // Valine (ambiguous base 3)
codonHash['GTR'] = 'V';    // Valine (ambiguous base 3)
codonHash['GTW'] = 'V';    // Valine (ambiguous base 3)
codonHash['GTS'] = 'V';    // Valine (ambiguous base 3)
codonHash['GTM'] = 'V';    // Valine (ambiguous base 3)
codonHash['GTK'] = 'V';    // Valine (ambiguous base 3)
codonHash['GTN'] = 'V';    // Valine (ambiguous base 3)
codonHash['GTX'] = 'V';    // Valine (ambiguous base 3)

codonHash['GCA'] = 'A';    // Alanine
codonHash['GCC'] = 'A';    // Alanine
codonHash['GCG'] = 'A';    // Alanine
codonHash['GCT'] = 'A';    // Alanine
codonHash['GCY'] = 'A';    // Alanine (ambiguous base 3)
codonHash['GCR'] = 'A';    // Alanine (ambiguous base 3)
codonHash['GCW'] = 'A';    // Alanine (ambiguous base 3)
codonHash['GCS'] = 'A';    // Alanine (ambiguous base 3)
codonHash['GCK'] = 'A';    // Alanine (ambiguous base 3)
codonHash['GCM'] = 'A';    // Alanine (ambiguous base 3)
codonHash['GCX'] = 'A';    // Alanine (ambiguous base 3)
codonHash['GCN'] = 'A';    // Alanine (ambiguous base 3)

codonHash['GAC'] = 'D';    // Aspartic Acid
codonHash['GAT'] = 'D';    // Aspartic Acid
codonHash['GAY'] = 'D';    // Aspartic Acid (ambiguous base 3)

codonHash['GAA'] = 'E';    // Glutamic Acid
codonHash['GAG'] = 'E';    // Glutamic Acid
codonHash['GAR'] = 'E';    // Glutamic Acid (ambiguous base 3)

codonHash['GGA'] = 'G';    // Glycine
codonHash['GGC'] = 'G';    // Glycine
codonHash['GGG'] = 'G';    // Glycine
codonHash['GGT'] = 'G';    // Glycine
codonHash['GGY'] = 'G';    // Glycine (ambiguous base 3)
codonHash['GGR'] = 'G';    // Glycine (ambiguous base 3)
codonHash['GGW'] = 'G';    // Glycine (ambiguous base 3)
codonHash['GGS'] = 'G';    // Glycine (ambiguous base 3)
codonHash['GGM'] = 'G';    // Glycine (ambiguous base 3)
codonHash['GGK'] = 'G';    // Glycine (ambiguous base 3)
codonHash['GGN'] = 'G';    // Glycine (ambiguous base 3)
codonHash['GGX'] = 'G';    // Glycine (ambiguous base 3)



//--Utility Functions--//
function SortHash(a){
  var tArr = new Array();
  for (var i in a){
    tArr[tArr.length] = i;
  }
  tArr.sort(CoordSort);
  return tArr;
}

function CoordSort(a,b){
  tempArr1 = a.split("  ");
  tempArr2 = b.split("  ");
  b2 = parseInt(tempArr1[0]);
  a2 = parseInt(tempArr2[0]);
  if(a2 > b2)
    return -1;
  if(a2 < b2)
    return 1;
  return 0;
}

function NumSort(a2,b2){
  a2 = parseInt(a2);
  b2 = parseInt(b2);
  if(a2 < b2)
    return -1;
  if(a2 > b2)
    return 1;
  return 0;
}
//--Shift_Click utility Functions--//
function Overlap(a,b) {
	return Math.max(0,Math.min(parseInt(a[1]),parseInt(b[1])) - Math.max(parseInt(a[0]),parseInt(b[0])));
}

function Within(array, string) {
	for (var i=0;i<array.length;i++) {
		if (array[i] == string) {
			return true;
		}
	}
	return false;
}

function OverlapWithin(arrr, strr) {
	coord = strr.match(/\d+/g);
	newArray = new Array();
	olapy = false;
	var toRemove;
	for(var i=0;i<arrr.length;i++) {
		coords = arrr[i].match(/\d+/g);
		if (coord[0] != coords[0] && coord[1] != coords[1]) {
			if (Overlap(coord,coords)!=0) {
				olapy = true;
				if (Math.abs(parseInt(coords[0])-parseInt(coords[1]) ) >  Math.abs(parseInt(coord[0])-parseInt(coord[1]))) {
					toRemove = coord[0] + '..' + coord[1];
					newArray.push(coords[0] + '..' + coords[1]);
				} else if (Math.abs(parseInt(coords[0])-parseInt(coords[1]) ) < Math.abs(parseInt(coord[0])-parseInt(coord[1]))){
					toRemove = coords[0] + '..' + coords[1];
					newArray.push(coord[0] + '..' + coord[1]);	
				} 
			} else if (coord[0]==coords[0] || coord[0]==coords[1] || coord[1]==coords[0] || coord[1] == coords[1]) {
				olapy = true;
				if (Math.abs(parseInt(coords[0])-parseInt(coords[1]) ) >  Math.abs(parseInt(coord[0])-parseInt(coord[1]))) {
					newArray.push(coords[0] + '..' + coords[1]);
				} else { newArray.push(coord[0] + '..' + coord[1]);}
			} else {
				
				newArray.push(arrr[i]);
			}
		} else if (Math.abs(parseInt(coords[0])-parseInt(coords[1]) ) == Math.abs(parseInt(coord[0])-parseInt(coord[1]))){
					newArray.push(coord[0] + '..' + coord[1]);
				}
	}
	if (toRemove) {
		for (var i = 0;i<newArray.length;i++) {
			if (newArray[i] == toRemove) {
				newArray.splice(i,1);
			}
		}
	}
	if (olapy) {
		return newArray;
	} else {
		return arrr;
	}
}

function Adjacency(clicky, shifty)  {
	var yourStrux = document.forms[formName].UCAstruct.value;
    var strand = (yourStrux.match(RegExp("[cC]"))) ? 1:0;
	//find adjacent shift clicked exon, return combined exon structure
	var minDist = 1000000000;
	var adj;
	for (var i=0;i<clicky.length;i++) {
		for (var j=0;j<shifty.length;j++) {
			var coords = shifty[j].match(/\d+/g);
      		var coord = clicky[i].match(/\d+/g);		
			// check clicked exon end closest to shift exon start
			if (Math.abs(parseInt(coord[1])-parseInt(coords[0])) < minDist) {
				minDist = Math.abs(parseInt(coord[1])-parseInt(coords[0]));	
                adj = Math.min(coord[1], coords[1], coord[0], coords[0]) + '..' + Math.max(coord[0], coords[1], coord[1], coords[0]);
			}
			// check clicked exon start closest to shift exon end
			if (Math.abs(parseInt(coord[1])-parseInt(coords[0])) < minDist) {
				minDist = Math.abs(parseInt(coord[1])-parseInt(coords[0]));
				adj = Math.min(coord[1], coords[0], coord[0], coords[1]) + '..' + Math.max(coord[0], coord[1], coords[0], coords[1]);
			}
			
		}
	}
	//confirm(adj);
	return adj;
}


function OrderExon(start, end) {
	if (!cStrand) {
		return start + '..' + end;
	} else {
		return end + '..' + start;
	}
}


function isStructure() {
	if (typeof document.forms[formName].UCAstruct.value != 'undefined') {
	  if (document.forms[formName].UCAstruct.value != "") {
	    return 1;
	  }
	} else { return 0; }
}

function SubtractOverlap(arrr) {
	newArray = new Array();
	olapy = false;
	var toRemove = new Array();
	for(var i=0;i<arrr.length;i++) {
		for(var j=0;j<arrr.length;j++) {
			coord = arrr[i].match(/\d+/g);
			coords = arrr[j].match(/\d+/g);
			if (coord[0] == coords[0] && coord[1] == coords[1]) {
				if (!Within(newArray, arrr[i])) {
					newArray.push(arrr[i]);	
					//newArray = OverlapWithin(newArray, arrr[i]);
				}
			} else if (Overlap(coord,coords)!=0) {
				olapy = true;
				if (Math.abs(parseInt(coords[0])-parseInt(coords[1]) ) >  Math.abs(parseInt(coord[0])-parseInt(coord[1]))) {
					toRemove.push(coord[0] + '..' + coord[1]);
					if (!Within(newArray, coords[0] + '..' + coords[1])) {
						newArray.push(coords[0] + '..' + coords[1]);
						//newArray = OverlapWithin(newArray, coords[0] + '..' + coords[1]);
					}
				} else if (Math.abs(parseInt(coords[0])-parseInt(coords[1]) ) < Math.abs(parseInt(coord[0])-parseInt(coord[1]))){
					toRemove.push(coords[0] + '..' + coords[1]);
					if (!Within(newArray, coord[0] + '..' + coord[1])) {
						newArray.push(coord[0] + '..' + coord[1]);
						//newArray = OverlapWithin(newArray, coord[0] + '..' + coord[1]);
					}
				} else {
					if (!Within(newArray, arrr[i])) {
						newArray.push(coord[0] + '..' + coord[1]);
						//newArray = OverlapWithin(newArray, coord[0] + '..' + coord[1]);	
					}
					if (!Within(newArray, arrr[j])) {
						newArray.push(arrr[j]);
						//newArray = OverlapWithin(newArray, arrr[j]);
					}
				}
			} else if (Overlap(coord, coords)==0) {
				if (!Within(newArray, arrr[j])) {
					newArray.push(arrr[j]);
					//newArray = OverlapWithin(newArray, arrr[j]);
				}
				
			}
					
		}
	}
	//confirm(toRemove.join());
	if (toRemove) {
		for (var j = 0; j<toRemove.length;j++) {
			for (var i = 0;i<newArray.length;i++) {
				if (newArray[i] == toRemove[j]) {
					newArray.splice(i,1);
				}
			}
		}
	}
	return newArray;
}

//--END Utility Functions--//

//--Mouse Functions--//
function go_to(){ // null function, needed for mouseovers in older browser
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

function findPosX(obj)
{
        var curleft = 0;
        if (obj.offsetParent)
        {
                while (obj.offsetParent)
                {
                        curleft += obj.offsetLeft
                        obj = obj.offsetParent;
                }
        }
        else if (obj.x)
                curleft += obj.x;
        return curleft;
}

//--External Queries --//

function Blast(t){
  if (t == "p"){
    if (document.forms[formName].protein.value){
      blastlink = "http://www.ncbi.nlm.nih.gov/blast/Blast.cgi?CMD=Web&LAYOUT=TwoWindows&AUTO_FORMAT=Semiauto&ALIGNMENTS=50&ALIGNMENT_VIEW=Pairwise&CDD_SEARCH=on&CLIENT=web&COMPOSITION_BASED_STATISTICS=on&DATABASE=nr&DESCRIPTIONS=100&ENTREZ_QUERY=%28none%29&EXPECT=10&FILTER=L&FORMAT_OBJECT=Alignment&FORMAT_TYPE=HTML&I_THRESH=0.005&MATRIX_NAME=BLOSUM62&NCBI_GI=on&PAGE=Proteins&PROGRAM=blastp&SERVICE=plain&SET_DEFAULTS.x=41&SET_DEFAULTS.y=5&SHOW_OVERVIEW=on&END_OF_HTTPGET=Yes&SHOW_LINKOUT=yes&GET_SEQUENCE=yes";
      blastlink = blastlink + "&QUERY=" + document.forms[formName].protein.value;
      winName = Sname+"blastp";
    }else{
      alert("no protein sequence");
      return;
    }
  }else if(t=="n"){
      if (document.forms[formName].mRNAseq.value != "no structure entered" && document.forms[formName].mRNAseq.value != ""){
	blastlink = "http://www.ncbi.nlm.nih.gov/blast/Blast.cgi?CMD=Web&LAYOUT=TwoWindows&AUTO_FORMAT=Semiauto&ALIGNMENTS=50&ALIGNMENT_VIEW=Pairwise&CDD_SEARCH=on&CLIENT=web&COMPOSITION_BASED_STATISTICS=on&DATABASE=nr&DESCRIPTIONS=100&ENTREZ_QUERY=%28none%29&EXPECT=10&FILTER=L&FORMAT_OBJECT=Alignment&FORMAT_TYPE=HTML&I_THRESH=0.005&MATRIX_NAME=BLOSUM62&NCBI_GI=on&PAGE=Nucleotides&PROGRAM=blastn&SERVICE=plain&SET_DEFAULTS.x=41&SET_DEFAULTS.y=5&SHOW_OVERVIEW=on&END_OF_HTTPGET=Yes&SHOW_LINKOUT=yes&GET_SEQUENCE=yes";
        blastlink = blastlink + "&QUERY=" + document.forms[formName].mRNAseq.value;
      winName = Sname+"blastn";
    }else{
      alert("no mRNA structure");
      return;
    }
  }else if(t=="tn"){
      if (document.forms[formName].protein.value){
	blastlink = "http://www.ncbi.nlm.nih.gov/blast/Blast.cgi?ALIGNMENTS=50&ALIGNMENT_VIEW=Pairwise&AUTO_FORMAT=Semiauto&CLIENT=web&DATABASE=nr&DESCRIPTIONS=100&ENTREZ_QUERY=All+organisms&EXPECT=10&FILTER=L&FORMAT_BLOCK_ON_RESPAGE=None&FORMAT_ENTREZ_QUERY=All+organisms&FORMAT_OBJECT=Alignment&FORMAT_TYPE=HTML&GAPCOSTS=11+1&GENETIC_CODE=1&GET_SEQUENCE=on&LAYOUT=TwoWindows&MASK_CHAR=0&MASK_COLOR=0&MATRIX_NAME=BLOSUM62&NCBI_GI=on&PAGE=Translations&PROGRAM=tblastn&SERVICE=plain&SET_DEFAULTS=Yes&SET_DEFAULTS.x=28&SET_DEFAULTS.y=11&SHOW_LINKOUT=on&SHOW_OVERVIEW=on&UNGAPPED_ALIGNMENT=no&WORD_SIZE=3&END_OF_HTTPGET=Yes";
	blastlink = blastlink + "&QUERY=" + document.forms[formName].protein.value;
      winName = Sname+"tblastn";
    }else{
      alert("no protein sequence");
      return;
    }
  }else if(t=="x"){
      if (document.forms[formName].mRNAseq.value != "no structure entered" && document.forms[formName].mRNAseq.value != ""){
        blastlink = "http://www.ncbi.nlm.nih.gov/blast/Blast.cgi?ALIGNMENTS=50&ALIGNMENT_VIEW=Pairwise&AUTO_FORMAT=Semiauto&CLIENT=web&DATABASE=nr&DESCRIPTIONS=100&ENTREZ_QUERY=All+organisms&EXPECT=10&FILTER=L&FORMAT_BLOCK_ON_RESPAGE=None&FORMAT_ENTREZ_QUERY=All+organisms&FORMAT_OBJECT=Alignment&FORMAT_TYPE=HTML&GAPCOSTS=11+1&GENETIC_CODE=1&GET_SEQUENCE=on&LAYOUT=TwoWindows&MASK_CHAR=0&MASK_COLOR=0&MATRIX_NAME=BLOSUM62&NCBI_GI=on&PAGE=Translations&PROGRAM=blastx&SERVICE=plain&SET_DEFAULTS=Yes&SET_DEFAULTS.x=28&SET_DEFAULTS.y=11&SHOW_LINKOUT=on&SHOW_OVERVIEW=on&UNGAPPED_ALIGNMENT=no&WORD_SIZE=3&END_OF_HTTPGET=Yes";
	blastlink = blastlink + "&QUERY=" + document.forms[formName].mRNAseq.value;
      winName = Sname+"tblastx";
    }else{
      alert("no mRNA structure");
      return;
    }
  }else if (t=="tx"){
 if (document.forms[formName].mRNAseq.value != "no structure entered" && document.forms[formName].mRNAseq.value != ""){
        blastlink = "http://www.ncbi.nlm.nih.gov/blast/Blast.cgi?ALIGNMENTS=50&ALIGNMENT_VIEW=Pairwise&AUTO_FORMAT=Semiauto&CLIENT=web&DATABASE=nr&DESCRIPTIONS=100&ENTREZ_QUERY=All+organisms&EXPECT=10&FILTER=L&FORMAT_BLOCK_ON_RESPAGE=None&FORMAT_ENTREZ_QUERY=All+organisms&FORMAT_OBJECT=Alignment&FORMAT_TYPE=HTML&GAPCOSTS=11+1&GENETIC_CODE=1&GET_SEQUENCE=on&LAYOUT=TwoWindows&MASK_CHAR=0&MASK_COLOR=0&MATRIX_NAME=BLOSUM62&NCBI_GI=on&PAGE=Translations&PROGRAM=tblastx&SERVICE=plain&SET_DEFAULTS=Yes&SET_DEFAULTS.x=28&SET_DEFAULTS.y=11&SHOW_LINKOUT=on&SHOW_OVERVIEW=on&UNGAPPED_ALIGNMENT=no&WORD_SIZE=3&END_OF_HTTPGET=Yes";
        blastlink = blastlink + "&QUERY=" + document.forms[formName].mRNAseq.value;
      winName = Sname+"tblastx";
    }else{
      alert("no mRNA structure");
      return;
    }

  }else{
    return;
  }
  window.open(blastlink,winName,'resizable=yes,screenX=200,screenY=200,top=200,left=200,toolbar=yes,status=yes,scrollbars=yes,location=yes,menubar=yes,directories=no,width=600,height=600');

}

function InterProScan() {
      // ProteinSeq = (); to be done later: get protein sequence into paste buffer
      // ProteinSeq.execCommand("Copy");
      interprolink = "http://www.ebi.ac.uk/Tools/InterProScan/";
      winName = "InterProScan";
      window.open(interprolink, winName, 'resizable=yes,screenX=200,screenY=200,top=200,left=200,toolbar=yes,status=yes,scrollbars=yes,location=yes,menubar=yes,directories=no,width=900,height=800');

}

function miRBASE() {
      // RNAseq = (); to be done later: get protein sequence into paste buffer
      // RNAseq.execCommand("Copy");
      mirbaselink = "http://www.mirbase.org/search.shtml";
      winName = "mirBASE";
      window.open(mirbaselink, winName, 'resizable=yes,screenX=200,screenY=200,top=200,left=200,toolbar=yes,status=yes,scrollbars=yes,location=yes,menubar=yes,directories=no,width=900,height=800');

}

//--Portals--//

function GORF(){
  if (document.forms[formName].mRNAseq.value != "no structure entered"){
    var link = 'portals/ORFportal.pl';
    window.open('',Sname+'linkorf','resizable=yes,screenX=40,screenY=40,top=40,left=40,toolbar=no,status=no,scrollbars=yes,location=no,menubar=no,directories=no,width=800,height=500');
    PortalForm(link,Sname+'linkorf');
  }else{
    alert("no mRNA structure entered");
  }
}

function smallWin(title,url){
    window.open(url,Sname + title,'resizable=yes,screenX=40,screenY=40,top=40,left=40,toolbar=no,status=no,scrollbars=yes,location=no,menubar=no,directories=no,width=800,height=500');
}

var SY = self.screen.height - 300;
var UnderPS = 300;
function GoGM(){
    var link = 'portals/GMportal.pl';
    UnderPS = findPosY('EvidenceCell');
    window.open('',Sname+'linkGM','resizable=yes,screenX=0,screenY=' + UnderPS + ',top=' + UnderPS + ',left=0,toolbar=no,status=no,scrollbars=yes,location=no,menubar=no,directories=no,width=800,height=300');
    PortalForm(link,Sname+'linkGM');
}

function GoGS(){
    var link = 'portals/GSportal.pl';
    window.open('',Sname + 'linkGS','resizable=yes,screenX=0,screenY=' + UnderPS + ',top=' + UnderPS + ',left=0,toolbar=no,status=no,scrollbars=yes,location=no,menubar=no,directories=no,width=800,height=300');
    PortalForm(link,Sname + 'linkGS');
}
function GoCpGAT(){
    link = 'portals/CpGATportal.pl';
    window.open('',Sname + 'linkCpGAT','resizable=yes,screenX=200,screenY=' + UnderPS + ',top='+ UnderPS + ',left=200,toolbar=yes,status=no,scrollbars=yes,location=no,menubar=no,directories=yes,width=800,height=450');
    PortalForm(link,Sname + 'linkCpGAT');
}

function GoGSQ(){
    link = 'portals/GSQportal.pl';
    window.open('',Sname + 'linkGSQ','resizable=yes,screenX=200,screenY=' + UnderPS + ',top=' + UnderPS + ',left=200,toolbar=yes,status=no,scrollbars=yes,location=yes,menubar=no,directories=no,width=800,height=500');
    PortalForm(link,Sname + 'linkGSQ');
}

function goGAEVAL(){
  link = 'gaevalUCA.pl';
  window.open('',Sname + 'linkGAEVAL','resizable=yes,screenX=200,screenY=' + UnderPS + ',top=' + UnderPS + ',left=200,toolbar=no,status=no,scrollbars=yes,location=no,menubar=no,directories=no,width=300,height=300');
  PortalForm(link,Sname + 'linkGAEVAL');
}

function goSeqEdit(){
  link = 'SeqEdit.pl';
  window.open('',Sname + 'linkGAEVAL','resizable=yes,screenX=200,screenY=' + UnderPS + ',top=' + UnderPS + ',left=200,toolbar=no,status=no,scrollbars=yes,location=no,menubar=no,directories=no,width=600,height=600');
  PortalForm(link,Sname + 'linkGAEVAL');
}

function GoGTH(){
    link = 'portals/GTHportal.pl';
    window.open('',Sname + 'linkGTH','resizable=yes,screenX=200,screenY=' + UnderPS + ',top=' + UnderPS + ',left=200,toolbar=no,status=no,scrollbars=yes,location=no,menubar=no,directories=no,width=600,height=600');
    PortalForm(link,Sname + 'linkGTH');
}
function PortalForm(link,wname){
   document.forms[formName].target = wname;
   document.forms[formName].action = link;
   document.forms[formName].submit();
   window.setTimeout("formreset()", 2000);
   //document.forms[formName].target = "_self";
   //document.forms[formName].action = "";
}


//--Document and Form Functions--//

function set_dropdown_from_textbox(textbox,option_box) {
	var dropdown = document.getElementById(option_box);
	var text_box = document.getElementById(textbox);
	if (text_box.value != ''){
		dropdown.value = text_box.value; // Used when loading saved annotation (not UI)
	}
}

function change_locus(new_value) {
	if (document.getElementById('anno_class_txt').value == 'New Locus'){
		document.getElementById('new_locus_gene_id').value = new_value;
	}
	document.getElementById('locus_id_txt').value = new_value
}

//Function to toggle the display of a text box when the Other option is chosen for a drop down list. Yoinked from /prj/AcDsTagging/Admin/barcodes_add.php , and modified.
function togglefield(val,tbox) {
	var o = document.getElementById(tbox);
	var dropdown = document.getElementById('anno_type_options');
//	dropdown.value = val; // Used when loading saved annotation (not UI)
//	if (val == '[Other...]'){ // User inputs own value
//		o.style.display = 'block';
//		o.value = '';
//	} else
//	if (val == '[Select...]' || val == '[None Available]' || val == '-none-'){ // Reset
	if (val == '[Select...]' || val == '[None Available]'){ // Reset
		o.style.display = 'none';
		o.value = '';
		
	} else { // User selected option from dropdown (including "-none-"
		o.style.display = 'none';
		o.value = val;
	}
}

function togglefield_annotype(val) { //Used to display or hide the locus and transcript dropdowns
	var anno_class = document.getElementById('anno_class_txt');
	var locus_id = document.getElementById('locus_id');
	var transcript_id = document.getElementById('transcript_id');
	var transcript_id_txt = document.getElementById('transcript_id_txt');
	var neue_locus_id = document.getElementById('new_locus_id');
	var locus_id_txt = document.getElementById('locus_id_txt');
	var dropdown = document.getElementById('anno_type_options');
	dropdown.value = val; // Used when loading saved annotation (not UI)

	if (val == 'Select An Annotation Class [required]' || val == '[Select...]' || val == ''){
		locus_id.style.display = 'none';
		transcript_id.style.display = 'none';
		neue_locus_id.style.display = 'none';
		anno_class.value = locus_id_txt.value = transcript_id_txt.value = '';
	} else if (val == 'Improve' || val == 'Confirm' || val == 'Delete' || val == 'Extend or Trim' || val == 'Not Resolved'){
		locus_id.style.display = 'block';
		transcript_id.style.display = 'block';
		neue_locus_id.style.display = 'none';
		anno_class.value = val;
	} else if (val == 'Variant'){
		locus_id.style.display = 'block';
		transcript_id.style.display = 'none';
		neue_locus_id.style.display = 'none';
		transcript_id_txt.value = '';
		anno_class.value = val;
	} else if (val == 'New Locus'){
		locus_id.style.display = 'none';
		transcript_id.style.display = 'none';
		neue_locus_id.style.display = 'block';
		transcript_id_txt.value = '';
		anno_class.value = 'New Locus';
		locus_id_txt.value = document.getElementById('new_locus_gene_id').value;
		change_locus(locus_id_txt.value);
	}
}
function val(){
  if (document.forms[formName].UCAannid.value == ""){
     alert("no Annotation ID entered.");
  }else{
     document.forms[formName].action = document.forms[formName].action + "?UCASubmit=1";
     document.forms[formName].submit();
  }
}
function submitUCA(){
   document.forms[formName].action = "AnnotationTool.pl?UCAsubmit=%3D%3D+Submit%3D%3D+";
   document.forms[formName].submit();
}

function formreset(){
   document.forms[formName].target = "_self";
   document.forms[formName].action = "";
}

function resetAll(){ // TODO: Need to change this? dhrasmus.
  resetMRNA();
  document.forms[formName].UCAannid.value = "";
  document.forms[formName].UCAprod.value = "";
  document.forms[formName].UCAcdsstart.value = "";
  document.forms[formName].UCAcdsend.value = "";
  document.forms[formName].UCAannalias.value = "";
  document.forms[formName].UCAprotalias.value = "";
  document.forms[formName].UCAdesc.value = "";
  document.forms[formName].UDEsource.value = "";
}

function formSubmit(Sname,mess,Starget){

  if ( ((Sname == "UCAsubmit")||(Sname == "UCAsave")||(Sname == "UCAprint"))&& !(submitCheck()) ){
    return 0;
  }
  evidenceFormat();
  if (mess != ""){
    LoadingMessage(mess);
  }
  document.forms[formName].mode.value = Sname;
  document.forms[formName].target = Starget;
  document.forms[formName].submit();
  return;
}

function LoadingMessage(txt){
  document.getElementById('message').innerHTML=txt + "<br>please wait<br><br><br><br><br><br><br><br><br><br><br><br><br>"+ txt + " <br>please wait<br><br><br><br><br><br><br><br><br>" + txt + "<br>please wait";
  changeObjectVisibility('LoadingPopUp', 'visible');
}

function submitCheck(){ // Checks now unnecessary (Bugzilla #160), because user doesn't enter ID themself, and can no longer change it.
// javascript check of format elements before submission or save of annotation
//   if (document.forms[formName].elements['UCAannid'].value.match(/ /)){
//     alert("Annotation ID cannot contain spaces.\n  Modify the Annotation ID field and try again.");
//     return 0;
//   }
//   if (document.forms[formName].elements['UCAannid'].length == 0){
//     alert("Annotation ID is required.\n  Modify the Annotation ID field and try again.");
//     return 0;
//   }
  return 1;
}
