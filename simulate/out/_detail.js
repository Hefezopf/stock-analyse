// Global Varables
var token1 = 'ghp_';
var token2 = 'x7Hce3kvS91tOCaKO0mSwTZO4eIOHsuUeCFd';

// Chart Store
var chartTimeSpanStore = new Map();
var chartImageStore = new Map();
var chartNotationIdStore = new Map();

// Open all in Tabs
var linkMap = new Map();
function updateImage(symbol, notationId, timespan) {
    var width = window.innerWidth || document.documentElement.clientWidth || document.body.clientWidth;
    var newWidth = '68%';

    if (width <= 4000) {
        newWidth = '40%';
    }
    if (width <= 2000) {
        newWidth = '50%';
    }    
    if (width <= 1200) { // Mobil IPhone = 1153xp
        newWidth = '70%';
    }
    if (width <= 1000) {
        newWidth = '100%';
    }

    if( /Android|webOS|iPhone|iPad|iPod|BlackBerry|IEMobile|Opera Mini/i.test(navigator.userAgent) ) {
        newWidth = '80%';
    }

    if (timespan !== undefined) {
        chartTimeSpanStore.set(symbol, timespan);
        chartImageStore.set(symbol, new Image());
        chartNotationIdStore.set(symbol, notationId);
    }

    if (chartImageStore.get(symbol).complete) {
        var urlWithTimeSpan = 'https://charts.comdirect.de/charts/rebrush/design_big.chart?AVG1=95&AVG2=38&AVG3=18&AVGTYPE=simple&IND0=SST&IND1=RSI&IND2=MACD&LCOLORS=5F696E&TYPE=MOUNTAIN&LNOTATIONS=' + chartNotationIdStore.get(symbol) + '&TIME_SPAN=' + chartTimeSpanStore.get(symbol);
//        var urlWithTimeSpan = 'https://charts.comdirect.de/charts/rebrush/design_big.chart?AVG1=95&AVG2=38&AVG3=18&AVGTYPE=simple&IND0=RSI&LCOLORS=5F696E&TYPE=MOUNTAIN&LNOTATIONS=' + chartNotationIdStore.get(symbol) + '&TIME_SPAN=' + chartTimeSpanStore.get(symbol);
        var elemIntervalSectionImage = document.getElementById('intervalSectionImage' + symbol);
        if(elemIntervalSectionImage) {
            elemIntervalSectionImage.src = urlWithTimeSpan;
            elemIntervalSectionImage.style.width = newWidth; 
        }
        var imageSymbol = new Image();
        imageSymbol.src = urlWithTimeSpan;
        chartImageStore.set(symbol, imageSymbol);
    }
    // setTimeout(updateImage$symbol, 5*60*1000); // 5 Minutes // 5*60*1000
}

function curlBuy(symbolParam, price, pieces) {
    if (symbolParam == '' || price == '' || pieces == '') {
        var currentInnerHTMLValueIntervalSectionRegularMarketPrice = document.getElementById('intervalSectionRegularMarketPrice' + symbolParam);
        if (currentInnerHTMLValueIntervalSectionRegularMarketPrice) {
            var currentStockValue = currentInnerHTMLValueIntervalSectionRegularMarketPrice.innerHTML.replace('€', '');
            var piecesSuggestion3000 = (3000 / currentStockValue).toFixed(0);
            var piecesSuggestion3500 = (3500 / currentStockValue).toFixed(0);
            var piecesSuggestion4000 = (4000 / currentStockValue).toFixed(0);
            alert('Error: Symbol, Price or Pieces not set! ' + piecesSuggestion3000 + ' pieces are 3000€. ' + piecesSuggestion3500 + ' pieces are 3500€. ' + piecesSuggestion4000 + ' pieces are 4000€.');
        }
        else {
            if (symbolParam == '' && price != '' && pieces == '') {
                var piecesSuggestion3000 = (3000 / price).toFixed(0);
                alert('Error: Symbol, Price or Pieces not set! ' + piecesSuggestion3000 + ' pieces are 3000€.');
            }
            else {
                alert('Error: Symbol, Price or Pieces not set!');
            }
        }
        return;
    }
    var symbolParamTrimmed = symbolParam.trim();
    var price = parseFloat(price.replace(',', '.')).toFixed(2);
    var pieces = pieces.replace('.', '');

    var intervalSectionPortfolioValues = document.getElementById('intervalSectionPortfolioValues' + symbolParamTrimmed);
    if (intervalSectionPortfolioValues) {
        intervalSectionPortfolioValues = intervalSectionPortfolioValues.innerHTML;
        var overallPieces = intervalSectionPortfolioValues.split('pc')[0];
        overallPieces = Number(overallPieces) + Number(pieces);

        // 940pc 51362€
        var overallPastValue = intervalSectionPortfolioValues.split(' ')[1];
        if(overallPastValue) {
            overallPastValue = overallPastValue.split('€')[0];
        }        
        var intervalSectionPortfolioGain = document.getElementById('intervalSectionPortfolioGain' + symbolParamTrimmed).innerHTML;
        var overallPastGain = intervalSectionPortfolioGain.split(' ')[0];
        overallPastGain = Math.abs(overallPastGain.split('€')[0]);
        var totalAmount = Number((pieces * price).toFixed(0)) + Number(overallPastValue) + Number(overallPastGain);
    }
    else {
        var overallPieces = pieces;
        var totalAmount = (pieces * price).toFixed(0);
    }
    totalAmount = Number(totalAmount) + Number(10); // Fees

    //headlineLinkBTL
    var headlineLink;
    var headlineLinkElem = document.getElementById('headlineLink' + symbolParamTrimmed);
    if(headlineLinkElem) {
        headlineLink = headlineLinkElem.innerHTML;
    }
    else {
        headlineLink = symbolParamTrimmed;
    }
    //var headlineLink = document.getElementById('headlineLink' + symbolParamTrimmed).innerHTML;
    if (confirm('Buy ' + pieces + ' pieces of: ' + headlineLink + ' for ' + price + '€? Overall pieces ' + overallPieces + ', Overall amount ' + totalAmount + '€?') == false) {
    //    if (confirm('Buy ' + pieces + ' pieces of:\n' + symbolParamTrimmed + ' for ' + price + '€? Overall pieces ' + overallPieces + ', Overall amount ' + totalAmount + '€?') == false) {
            return;
    }
    if (document.getElementById('intervalSectionInputPriceBuy' + symbolParamTrimmed)) {
        document.getElementById('intervalSectionInputPriceBuy' + symbolParamTrimmed).value = '';
    }
    if (document.getElementById('intervalSectionInputPiecesBuy' + symbolParamTrimmed)) {
        document.getElementById('intervalSectionInputPiecesBuy' + symbolParamTrimmed).value = '';
    }
    document.getElementById('intervalSectionInputSymbolBuyGenerell') ? document.getElementById('intervalSectionInputSymbolBuyGenerell').value : '';
    document.getElementById('intervalSectionInputPriceBuyGenerell') ? document.getElementById('intervalSectionInputPriceBuyGenerell').value : '';
    document.getElementById('intervalSectionInputPiecesBuyGenerell') ? document.getElementById('intervalSectionInputPiecesBuyGenerell').value : '';

    var url = 'https://api.github.com/repos/Hefezopf/stock-analyse/dispatches';
    var xhr = new XMLHttpRequest();
    xhr.open('POST', url);
    xhr.setRequestHeader('Authorization', 'token ' + token1 + token2.split("").reverse().join(""));
    xhr.setRequestHeader('Accept', 'application/vnd.github.everest-preview+json');
    xhr.onreadystatechange = function () {
        const DONE = 4; // readyState 4 means the request is done.
        if (xhr.readyState === DONE) {
            // console.log(xhr.status);
            console.log(xhr.responseText);
        }
    };
    var data = {
        event_type: 'buy',
        client_payload: {
            symbol: symbolParamTrimmed,
            pieces: pieces,
            price: price,
        }
    };
    xhr.send(JSON.stringify(data));
}

function curlSell(symbolParam, stockPiecesParam, sellPriceParam) {
    if (symbolParam.charAt(0) !== '*') {
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

function decryptElement(ele) {
    var dec = document.getElementById(ele.id).innerHTML;
    dec = revers(dec);
    dec = replaceInString(dec);
    document.getElementById(ele.id).innerHTML = dec;
}

function replaceInString(str) {
    var ret = str.replace(/XX/g, 'pc ');
    var ret = ret.replace(/YY/g, '€ ');
    return ret.replace(/ZZ/g, '% ');
}

function revers(num) {
    return String(num).split("").reverse().join("");
}

function revealElement(ele) {
    ele.style.display = '';
}

function styleElement(ele) {
    ele.style.marginBottom = '-22px';
}

function unstyleElement(ele) {
    ele.style.marginBottom = '';
}

function hideElement(ele) {
    ele.style.display = 'none';
}

// Hover Chart
function showChart(timeSpan, symbol) { // function is ALLMOST!!! (symbol parameter) redundant in result html and detail html file! (template\indexPart12.html)
//console.log('result.js: showChart');
    var elementSpanToReplace = document.getElementById('imgToReplace'+ symbol);
    elementSpanToReplace.style.display = 'block';
    //elementSpanToReplace.style.left = '17%'; 
//    elementSpanToReplace.style.left = '500px'; 
    elementSpanToReplace.style.left = '20%'; 
    elementSpanToReplace.src = elementSpanToReplace.src + '&TIME_SPAN=' + timeSpan; // Concat is not clean, but works!
}

function hideChart(symbol) {  // function is ALLMOST!!! (symbol parameter) redundant in result html and detail html file! (template\indexPart12.html)
//console.log('result.js: hideChart');
    var elementSpanToReplace = document.getElementById('imgToReplace'+ symbol);
    elementSpanToReplace.style.display = 'none';
}

function trimOwnChar(text) {
    if(text.charAt(0) === '*') {
        return text.substring(1).trim();
    }
    return text.trim();
}