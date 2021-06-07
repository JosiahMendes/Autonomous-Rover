import React from 'react';
import Battery from './konvaBattery';
import {Stage, Layer, Text} from 'react-konva';

function PowerSection({batteryLevel, energyLeft, maximumCapacity, chargingSpeed, voltageToCharge}) {
    var energyText = typeof(energyLeft) === 'undefined' ? "Energy left: unavailable" : "Energy left: " + energyLeft + " J";
    var maximumCapacityText = typeof(maximumCapacity) === 'undefined' ? "Maximum capacity: unavailable" : "Maximum capacity: " + maximumCapacity + " %";
    var chargingSpeedText = typeof(chargingSpeed) === 'undefined' ? "Charging speed: unavailable" : "Charging speed: " + chargingSpeed;
    var chargingTimeText = (typeof(chargingSpeed) === 'undefined' || typeof(voltageToCharge) === 'undefined') ? "Estimated charging time: unavailable" : "Estimated charging time: " + voltageToCharge/chargingSpeed;
    return (
        <>
        <h1>Welcome to the Power page</h1>
        <Stage width={window.innerWidth} height={window.innerHeight*3/4}>
            <Layer>
                <Text x={50} y={10} text={energyText} fontSize={20} fill="grey" />
                <Text x={50} y={70} text="Battery Status" fontSize={30} textDecoration="underline" fill="grey" />
                <Battery x={50} y={150} width={100} height={200} batteryLevel={batteryLevel[0]} children="Cell 1"/>
                <Battery x={200} y={150} width={100} height={200} batteryLevel={batteryLevel[1]} children="Cell 2"/>
                <Battery x={350} y={150} width={100} height={200} batteryLevel={batteryLevel[2]} children="Cell 3"/>
                <Battery x={500} y={150} width={100} height={200} batteryLevel={batteryLevel[3]} children="Cell 4"/>
                <Text x={700} y={70} text="Battery Charging" fontSize={30} textDecoration="underline" fill="grey" />
                <Text x={700} y={120} text={chargingSpeedText} fontSize={20} />
                <Text x={700} y={160} text={chargingTimeText} fontSize={20} />
                <Text x={700} y={220} text="Battery Health" fontSize={30} textDecoration="underline" fill="grey" />
                <Text x={700} y={270} text={maximumCapacityText} fontSize={20} />
                <Text x={700} y={310} text="* The value indicates the current battery capacity relative to when it was new." fontSize={15} />
            </Layer>
        </Stage>
        </>
    )
}

export default PowerSection;