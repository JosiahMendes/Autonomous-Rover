import React from 'react';
import './Textbox.css';

export const Textbox = ({id, children, className, name}) => {
    return (
        <>
            <label for={id} className={className}>
                {children}
            </label>
            <input type='text' id={id} name={name}></input>
        </>
    );
};