import React, {useState, useEffect} from 'react';
import { Link } from 'react-router-dom';
import './Navbar.css';
import {Button} from './Button';

function Navbar() {
    const [click, setClick] = useState(false);
    const [button, setButton] = useState(true);

    const handleClick = () => setClick(!click);
    const closeMobileMenu = () => {
        setClick(false);
    };

    const showButton = () => {
        if(window.innerWidth <= 960) {
            setButton(false);
        } else {
            setButton(true);
        }
    };

    useEffect(() => {
        showButton();
    }, []);

    window.addEventListener('resize', showButton);

    return (
        <>
            <nav className ="navbar">
                <div className ="navbar-container">
                    <Link to="/" className="navbar-logo" onClick={closeMobileMenu}>
                        Group 1 <i className="fab fa-typo3" />
                    </Link>
                    <div classname="menu-icon" onClick={handleClick}>
                        <i className={click ? 'fas fa-times' : 'fas fa-bars'} />
                    </div>
                    <ul className={click ? 'nav-menu active' : 'nav-menu'}>
                        <li className='nav-item'>
                            <Link to='/' className='nav-links' onClick={closeMobileMenu}>
                                Home
                            </Link>
                        </li>
                        <li className='nav-item'>
                            <Link to='/power' className='nav-links' onClick={closeMobileMenu}>
                                Power
                            </Link>
                        </li>
                        <li className='nav-item'>
                            <Link to='/view' className='nav-links' onClick={closeMobileMenu}>
                                View
                            </Link>
                        </li>
                        <li className='nav-item'>
                            <Link to='/commands' className='nav-links-mobile' onClick={closeMobileMenu}>
                                Commands
                            </Link>
                        </li>
                    </ul>
                    {button && 
                    <Button buttonStyle='btn--outline'>
                        <Link to='/commands' className='nav-links' onClick={closeMobileMenu}>
                            Commands
                        </Link>
                    </Button>}
                </div>
            </nav>
        </>
    );
}

export default Navbar;