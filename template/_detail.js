// 
// _detail.js
// 

function showChart(timeSpan) {
    var elementSpanToReplace = document.getElementById('imgToReplace');
    if(isMobil()) {
        elementSpanToReplace.style.top = '25%';
        elementSpanToReplace.style.left = '20%'
        elementSpanToReplace.style.transform = 'scale(1.7)'; // yyy
       // elementSpanToReplace.style.transform = 'scale(1.85)'; // yyy        
    }
    else {
        elementSpanToReplace.style.top = '9%';
        elementSpanToReplace.style.left = '34%';
        elementSpanToReplace.style.transform = 'scale(1.2)';
    }   
    elementSpanToReplace.style.display = 'block';
 
    // Concat is not clean, but works!
    elementSpanToReplace.src = elementSpanToReplace.src + '&TIME_SPAN=' + timeSpan;
}   

function hideChart() {
    var elementSpanToReplace = document.getElementById('imgToReplace');
    elementSpanToReplace.style.display = 'none';
}
