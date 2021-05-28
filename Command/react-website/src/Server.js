// TCP server communicates with the ESP32    
var net = require('net');
var tcpserver = net.createServer();
var client = "undefined";
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

const express = require('express'); // express js
const bodyParser = require('body-parser');
const fs = require('fs').promises; // contains readFile() function to load a HTML file
const app = express();
/*
let indexFile;
fs.readFile(__dirname + "/index.html")
    .then(contents => {
        indexFile = contents;
    })
    .catch(err => {
        console.error(`Could not read index.html file: ${err}`);
        process.exit(1);
    });
*/

app.listen(8000, () => {
    console.log("Application started and listening on port 8000");
});

app.use(bodyParser.urlencoded({ extended: true}));


app.post("/commands", (req,res) => { // post from /commands page
    switch(req.body.button) {
        case "1":
            if(client !== "undefined") {
                client.write("1");
                console.log("sent 1 to client");
            } else {
                console.log("client undefined");
            }
            console.log('button 1 pressed');
            break
        case "2":
            console.log('button 2 pressed');
            break
        case "3":
            console.log('button 3 pressed');
            break
        default:
            console.log('error');
    };
    //res.redirect("/");
});
/*
// serve css as static
app.use(express.static(__dirname));
// use body parser to get http request value
app.use(bodyParser.urlencoded({ extended: true}));

app.get("/", (req, res) => {
    res.sendFile(__dirname + "/index.html");
    //res.send(indexFile);
});

app.post("/", (req, res) => {
    if(typeof req.body.command !== "undefined") {
        client.write("Command: " + req.body.command);
        res.sendFile(__dirname + "/index.html");
    }
    else if(typeof req.body.button !== "undefined") {
        client.write("Button: " + req.body.button);
        if(req.body.button === "1") {
            res.sendFile(__dirname + "/another.html");
        }
    }
    else {
        client.write("Error");
    }
});
*/