import React from 'react'

export type Handler = () => void

export interface PopupContextProps {
  isOpen: boolean
  nodeId: string
  modalNode: React.ReactNode
  setModalNode: React.Dispatch<React.SetStateAction<React.ReactNode>>
  onPresent: (node: React.ReactNode, newNodeId: string) => void
  onDismiss: Handler
  setCloseOnOverlayClick: React.Dispatch<React.SetStateAction<boolean>>
}


export interface UserProfileContextProps {
  userAddress: string;
  isConnected: boolean;
  isCollector: boolean;
  walletConnectSession: any;
  setUserAddress: React.Dispatch<React.SetStateAction<string>>;
  setIsConnected: React.Dispatch<React.SetStateAction<boolean>>;
  setIsCollector: React.Dispatch<React.SetStateAction<boolean>>;
  setWalletConnectSession: React.Dispatch<React.SetStateAction<any>>;
}