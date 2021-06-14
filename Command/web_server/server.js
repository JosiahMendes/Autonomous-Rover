// TCP server communicates with the ESP32    
var net = require('net');
var tcpserver = net.createServer();
var client;
tcpserver.on('connection', handleConnection);
const tcphost = '0.0.0.0'; // localhost
const tcpport = 9000;
tcpserver.listen(tcpport, tcphost, function() {
    console.log('Server is listening to %j', tcpserver.address());
});
function handleConnection(socket) {
  client = socket; // storing client so it can be accessed by the web server
  console.log('client saved');
  var remoteAddress = socket.remoteAddress + ':' + socket.remotePort;  
  console.log('new client connection from %s', remoteAddress);
  socket.write("You are connected");
  socket.on('data', onDataReceived);  
  socket.once('close', onConnClose);  
  socket.on('error', onConnError);
  function onDataReceived(data) {  
    console.log('connection data from %s: %j', remoteAddress, data.toString());  
    //conn.write(d); send back to client  
  }
  function onConnClose() {  
    console.log('connection from %s closed', remoteAddress);  
  }
  function onConnError(err) {  
    console.log('Connection %s error: %s', remoteAddress, err.message);  
  }  
}

const http = require('http');
const fs = require('fs').promises; // this module contains a readFile() function: used to load HTML file
const qs = require('querystring'); // contains parse() function to convert post data to plain text

const httphost = 'localhost';
const httpport = 8000;

let indexFile;

const requestListener = function(req, res) {
	if(req.method == 'GET') {
		// just serve the file
	}
    else if(req.method == 'POST') { // data are in several packets and can arrive at different times
    	var body = ''; // this body variable will contain all the data arrived
        req.on('data', (data) => { // data coming in
        	body = body + data;
        });
        req.on('end', () => {
        	postData = qs.parse(body);
          console.log("Data received: %s", postData);
          if(typeof postData.Command !== "undefined") {
            client.write("Command: " + postData.Command);
          }
          else {
            switch(postData.button) {
              case "1":
                client.write("Button: 1");
                break
              case "2":
                client.write("Button: 2");
                break
              default:
                client.write("Error");
            };
          }
        });
    }
    res.setHeader("Content-Type", "text/html");
    res.writeHead(200);
    res.end(indexFile);
};

const httpserver = http.createServer(requestListener);

fs.readFile(__dirname + "/index.html")
    .then(contents => {
        indexFile = contents;
        httpserver.listen(httpport, httphost, () => {
            console.log(`Server is running on http://${httphost}:${httpport}`);
        });
    })
    .catch(err => {
        console.error(`Could not read index.html file: ${err}`);
        process.exit(1);
    });