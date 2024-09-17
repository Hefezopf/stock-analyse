//
// _common.js
//

// Global Varables
var token1 = 'ghp_';
var token2 = 'x7Hce3kvS91tOCaKO0mSwTZO4eIOHsuUeCFd';

function curlBuy(symbolParam, price, pieces) {
}

function curlSell(symbolParam, stockPiecesParam, sellPriceParam) {

}

function trimOwnChar(text) {
if(text.charAt(0) === '*') {
return text.substring(1).trim();
}
return text.trim();
}
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
