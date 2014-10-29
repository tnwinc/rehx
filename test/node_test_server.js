var express = require('express');
var app = express();
var inspect = require('eyes').inspector({styles: {all: 'blue'}, hideFunctions: true});
console.log(__dirname);
app.use(require('mimic')());

app.get('/swf', function(req, res) {
    console.log('SWF Requested');
    res.sendFile('TestMain.swf', {root: __dirname + '/../build'});
});

app.get('/crossdomain', function(req, res) {
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

console.log('Server Started');
app.listen(3000);
