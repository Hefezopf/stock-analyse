// 
// _detail.js
// 

function showChart(timeSpan) {
    var elementSpanToReplace = document.getElementById('imgToReplace');
    elementSpanToReplace.style.display = 'block';

    if(isMobil()) {
        elementSpanToReplace.style.top = '25%';
        elementSpanToReplace.style.left = '22%'
    }
    else {
        elementSpanToReplace.style.top = '38%';
        elementSpanToReplace.style.left = '38%';
    }   
    elementSpanToReplace.style.transform = 'scale(1.85)';
 
    // Concat is not clean, but works!
    elementSpanToReplace.src = elementSpanToReplace.src + '&TIME_SPAN=' + timeSpan;
}   

function hideChart() {
    var elementSpanToReplace = document.getElementById('imgToReplace');
    elementSpanToReplace.style.display = 'none';
}
