var express = require('express');
var app = express();
var inspect = require('eyes').inspector({styles: {all: 'blue'}, hideFunctions: true});
console.log(__dirname);

var methodOverride = require('method-override')

// override with different headers; last one takes precedence
app.use(methodOverride('X-HTTP-Method'))          // Microsoft
app.use(methodOverride('X-HTTP-Method-Override')) // Google/GData
app.use(methodOverride('X-Method-Override'))      // IBM

app.get('/swf.swf', function(req, res) {
    console.log('SWF Requested');
    res.sendFile('TestMain.swf', {root: __dirname + '/../build'});
});

app.get('/crossdomain.xml', function(req, res) {
    console.log('Cross Domain XML Requested: ' + req.hostname);
    res.set('Content-Type', 'application/xml');
    res.end('<?xml version="1.0"?>' +
        '<!DOCTYPE cross-domain-policy SYSTEM "http://www.adobe.com/xml/dtds/cross-domain-policy.dtd">' +
        '<cross-domain-policy>' +
            '<site-control permitted-cross-domain-policies="all"/>' +
            '<allow-access-from domain="*" to-ports="*" secure="false"/>' +
            '<allow-http-request-headers-from domain="*" headers="*" secure="false"/>' +
        '</cross-domain-policy>');
});

app.get('/hello_world', function (req, res) {
    console.log(req.headers.accept)
    res.format({
        text: function () {
            res.end('Hello World');
        },
        json: function () {
            res.end(JSON.stringify({ title: "Hello World" }));
        },
        html: function () {
            res.end('<html>Hello World</html>')
        }
    });
});

app.post('/hello_world', function (req, res) {
    res.send('Hello World');
});

app.delete('/delete_me', function (req, res) {
    res.send('deleted');
});

app.put('/put_here', function (req, res) {
    res.send('placed');
});

console.log('Server Started');
app.listen(3000);
