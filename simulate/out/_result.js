// Global Varables
var token1 = 'ghp_';
var token2 = 'x7Hce3kvS91tOCaKO0mSwTZO4eIOHsuUeCFd';

// Spinner Counters
var counterFetchLoaded = 0;
var counterOwnStocks = 0;

// Sort Button Status
var sortToggleSortDaily = false;
var sortToggleSortValue = false;
var sortToggleOverall = false;

// Realtime Overall Value
var realtimeOverallValue = 0;

// Realtime Daily Value
var realtimeDailyDiff = 0;

// Sound
var sound = new Audio('data:audio/wav;base64,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qJrx4KOQjahZxWbcZgztj2c49nKmkId44S71j0c8eV9yDK6uPRzx5X18eDvjvQ6yKo9ZSS6l//8elePK/Lf//IInrOF/FvDoADYAGBMGb7FtErm5MXMlmPAJQVgWta7Zx2go+8xJ0UiCb8LHHdftWyLJE0QIAIsI+UbXu67dZMjmgDGCGl1H+vpF4NSDckSIkk7Vd+sxEhBQMRU8j/12UIRhzSaUdQ+rQU5kGeFxm+hb1oh6pWWmv3uvmReDl0UnvtapVaIzo1jZbf/pD6ElLqSX+rUmOQNpJFa/r+sa4e/pBlAABoAAAAA3CUgShLdGIxsY7AUABPRrgCABdDuQ5GC7DqPQCgbbJUAoRSUj+NIEig0YfyWUho1VBBBA//uQZB4ABZx5zfMakeAAAAmwAAAAF5F3P0w9GtAAACfAAAAAwLhMDmAYWMgVEG1U0FIGCBgXBXAtfMH10000EEEEEECUBYln03TTTdNBDZopopYvrTTdNa325mImNg3TTPV9q3pmY0xoO6bv3r00y+IDGid/9aaaZTGMuj9mpu9Mpio1dXrr5HERTZSmqU36A3CumzN/9Robv/Xx4v9ijkSRSNLQhAWumap82WRSBUqXStV/YcS+XVLnSS+WLDroqArFkMEsAS+eWmrUzrO0oEmE40RlMZ5+ODIkAyKAGUwZ3mVKmcamcJnMW26MRPgUw6j+LkhyHGVGYjSUUKNpuJUQoOIAyDvEyG8S5yfK6dhZc0Tx1KI/gviKL6qvvFs1+bWtaz58uUNnryq6kt5RzOCkPWlVqVX2a/EEBUdU1KrXLf40GoiiFXK///qpoiDXrOgqDR38JB0bw7SoL+ZB9o1RCkQjQ2CBYZKd/+VJxZRRZlqSkKiws0WFxUyCwsKiMy7hUVFhIaCrNQsKkTIsLivwKKigsj8XYlwt/WKi2N4d//uQRCSAAjURNIHpMZBGYiaQPSYyAAABLAAAAAAAACWAAAAApUF/Mg+0aohSIRobBAsMlO//Kk4soosy1JSFRYWaLC4qZBYWFRGZdwqKiwkNBVmoWFSJkWFxX4FFRQWR+LsS4W/rFRb/////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////VEFHAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAU291bmRib3kuZGUAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAMjAwNGh0dHA6Ly93d3cuc291bmRib3kuZGUAAAAAAAAAACU=');

// Chart Store
var chartTimeSpanStore = new Map();
var chartImageStore = new Map();
var chartNotationIdStore = new Map();

// Open all in Tabs
var linkMap = new Map();

// Refresh the page after a delay of 5 Min
// If changed, change here as well: analyse.sh: <progress value=0 max=300 id=intervalSectionHeadlineDailyProgressBar
const initRefreshSeconds = 300;
if (location.href.startsWith('file') && location.href.endsWith('_result.html')) {
    setTimeout(function() {
        location.reload();
    }, initRefreshSeconds * 1000); // 300 * 1000 milliseconds = 300 seconds = 5 Min
}

var timeleftToRefresh = initRefreshSeconds; // 300 seconds total
var progressBarTimer = setInterval(function() {
  if(timeleftToRefresh <= 0) {
    clearInterval(progressBarTimer);
  }
  var intervalSectionHeadlineDailyProgressBar = document.getElementById("intervalSectionHeadlineDailyProgressBar");
  if(intervalSectionHeadlineDailyProgressBar) {
    intervalSectionHeadlineDailyProgressBar.value = initRefreshSeconds - timeleftToRefresh;
  }
  timeleftToRefresh -= 1;
}, 1000); // Visualize in 1 second steps

var delay = ( function() {
    var timer = 0;
    return function(callback, ms) {
        clearTimeout (timer);
        timer = setTimeout(callback, ms);
    };
})();

// Spinner
var intervalLoadingSpinnerId = setInterval(function () {
    if (counterFetchLoaded >= counterOwnStocks) {
        // Show local link, if on PC
        if (location.href.startsWith('file')) {
            delay(function() {
                processAll();
                doHideDetails();
                doSortDailyGain();
           // }, 12000 ); // end delay, timeout, Warten
            }, 500 ); // end delay, timeout, Warten
        }   
        else{
            document.getElementsByTagName('body')[0].ondblclick = processAll;
        }
        hideSpinner();
        clearInterval(intervalLoadingSpinnerId);
        // Enable Buttons
        var intervalSectionButtonSortDaily = document.querySelector('#intervalSectionButtonSortDaily');
        if(intervalSectionButtonSortDaily) {
            intervalSectionButtonSortDaily.disabled = false;
        }
        var intervalSectionButtonSortValue = document.querySelector('#intervalSectionButtonSortValue');
        if(intervalSectionButtonSortValue) {
            intervalSectionButtonSortValue.disabled = false;
        }
        var intervalSectionButtonSortOverall = document.querySelector('#intervalSectionButtonSortOverall');
        if(intervalSectionButtonSortOverall) {
            intervalSectionButtonSortOverall.disabled = false;
        }
        var intervalSectionButtonHideDetails = document.querySelector('#intervalSectionButtonHideDetails');
        if(intervalSectionButtonHideDetails) {
            intervalSectionButtonHideDetails.disabled = false;
        }
        var intervalSectionButtonGoToEnd = document.querySelector('#intervalSectionButtonGoToEnd');
        if(intervalSectionButtonGoToEnd) {
            intervalSectionButtonGoToEnd.disabled = false;
        }
        var intervalSectionButtonOpenAll = document.querySelector('#intervalSectionButtonOpenAll');
        if(intervalSectionButtonOpenAll) {
            intervalSectionButtonOpenAll.disabled = false;
        }
    }
}, 3000);

function setBeepInterval(symbol) {
    var intervalValue = document.getElementById('intervalField' + symbol).value;
    var intervalVarSymbol = setInterval(function () {
        var elementAlert = document.getElementById('intervalText' + symbol);
        elementAlert.innerHTML = ' ALERT!!!';
        elementAlert.style.color = 'red';
        sound.play();
        clearInterval(intervalVarSymbol);
    }, intervalValue * 60 * 1000); // 60*1000 = 1 Minute
    var elementIntervalText = document.getElementById('intervalText' + symbol);
    elementIntervalText.innerHTML = ' ...' + intervalValue;
    elementIntervalText.style.color = 'green';
}

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

function doSortDailyGain() {
    var portfolioValueDaxFooterId = document.getElementById('portfolioValueDaxFooterId');
    if (portfolioValueDaxFooterId) {
        sortToggleSortDaily = !sortToggleSortDaily;
        var intervalSectionButtonSortDailyButton = document.getElementById('intervalSectionButtonSortDaily');
        if (sortToggleSortDaily) {
            intervalSectionButtonSortDailyButton.innerHTML = '&uarr;&nbsp;Daily&nbsp;%';
        }
        else {
            intervalSectionButtonSortDailyButton.innerHTML = '&darr;&nbsp;Daily&nbsp;%';
        }
        var intervalSectionButtonSortOverallButton = document.getElementById('intervalSectionButtonSortOverall');
        intervalSectionButtonSortOverallButton.innerHTML = '&nbsp;&nbsp;&sum;&nbsp;%';
        var intervalSectionButtonSortValueButton = document.getElementById('intervalSectionButtonSortValue');
        intervalSectionButtonSortValueButton.innerHTML = '&nbsp;&nbsp;Value&nbsp;€';

        var container = document.getElementById('symbolsListId');
        var elements = container.childNodes;
        var sortPositivDailyValues = [];
        var sortNegativDailyValues = [];
        for (var i = 0; i < elements.length; i++) {
            // Skip nodes without an ID
            if (!elements[i].id) {
                continue;
            }

            var sortPart = elements[i].id.split('_');
            // Only add the element for sorting if it has a '+' in it
            // Example ID: id='symbolLineIdEUZ_-115_+111_9999'
            if (sortPart.length > 1) {
                if (sortPart[1][0] === '-') {
                    sortNegativDailyValues.push([-1 * sortPart[1], elements[i]]);
                }
                else { // if (sortPart[1][0] === '+') {
                    /*
                    * prepare the ID for faster comparison
                    * array will contain:
                    *   [0] => number which will be used for sorting 
                    *   [1] => element
                    * 1 * something is the fastest way I know to convert a string to a
                    * number. It should be a number to make it sort in a natural way,
                    * so that it will be sorted as 1, 2, 10, 20, and not 1, 10, 2, 20
                    */
                    sortPositivDailyValues.push([1 * sortPart[1], elements[i]]);
                }
            }
        }

        // Sort the array sortPositivDailyValues, elements with the highest ID will be first
        sortPositivDailyValues.sort(function (x, y) {
            if (sortToggleSortDaily) {
                return y[0] - x[0];
            }
            else {
                return x[0] - y[0];
            }
        });
        sortNegativDailyValues.sort(function (x, y) {
            if (sortToggleSortDaily) {
                return x[0] - y[0];
            }
            else {
                return y[0] - x[0];
            }
        });

        addButtons(container);

        // Append the sorted elements again, the old element will be moved to the new position
        if (sortToggleSortDaily) {
            for (var i = 0; i < sortPositivDailyValues.length; i++) {
                container.appendChild(sortPositivDailyValues[i][1]);
            }
            for (var i = 0; i < sortNegativDailyValues.length; i++) {
                container.appendChild(sortNegativDailyValues[i][1]);
            }
        }
        else {
            for (var i = 0; i < sortNegativDailyValues.length; i++) {
                container.appendChild(sortNegativDailyValues[i][1]);
            }
            for (var i = 0; i < sortPositivDailyValues.length; i++) {
                container.appendChild(sortPositivDailyValues[i][1]);
            }
        }

        container.appendChild(document.createElement("br"));
        container.appendChild(portfolioValueDaxFooterId);

        resizeSortedText('xx-large', 'medium', 'medium');
    }
}

function doSortInvestedValue() {
    var portfolioValueDaxFooterId = document.getElementById('portfolioValueDaxFooterId');

    sortToggleSortValue = !sortToggleSortValue;
    var intervalSectionButtonSortValueButton = document.getElementById('intervalSectionButtonSortValue');
    if (sortToggleSortValue) {
        intervalSectionButtonSortValueButton.innerHTML = '&uarr;&nbsp;Value&nbsp;€';
    }
    else {
        intervalSectionButtonSortValueButton.innerHTML = '&darr;&nbsp;Value&nbsp;€';
    }
    var intervalSectionButtonSortDailyButton = document.getElementById('intervalSectionButtonSortDaily');
    intervalSectionButtonSortDailyButton.innerHTML = '&nbsp;&nbsp;Daily&nbsp;%';
    var intervalSectionButtonSortOverallButton = document.getElementById('intervalSectionButtonSortOverall');
    intervalSectionButtonSortOverallButton.innerHTML = '&nbsp;&nbsp;&sum;&nbsp;%';

    var container = document.getElementById('symbolsListId');
    var elements = container.childNodes;
    var sortOverallValues = [];
    for (var i = 0; i < elements.length; i++) {
        if (!elements[i].id) {
            continue;
        }
        var sortPart = elements[i].id.split('_');
        if (sortPart.length > 1) {
            sortOverallValues.push([1 * sortPart[3], elements[i]]);
        }
    }

    sortOverallValues.sort(function (x, y) {
        if (sortToggleSortValue) {
            return y[0] - x[0];
        }
        else {
            return x[0] - y[0];
        }
    });

    addButtons(container);

    for (var i = 0; i < sortOverallValues.length; i++) {
        container.appendChild(sortOverallValues[i][1]);
    }

    container.appendChild(document.createElement("br"));
    container.appendChild(portfolioValueDaxFooterId);

    resizeSortedText('medium', 'xx-large', 'medium');
}

function doSortOverallGain() {
    var portfolioValueDaxFooterId = document.getElementById('portfolioValueDaxFooterId');

    sortToggleOverall = !sortToggleOverall;
    var intervalSectionButtonSortOverallButton = document.getElementById('intervalSectionButtonSortOverall');
    if (sortToggleOverall) {
        intervalSectionButtonSortOverallButton.innerHTML = '&uarr;&nbsp;&sum;&nbsp;%';
    }
    else {
        intervalSectionButtonSortOverallButton.innerHTML = '&darr;&nbsp;&sum;&nbsp;%';
    }
    var intervalSectionButtonSortDailyButton = document.getElementById('intervalSectionButtonSortDaily');
    intervalSectionButtonSortDailyButton.innerHTML = '&nbsp;&nbsp;Daily&nbsp;%';
    var intervalSectionButtonSortValueButton = document.getElementById('intervalSectionButtonSortValue');
    intervalSectionButtonSortValueButton.innerHTML = '&nbsp;&nbsp;Value&nbsp;€';

    var container = document.getElementById('symbolsListId');
    var elements = container.childNodes;
    var sortPositivOverallValues = [];
    var sortNegativOverallValues = [];
    for (var i = 0; i < elements.length; i++) {
        if (!elements[i].id) {
            continue;
        }
        var sortPart = elements[i].id.split('_');
        if (sortPart.length > 1) {
            if (sortPart[2][0] === '+') {
                sortPositivOverallValues.push([1 * sortPart[2], elements[i]]);
            }
            if (sortPart[2][0] === '-') {
                sortNegativOverallValues.push([-1 * sortPart[2], elements[i]]);
            }
        }
    }
    sortPositivOverallValues.sort(function (x, y) {
        if (sortToggleOverall) {
            return y[0] - x[0];
        }
        else {
            return x[0] - y[0];
        }
    });
    sortNegativOverallValues.sort(function (x, y) {
        if (sortToggleOverall) {
            return x[0] - y[0];
        }
        else {
            return y[0] - x[0];
        }
    });

    addButtons(container);

    if (sortToggleOverall) {
        for (var i = 0; i < sortPositivOverallValues.length; i++) {
            container.appendChild(sortPositivOverallValues[i][1]);
        }
        for (var i = 0; i < sortNegativOverallValues.length; i++) {
            container.appendChild(sortNegativOverallValues[i][1]);
        }
    }
    else {
        for (var i = 0; i < sortNegativOverallValues.length; i++) {
            container.appendChild(sortNegativOverallValues[i][1]);
        }
        for (var i = 0; i < sortPositivOverallValues.length; i++) {
            container.appendChild(sortPositivOverallValues[i][1]);
        }
    }

    container.appendChild(document.createElement("br"));
    container.appendChild(portfolioValueDaxFooterId);

    resizeSortedText('medium', 'medium', 'xx-large');
}

function addButtons(container) {
    var parameterId = document.getElementById('parameterId');
    var analyseId = document.getElementById('analyseId');

    var intervalSectionHeadlineDaily = document.getElementById('intervalSectionHeadlineDaily');
    var obfuscatedValueBuyingDailyRealtime = document.getElementById('obfuscatedValueBuyingDailyRealtime');
    var intervalSectionHeadlineDailyProgressBar = document.getElementById('intervalSectionHeadlineDailyProgressBar');

    var intervalSectionButtonSortDailyButton = document.getElementById('intervalSectionButtonSortDaily');
    var intervalSectionButtonSortValueButton = document.getElementById('intervalSectionButtonSortValue');
    var intervalSectionButtonSortOverallButton = document.getElementById('intervalSectionButtonSortOverall');
    var intervalSectionButtonHideDetails = document.getElementById('intervalSectionButtonHideDetails');
    var intervalSectionButtonGoToEnd = document.getElementById('intervalSectionButtonGoToEnd');
    var intervalSectionButtonOpenAll = document.getElementById('intervalSectionButtonOpenAll');

    var intervalSectionHROverallButtons = document.getElementById('intervalSectionHROverallButtons');

    // Clear page
    container.innerHTML = '';

    // Add content and sort buttons
    container.appendChild(parameterId);
    container.appendChild(analyseId);

    container.appendChild(document.createElement("br"));
    container.appendChild(intervalSectionHeadlineDaily);
    container.appendChild(document.createElement("br"));
    container.appendChild(obfuscatedValueBuyingDailyRealtime);

    if (location.href.startsWith('file')) {
        container.appendChild(document.createTextNode(" "));
        container.appendChild(intervalSectionHeadlineDailyProgressBar); 
    }
        
    container.appendChild(document.createElement("br"));
    container.appendChild(document.createElement("br"));

    container.appendChild(intervalSectionButtonSortDailyButton);
    container.appendChild(document.createTextNode(" "));
    container.appendChild(intervalSectionButtonSortValueButton);
    container.appendChild(document.createTextNode(" "));
    container.appendChild(intervalSectionButtonSortOverallButton);
    container.appendChild(document.createTextNode(" "));
    container.appendChild(intervalSectionButtonHideDetails);
    container.appendChild(document.createTextNode(" "));
    container.appendChild(intervalSectionButtonGoToEnd);
    container.appendChild(document.createTextNode(" "));
    container.appendChild(intervalSectionButtonOpenAll);

    container.appendChild(document.createElement("br"));
    container.appendChild(intervalSectionHROverallButtons);
}

function resizeSortedText(fontSizeRealTimeQuotesPercentagesGain, fontSizePortfolioValues, fontSizePortfolioGains) {
    var intervalSectionRealTimeQuotes = document.querySelectorAll('[id ^= \"intervalSectionRealTimeQuote\"]');
    for (var i = 0; i < intervalSectionRealTimeQuotes.length; i++) {
        intervalSectionRealTimeQuotes[i].style.fontSize = fontSizeRealTimeQuotesPercentagesGain;
    }
    var intervalSectionPercentages = document.querySelectorAll('[id ^= \"intervalSectionPercentage\"]');
    for (var i = 0; i < intervalSectionPercentages.length; i++) {
        intervalSectionPercentages[i].style.fontSize = fontSizeRealTimeQuotesPercentagesGain;
    }
    var intervalSectionGain = document.querySelectorAll('[id ^= \"intervalSectionGain\"]');
    for (var i = 0; i < intervalSectionGain.length; i++) {
        intervalSectionGain[i].style.fontSize = fontSizeRealTimeQuotesPercentagesGain;
    }

    var intervalSectionPortfolioValues = document.querySelectorAll('[id ^= \"intervalSectionPortfolioValues\"]');
    for (var i = 0; i < intervalSectionPortfolioValues.length; i++) {
        intervalSectionPortfolioValues[i].style.fontSize = fontSizePortfolioValues;
    }

    var intervalSectionPortfolioGains = document.querySelectorAll('[id ^= \"intervalSectionPortfolioGain\"]');
    for (var i = 0; i < intervalSectionPortfolioGains.length; i++) {
        intervalSectionPortfolioGains[i].style.fontSize = fontSizePortfolioGains;
    }
}

function doGoToEnd() {
    var scrollingElement = (document.scrollingElement || document.body);
    scrollingElement.scrollTop = scrollingElement.scrollHeight;
}

function doOpenAllInTab() {
    for (let [key, value] of linkMap) {
        window.open(value, '_blank').focus();
    }
}

var toggleIsDetailsVisible = true;
function doHideDetails() {
    var detailsIdValues = document.querySelectorAll('[id ^= \"detailsId\"]');
    var intervalSectionBeepValues = document.querySelectorAll('[id ^= \"intervalSectionBeep\"]');
    var intervalSectionButtonValues = document.querySelectorAll('[id ^= \"intervalSectionButtonDetails\"]');
    var intervalSectionButtonHideDetailsButton = document.getElementById('intervalSectionButtonHideDetails');
    var intervalSectionRealTimeQuoteValues = document.querySelectorAll('[id ^= \"intervalSectionRealTimeQuote\"]');
    var intervalSectionGainValues = document.querySelectorAll('[id ^= \"intervalSectionGain\"]');
    var intervalSectionPortfolioValues = document.querySelectorAll('[id ^= \"intervalSectionPortfolioValues\"]');

    var symbolLineIdValues = document.querySelectorAll('[id ^= \"symbolLineId\"]');
    if(toggleIsDetailsVisible) {
        Array.prototype.forEach.call(detailsIdValues, hideElement);
        Array.prototype.forEach.call(intervalSectionBeepValues, hideElement);
        Array.prototype.forEach.call(intervalSectionButtonValues, hideElement);
        Array.prototype.forEach.call(intervalSectionRealTimeQuoteValues, hideElement);
        Array.prototype.forEach.call(intervalSectionGainValues, hideElement); 
        Array.prototype.forEach.call(intervalSectionPortfolioValues, hideElement);
        if(intervalSectionButtonHideDetailsButton) {
            intervalSectionButtonHideDetailsButton.innerHTML = '- Details';
        }
        Array.prototype.forEach.call(symbolLineIdValues, styleElement);
    }
    else{
        Array.prototype.forEach.call(detailsIdValues, revealElement);
        Array.prototype.forEach.call(intervalSectionBeepValues, revealElement);
        Array.prototype.forEach.call(intervalSectionButtonValues, revealElement);
        Array.prototype.forEach.call(intervalSectionRealTimeQuoteValues, revealElement);
        Array.prototype.forEach.call(intervalSectionGainValues, revealElement);
        Array.prototype.forEach.call(intervalSectionPortfolioValues, revealElement);
        intervalSectionButtonHideDetailsButton.innerHTML = '+ Details';
        Array.prototype.forEach.call(symbolLineIdValues, unstyleElement);
    }
    toggleIsDetailsVisible = !toggleIsDetailsVisible;
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
            console.log(xhr.status);
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

var toggleIsContentVisible = false;
var toggleDecryptOnlyOnce = false;

function processAll(ele) {
    var intervalValues = document.querySelectorAll('[id ^= \"intervalSection\"]');
    var obfuscatedValues = document.querySelectorAll('[id ^= \"obfuscatedValue\"]');
    if (!toggleIsContentVisible) {
        Array.prototype.forEach.call(intervalValues, revealElement);

        var intervalOwnSymbolsValues = document.querySelectorAll('[id ^= \"intervalSectionRealTimeQuote\"]');
        Array.prototype.forEach.call(intervalOwnSymbolsValues, calculateRealtimeDailyDiff);

        Array.prototype.forEach.call(obfuscatedValues, revealElement);
        if (!toggleDecryptOnlyOnce) {
            Array.prototype.forEach.call(obfuscatedValues, decryptElement);

            // 105778/95439€
            var obfuscatedValueBuyingOverallElem = document.getElementById('obfuscatedValueBuyingOverall');
            if(obfuscatedValueBuyingOverallElem) {
                var buyingOverallYesterdaysValue = obfuscatedValueBuyingOverallElem.innerHTML;
                var buyingValue = buyingOverallYesterdaysValue.split('/')[0];
                var realtimeToBuyingDiffValue = realtimeOverallValue - buyingValue;
                var obfuscatedValueBuyingOverallRealtimeElem = document.getElementById('obfuscatedValueBuyingOverallRealtime');
            
                var percentageRealtime = 100 / buyingValue * realtimeToBuyingDiffValue;
                obfuscatedValueBuyingOverallRealtimeElem.innerHTML = realtimeToBuyingDiffValue + '€ / ' + percentageRealtime.toFixed(1) + '%';

                if (realtimeToBuyingDiffValue < 0) {
                    obfuscatedValueBuyingOverallRealtimeElem.style.color = 'red';
                }
                else {
                    obfuscatedValueBuyingOverallRealtimeElem.style.color = 'green';
                }
            }

            // 940pc 51362€
            var obfuscatedValueBuyingDailyRealtimeElem = document.getElementById('obfuscatedValueBuyingDailyRealtime');
            if(obfuscatedValueBuyingDailyRealtimeElem) {
                var buyingYesterdaysValue = buyingOverallYesterdaysValue.split('/')[1];
                if (buyingYesterdaysValue) {
                    buyingYesterdaysValue = buyingYesterdaysValue.split('€')[0];
                }
                var diff = (realtimeDailyDiff).toFixed(0);
                if (diff < 0) {
                    obfuscatedValueBuyingDailyRealtimeElem.style.color = 'red';
                }
                else {
                    obfuscatedValueBuyingDailyRealtimeElem.style.color = 'green';
                }

                if (diff === "NaN") {
                    obfuscatedValueBuyingDailyRealtimeElem.innerHTML = 'TIMEOUT / Moesif CORS';
                    obfuscatedValueBuyingDailyRealtimeElem.style.color = 'red';
                }
                else{
                    obfuscatedValueBuyingDailyRealtimeElem.innerHTML = diff + '€';
                }
            }

            toggleDecryptOnlyOnce = true;
        }
    }
    else {
        Array.prototype.forEach.call(intervalValues, hideElement);
        Array.prototype.forEach.call(obfuscatedValues, hideElement);
    }
    toggleIsContentVisible = !toggleIsContentVisible;
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

function calculateRealtimeDailyDiff(ele) {
    var siblingElem = ele.nextElementSibling;
    siblingElem = siblingElem.nextElementSibling;
    var difference = siblingElem.innerHTML.split('€')[0];
    difference = difference.replace(' ', '');
    siblingElem = siblingElem.nextElementSibling;
    siblingElem = siblingElem.nextElementSibling;
    var pieces = siblingElem.innerHTML.split('pc')[0];
    //var pieces = siblingElem.innerHTML.split(' ')[0];
    diffFloat = parseFloat(difference);
    realtimeDailyDiff = realtimeDailyDiff + (diffFloat * parseInt(pieces));
   // console.info('realtimeDailyDiff: '+ realtimeDailyDiff);
}

function hideElement(ele) {
    ele.style.display = 'none';
}

function hideSpinner() {
    spinnerElement = document.querySelectorAll('[id ^= \"spinner\"]');
    Array.prototype.forEach.call(spinnerElement, hideElement);
}

function onContentLoaded(symbol, notationId, asset_type) {
    // Show local link, if on PC
    if (location.href.startsWith('file')) {
        var linkPCValue = document.getElementById('linkPC' + symbol);
        revealElement(linkPCValue);
    }

    console.info('fetch '+ symbol + ' ...');

    var part_url = 'aktien';
    if (['INDEX'].indexOf(asset_type) >= 0) {
//        if (['IWLE', 'IS4S', 'XXXX'].indexOf(symbol) >= 0) {
            // if(symbol === "IWLE") {
        part_url = 'etfs';
    }
    var url = 'https://www.comdirect.de/inf/' + part_url + '/detail/uebersicht.html?ID_NOTATION=' + notationId;
    //var url = 'https://www.comdirect.de/inf/aktien/detail/uebersicht.html?ID_NOTATION=' + notationId;
    var xhr = new XMLHttpRequest();
    xhr.open("GET", url, true);
    //console.log(url); // url

    xhr.timeout = 3000; // time in milliseconds
    xhr.ontimeout = (e) => {
        console.error('TIMEOUT!!'+ symbol);
    };
   // xhr.setRequestHeader("Origin", null);

    //xhr.setRequestHeader("Origin", "https://www.comdirect.de");
    //xhr.setRequestHeader('Content-Type', 'application/json');
    xhr.onreadystatechange = function () {
        const DONE = 4; // readyState 4 means the request is done.
        const OK = 200; // status 200 is a successful return.
        if (xhr.readyState === DONE) {
            if (xhr.status === OK) {
                //console.log(xhr.responseText); // 'This is the output.'
                console.info('... ' + symbol +' done.'); 

                // Quote
                //searchstring = notationId + '\', key: \'prices.[type=LAST].price.value';
                let positionQuote1 = xhr.responseText.indexOf(notationId + '\', key: \'prices.[type=LAST].price.value');
                //let positionQuote1 = xhr.responseText.indexOf(', key: \'prices.[type=LAST].price.value');
                //let positionQuote1 = xhr.responseText.indexOf(notationId +', key: \'prices.[type=LAST].price.value');
                //let positionQuote1 = xhr.responseText.indexOf('prices.[type=LAST].price.value');
                
                //</td>let positionQuote1 = xhr.responseText.indexOf('layer__close-icon layer-tooltip__close-icon layer__close-icon--ring\"><svg class=\"icon__svg\" focusable=\"false\"><use xlink:href=\"/ccf2/lsg/assets/svg/svg-symbol.svg#cd_circle-40\"></use></svg></span><span class=\"icon icon--cd_close-16 icon--size-16 layer__close-icon layer-tooltip__close-icon\"><svg class=\"icon__svg\" focusable=\"false\"><use xlink:href=\"/ccf2/lsg/assets/svg/svg-symbol.svg#cd_close-16\"></use></svg></span></label><div class=\"layer__content layer-tooltip__content\" data-role=\"layer__content\"><header class=\"layer__header  \" data-role=\"layer__header\"></header><div class=\"layer__content-scroll-container grid-container layer-tooltip__content-scroll-container\" data-role=\"layer__inner-content\"></div></div></div></div></div></div></span><span class=\"realtime-indicator--value \">');
                //let positionQuote1 = xhr.responseText.indexOf('<td class=\"simple-table__cell\"><div class=\"realtime-indicator\"');
                //let positionQuote2 = xhr.responseText.indexOf('com-push-text>');
                //let positionQuote2 = xhr.responseText.indexOf('&nbsp;EUR</span></div></td>');
                
                var realTimeQuoteGrob = xhr.responseText.slice(positionQuote1 + 65, positionQuote1 + 74);
               // var realTimeQuoteGrob = xhr.responseText.slice(positionQuote1 + 48, positionQuote2);
//                var realTimeQuoteGrob = xhr.responseText.slice(positionQuote1 + 780, positionQuote2);
                //var realTimeQuoteGrob = xhr.responseText.slice(positionQuote1 + 1990, positionQuote2);
                let feinPos = realTimeQuoteGrob.indexOf('\n') + 0;
                //let feinPos = realTimeQuoteGrob.indexOf('>') + 1;
                var realTimeQuote = realTimeQuoteGrob.slice(0, feinPos);
                //var realTimeQuote = realTimeQuoteGrob.slice(feinPos);
                var elementRealTimeQuoteSymbol = document.getElementById('intervalSectionRealTimeQuote' + symbol);
                // var realTimeQuoteSymbol = realTimeQuote.replace('.', '');
                // if (parseFloat(realTimeQuoteSymbol) < 1000) {
                //     realTimeQuoteSymbol = parseFloat(realTimeQuoteSymbol.replace(',', '.')).toFixed(2);
                // }
                // else {
                //     realTimeQuoteSymbol = parseFloat(realTimeQuoteSymbol).toFixed(0);
                // }
                // elementRealTimeQuoteSymbol.innerHTML = realTimeQuoteSymbol + '€';
                elementRealTimeQuoteSymbol.innerHTML = realTimeQuote + '€';
               // console.info('elementRealTimeQuoteSymbol.innerHTML: '+ elementRealTimeQuoteSymbol.innerHTML);
        
                // Percent
                //let positionProz1 = xhr.responseText.indexOf('com-push-text dynamic-color show-positive-sign format=\"ticker\" suffix=\"%\"');
                //let positionProz1 = xhr.responseText.indexOf('&#160;%');
                //let positionProz1 = xhr.responseText.indexOf('com-push-text dynamic-color show-positive-sign format=\"ticker\" suffix=\"%\"');
                //let positionProz1 = xhr.responseText.indexOf('prices.[type=LAST].profitLossAbs.value');
                let positionProz1 = xhr.responseText.indexOf(notationId + '\', key: \'prices.[type=LAST].profitLossRel');
                
                //var realTimeProzSymbol = xhr.responseText.slice(positionProz1 + 206, positionProz1 + 211);
                var realTimeProzSymbol = xhr.responseText.slice(positionProz1 + 67, positionProz1 + 73);
                //var realTimeProzSymbol = xhr.responseText.slice(positionProz1 + 56, positionProz1 + 61);
                //var realTimeProzSymbol = xhr.responseText.slice(positionProz1 - 4, positionProz1);
                //var realTimeProzSymbol = xhr.responseText.slice(positionProz1 - 6, positionProz1);
                realTimeProzSymbol = realTimeProzSymbol.replace(' ', '');
                realTimeProzSymbol = realTimeProzSymbol.replace(',', '.');
                var elementPercentageSymbol = document.getElementById('intervalSectionPercentage' + symbol);
                elementPercentageSymbol.innerHTML = realTimeProzSymbol.slice(0, -1) + '%';
                //console.info('elementPercentageSymbol.innerHTML: '+ elementPercentageSymbol.innerHTML);
        
                //elementPercentageSymbol.innerHTML = realTimeProzSymbol + '%';
                if (parseFloat(realTimeProzSymbol) < 0) {
                    elementPercentageSymbol.style.color = 'red';
                }
                else {
                    elementPercentageSymbol.style.color = 'green';
                }
        
                // Gain
                let positionGain1 = xhr.responseText.indexOf(notationId + '\', key: \'prices.[type=LAST].profitLossAbs.value');
                //let positionGain1 = xhr.responseText.indexOf('prices.[type=LAST].profitLossAbs.value');
                //let positionGain1 = xhr.responseText.indexOf('com-push-text dynamic-color show-positive-sign format=\"ticker\" suffix=\"%\"');
                
                //let positionGain1 = xhr.responseText.indexOf('&#160;%');
                //let positionGain2 = xhr.responseText.indexOf('com-push-text>');
                //var realTimeGainSymbol = xhr.responseText.slice(positionGain1 + 200, positionGain2 );
                var realTimeGainSymbol = xhr.responseText.slice(positionGain1 + 73, positionGain1 + 78);
                //var realTimeGainSymbol = xhr.responseText.slice(positionGain1 + 56, positionGain1 + 61);
               // var realTimeGainSymbol = xhr.responseText.slice(positionGain1 + 206, positionGain1 + 211);
//                var realTimeGainSymbol = xhr.responseText.slice(positionGain1, positionGain1 + 200);
                
//realTimeGainSymbol = realTimeGainSymbol.split('         '); // \n
  //              realTimeGainSymbol = realTimeGainSymbol[4]; // \n
    //            realTimeGainSymbol = realTimeGainSymbol.trim();
                realTimeGainSymbol = realTimeGainSymbol.replace(' ', '');
                realTimeGainSymbol = realTimeGainSymbol.replace(',', '.');
                var elementGainSymbol = document.getElementById('intervalSectionGain' + symbol);
                elementGainSymbol.innerHTML = realTimeGainSymbol + '€';
                //console.info('elementGainSymbol.innerHTML: '+ elementGainSymbol.innerHTML);
        
                if (parseFloat(realTimeGainSymbol) < 0) {
                    elementGainSymbol.style.color = 'red';
                }
                else {
                    elementGainSymbol.style.color = 'green';
                }
        
                // Extract Time
                let positionTime1 = xhr.responseText.indexOf(' -  ');
                var timeSymbol = xhr.responseText.slice(positionTime1 + 4, positionTime1 + 12);
                var hoursSymbol = timeSymbol.slice(0, 2);
                var minutesSymbol = timeSymbol.slice(3, 5);
                var secondsSymbol = timeSymbol.slice(6, 8);
                var dateSymbol = xhr.responseText.slice(positionTime1 - 9, positionTime1 - 1);
                var daysSymbol = dateSymbol.slice(0, 2);
                var monthSymbol = dateSymbol.slice(3, 5) - 1;
                var yearSymbol = '20' + dateSymbol.slice(6, 8);
                const dateEclpsedSymbol = new Date(yearSymbol, monthSymbol, daysSymbol);
                dateEclpsedSymbol.setHours(hoursSymbol);
                dateEclpsedSymbol.setMinutes(minutesSymbol);
                dateEclpsedSymbol.setSeconds(secondsSymbol);
                var deltaMinutesSymbol = ((new Date().getTime() - dateEclpsedSymbol.getTime()) / 1000) / 60;
                var elementRegularMarketTimeOffsetSymbol = document.getElementById('intervalSectionRegularMarketTimeOffset' + symbol);
                elementRegularMarketTimeOffsetSymbol.innerHTML = deltaMinutesSymbol.toFixed(0) + 'min';
                //console.info('elementRegularMarketTimeOffsetSymbol.innerHTML: '+ elementRegularMarketTimeOffsetSymbol.innerHTML);
        
                var elementPortfolioValuesSymbol = document.getElementById('intervalSectionPortfolioValues' + symbol);
                var obfuscatedValuePcEuroSymbol = document.getElementById('obfuscatedValuePcEuro' + symbol);
                decryptElement(obfuscatedValuePcEuroSymbol);
                // 940pc 51362€
                var piecesSymbol = obfuscatedValuePcEuroSymbol.innerHTML.split('pc')[0];
                var buyingValueSymbol = obfuscatedValuePcEuroSymbol.innerHTML.split('/')[0];
                buyingValueSymbol = buyingValueSymbol.split(' ')[1];
               // var portfolioValueSymbol = piecesSymbol * realTimeQuoteSymbol;
                var portfolioValueSymbol = piecesSymbol * realTimeQuote;
        
                // Sum up all current symbols
                realtimeOverallValue = parseInt(realtimeOverallValue) + parseInt(portfolioValueSymbol);
                var obfuscatedValueBuyingOverallRealtimeElem = document.getElementById('obfuscatedValueBuyingOverallRealtime');
                if (obfuscatedValueBuyingOverallRealtimeElem) {
                    obfuscatedValueBuyingOverallRealtimeElem.innerHTML = revers(realtimeOverallValue);
                }
                //console.info('obfuscatedValueBuyingOverallRealtimeElem.innerHTML: '+ obfuscatedValueBuyingOverallRealtimeElem.innerHTML);
        
                var stocksPerformanceSymbol = ((portfolioValueSymbol / buyingValueSymbol) - 1) * 100;
                elementPortfolioValuesSymbol.innerHTML = piecesSymbol + 'pc ' + portfolioValueSymbol.toFixed(0) + '€ ';
               //console.info('elementPortfolioValuesSymbol.innerHTML: '+ elementPortfolioValuesSymbol.innerHTML);
        
                var elementPortfolioGainSymbol = document.getElementById('intervalSectionPortfolioGain' + symbol);
                //elementPortfolioGainSymbol.innerHTML = stocksPerformanceSymbol.toFixed(1) + '% ' + (portfolioValueSymbol - buyingValueSymbol).toFixed(0) + '€';
                elementPortfolioGainSymbol.innerHTML = (portfolioValueSymbol - buyingValueSymbol).toFixed(0) + '€ ' + stocksPerformanceSymbol.toFixed(1) + '%';
                //console.info('elementPortfolioGainSymbol.innerHTML: '+ elementPortfolioGainSymbol.innerHTML);
        
                // Sorting, if 0,00% then add '+' -> +0,00%
                if (realTimeProzSymbol[0] === ' ') {
                    realTimeProzSymbol = '+' + realTimeProzSymbol.substring(1);
                }
        
                // Example ID: id='symbolLineIdEUZ_-115_+111_9999'
                var numericRealTimeProzSymbol = realTimeProzSymbol.replace('.', '');
                var symbolLineId = 'symbolLineId' + symbol;
                var symbolLineIdElements = document.querySelectorAll('[id ^="' + symbolLineId + '"]');
                var numericOverallProzSymbol;
                if (stocksPerformanceSymbol >= 0) {
                    numericOverallProzSymbol = '+' + stocksPerformanceSymbol.toFixed(2);
                }
                else {
                    numericOverallProzSymbol = stocksPerformanceSymbol.toFixed(2);
                }
                numericOverallProzSymbol = numericOverallProzSymbol.replace('.', '');
        
                symbolLineIdElements[0].id = 'symbolLineId' + symbol + '_' + numericRealTimeProzSymbol + '_' + numericOverallProzSymbol + '_' + portfolioValueSymbol.toFixed(0);
        
                if (stocksPerformanceSymbol < 0) {
                    elementPortfolioGainSymbol.style.color = 'red';
                }
                else {
                    elementPortfolioGainSymbol.style.color = 'green';
                }
        
                counterFetchLoaded++; // For Spinner
        
            } else {
                console.error('Network response error:' + symbol);
                counterFetchLoaded++; // For Spinner
                throw new Error('Network response error!');
            }
        }
        else {
            counterFetchLoaded++; // For Spinner
        }
    }
    xhr.send();
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