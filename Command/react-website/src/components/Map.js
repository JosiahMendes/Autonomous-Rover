import React from 'react';
import {Stage, Layer, Rect, Circle} from 'react-konva';

const roverWidth = 30;
const roverHeight = 30;

const angle = 90;

// angle in degrees
function rotatedCoordinates(x, y, angle) {
    if(angle === 0) {
        return [x, y];
    } else if(angle === 180) {
        return [x + roverWidth, y + roverWidth];
    }
    var a = Math.sqrt(2)/2*roverWidth * Math.sin(angle*Math.PI/180) / Math.sin((180-angle)/2*Math.PI/180);
    var specialAngle = (90-angle)/2;
    var rotatedX = x + a*Math.cos(specialAngle*Math.PI/180);
    var rotatedY = y - a*Math.sin(specialAngle*Math.PI/180);
    return [rotatedX, rotatedY];
}

function paths(roverPath, totalAngle, angleDistance, pos, color) {
    //var scale = 5;
    //var height = angleDistance[1]/scale;
    var height = roverWidth + angleDistance[1];
    var finalAngle = Number((totalAngle+angleDistance[0])%360);
    //var transformed = rotatedCoordinates(pos[0], pos[1], angleDistance[0]);
    //var xcoord = roverPath.length === 0 ? pos[0] : transformed[0];
    //var ycoord = roverPath.length === 1 ? pos[1] : transformed[1];
    roverPath.push(<Rect x={pos[0]} y={pos[1]} width={roverWidth} height={height} fill={color} rotation={finalAngle} offsetX={roverWidth/2} offsetY={roverWidth/2}/>);
    var sine = Math.sin(Math.PI/180*finalAngle);
    var cosine = Math.cos(Math.PI/180*finalAngle);
    var newPos = [pos[0] - (angleDistance[1])*sine, 
                pos[1] + (angleDistance[1])*cosine];
    return [roverPath, finalAngle, newPos];
}

export default function Map() {
    var global_angle = 0;
    var currPos = [window.innerWidth/2 - roverWidth/2, window.innerHeight/2];
    var roverPath = [];
    /*
    var rectangles = [];
    rectangles.push(<Rect x={currPos[0]} y={currPos[1]} width = {rectangleWidth} height={200} fill="grey" rotation={0}/>)
    rectangles.push(<Rect x={rotated45[0]} y={rotated45[1]} width={rectangleWidth} height={200} fill="red" rotation={angle}/>)
    */
    [roverPath, global_angle, currPos] = paths(roverPath, global_angle, [90, 200], currPos, "grey");
    [roverPath, global_angle, currPos] = paths(roverPath, global_angle, [45, 50], currPos, "grey");
    [roverPath, global_angle, currPos] = paths(roverPath, global_angle, [135, 150], currPos, "grey");
    return (
        <Stage width={window.innerWidth} height={window.innerHeight}>
            <Layer>
                {roverPath}
            </Layer>
        </Stage>
    )
}