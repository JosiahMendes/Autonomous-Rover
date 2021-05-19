import { BrowserRouter as Router, Switch, Route, Link } from 'react-router-dom';
import App from './App'
import Login from './login'
import PrivateRoute from './PrivateRoute'
import { AuthContext } from "./auth";
import React, { useState } from "react"
//Here is the Main component that connects the Login page with the App

function Main (props){
        const [Authenticated,setAuthenticated] = useState("false");

  
        return (
            <AuthContext.Provider value={[Authenticated,setAuthenticated]}>
                <Router>
                    <Switch>
                    
                    
                    <Route exact path='/' component={Login}/>
                <PrivateRoute exact path='/app' component = {App} />
                    </Switch>
                </Router>
            </AuthContext.Provider>
            
        );
    
}

export default Main;