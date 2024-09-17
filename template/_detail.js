//
// _detail.js
//

// Hover Chart
function showChart(timeSpan) {
    var elementSpanToReplace = document.getElementById('imgToReplace');
    elementSpanToReplace.style.display = 'block';
    elementSpanToReplace.style.left = '26%'; 
    elementSpanToReplace.style.transform = 'scale(1.85)';
 
    elementSpanToReplace.src = elementSpanToReplace.src + '&TIME_SPAN=' + timeSpan; // Concat is not clean, but works!  
}   

function hideChart() {
    var elementSpanToReplace = document.getElementById('imgToReplace');
    elementSpanToReplace.style.display = 'none';
}
