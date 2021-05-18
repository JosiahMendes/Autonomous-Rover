import React from 'react';
import { Route , Redirect } from 'react-router-dom';
import { useAuth } from "./auth";
//This is a router that can be used to redirect from one page to another

function PrivateRoute({ component: Component, ...rest }) {
    const [Authenticated,setAuthenticated] = useAuth();
    console.log(Authenticated,"came from private");
  return(
    <Route
      {...rest}
      render={props =>
        Authenticated==="true" ? (
          <Component {...props} />
        ) : (
          <Redirect to="/" />
        )
      }
    />
  );
}

export default PrivateRoute;