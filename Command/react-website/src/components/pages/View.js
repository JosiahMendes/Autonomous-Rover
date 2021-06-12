import React from 'react';
import '../../App.css';
import ViewSection from '../ViewSection';

export default function View({path, pos}) {
    return (
        <>
            <ViewSection path={path} pos={pos}/>
        </>
    )
}