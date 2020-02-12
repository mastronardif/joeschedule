var http = require('http');

var gPORT=3003

app.use(express.static(__dirname + '/public'));

http.createServer(function (req, res) {
    res.writeHead(200, {'Content-Type': 'text/html'});
    res.end('FxM application at index.js! [defaultdocument sample]');
}).listen(gPORT); 