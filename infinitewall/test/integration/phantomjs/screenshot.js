var page = require('webpage').create()
page.viewportSize = { width:1024, height:980 }
page.onError = function(msg, trace) {
    var msgStack = ['ERROR: ' + msg];
    if (trace) {
        msgStack.push('TRACE:');
        trace.forEach(function(t) {
            msgStack.push(' -> ' + t.file + ': ' + t.line + (t.function ? ' (in function "' + t.function + '")' : ''));
        });
    }
    console.error(msgStack.join('\n'));
};

page.onNavigationRequested = function(url, type, willNavigate, main) {
    console.log('Trying to navigate to: ' + url + 'caused by: ' + type);
}

page.onClosing = function(closingPage) {
    console.log('The page is closing! URL: ' + closingPage.url);
};

page.onUrlChanged = function(targetUrl) {
    console.log('URL Changed to: ' + targetUrl);
};

page.onLoadStarted = function() {
    var currentUrl = page.evaluate(function() {
        return window.location.href;
    });
    console.log('Loading started. Current page ' + currentUrl +' will be gone...');
};

page.onLoadFinished = function(status) {
    console.log('Loaded. (' + status + '). Saving screenshot');
    // Do other things here...
    page.render('index2.png')
};

page.open('http://localhost:9000/', function () {
    page.evaluate(function() {
        $(function()  {
            $('input[name="email"]').val('wall@wall.com')
            $('input[name="password"]').val('wallwall')
            $('button[type="submit"]').click()
        })
    })
})


setTimeout(function () { phantom.exit() }, 5000)

//var page = require('webpage').create();
//page.open('http://www.sample.com', function() {
//    page.includeJs("http://ajax.googleapis.com/ajax/libs/jquery/1.6.1/jquery.min.js", function() {
//        page.evaluate(function() {
//            $("button").click();
//        });
//        phantom.exit()
//    });
//});