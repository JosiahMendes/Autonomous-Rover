import React from 'react';
import '../../App.css';
import CommandSection from '../CommandSection';

export default function Commands({batteryLevel}) {
    return (
        <>
            <CommandSection BatLevel={batteryLevel}/>
        </>
    );
};