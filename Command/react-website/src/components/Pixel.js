import React, {useState} from 'react';

export default function Pixel({passed}) {

    var initialColor = 'transparent';

    const color = passed === '1' ? 'grey' : initialColor;

    const [pixelColor, setPixelColor] = useState(color); // pixel initially white
    const [previousColor, setPreviousColor] = useState(pixelColor);

    function showDataOnHover() {
        // show data
        setPreviousColor(pixelColor);
        setPixelColor('red');
    }

    function removeData() {
        // remove data
        setPixelColor(previousColor);
    }
    return (
        <div className='pixel' onMouseEnter={showDataOnHover} onMouseLeave={removeData} style={{backgroundColor: pixelColor}}></div>
    )
}