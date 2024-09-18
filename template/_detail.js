// 
// _detail.js
// 

function showChart(timeSpan) {
    var elementSpanToReplace = document.getElementById('imgToReplace');
    if(isMobil()) {
        elementSpanToReplace.style.top = '25%';
        elementSpanToReplace.style.left = '25%'
    }
    else {
        elementSpanToReplace.style.top = '38%';
        elementSpanToReplace.style.left = '52%';
    }   
    elementSpanToReplace.style.transform = 'scale(1.85)';
    elementSpanToReplace.style.display = 'block';
 
    // Concat is not clean, but works!
    elementSpanToReplace.src = elementSpanToReplace.src + '&TIME_SPAN=' + timeSpan;
}   

function hideChart() {
    var elementSpanToReplace = document.getElementById('imgToReplace');
    elementSpanToReplace.style.display = 'none';
}
