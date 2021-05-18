import React, { useState, useContext } from "react";
import socket from './socket';
import { BrowserRouter as Router, Switch, Route, Link } from 'react-router-dom';
import App from './App'
import { Redirect } from "react-router-dom";
import axios from 'axios';
import {useAuth } from "./auth";
import Card from '@material-ui/core/Card';
import CardActions from '@material-ui/core/CardActions';
import CardContent from '@material-ui/core/CardContent';
import Button from '@material-ui/core/Button';
import TextField from '@material-ui/core/TextField';
import { makeStyles } from '@material-ui/core/styles';
import Grid from '@material-ui/core/Grid';
import { sizing } from '@material-ui/system';
//This is the login page code. Here because I followed a guide I treated the page as a function rather than a class. It is basically the same thing though but different syntax
const useStyles = makeStyles({
    root: {
      minWidth: 50,
    },
    bullet: {
      display: 'inline-block',
      margin: '0 2px',
      transform: 'scale(0.8)',
    },
    title: {
      fontSize: 14,
    },
    pos: {
      marginBottom: 12,
    },
  });

function Login(props){
    const [isLoggedIn, setLoggedIn] = useAuth();
   
    // const isLoggedIn = false;
    const [isError, setIsError] = useState(false);
    const [userName, setUserName] = useState("");
    const [password, setPassword] = useState("");
    const classes = useStyles();
    console.log(isLoggedIn);
    function postLogin() {
       socket.emit("authentication", {
         user: userName,
         pass: password
       })
      }
      socket.on("authenticated",(result)=>{
            if(result === "true")
            {
              setLoggedIn("true");
             
            }
            
      })
      if (isLoggedIn === "true") {
            // window.localStorage.setItem('user', userName);
            console.log("I can redirect")
            return (<Redirect to={{
            pathname:  '/app',
            state: {user: userName}

            }} />);
        
      }
        return ( 
            <Card className= {classes.root} maxWidth={1/4} >
                <CardContent width="25%">
                    
                    <Grid container spacing={1} alignItems="center"  direction="column" justify="center" width={1/4} >
                    <Grid  item xs={0} spacing={0} allignContent = '| center'>
                      <img src="indigital.png" />
                    </Grid>
                        <Grid  item xs={0} spacing={0} allignContent = '| center'>
                            <TextField id="outlined-basic" label="username" variant="outlined" onChange={e => {setUserName(e.target.value); }} />
                        </Grid>
                        <Grid  item xs={0} spacing={3} allignContent = 'center'>
                            <TextField id="outlined-basic" label="password" variant="outlined"  type="password" onChange={e => {setPassword(e.target.value); }} />
                        </Grid>
                        <Grid  item xs={0} spacing={3} allignItems = 'center'>
                            <Button variant="contained" onClick={()=>{
                              
                             postLogin();
                             
                              
                              }} >Sign in</Button>
                        </Grid>
                    </Grid>
                </CardContent>
               
            </Card>
            
        );
        
}

export default Login;