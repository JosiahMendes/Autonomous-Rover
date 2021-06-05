import React from 'react';
import Pixel from './Pixel';

export default function Row({width, index, set}) {

    let pixels = [];
    let passed = '0';
    let i = 0;
    for(i=0; i < width; i++) {
        for(let j = 0; j < set.length; j++) {
            if(index == set[j][0] && i == set[j][1]) {
                passed = '1';
            }
        }
        pixels.push(<Pixel index={i} passed={passed}/>)
        passed = '0';
    }

    return (
        <div className='row'>
            {pixels}
        </div>
    )
}