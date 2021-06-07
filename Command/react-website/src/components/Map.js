import React from 'react';
import {Stage, Layer} from 'react-konva';

export default function Map({roverPath}) {
    return (
        <Stage width={window.innerWidth} height={window.innerHeight}>
            <Layer>
                {roverPath}
            </Layer>
        </Stage>
    )
}