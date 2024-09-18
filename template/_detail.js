// 
// _detail.js
// 

function showChart(timeSpan) {
    var elementSpanToReplace = document.getElementById('imgToReplace');
    elementSpanToReplace.style.display = 'block';

    var bodyId = document.getElementById('bodyId');
    if(isMobil()) {
        bodyId.style.background = 'blue';
        elementSpanToReplace.style.top = '25%';
        elementSpanToReplace.style.left = '25%'
    }
    else {
        bodyId.style.background = 'red'
        elementSpanToReplace.style.top = '38%';
        elementSpanToReplace.style.left = '40%';
    }   
    elementSpanToReplace.style.transform = 'scale(1.85)';
 
    // Concat is not clean, but works!
    elementSpanToReplace.src = elementSpanToReplace.src + '&TIME_SPAN=' + timeSpan;
}   

return true;

function hideChart() {
    var elementSpanToReplace = document.getElementById('imgToReplace');
    elementSpanToReplace.style.display = 'none';
}
