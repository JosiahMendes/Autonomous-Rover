const express = require('express'); // express js
const bodyParser = require('body-parser');
const fs = require('fs').promises; // contains readFile() function to load a HTML file
const app = express();
const socketIO = require('socket.io');

var website;

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
    website.emit("BatteryLevel", [data.toString(),100,100,100]);
    //conn.write(d); send back to client  
  }
  function onConnClose() {  
    console.log('connection from %s closed', remoteAddress);  
    fs.writeFile('onlinestatus.txt', 'Disconnected', function (err) {
        if (err) return console.log(err);
        console.log('Disconnected > onlinestatus.txt');
    });
  }
  function onConnError(err) {  
    console.log('Connection %s error: %s', remoteAddress, err.message); 
    fs.writeFile('onlinestatus.txt', 'Disconnected', function (err) {
        if (err) return console.log(err);
        console.log('Disconnected > onlinestatus.txt');
    }); 
  }  
}

const server = app.listen(8000, () => {
    console.log("Application started and listening on port 8000");
});

const io = require('socket.io')(server);
io.on('connection', (socket) => {
    console.log('website client connected: %s', socket);
    website = socket;
    socket.once('disconnect', () => {
        console.log('website client disconnected');
    });
    socket.emit('BatteryLevel', [100,100,100,100]);
    socket.on('AngleDistance', data => {
        console.log('AngleDistance received on server: %s, %s', data[0], data[1]);
        socket.emit('AngleDistance', data);
    })
});

app.use(bodyParser.urlencoded({ extended: true}));

app.post("/commands", (req,res) => { // post from /commands page
    if(typeof(req.body.button) != 'undefined') {
        switch(req.body.button) {
            case "1":
                website.emit('BatteryLevel', '80');
                if(client !== "undefined") {
                    console.log("angle: %s", req.body);
                    client.write("1");
                    console.log("sent 1 to client");
                } else {
                    console.log("tcp client undefined");
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
                console.log('error: %s', req.body);
                console.log('button value: %s',req.body.button);
        };
    } else if(typeof(req.body.angle) != 'undefined') {
        console.log('angle, distance pair: [%s, %s]', req.body.angle, req.body.distance);
        const message = "[" + req.body.angle + ", " + req.body.distance + "]";
        if(client !== 'undefined') {
            client.write(message);
        }
        //website.emit('BatteryLevel', "70");
        angletoweb = req.body.angle;
        distancetoweb = req.body.distance;
        res.redirect("/commands");
    }
    //res.redirect("/");
});

var exportTest = "3";

const {MongoClient} = require('mongodb');
const { Console } = require('console');

async function main() {
    const uri = "mongodb+srv://marsrover:marsrover123@cluster0.odoqq.mongodb.net/myFirstDatabase?retryWrites=true&w=majority";

    const client = new MongoClient(uri, {useNewUrlParser: true, useUnifiedTopology: true});

    try {
        await client.connect();
        console.log('mongodb connected');
        /*
        await findingListings(client, {
            minimumBedroom: 4, 
            minimumBathroom: 2, 
            maximumResults: 5
        });
        */
        
    } catch (e) {
        console.error(e);
    } finally {
        await client.close();
    }
}

main().catch(console.error);

async function listDatabases(client) {
    const databasesList = await client.db().admin().listDatabases();
    console.log("Databases:");
    databasesList.databases.forEach(db => {
        console.log(`- ${db.name}`);
    })
}

async function createMultipleListings(client, newListings) {
    const result = await client.db("sample_airbnb").collection("listingsAndReviews").insertMany(newListings);
    console.log(`${result.insertedCount} new listings created with the following id(s):`);
    console.log(result.insertedIds);
}

async function createListing(client, newListing) {
    const result = await client.db("sample_airbnb").collection("listingsAndReviews").insertOne(newListing);
    console.log(`New listing created with the following id: ${result.insertedId}`);
}

async function findOneListingByName(client, nameOfListing) {
    const result = await client.db("sample_airbnb").collection("listingsAndReviews").findOne({name: nameOfListing});
    if(result) {
        console.log(`Found a listing in the collection with the name '${nameOfListing}'`);
        console.log(result);
    } else {
        console.log(`No listings found with the name '${nameOfListing}`);
    }
}

async function findingListings(client, {
    minimumBedroom = 0, 
    minimumBathroom = 0, 
    maximumResults = Number.MAX_SAFE_INTEGER
} = {}) {
    const cursor = client.db("sample_airbnb").collection("listingsAndReviews").find({
        bedrooms: { $gte: minimumBedroom },
        bathrooms: { $gte: minimumBathroom }
    }).sort( { last_review: -1 })
    .limit(maximumResults);

    const result = await cursor.toArray();

    if(result.length > 0) {
        result.forEach(db => {
            console.log(db.name);
            console.log(db._id);
            console.log(db.bedrooms);
            console.log(db.bathrooms);
            exportTest = (db.bedrooms).toString();
        })
    }
}

async function updateListingByName(client, nameOfListing, updatedListing) {
    const result = await client.db("sample_airbnb").collection("listingsAndReviews").updateOne(
        { name: nameOfListing }, { $set: updatedListing });
}