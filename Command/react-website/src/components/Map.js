import React from 'react';
import {Stage, Layer, Text, RegularPolygon, Star} from 'react-konva';

var stageX = 0;
var stageY = 0;
var stageWidth = window.innerWidth;
var stageHeight = window.innerHeight*3/4;

export default function Map({roverPath, pos, obstacle, stage}) {
    var roverWidth = 25;
    var basePos = [window.innerWidth/2 - roverWidth/2, window.innerHeight/2];
    if(pos[0] < -stageX) {
        stageX = stageX - pos[0] + 100;
        stageWidth = stageWidth - pos[0] + 100;
    } else if(pos[0] > stageWidth + stageX) {
        stageWidth = pos[0] + 100;
    }
    if(pos[1] < -stageY) {
        stageY = stageY - pos[1] + 100;
        stageHeight = stageHeight - pos[1] + 100;
    } else if(pos[1] > stageHeight + stageY) {
        stageHeight = pos[1] + 100;
    }
    return (
        <Stage x={stage[0]} y={stage[1]} width={stage[2]} height={stage[3]}>
            <Layer>
                {roverPath}
                <Text x={40} y={20} text="* Red star: the current location of the rover" fontSize={18} />
                <Text x={52} y={40} text="Blue triangle: the base" fontSize={18} />
                <RegularPolygon sides={3} x={basePos[0]} y={basePos[1]} fill="blue" radius={20}/>
                <Star x={pos[0]} y={pos[1]} fill="red" numPoints={5} innerRadius={10} outerRadius={20} />
                {obstacle}
            </Layer>
        </Stage>
    )
}