import React, {useState, useEffect} from 'react';
import './App.css';
import Navbar from './components/Navbar';
import {BrowserRouter as Router, Switch, Route} from 'react-router-dom';
import Home from './components/pages/Home';
import View from './components/pages/View';
import Commands from './components/pages/Commands';
import SignUp from './components/pages/SignUp';
import Socket from './components/Socket';

function pixelCal(angle, distance) {
  if(distance === 0) {
      return [];
  }
  let scale = 5; // distance of 5 is 1 pixel
  var relativepixel = [];
  const distanceinscale = Math.ceil(distance / scale);
  if(angle === 0) { // up
      for(let i = 1; i <= distanceinscale; i++) {
          relativepixel.push([-i, 0]);
      }
  } else if(angle === 45) {
      for(let i = 1; i <= distanceinscale; i++) {
          relativepixel.push([-i, i]);
      }
  } else if(angle === 90) { // right
      for(let i = 1; i <= distanceinscale; i++) {
          relativepixel.push([0, i]);
      }
  } else if(angle === 135) {
      for(let i = 1; i <= distanceinscale; i++) {
          relativepixel.push([i, i]);
      }
  } else if(angle === 180) { // down
      for(let i = 1; i <= distanceinscale; i++) {
          relativepixel.push([i, 0]);
      }
  } else if(angle === 225) {
      for(let i = 1; i <= distanceinscale; i++) {
          relativepixel.push([i, -i]);
      }
  } else if(angle === 270) { // left
      for(let i = 1; i <= distanceinscale; i++) {
          relativepixel.push([0, -i]);
      }
  } else if(angle === 315) {
      for(let i = 1; i <= distanceinscale; i++) {
          relativepixel.push([-i, -i]);
      }
  }
  return relativepixel;
}

function passedsetCalc(currSet, angle, newAngle, newDistance, currPos) {
  var finalAngle = (Number(angle) + Number(newAngle))%360;
  var relativeset = pixelCal(finalAngle, newDistance);
  if(relativeset.length !== 0) {
      relativeset.forEach(element => {
          let temp = [0,0];
          temp[0] = element[0]+currPos[0];
          temp[1] = element[1]+currPos[1];
          currSet.push(temp);
      });
  }
  let finalPos = currSet.length === 0 ? currPos : currSet[currSet.length-1];
  return [currSet, finalAngle, finalPos];
}
var global_angle = 0;
var passedSet = [];
var currPos = [15, 15]; // starting point on the map

function App() {
  
  const [batteryLevel, setBattery] = useState("unknown");
  useEffect(() => {
    Socket.on('BatteryLevel', data => {
      setBattery(data);
    });
  }, []);
  const [angleDistanceSet, setAngleDistance] = useState([0,0]);
  useEffect(() => {
    Socket.on('AngleDistance', data => {
      setAngleDistance(data);
    })
  }, []);

  const calculated = passedsetCalc(passedSet, global_angle, angleDistanceSet[0], angleDistanceSet[1], currPos);
  passedSet = calculated[0];
  global_angle = calculated[1];
  currPos = calculated[2];

  return (
    <>
    <Router>
      <Navbar />
      <Switch>
        <Route path='/' exact component={Home} />
        <Route path='/view' render={(props) => (
          <View {...props} pixels={passedSet}/>
        )} />
        <Route path='/commands' render={(props) => (
          <Commands {...props} batteryLevel={batteryLevel}/>
        )} />
        <Route path='/sign-up' component={SignUp} />
      </Switch>
    </Router>
    </>
  );
}

export default App;
