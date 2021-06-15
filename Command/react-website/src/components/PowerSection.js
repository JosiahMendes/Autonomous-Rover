import React from 'react';
import Battery from './konvaBattery';
import {Stage, Layer, Text} from 'react-konva';

function PowerSection({cell, energyLeft, energyFull, chargingCycle, currentCapacity, maxCapacity}) {
    var energyText = typeof(energyLeft) === 'undefined' ? "Energy left in the batteries: unavailable" : "Energy left in the batteries: " + energyLeft + " mJ";
    var maximumCapacityText = typeof(currentCapacity) === 'undefined' ? "Maximum capacity: unavailable" : "Maximum capacity: " + Number(currentCapacity)/Number(maxCapacity)*100 + " %";
    var chargingCycleText = typeof(chargingCycle) === 'undefined' ? "Number of charge cycles: unavailable" : "Number of charge cycles: " + chargingCycle; 
    var cellAvailable = typeof(cell) === 'undefined' ? ["unavailable", "unavailable", "unavailable", "unavailable"] : cell;
    return (
        <>
        <h1>Welcome to the Power page</h1>
        <Stage width={window.innerWidth} height={window.innerHeight*3/4}>
            <Layer>
                <Text x={50} y={70} text="Battery Status" fontSize={30} textDecoration="underline" fill="grey" />
                <Text x={50} y={120} text={energyText} fontSize={20} />
                <Battery x={50} y={180} width={100} height={200} batteryLevel={energyLeft/energyFull*100} children="Batteries" />
                <Text x={200} y={200} text={"Cell 1: " + cellAvailable[0] + " mV"} fontSize={20}/>
                <Text x={200} y={250} text={"Cell 2: " + cellAvailable[1] + " mV"} fontSize={20}/>
                <Text x={200} y={300} text={"Cell 3: " + cellAvailable[2] + " mV"} fontSize={20}/>
                <Text x={200} y={350} text={"Cell 4: " + cellAvailable[3] + " mV"} fontSize={20}/>
                <Text x={550} y={70} text="Battery Charging" fontSize={30} textDecoration="underline" fill="grey" />
                <Text x={550} y={120} text={chargingCycleText} fontSize={20} />
                <Text x={550} y={160} text="* The value indicates the number of charging cycles the battery has gone through in its lifespan." fontSize={15} />
                <Text x={550} y={220} text="Battery Health" fontSize={30} textDecoration="underline" fill="grey" />
                <Text x={550} y={270} text={maximumCapacityText} fontSize={20} />
                <Text x={550} y={310} text="* The value indicates the current battery capacity relative to when it was new." fontSize={15} />
            </Layer>
        </Stage>
        </>
    )
}

export default PowerSection;