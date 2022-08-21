import React, { createContext, useState } from 'react'
import { UserProfileContextProps } from './types'


export const Context = createContext<UserProfileContextProps>({
  userAddress: "",
  isConnected: false,
  isCollector: false,
  walletConnectSession: null,
  setUserAddress: () => null,
  setIsCollector: () => null,
  setIsConnected: () => null,
  setWalletConnectSession: () => null,
})

const UserProfileContext: React.FC = ({ children }) => {
  const [walletConnectSession, setWalletConnectSession] = useState<any>({})
  const [userAddress, setUserAddress] = useState('0x0')
  const [isConnected, setIsConnected] = useState(false)
  const [isCollector, setIsCollector] = useState(false)

  //This function checks if a user address has a smart contract stored in our Verifier contract
  const checkRegister = ()=> null

  const onConnect = (addr?:string) => {
    setIsConnected(true)
    if (addr) setUserAddress(addr)
  }

  //This function disconnects from WalletConnect
  const onDisconnect = () => null

  return (
    <Context.Provider
      value={{
        walletConnectSession,
        userAddress,
        isConnected,
        isCollector,
        setUserAddress,
        setIsCollector,
        setIsConnected,
        setWalletConnectSession,
      }}
    >
      {children}
    </Context.Provider>
  )
}

export default UserProfileContext;
