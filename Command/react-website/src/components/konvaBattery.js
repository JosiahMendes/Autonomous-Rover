import React from 'react';
import {Rect, Text} from 'react-konva';

export default function konvaBattery(props) {
    var batteryColor = 'transparent';
    var fillHeight;
    var fillStart;
    if(Number(props.batteryLevel) !== 0 && props.batteryLevel <= 7) {
        fillHeight = props.height*7/100;
        fillStart = props.y+props.height*(100-7)/100
    } else {
        fillHeight = props.height*props.batteryLevel/100;
        fillStart = props.y+props.height*(100-props.batteryLevel)/100;
    }
    if(props.batteryLevel <= 20) {
        batteryColor = 'red';
    } else {
        batteryColor = '#64dd17';
    }
    var description = props.children + ": " + props.batteryLevel + "%";
    return (
        <>
            <Rect x={props.x} y={fillStart} width={props.width} height={fillHeight} fill={batteryColor} strokeWidth={10} stroke="white"/>
            <Rect x={props.x+props.width/3} y={props.y-props.height/15} width={props.width/3} height={props.height/15} fill="black" />
            <Rect x={props.x} y={props.y} width={props.width} height={props.height} strokeWidth={10} stroke="black" />
            <Text text={description} fontSize={15} x={props.x-4} y={props.y+props.height + 30} />
        </>
    )
}