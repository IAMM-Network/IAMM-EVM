import { useCallback, useEffect, useState } from "react";
import Web3 from "web3"
import {AbiItem} from "web3-utils";
import constants from "../constants";

const useContractInstance = (abi:AbiItem, address:string) => {
    const [contractInstance, setConstractInstance] = useState<any>()

    const loadContract = useCallback(async () => {
        //Instance of web3
        const web3 = new Web3(constants.ALCHEMY_URI);

        //Contract Instance
        const Contract = new web3.eth.Contract(abi, address);
        setConstractInstance(Contract)
    }, [abi, address])

    useEffect(() => {
        loadContract();
    }, [loadContract])

    return {contractInstance};
}

export default useContractInstance;
