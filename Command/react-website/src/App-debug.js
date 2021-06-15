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

const roverWidth = 25;
var global_angle = 0;
var currPos = [window.innerWidth/2 - roverWidth/2, window.innerHeight/2];
var currPos_backend = [0,0];
var roverPath = [];
var obstacleSet = [];

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
  var xpos = obstacle[1][0]*Math.cos(angle*Math.PI/180) - obstacle[1][1]*Math.sin(angle*Math.PI/180);
  var ypos = obstacle[1][0]*Math.sin(angle*Math.PI/180) + obstacle[1][1]*Math.cos(angle*Math.PI/180);
  obstacleSet.push(<Circle x={pos[0]+xpos} y={pos[1]+ypos} radius={2.5} fill={color}/>);
}
var angleDistanceSet = [0,0];
function App() {
  
  const [batteryLevel, setBattery] = useState(["unknown","unknown","unknown","unknown"]);
  useEffect(() => {
    Socket.on('BatteryLevel', data => {
      for(let i = 0; i < data.length; i++) {
        data[i] = Number(data[i]);
      }
      setBattery(data);
    });
  }, []);
  
  useEffect(() => {
    Socket.on('AngleDistance', data => {
      console.log(data);
      angleDistanceSet = data;
    })
  }, []);
  const [obstacle, setObstacle] = useState(["unknown",[0,0]]);
  useEffect(() => {
    Socket.on("Obstacle", data => {
      setObstacle(data);
      drawObstacle(obstacle, currPos, global_angle);
    });
  });
  useEffect(() => {
    Socket.on("CurrentPosition", data => {
      Socket.emit("CurrentPosition", [currPos_backend, global_angle]);
    });
  }, []);

  [roverPath, global_angle, currPos] = paths(roverPath, global_angle, angleDistanceSet, currPos, "grey");
  return (
    <>
    <Router>
      <Navbar />
      <Switch>
        <Route path='/' exact render={(props) => (
          <Home {...props} batteryLevel={(batteryLevel[0]+batteryLevel[1]+batteryLevel[2]+batteryLevel[3])/4}/>
        )} />
        <Route path='/view' render={(props) => (
          <View {...props} path={roverPath} pos={currPos} obstacle={obstacleSet}/>
        )} />
        <Route path='/command' render={(props) => (
          <Command {...props} />
        )} />
        <Route path='/power' render={(props) => (
          <Power {...props} batteryLevel={batteryLevel}/>
        )} />
      </Switch>
    </Router>
    </>
  );
}

export default App;
