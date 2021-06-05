import React from 'react';
import './Textbox.css';

export const Textbox = ({id, children, className, name, onChange}) => {
    return (
        <>
            <label for={id} className={className}>
                {children}
            </label>
            <input type='number' id={id} name={name} onChange={onChange}></input>
        </>
    );
};