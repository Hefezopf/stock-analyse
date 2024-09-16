// Hover Chart
function showChart(timeSpan) {
    var elementSpanToReplace = document.getElementById('imgToReplace');
    elementSpanToReplace.style.display = 'block';
    elementSpanToReplace.style.left = '20%'; 
    elementSpanToReplace.style.transform = 'scale(1.8)';
 
    elementSpanToReplace.src = elementSpanToReplace.src + '&TIME_SPAN=' + timeSpan; // Concat is not clean, but works!  
}   

function hideChart() {
    var elementSpanToReplace = document.getElementById('imgToReplace');
    elementSpanToReplace.style.display = 'none';
}
