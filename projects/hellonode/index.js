var os = require('os');
var ifaces = os.networkInterfaces();

Object.keys(ifaces).forEach(function (ifname) {
  var alias = 0
    ;

  ifaces[ifname].forEach(function (iface) {
    if ('IPv4' !== iface.family || iface.internal !== false) {
      // skip over internal (i.e. 127.0.0.1) and non-ipv4 addresses
      return;
    }

    if (alias >= 1) {
      // this single interface has multiple ipv4 addresses
      console.log(ifname + ':' + alias, iface.address);
    } else {
      // this interface has only one ipv4 adress
      console.log(ifname, iface.address);
    }
  });
});


var http = require('http')
var port = process.env.HTTP_PORT || 3000;
var name = process.env.INSTANCE_NAME;

var times = 0;

http.createServer(function (req, res) {
  times++;
  if (name) {
    res.end('Node says you hello from mesos! I has been called ' + times + ' times. My name is "' + name + '":D\n');
  } else {
    res.end('Node says you hello from mesos. I has been called ' + times + ' times. I have no name:(\n');
  }
}).listen(port);
console.log('Hello node up and running on port ' + port);
