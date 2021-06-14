// A basic node server

const http = require('http'); // node package, a web server that listens to requests

const server = http.createServer(function(req, res){ // req object: when someone makes a request from the website, res object: send back to the browser
    res.setHeader('content-type', 'application/json'); // setting the content type as json
    res.setHeader('Access-Control-Allow-Origin', '*'); // request can come from any domain, any browser
    res.writeHead(200); // only called once at the end: the status code (HTTP 200 ok)

    let dataObj = {"id":123, "name":"Bob", "email":"bob@work.org"};
    let data = JSON.stringify(dataObj);
    res.end(data) // everything is done, everything is packed so sending data to the browser *data has to be in STRING
});

server.listen(1234, function(){
    console.log('Listening on port number 1234');
}) // choose which port number the server would be listening on