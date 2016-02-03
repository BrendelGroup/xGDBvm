function validateComplete(formObj){
    if(emptyField(formObj._gdnap.value) && emptyField(formObj.acc.value)
        &&emptyField(formObj.gdnaf.value)){
        alert('Please Input Genomic Sequence(s)!');
    }else if(emptyField(formObj._estp.value) && emptyField(formObj._e.value)
        && (formObj._d.selectedIndex==0)){
        alert('Please Select or Input EST, TUG, or cDNA sequence(s)!');
    }else{
        return true;
    }
    
    return false;
}

function emptyField(value){
    if(!value) return true;
    if(value.length==0) return true;
    for(var i=0;i<value.length;i++){
        var ch=value.charAt(i);
        if(ch != ' ' && ch != '\t') return false;
    }
    return true;
}
