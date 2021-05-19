import { createContext, useContext } from 'react';

export const AuthContext = createContext();
//not important
export function useAuth() {
  return useContext(AuthContext);
}