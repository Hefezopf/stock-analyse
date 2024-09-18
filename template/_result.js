// 
// _result.js
// 

// Spinner Counters
var counterFetchLoaded = 0;
var counterOwnStocks = 0;

// Realtime Overall Value
var realtimeOverallValue = 0;

// Realtime Daily Value
var realtimeDailyDiff = 0;

// Sound
var sound = new Audio('data:audio/wav;base64,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qJrx4KOQjahZxWbcZgztj2c49nKmkId44S71j0c8eV9yDK6uPRzx5X18eDvjvQ6yKo9ZSS6l//8elePK/Lf//IInrOF/FvDoADYAGBMGb7FtErm5MXMlmPAJQVgWta7Zx2go+8xJ0UiCb8LHHdftWyLJE0QIAIsI+UbXu67dZMjmgDGCGl1H+vpF4NSDckSIkk7Vd+sxEhBQMRU8j/12UIRhzSaUdQ+rQU5kGeFxm+hb1oh6pWWmv3uvmReDl0UnvtapVaIzo1jZbf/pD6ElLqSX+rUmOQNpJFa/r+sa4e/pBlAABoAAAAA3CUgShLdGIxsY7AUABPRrgCABdDuQ5GC7DqPQCgbbJUAoRSUj+NIEig0YfyWUho1VBBBA//uQZB4ABZx5zfMakeAAAAmwAAAAF5F3P0w9GtAAACfAAAAAwLhMDmAYWMgVEG1U0FIGCBgXBXAtfMH10000EEEEEECUBYln03TTTdNBDZopopYvrTTdNa325mImNg3TTPV9q3pmY0xoO6bv3r00y+IDGid/9aaaZTGMuj9mpu9Mpio1dXrr5HERTZSmqU36A3CumzN/9Robv/Xx4v9ijkSRSNLQhAWumap82WRSBUqXStV/YcS+XVLnSS+WLDroqArFkMEsAS+eWmrUzrO0oEmE40RlMZ5+ODIkAyKAGUwZ3mVKmcamcJnMW26MRPgUw6j+LkhyHGVGYjSUUKNpuJUQoOIAyDvEyG8S5yfK6dhZc0Tx1KI/gviKL6qvvFs1+bWtaz58uUNnryq6kt5RzOCkPWlVqVX2a/EEBUdU1KrXLf40GoiiFXK///qpoiDXrOgqDR38JB0bw7SoL+ZB9o1RCkQjQ2CBYZKd/+VJxZRRZlqSkKiws0WFxUyCwsKiMy7hUVFhIaCrNQsKkTIsLivwKKigsj8XYlwt/WKi2N4d//uQRCSAAjURNIHpMZBGYiaQPSYyAAABLAAAAAAAACWAAAAApUF/Mg+0aohSIRobBAsMlO//Kk4soosy1JSFRYWaLC4qZBYWFRGZdwqKiwkNBVmoWFSJkWFxX4FFRQWR+LsS4W/rFRb/////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////VEFHAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAU291bmRib3kuZGUAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAMjAwNGh0dHA6Ly93d3cuc291bmRib3kuZGUAAAAAAAAAACU=');

// Refresh the page after a delay of 5 Min
// If changed, change here as well: analyse.sh: <progress value=0 max=300 id=intervalSectionHeadlineDailyProgressBar
const initRefreshSeconds = 300;
if (location.href.startsWith('file') && location.href.endsWith('_result.html')) {
    setTimeout(function() {
        location.reload();
    // 300 * 1000 milliseconds = 300 seconds = 5 Min
    }, initRefreshSeconds * 1000);
}

// 300 seconds total
var timeleftToRefresh = initRefreshSeconds;
var progressBarTimer = setInterval(function() {
  if(timeleftToRefresh <= 0) {
    clearInterval(progressBarTimer);
  }
  var intervalSectionHeadlineDailyProgressBar = document.getElementById("intervalSectionHeadlineDailyProgressBar");
  if(intervalSectionHeadlineDailyProgressBar) {
    intervalSectionHeadlineDailyProgressBar.value = initRefreshSeconds - timeleftToRefresh;
  }
  timeleftToRefresh -= 1;
  // Visualize in 1 second steps
}, 1000);

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
            // end delay, timeout, Warten
            }, 1000);
        }   
        else {
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
    // 60*1000 = 1 Minute
    }, intervalValue * 60 * 1000);
    var elementIntervalText = document.getElementById('intervalText' + symbol);
    elementIntervalText.innerHTML = ' ...' + intervalValue;
    elementIntervalText.style.color = 'green';
}

// Chart Store
var chartTimeSpanStore = new Map();
var chartImageStore = new Map();
var chartNotationIdStore = new Map();
function updateImage(symbol, notationId, timespan) {
    var width = window.innerWidth || document.documentElement.clientWidth || document.body.clientWidth;
    var newWidth = '68%';

    if (width <= 4000) {
        newWidth = '40%';
    }
    if (width <= 2000) {
        newWidth = '50%';
    }    
    // Mobil IPhone = 1153xp
    if (width <= 1200) {
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
        var elemIntervalSectionImage = document.getElementById('intervalSectionImage' + symbol);
        if(elemIntervalSectionImage) {
            elemIntervalSectionImage.src = urlWithTimeSpan;
            elemIntervalSectionImage.style.width = newWidth;
        }
        var imageSymbol = new Image();
        imageSymbol.src = urlWithTimeSpan;
        chartImageStore.set(symbol, imageSymbol);
    }
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
            // Example ID: id='symbolLineIdEUZ_-1150_+111_9999'
            if (sortPart.length > 1) {
                if (sortPart[1][0] === '-') {
                    sortNegativDailyValues.push([-1 * sortPart[1], elements[i]]);
                }
                // if (sortPart[1][0] === '+') {
                else { 
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

// Sort Button Status
var sortToggleSortDaily = false;
var sortToggleSortValue = false;
var sortToggleOverall = false;
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
    var intervalSectionHeadlineDailyProgressBarSpan = document.getElementById('intervalSectionHeadlineDailyProgressBarSpan');

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
        container.appendChild(intervalSectionHeadlineDailyProgressBarSpan);
        intervalSectionHeadlineDailyProgressBarSpan.style.display = "inline-block";
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
    const intervalSectionRealTimeQuotes = document.querySelectorAll('[id ^= \"intervalSectionRealTimeQuote\"]');
    for (var i = 0; i < intervalSectionRealTimeQuotes.length; i++) {
        intervalSectionRealTimeQuotes[i].style.fontSize = fontSizeRealTimeQuotesPercentagesGain;
    }
    const intervalSectionPercentages = document.querySelectorAll('[id ^= \"intervalSectionPercentage\"]');
    for (var i = 0; i < intervalSectionPercentages.length; i++) {
        intervalSectionPercentages[i].style.fontSize = fontSizeRealTimeQuotesPercentagesGain;
    }
    const intervalSectionGain = document.querySelectorAll('[id ^= \"intervalSectionGain\"]');
    for (var i = 0; i < intervalSectionGain.length; i++) {
        intervalSectionGain[i].style.fontSize = fontSizeRealTimeQuotesPercentagesGain;
    }
    const intervalSectionPortfolioValues = document.querySelectorAll('[id ^= \"intervalSectionPortfolioValues\"]');
    for (var i = 0; i < intervalSectionPortfolioValues.length; i++) {
        intervalSectionPortfolioValues[i].style.fontSize = fontSizePortfolioValues;
    }
    const intervalSectionPortfolioGains = document.querySelectorAll('[id ^= \"intervalSectionPortfolioGain\"]');
    for (var i = 0; i < intervalSectionPortfolioGains.length; i++) {
        intervalSectionPortfolioGains[i].style.fontSize = fontSizePortfolioGains;
    }
}

function doGoToEnd() {
    var scrollingElement = (document.scrollingElement || document.body);
    scrollingElement.scrollTop = scrollingElement.scrollHeight;
}

// Open all in Tabs
var linkMap = new Map();
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
        Array.prototype.forEach.call(symbolLineIdValues, function(ele) {
            ele.style.marginBottom = '-22px';
        });
    }
    else {
        Array.prototype.forEach.call(detailsIdValues, revealElement);
        Array.prototype.forEach.call(intervalSectionBeepValues, revealElement);
        Array.prototype.forEach.call(intervalSectionButtonValues, revealElement);
        Array.prototype.forEach.call(intervalSectionRealTimeQuoteValues, revealElement);
        Array.prototype.forEach.call(intervalSectionGainValues, revealElement);
        Array.prototype.forEach.call(intervalSectionPortfolioValues, revealElement);
        intervalSectionButtonHideDetailsButton.innerHTML = '+ Details';
        Array.prototype.forEach.call(symbolLineIdValues, function(ele) {
            ele.style.display = '';
        });
    }
    toggleIsDetailsVisible = !toggleIsDetailsVisible;
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
                else {
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

    var intervalSectionHeadlineDailyProgressBarSpan = document.getElementById('intervalSectionHeadlineDailyProgressBarSpan');
    // Hide Refresh ProgressBar in Mobil Version, because CORS is not working there!
    if( /Android|webOS|iPhone|iPad|iPod|BlackBerry|IEMobile|Opera Mini/i.test(navigator.userAgent) ) {
        Array.prototype.forEach.call(intervalSectionHeadlineDailyProgressBarSpan, hideElement);
        intervalSectionHeadlineDailyProgressBarSpan.style.display = "none";
    }
     
    toggleIsContentVisible = !toggleIsContentVisible;
}

function calculateRealtimeDailyDiff(ele) {
    var siblingElem = ele.nextElementSibling;
    siblingElem = siblingElem.nextElementSibling;
    var difference = siblingElem.innerHTML.split('€')[0];
    difference = difference.replace(' ', '');
    siblingElem = siblingElem.nextElementSibling;
    siblingElem = siblingElem.nextElementSibling;
    var pieces = siblingElem.innerHTML.split('pc')[0];
    diffFloat = parseFloat(difference);
    realtimeDailyDiff = realtimeDailyDiff + (diffFloat * parseInt(pieces));
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
    var xhr = new XMLHttpRequest();
    xhr.open("GET", url, true);
    // console.log(url);// url

    // time in milliseconds
    xhr.timeout = 3000;
    xhr.ontimeout = (e) => {
        console.error('TIMEOUT!!'+ symbol);
    };
    xhr.onreadystatechange = function () {
        // readyState 4 means the request is done.
        const DONE = 4;
        // status 200 is a successful return.
        const OK = 200;
        if (xhr.readyState === DONE) {
            if (xhr.status === OK) {
                // console.log(xhr.responseText); // 'This is the output.'
                console.info('... ' + symbol +' done.');

                // Realtime Quote
                let positionQuote1 = xhr.responseText.indexOf(notationId + '\', key: \'prices.[type=LAST].price.value');
                var realTimeQuoteGrob = xhr.responseText.slice(positionQuote1 + 64, positionQuote1 + 74);
                let feinPos = realTimeQuoteGrob.indexOf('\n') + 0;
                var realTimeQuote = realTimeQuoteGrob.slice(0, feinPos);
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
        
                // Realtime Percent
                let positionProz1 = xhr.responseText.indexOf(notationId + '\', key: \'prices.[type=LAST].profitLossRel');
                var realTimeProzSymbol = xhr.responseText.slice(positionProz1 + 66, positionProz1 + 73);
                realTimeProzSymbol = realTimeProzSymbol.replace(' ', '');
                realTimeProzSymbol = realTimeProzSymbol.replace(',', '.');
                var elementPercentageSymbol = document.getElementById('intervalSectionPercentage' + symbol);
                elementPercentageSymbol.innerHTML = realTimeProzSymbol.slice(0, -1) + '%';

                if (parseFloat(realTimeProzSymbol) < 0) {
                    elementPercentageSymbol.style.color = 'red';
                }
                else {
                    elementPercentageSymbol.style.color = 'green';
                }
        
                // Realtime Gain
                let positionGain1 = xhr.responseText.indexOf(notationId + '\', key: \'prices.[type=LAST].profitLossAbs.value');
                var realTimeGainSymbol = xhr.responseText.slice(positionGain1 + 73, positionGain1 + 79);
                realTimeGainSymbol = realTimeGainSymbol.replace(' ', '');
                realTimeGainSymbol = realTimeGainSymbol.replace(',', '.');
                var elementGainSymbol = document.getElementById('intervalSectionGain' + symbol);
                elementGainSymbol.innerHTML = realTimeGainSymbol + '€';
        
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
        
                var elementPortfolioValuesSymbol = document.getElementById('intervalSectionPortfolioValues' + symbol);
                var obfuscatedValuePcEuroSymbol = document.getElementById('obfuscatedValuePcEuro' + symbol);
                decryptElement(obfuscatedValuePcEuroSymbol);
                // 940pc 51362€
                var piecesSymbol = obfuscatedValuePcEuroSymbol.innerHTML.split('pc')[0];
                var buyingValueSymbol = obfuscatedValuePcEuroSymbol.innerHTML.split('/')[0];
                buyingValueSymbol = buyingValueSymbol.split(' ')[1];
                var portfolioValueSymbol = piecesSymbol * realTimeQuote;
        
                // Sum up all current symbols
                realtimeOverallValue = parseInt(realtimeOverallValue) + parseInt(portfolioValueSymbol);
                var obfuscatedValueBuyingOverallRealtimeElem = document.getElementById('obfuscatedValueBuyingOverallRealtime');
                if (obfuscatedValueBuyingOverallRealtimeElem) {
                    obfuscatedValueBuyingOverallRealtimeElem.innerHTML = revers(realtimeOverallValue);
                }
        
                var stocksPerformanceSymbol = ((portfolioValueSymbol / buyingValueSymbol) - 1) * 100;
                elementPortfolioValuesSymbol.innerHTML = piecesSymbol + 'pc ' + portfolioValueSymbol.toFixed(0) + '€ ';
        
                var elementPortfolioGainSymbol = document.getElementById('intervalSectionPortfolioGain' + symbol);
                elementPortfolioGainSymbol.innerHTML = (portfolioValueSymbol - buyingValueSymbol).toFixed(0) + '€ ' + stocksPerformanceSymbol.toFixed(1) + '%';
        
                // Sorting, if 0,00% then add '+' -> +0,00%
                if (realTimeProzSymbol[0] === ' ') {
                    realTimeProzSymbol = realTimeProzSymbol.substring(1).trim();
               } 
               if ((realTimeProzSymbol.charAt(0) === '-') || (realTimeProzSymbol.charAt(0) === '+')) {
                   ;
               }   
               else {
                   realTimeProzSymbol = '+' + realTimeProzSymbol;
               }  
        
                // Example ID: id='symbolLineIdEUZ_-115_+111_9999'
                var numericRealTimeProzSymbol = realTimeProzSymbol.trim().replace('.', ''); 
                // Mit Nullen hinten auffüllen
                if (!numericRealTimeProzSymbol.charAt(4)) {
                    // 3 -> 4 stellig
                    numericRealTimeProzSymbol = numericRealTimeProzSymbol + 0;
                }

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
        
                // For Spinner
                counterFetchLoaded++;
        
            } else {
                console.error('Network response error:' + symbol);
                // For Spinner
                counterFetchLoaded++;
                throw new Error('Network response error!');
            }
        }
        else {
            // For Spinner
            counterFetchLoaded++;
        }
    }
    xhr.send();
}

function revealElement(ele) {
    ele.style.display = '';
}

function showChart(timeSpan, symbol) {
    var elementSpanToReplace = document.getElementById('imgToReplace'+ symbol);
    elementSpanToReplace.style.display = 'block';
    elementSpanToReplace.style.top = '30%';
    elementSpanToReplace.style.left = '5%';
    elementSpanToReplace.style.transform = 'scale(1.05)';
    // Concat is not clean, but works!
    elementSpanToReplace.src = elementSpanToReplace.src + '&TIME_SPAN=' + timeSpan;
}

function hideChart(symbol) {
    var elementSpanToReplace = document.getElementById('imgToReplace'+ symbol);
    elementSpanToReplace.style.display = 'none';
}
