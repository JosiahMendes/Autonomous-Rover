import React from 'react';
import Row from './Row';
import './Canvas.css';
export default function Canvas({width, height, set}) {

    let rows = [];
    let i = 0;
    for(i = 0; i < height; i++) {
        rows.push(
            <Row index={i} width={width} set={set}></Row>
        )
    }

    return (
        <div id='canvas'>
            <div id='pixels'>
                {rows}
            </div>
        </div>
    )
}