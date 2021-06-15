import React, {useState, useEffect} from 'react';
import './App.css';
import Navbar from './components/Navbar';
import {BrowserRouter as Router, Switch, Route} from 'react-router-dom';
import Home from './components/pages/Home';
import View from './components/pages/View';
import Command from './components/pages/Command';
import Power from './components/pages/Power';
import Socket from './components/Socket';
import {Rect, Circle} from 'react-konva';
import ReactDOM from 'react-dom';

const roverWidth = 25;
var global_angle = 0;
var currPos = [window.innerWidth/2 - roverWidth/2, window.innerHeight/2];
var currPos_backend = [0,0];
var roverPath = [];
var obstacleSet = [];

var stageX = 0;
var stageY = 0;
var stageWidth = window.innerWidth;
var stageHeight = window.innerHeight*3/4;

/*
function paths(roverPath, totalAngle, angleDistance, pos, color) {
  //var scale = 5;
  //var height = angleDistance[1]/scale;
  var height = Number(roverWidth) + Number(angleDistance[1]);
  var finalAngle = Number((Number(totalAngle)+Number(angleDistance[0]))%360);
  if(angleDistance[1] !== 0) {
    roverPath.push(<Rect x={pos[0]} y={pos[1]} width={roverWidth} height={height} fill={color} rotation={finalAngle} offsetX={roverWidth/2} offsetY={roverWidth/2}/>);
  }
  var sine = Math.sin(Math.PI/180*finalAngle);
  var cosine = Math.cos(Math.PI/180*finalAngle);
  var newPos = [Number(pos[0]) - Number(angleDistance[1])*sine, 
              Number(pos[1]) + Number(angleDistance[1])*cosine];
  currPos_backend = [Number(currPos_backend[0]) - Number(angleDistance[1])*sine,
              Number(currPos_backend[1]) + Number(angleDistance[1])*cosine];
  return [roverPath, finalAngle, newPos];
}
*/

function paths(angleDistance, color) {
  var height = Number(roverWidth) + Number(angleDistance[1]);
  var finalAngle = Number((Number(global_angle)+Number(angleDistance[0]))%360);
  if(angleDistance[1] !== 0) {
    roverPath.push(<Rect x={currPos[0]} y={currPos[1]} width={roverWidth} height={height} 
      fill={color} rotation={finalAngle} offsetX={roverWidth/2} offsetY={roverWidth/2}/>);
  }
  var sine = Math.sin(Math.PI/180*finalAngle);
  var cosine = Math.cos(Math.PI/180*finalAngle);
  currPos = [Number(currPos[0]) - Number(angleDistance[1])*sine, 
              Number(currPos[1]) + Number(angleDistance[1])*cosine];
  currPos_backend = [Number(currPos_backend[0]) - Number(angleDistance[1])*sine,
              Number(currPos_backend[1]) + Number(angleDistance[1])*cosine];
  global_angle = Number(finalAngle);
}

function drawObstacle(obstacle, pos, angle) {
  var color = "black";
  switch(obstacle[0]) {
    case "pink":
      color = "#eb7bdd";
      break
    case "green":
      color = "#97df62";
      break
    case "blue":
      color = "#8bcbd4";
      break
    case "orange":
      color = "fc9031";
      break
    case "grey":
      color = "1c1e1b";
      break
    default:
      //
  };
  var xpos = obstacle[1][0]*Math.cos(angle*Math.PI/180) 
              - obstacle[1][1]*Math.sin(angle*Math.PI/180);
  var ypos = obstacle[1][0]*Math.sin(angle*Math.PI/180) 
              + obstacle[1][1]*Math.cos(angle*Math.PI/180);
  obstacleSet.push(<Circle x={pos[0]+xpos} y={pos[1]+ypos} 
                    radius={15} fill={color}/>);
}

function App() {
  
  const [batteryLevel, setBattery] = useState(["unknown","unknown","unknown","unknown"]);
  const [energyData1, setEnergyData1] = useState([["unavailable","unavailable","unavailable","unavailable"],"unavailable","unavailable"]);
  const [energyData2, setEnergyData2] = useState(["unavailable","unavailable","unavailable"]);
  useEffect(() => {
    Socket.on('EnergyData1', data => {
      setEnergyData1(data);
    });
  }, []);
  useEffect(() => {
    Socket.on('EnergyData2', data => {
      setEnergyData2(data);
    });
  }, []);
  //const [angleDistanceSet, setAngleDistance] = useState([0,0]);
  useEffect(() => {
    Socket.on('AngleDistance', data => {
      console.log("AngleDistance from server: %s", data);
      //setAngleDistance(data);
      paths(data, "grey");
      if(currPos[0] < -stageX) {
        stageX = stageX - currPos[0] + 100;
        stageWidth = stageWidth - currPos[0] + 100;
      } else if(currPos[0] > stageWidth + stageX) {
        stageWidth = currPos[0] + 100;
      }
      if(currPos[1] < -stageY) {
        stageY = stageY - currPos[1] + 100;
        stageHeight = stageHeight - currPos[1] + 100;
      } else if(currPos[1] > stageHeight + stageY) {
        stageHeight = currPos[1] + 100;
      }
      //this.setState({});
    })
  }, []);
  const [obstacle, setObstacle] = useState(["unknown",[0,0]]);
  useEffect(() => {
    Socket.on("Obstacle", data => {
      console.log("obstacle detected: %s", data);
      setObstacle(data);
      drawObstacle(data, currPos, global_angle);
    });
  });
  useEffect(() => {
    Socket.on("CurrentPosition", data => {
      Socket.emit("CurrentPosition", [currPos_backend, global_angle]);
    });
  }, []);

  //[roverPath, global_angle, currPos] = paths(roverPath, global_angle, angleDistanceSet, currPos, "grey");
  /*
  if(currPos[0] < -stageX) {
    stageX = stageX - currPos[0] + 100;
    stageWidth = stageWidth - currPos[0] + 100;
  } else if(currPos[0] > stageWidth + stageX) {
    stageWidth = currPos[0] + 100;
  }
  if(currPos[1] < -stageY) {
    stageY = stageY - currPos[1] + 100;
    stageHeight = stageHeight - currPos[1] + 100;
  } else if(currPos[1] > stageHeight + stageY) {
    stageHeight = currPos[1] + 100;
  }
  */
  return (
    <>
    <Router>
      <Navbar />
      <Switch>
        <Route path='/' exact render={(props) => (
          <Home {...props} batteryLevel={(batteryLevel[0]+batteryLevel[1]+batteryLevel[2]+batteryLevel[3])/4}/>
        )} />
        <Route path='/view' render={(props) => (
          <View {...props} path={roverPath} pos={currPos} obstacle={obstacleSet} stage={[stageX,stageY,stageWidth,stageHeight]}/>
        )} />
        <Route path='/command' render={(props) => (
          <Command {...props} />
        )} />
        <Route path='/power' render={(props) => (
          <Power {...props} cell={energyData1[0]} energyLeft={energyData1[1]} energyFull={energyData1[2]} chargingCycle={energyData2[0]} currentCapacity={energyData2[1]} maxCapacity={energyData2[2]}/>
        )} />
      </Switch>
    </Router>
    </>
  );
}

export default App;
