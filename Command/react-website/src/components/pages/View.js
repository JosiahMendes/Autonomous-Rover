import React from 'react';
import '../../App.css';
import ViewSection from '../ViewSection';

export default function View({path, pos, obstacle}) {
    return (
        <>
            <ViewSection path={path} pos={pos} obstacle={obstacle}/>
        </>
    )
}