import React from 'react';
import '../../App.css';
import PowerSection from '../PowerSection';

export default function Power({cell, energyLeft, energyFull, chargingCycle, currentCapacity, maxCapacity}) {
    return (
        <>
            <PowerSection cell={cell} energyLeft={energyLeft} energyFull={energyFull} chargingCycle={chargingCycle} currentCapacity={currentCapacity} maxCapacity={maxCapacity}/>
        </>
    )
}