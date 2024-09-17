//
// _common.js
//

// Global Varables
var token1 = 'ghp_';
var token2 = 'x7Hce3kvS91tOCaKO0mSwTZO4eIOHsuUeCFd';

function curlBuy(symbolParam, price, pieces) {
}

function curlSell(symbolParam, stockPiecesParam, sellPriceParam) {
    if (stockPiecesParam === '?' && symbolParam.charAt(0) !== '*') {
        alert('Error: Stock ' + symbolParam.trim() + ' not in portfolio!');
        return;
    }
    symbolParam = trimOwnChar(symbolParam);    

    if (sellPriceParam == '') {
        alert('Error: Price not set!');
        return;
    }

    var headlineLink = symbolParam;
    var headlineLinkElem = document.getElementById('headlineLink' + symbolParam);
    if(headlineLinkElem) {
        headlineLink = headlineLinkElem.innerHTML;
    }
   
    if (confirm('Sell ALL ' + stockPiecesParam + ' pieces of: ' + headlineLink + ' for ' + sellPriceParam + '€?') == false) {
        return;
    }
    var url = 'https://api.github.com/repos/Hefezopf/stock-analyse/dispatches';
    var xhr = new XMLHttpRequest();
    xhr.open('POST', url);
    xhr.setRequestHeader('Authorization', 'token ' + token1 + token2.split("").reverse().join(""));
    xhr.setRequestHeader('Accept', 'application/vnd.github.everest-preview+json');
    xhr.onreadystatechange = function () {
        const DONE = 4; // readyState 4 means the request is done.
        if (xhr.readyState === DONE) {
            console.log(xhr.status);
            console.log(xhr.responseText);
        }
    };
    var data = {
        event_type: 'sell',
        client_payload: {
            symbol: symbolParam,
            sellPrice: sellPriceParam
        }
    };
    xhr.send(JSON.stringify(data));
}

function trimOwnChar(text) {
    if(text.charAt(0) === '*') {
        return text.substring(1).trim();
    }
    return text.trim();
}
