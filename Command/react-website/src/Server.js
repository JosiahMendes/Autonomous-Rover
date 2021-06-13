const express = require('express'); // express js
const app = express();

// astar algorithm for pathfinding
const astar = require('javascript-astar');
const Graph = astar.Graph;

var vision = [ [0,0], [0,0], [0,0], [0,0], [0,0] ];
var stop = false;
var back = false;
var CurrentPosition = ["undefined","undefined"];
var globalAngle = 0;

function createMap(distance, obstacles) {
    let width = 1; // an element represents 5cm x 5cm box
    let extra = 10; // extra width
    var largestWidth = obstacles[0][1] !== 0 ? Math.abs(obstacles[0][0]) : 1;
    var furthestAway = obstacles[0][1];
    for(let i = 1; i < obstacles.length; i++) {
        if(Math.abs(obstacles[i][0]) > largestWidth) {
            largestWidth = Math.abs(obstacles[i][0]);
        }
        if(obstacles[i][1] > furthestAway) {
            furthestAway = obstacles[i][1];
        }
    }
    var graphWidth = Math.ceil((largestWidth + 15 + extra) * 2 / width);
    var graphHeight = Math.max(Math.ceil(distance / width)+1, Math.ceil((furthestAway + 15 + 1) / width) );
    var result = Array(graphHeight);
    for(let i = 0; i < graphHeight; i++) {
        result[i] = Array(graphWidth).fill(1);
    }
    obstacles.forEach(obstacle => {
        if(obstacle[1] !== 0) {
            var obstacleX = obstacle[0] > 0 ? graphWidth/2 + Math.ceil(obstacle[0]/width) : graphWidth/2 + Math.floor(obstacle[0]/width);
            for(let i = Math.ceil(obstacle[1]/width) - Math.ceil(15/width); i < Math.ceil(obstacle[1]/width) + Math.ceil(15/width); i++) {
                for(let j = Math.ceil(obstacleX) - Math.ceil(15/width); j < Math.ceil(obstacleX) + Math.ceil(15/width); j++) {
                    result[i][j] = 0;
                }
            }
        }
    });
    var blocked = false;
    var distanceAfterObstacle = 0;
    var distanceBeforeObstacle = 0;
    if(result[Math.ceil(distance)][Math.ceil(result[0].length/2)-1] === 0) {
        blocked = true;
        let i = Math.ceil(distance);
        for(let i = Math.ceil(distance); i < result.length; i++) {
            if(result[i][Math.ceil(result[0].length/2)-1] === 1) {
                distanceAfterObstacle = i;
                break
            }
        }
        for(let i = Math.ceil(distance)-1; i >= 0; i--) {
            if(result[i][Math.ceil(result[0].length/2)-1] === 1) {
                distanceBeforeObstacle = i;
                break
            }
        }
    }
    return [result, blocked, distanceAfterObstacle, distanceBeforeObstacle];
}

function convert2command(result) {
    var index = 0;
    var command = [];
    var direction = "forward";
    var angle = 0;
    var distance = 0;
    while(index < result.length) {
        if(result[index].y < result[index].parent.y) {
            console.log("CHECK: the rover went backward. Index: " + index);
        }
        if(direction === "forward") {
            if(result[index].x === result[index].parent.x) { // forward
                distance += 10; // cm to mm
                index++;
            } else if(result[index].x > result[index].parent.x) {
                if(distance !== 0) {
                    command.push([angle, Math.ceil(distance)]);
                    angle = 0;
                    distance = 0;
                }
                if(result[index].y === result[index].parent.y) { // left
                    direction = "left";
                    angle = 270;
                } else if(result[index].y > result[index].parent.y) { // left forward
                    direction = "left-forward";
                    angle = 315;
                }
            } else if(result[index].x < result[index].parent.x) {
                if(distance !== 0) {
                    command.push([angle, Math.ceil(distance)]);
                    angle = 0;
                    distance = 0;
                }
                if(result[index].y === result[index].parent.y) { // right
                    direction = "right";
                    angle = 90;
                } else if(result[index].y > result[index].parent.y) { // right forward
                    direction = "right-forward";
                    angle = 45;
                }
            }
        } else if(direction === "right") {
            if(result[index].x === result[index].parent.x) {
                if(distance !== 0) {
                    command.push([angle, Math.ceil(distance)]);
                    angle = 0;
                    distance = 0;
                }
                if(result[index].y > result[index].parent.y) { // forward
                    direction = "forward";
                    angle = 270;
                }
            } else if(result[index].x < result[index].parent.x) {
                if(result[index].y === result[index].parent.y) { // right
                    distance += 10;
                    index++;
                } else if(result[index].y > result[index].parent.y) { // right forward
                    if(distance !== 0) {
                        command.push([angle, Math.ceil(distance)]);
                        angle = 0;
                        distance = 0;
                    }
                    direction = "right-forward";
                    angle = 315;
                }
            } else if(result[index].x > result[index].parent.x) {
                if(distance !== 0) {
                    command.push([angle, Math.ceil(distance)]);
                    angle = 0;
                    distance = 0;
                }
                if(result[index].y === result[index].parent.y) { // left
                    direction = "left";
                    angle = 180;
                } else if(result[index].y > result[index].parent.y) { // left forward
                    direction = "left-forward";
                    angle = 225;
                }
            }
        } else if(direction === "right-forward") {
            if(result[index].x === result[index].parent.x) {
                if(distance !== 0) {
                    command.push([angle, Math.ceil(distance)]);
                    angle = 0;
                    distance = 0;
                }
                if(result[index].y > result[index].parent.y) { // forward
                    direction = "forward";
                    angle = 315;
                }
            } else if(result[index].x > result[index].parent.x) {
                if(distance !== 0) {
                    command.push([angle, Math.ceil(distance)]);
                    angle = 0;
                    distance = 0;
                }
                if(result[index].y === result[index].parent.y) { // left
                    direction = "left";
                    angle = 225;
                } else if(result[index].y > result[index].parent.y) { // left forward
                    direction = "left-forward";
                    angle = 270;
                }
            } else if(result[index].x < result[index].parent.x) {
                if(result[index].y === result[index].parent.y) { // right
                    if(distance !== 0) {
                        command.push([angle, Math.ceil(distance)]);
                        angle = 0;
                        distance = 0;
                    }
                    direction = "right";
                    angle = 45;
                } else if(result[index].y > result[index].parent.y) { // right forward
                    distance += 10*Math.sqrt(2);
                    index++;
                }
            }
        } else if(direction === "left") {
            if(result[index].x === result[index].parent.x) {
                if(distance !== 0) {
                    command.push([angle, Math.ceil(distance)]);
                    angle = 0;
                    distance = 0;
                }
                if(result[index].y > result[index].parent.y) { // forward
                    direction = "forward";
                    angle = 90;
                }
            } else if(result[index].x > result[index].parent.x) {
                if(result[index].y === result[index].parent.y) { // left
                    distance += 10;
                    index++;
                } else if(result[index].y > result[index].parent.y) { // left forward
                    if(distance !== 0) {
                        command.push([angle, Math.ceil(distance)]);
                        angle = 0;
                        distance = 0;
                    }
                    direction = "left-forward";
                    angle = 45;
                }
            } else if(result[index].x < result[index].parent.x) {
                if(distance !== 0) {
                    command.push([angle, Math.ceil(distance)]);
                    angle = 0;
                    distance = 0;
                }
                if(result[index].y === result[index].parent.y) { // right
                    direction = "right";
                    angle = 180;
                } else if(result[index].y > result[index].parent.y) { // right forward
                    direction = "right-forward";
                    angle = 135;
                }
            }
        } else if(direction === "left-forward") {
            if(result[index].x === result[index].parent.x) {
                if(distance !== 0) {
                    command.push([angle, Math.ceil(distance)]);
                    angle = 0;
                    distance = 0;
                }
                if(result[index].y > result[index].parent.y) { // forward
                    direction = "forward";
                    angle = 45;
                }
            } else if(result[index].x > result[index].parent.x) {
                if(result[index].y === result[index].parent.y) { // left
                    if(distance !== 0) {
                        command.push([angle, Math.ceil(distance)]);
                        angle = 0;
                        distance = 0;
                    }
                    direction = "left";
                    angle = 315;
                } else if(result[index].y > result[index].parent.y) { // left forward
                    distance += 10*Math.sqrt(2);
                    index++;
                }
            } else if(result[index].x < result[index].parent.x) {
                if(distance !== 0) {
                    command.push([angle, Math.ceil(distance)]);
                    angle = 0;
                    distance = 0;
                }
                if(result[index].y === result[index].parent.y) { // right
                    direction = "right";
                    angle = 135;
                } else if(result[index].y > result[index].parent.y) { // right forward
                    direction = "right-forward";
                    angle = 90;
                }
            }
        }
    }
    if(distance !== 0) {
        command.push([angle, Math.ceil(distance)]);
    }
    return command;
}

function printMap(map) { // debugging: print 2d array
    console.log("Map:");
    for(let i = 0; i < map.length; i++) {
        for(let j = 0; j < map[i].length; j++) {
            process.stdout.write(map[i][j] + " ");
        }
        console.log();
    }
}

function automatedDriving() {
    const step = 27; // 1 step = 27cm
    var distanceToTravel = step; // will increase every time
    var distanceToTravelLeft = distanceToTravel;
    var stage = 0;
    command = [];
    var obstaclesFound = [];
    while(!back && obstaclesFound.length < 5) {
        if(vision[0][1] !== 0 && !obstaclesFound.includes("pink")) {
            obstaclesFound.push("pink");
            website.emit("Obstacle", ["pink", vision[0]]);
        }
        if(vision[1][1] !== 0 && !obstaclesFound.includes("green")) {
            obstaclesFound.push("green");
            website.emit("Obstacle", ["green", vision[1]]);
        }
        if(vision[2][1] !== 0 && !obstaclesFound.includes("blue")) {
            obstaclesFound.push("blue");
            website.emit("Obstacle", ["blue", vision[2]]);
        }
        if(vision[3][1] !== 0 && !obstaclesFound.includes("orange")) {
            obstaclesFound.push("orange");
            website.emit("Obstacle", ["orange", vision[3]]);
        }
        if(vision[4][1] !== 0 && !obstaclesFound.includes("grey")) {
            obstaclesFound.push("grey");
            website.emit("Obstacle", ["grey", vision[4]]);
        }
        var map = createMap(step, vision);
        var graph = new Graph(map[0]);
        var start = graph.grid[Math.ceil(map[0][0].length/2)-1][0];
        var distanceTravelled = 0;
        if(map[1]) {
            if(distanceToTravelLeft < map[2]) {
                distanceTravelled = map[3];
            } else {
                distanceTravelled = map[2];
            }
        } else {
            distanceTravelled = step;
        }
        var end = graph.grid[Math.ceil(map[0][0].length/2)-1][distanceTravelled];
        command = convert2command(astar.astar.search(graph, start, end));
        distanceToTravelLeft -= distanceTravelled;
        if(distanceToTravelLeft < step) {
            command.push([90, 0]); // rotate 90 degrees
            stage++;
            if(stage === 2) {
                distanceToTravel += step;
                distanceToTravelLeft = distanceToTravel;
                stage = 0;
            }
        }
        while(command.length > 0) {
            esp32.write("[" + command[0][0] + "," + command[0][1] + "]");
            command.shift();
            website.emit("AngleDistance", [command[0][0],command[0][1]]);
            // while(esp32respond);
        }
        while(stop); // the rover does not move when stopped
    }
    // going back to the base
    website.emit("CurrentPosition", "request");
    while(CurrentPosition[0] !== "undefined"); // wait for data to arrive
    distanceToTravel = Math.abs(CurrentPosition[0]);
    if(CurrentPosition[0] > 0) {
        esp32.write("[" + ((-90-Number(globalAngle))%360+360)%360 + "," + Number(0) + "]");
    } else {
        esp32.write("[" + ((90-Number(globalAngle))%360+360)%360 + "," + Number(0) + "]");
    }
    // while(esp32respond);
    while(distanceToTravel > step) {
        var map = createMap(step, vision);
        var graph = new Graph(map[0]);
        var start = graph.grid[Math.ceil(map[0][0].length/2)-1][0];
        var distanceTravelled = 0;
        if(map[1]) {
            if(distanceToTravel < map[2]) {
                distanceTravelled = map[3];
            } else {
                distanceTravelled = map[2];
            }
        } else {
            distanceTravelled = step;
        }
        var end = graph.grid[Math.ceil(map[0][0].length/2)-1][distanceTravelled];
        command = convert2command(astar.astar.search(graph, start, end));
        distanceToTravel -= distanceTravelled;
        while(command.length > 0) {
            esp32.write("[" + command[0][0] + "," + command[0][1] + "]");
            command.shift();
            website.emit("AngleDistance", [command[0][0],command[0][1]]);
            // while(esp32respond);
        }
    }
    var distanceLeftX = distanceToTravel;
    distanceToTravel = Math.abs(CurrentPosition[1]);
    if(CurrentPosition[1] > 0) {
        if(CurrentPosition[0] > 0) {
            esp32.write("[90,0]");
        } else {
            esp32.write("[270,0]");
        }
    } else {
        if(CurrentPosition[0] > 0) {
            esp32.write("[270,0]");
        } else {
            esp32.write("[90,0]");
        }
    }
    // while(esp32respond);
    while(distanceToTravel > step) {
        var map = createMap(step, vision);
        var graph = new Graph(map[0]);
        var start = graph.grid[Math.ceil(map[0][0].length/2)-1][0];
        var distanceTravelled = 0;
        if(map[1]) {
            if(distanceToTravel < map[2]) {
                distanceTravelled = map[3];
            } else {
                distanceTravelled = map[2];
            }
        } else {
            distanceTravelled = step;
        }
        var end = graph.grid[Math.ceil(map[0][0].length/2)-1][distanceTravelled];
        command = convert2command(astar.astar.search(graph, start, end));
        distanceToTravel -= distanceTravelled;
        while(command.length > 0) {
            esp32.write("[" + command[0][0] + "," + command[0][1] + "]");
            command.shift();
            website.emit("AngleDistance", [command[0][0],command[0][1]]);
            // while(esp32respond);
        }
    }
    var distanceLeftY = distanceToTravel;
    if(distanceLeftX !== 0) {
        if(CurrentPosition[0] > 0) {
            if(CurrentPosition[1] > 0) {
                esp32.write("[270," + distanceLeftX + "]");
                if(distanceLeftY !== 0) {
                    esp32.write("[90," + distanceLeftY + "]");
                }
            } else {
                esp32.write("[90," + distanceLeftX + "]");
                if(distanceLeftY !== 0) {
                    esp32.write("[270," + distanceLeftY + "]");
                }
            }
        } else {
            if(CurrentPosition[1] > 0) {
                esp32.write("[90," + distanceLeftX + "]");
                if(distanceLeftY !== 0) {
                    esp32.write("[270," + distanceLeftY + "]");
                }
            } else {
                esp32.write("[270," + distanceLeftX + "]");
                if(distanceLeftY !== 0) {
                    esp32.write("[90," + distanceLeftY + "]");
                }
            }
        }
    }
}
/*
var testMap = createMap(30, [[0, 30]]);
printMap(testMap[0]);
console.log("blocked?: " + testMap[1]);
console.log("Distance after obstacle: " + testMap[2]);
console.log("Distance before obstacle: " + testMap[3]);
var testGraph = new Graph(testMap[0], {diagonal: true});
var testStart = testGraph.grid[Math.ceil(testMap[0][0].length/2)-1][0];
var testEnd = testGraph.grid[Math.ceil(testMap[0][0].length/2)-1][testMap.length-1];
var testResult = astar.astar.search(testGraph, testStart, testEnd);
var testCommand = convert2command(testResult);
*/
//console.log(testCommand);

// TCP server communicates with the ESP32    
var net = require('net');
var tcpserver = net.createServer();
var esp32 = "undefined";
tcpserver.on('connection', handleConnection);
const tcphost = '0.0.0.0'; // localhost
const tcpport = 9000;
tcpserver.listen(tcpport, tcphost, function() {
    console.log('Server is listening to %j', tcpserver.address());
});
function handleConnection(socket) {
  esp32 = socket; // storing client so it can be accessed by the web server
  CurrentPosition = [0,0];
  console.log('esp32 saved');
  var remoteAddress = socket.remoteAddress + ':' + socket.remotePort;  
  console.log('TCP: new client connection from %s', remoteAddress);
  socket.write("You are connected");
  socket.on('data', onDataReceived);  
  socket.once('close', onConnClose);  
  socket.on('error', onConnError);
  function onDataReceived(data) {  
    console.log('connection data from %s: %j', remoteAddress, data.toString());
    website.emit("BatteryLevel", [Number(data.toString()),100,100,100]);
    if(data.toString().charAt(0) === '[') { // special starting character for vision data
        var visionData = data.toString().substring(1).slice(0, -1).split(";");
        for(let i = 0; i < visionData.length; i++) {
            visionData[i] = visionData[i].split(",");
            visionData[i][0] = Number(visionData[i][0]);
            visionData[i][1] = Number(visionData[i][1]);
        }
        vision = visionData;
    }
    //conn.write(d); send back to client
  }
  function onConnClose() {  
    console.log('connection from %s closed', remoteAddress);  
  }
  function onConnError(err) {  
    console.log('Connection %s error: %s', remoteAddress, err.message); 
  }  
}

/*
var graph = new Graph([
	[1,1,1,1],
	[0,1,1,0],
	[0,0,1,1]
], { diagonal: true });
var start = graph.grid[0][0];
var end = graph.grid[1][2];
var result = astar.astar.search(graph, start, end);
*/
//console.log(result);

const server = app.listen(8000, () => {
    console.log("Application started and listening on port 8000");
});
var website;
const io = require('socket.io')(server);
io.on('connection', (socket) => {
    console.log('website client connected');
    website = socket; // storing website client
    socket.once('disconnect', () => {
        console.log('website client disconnected');
    });
    socket.emit('BatteryLevel', [100,100,100,100]);
    socket.on('AngleDistance', data => {
        console.log('AngleDistance received on server: %s, %s', data[0], data[1]);
        if(esp32 !== "undefined") {
            esp32.write("AngleDistance: %s, %s", data[0], data[1]);
        }
        socket.emit('AngleDistance', data);
    });
    socket.on('Command', data => {
        console.log("Command from web: %s", data);
        switch(data) {
            case "investigate":
                stop = false;
                back = false;
                automatedDriving();
                break
            case "back":
                back = true;
                break
            case "stop":
                stop = !stop;
                break
            default:
                console.log("Error: unknown command keyword %s from web", data);
        };
    });
    socket.on('Speed', data => {
        console.log("Speed from web: %s", data);
        if(data === "veryfast" ||
           data === "fast" ||
           data === "regular" ||
           data === "slow" ||
           data === "veryslow") {
            esp32.write("Speed: " + data);
        } else {
            console.log("Error: unknown speed keyword %s from web", data);
        }
    });
    socket.on("CurrentPosition", data => {
        globalAngle = Number(data[1]);
        CurrentPosition = [Number(data[0][0]),Number(data[0][1])];
    })
});
/*
const {MongoClient} = require('mongodb');
const { Console } = require('console');

async function main() {
    const uri = "mongodb+srv://marsrover:marsrover123@cluster0.odoqq.mongodb.net/myFirstDatabase?retryWrites=true&w=majority";

    const client = new MongoClient(uri, {useNewUrlParser: true, useUnifiedTopology: true});

    try {
        await client.connect();
        console.log('mongodb connected');
        await findingListings(client, {
            minimumBedroom: 4, 
            minimumBathroom: 2, 
            maximumResults: 5
        });
        
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
*/