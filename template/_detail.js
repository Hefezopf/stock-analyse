// 
// _detail.js
// 

function showChart(timeSpan) {
    var elementSpanToReplace = document.getElementById('imgToReplace');
    elementSpanToReplace.style.display = 'block';
    // ?Hier muss unterschieden werden, ob Mobil oder PC-Browser?
    elementSpanToReplace.style.top = '40%';
    elementSpanToReplace.style.left = '26%';
    elementSpanToReplace.style.transform = 'scale(1.85)';
 
    // Concat is not clean, but works!
    elementSpanToReplace.src = elementSpanToReplace.src + '&TIME_SPAN=' + timeSpan;
}   

function hideChart() {
    var elementSpanToReplace = document.getElementById('imgToReplace');
    elementSpanToReplace.style.display = 'none';
}
