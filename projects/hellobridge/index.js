var http = require('http')
var port = process.env.HTTP_PORT || 3001;
var stub_host = process.env.STUB_HOST || 'localhost';
var stub_port = process.env.STUB_PORT || 3000;

var remoteAddress = 'http://' + stub_host + ':' + stub_port;

http.createServer(function (req, res) {
  //console.log('received request... trying to contact stub at ' + remoteAddress);
  http.get({
    host: stub_host,
    path: '/',
    port: stub_port
  }, function(response){
    var str = ''
    response.on('data', function (chunk) {
      //console.log('received data:"' + chunk+ '"');
      str += chunk;
    });
    response.on('end', function () {
      //console.log('receive ended:"' + str+ '"');
      res.end('received reply from ' + remoteAddress + ': [' + str + ']\n');
    });
    response.on('error', function (e) {
      res.end('ERROR received: "' + e.message + '"');
    });
  });
}).listen(port);
console.log('Hello bridge up and running on port ' + port);
