var express = require('express');
var app = express();
var inspect = require('eyes').inspector({styles: {all: 'blue'}, hideFunctions: true});

app.get('/hello_world', function (req, res) {
    //inspect(req, "GET /hello_world");
    if (req.get('Content-Type') === 'application/json') {
        console.log('is json');
        res.setHeader('Content-Type', 'application/json');
        res.end(JSON.stringify({ title: "Hello World" }));
    } else {
        res.send('Hello World');
    }
});

app.post('/hello_world', function (req, res) {
    //inspect(req, "POST /hello_world");
    res.send('Hello World');
});

console.log('Server Started');
app.listen(3000);
