// 
// _detail.js
// 

function showChart(timeSpan) {
    var elementSpanToReplace = document.getElementById('imgToReplace');
    elementSpanToReplace.style.display = 'block';

    if( /Android|webOS|iPhone|iPad|iPod|BlackBerry|IEMobile|Opera Mini/i.test(navigator.userAgent) ) {
        elementSpanToReplace.style.top = '25%';
        elementSpanToReplace.style.left = '25%';
    }
    else{
        elementSpanToReplace.style.top = '38%';
        elementSpanToReplace.style.left = '38%';
        // top:25%;left:20%;transform:scale(1.5);'/>"
    }   
    elementSpanToReplace.style.transform = 'scale(1.85)';
    // elementSpanToReplace.style.left = '26%';
    // elementSpanToReplace.style.transform = 'scale(1.85)';
 
    // Concat is not clean, but works!
    elementSpanToReplace.src = elementSpanToReplace.src + '&TIME_SPAN=' + timeSpan;
}   

function hideChart() {
    var elementSpanToReplace = document.getElementById('imgToReplace');
    elementSpanToReplace.style.display = 'none';
}
