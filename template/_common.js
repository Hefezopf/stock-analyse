// 
// _common.js
// 

// Global Varables
var token1 = 'ghp_';
var token2 = 'x7Hce3kvS91tOCaKO0mSwTZO4eIOHsuUeCFd';

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

    var buyingAmount = Number((pieces * price).toFixed(0));

    var totalAmount;
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
        totalAmount = buyingAmount + Number(overallPastValue) + Number(overallPastGain);

// if (confirm('totalAmount ' + totalAmount + ' buyingAmount ' + buyingAmount + ' intervalSectionPortfolioValues ' + intervalSectionPortfolioValues) == false) {
//     return;
// }


    }
    else {
        var stocksPieces = document.getElementById('stocksPiecesId').innerHTML;
        var overallPieces = Number(stocksPieces) + Number(pieces);
        var stocksBuyingValue = document.getElementById('stocksBuyingValueId');
        totalAmount = buyingAmount + Number(stocksBuyingValue.innerHTML);
    }

    // headlineLink<Symbol>
    var headlineLink;
    var headlineLinkElem = document.getElementById('headlineLink' + symbolParamTrimmed);
    if(headlineLinkElem) {
        headlineLink = headlineLinkElem.innerHTML;
    }
    else {
        headlineLink = symbolParamTrimmed;
    }

    // Trading fees
    var txFee = tradingFees(buyingAmount);
    
    // Condition only for Mobil -> No CORS!
    if(isNaN(totalAmount)) {
        totalAmount = '0';
        overallPieces = '?';
    }
    totalAmount = Number(totalAmount) + txFee;

    if (confirm('Buy ' + pieces + ' pieces of: ' + headlineLink + ' for ' + price + '€? Overall pieces ' + overallPieces + ', Overall amount ' + totalAmount + '€? (Included fees ' + txFee + '€)') == false) {
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
        // readyState 4 means the request is done.
        const DONE = 4;
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
   
    var stocksPiecesId = document.getElementById('stocksPiecesId');
    if(stocksPiecesId) {
        stockPiecesParam = stocksPiecesId.innerHTML;
    }

    const sellingAmount = (Number(stockPiecesParam) * Number(sellPriceParam));
    // Trading fees
    var txFee = tradingFees(sellingAmount);
    const sellingAmountAndTxFee = Number(sellingAmount) + txFee;
    if (confirm('Sell ALL ' + stockPiecesParam + ' pieces of: ' + headlineLink + ' for ' + sellingAmountAndTxFee + '€? (Included fees ' + txFee + '€)') == false) {
        return;
    }
    var url = 'https://api.github.com/repos/Hefezopf/stock-analyse/dispatches';
    var xhr = new XMLHttpRequest();
    xhr.open('POST', url);
    xhr.setRequestHeader('Authorization', 'token ' + token1 + token2.split("").reverse().join(""));
    xhr.setRequestHeader('Accept', 'application/vnd.github.everest-preview+json');
    xhr.onreadystatechange = function () {
        // readyState 4 means the request is done.
        const DONE = 4;
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

function isMobil() {
    if( /Android|webOS|iPhone|iPad|iPod|BlackBerry|IEMobile|Opera Mini/i.test(navigator.userAgent) ) {
        return true;
    }
}

function tradingFees(tradingAmount) {
    var txFee = 10;
    if (tradingAmount > 25000) {
        txFee = 47;
    } 
    else if (tradingAmount > 15000) {
        txFee = 30;
    }
    else if (tradingAmount > 10000) {
        txFee = 20;
    }
    else if (tradingAmount > 5000) {
        txFee = 15;
    }
    return txFee;
}
