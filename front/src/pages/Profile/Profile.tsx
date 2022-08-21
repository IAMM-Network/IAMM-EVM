import { useContext, useEffect, useState, useCallback } from 'react'
import { Flex, Grid } from '../../components/Box'
import { Button } from '../../components/Button'
import { Container } from '../../components/Layout'
import { TitleSection, Title, Description, BoxOption } from './styles'
import Header from './components/Header'
import Menu from './components/Menu'
import { Context } from '../../contexts/UserProfile'
import Web3 from 'web3'
import constants from '../../constants'
import ClaimVerifierABI from "../../contracts/ClaimVerifier.json"
import EthereumProvider from "@walletconnect/ethereum-provider"
import { WalletUtil } from '../../util/walletUtil'
import { SignClient } from '@walletconnect/sign-client'

const CreatorImage = require('../../assets/images/profile/profile-creator.png')
const BuilderImage = require('../../assets/images/profile/profile-builder.png')
const CuratorImage = require('../../assets/images/profile/profile-curator.png')
const CollectorImage = require('../../assets/images/profile/profile-collector.png')


const options = [
  {
    image: CreatorImage,
    description: 'Creator',
  },
  {
    image: BuilderImage,
    description: 'Builder',
  },
  {
    image: CuratorImage,
    description: 'Curator',
  },
  {
    image: CollectorImage,
    description: 'Collector',
  },
]

const Profile: React.FC = () => {
  // Check if is the first time a user opens dashboard
  const [isFirstTime, setIsFirstTime] = useState(true)
  const [activeBox, setActiveBox] = useState(0)
  const [actualProcess, setActualProcess] = useState("1")

  const {userAddress} = useContext(Context)

  const getProcessMsg = (process:string) => {
    const options = ["Choose", "Creating Profile...", "Add profile"]

    return (options[Number(process)] && options[Number(process)]) || "Choose"
  }

  const loadClaimVerifierCall = useCallback(async () => {
    const client = await SignClient.init({
      projectId: WalletUtil.projectId,
      metadata: {
          name: "IAMM - (Polygon - WalletConnect) 🚀",
          description: "Building libre and creative economies through impact meta-markets",
          url: "www.iamm.network",
          icons: ["https://iamm.network/static/media/iamm-home.ed82176cc59e1f880bfb.png"],
      },
  });
    const web3 = new Web3()
    
    const claimVerifier = new web3.eth.Contract(JSON.parse(JSON.stringify(ClaimVerifierABI.abi)), constants.CONTRACT_CLAIM_VERIFIER)

    const isAClaimVerifier = await claimVerifier.methods.getERC725At(userAddress).call()

    if (isAClaimVerifier.length <= 0) {
      //Set Profile
      console.log(isAClaimVerifier)
    }
    setActualProcess("1")
  }, [userAddress])

  useEffect(() => {
    loadClaimVerifierCall()
  }, [loadClaimVerifierCall])

  // If first time is true return that
  return !!isFirstTime ? (
    <>
      <Header title='Welcome' />
      <Container maxWidth='90%'>
        <Flex flexDirection='column' paddingTop='2rem'>
          <TitleSection>
            <Title>PROFILES for:</Title>
            <Description>{userAddress && userAddress}</Description>
          </TitleSection>

          <Grid gridTemplateColumns='repeat(2, 1fr)' gridTemplateRows='repeat(2, 1fr)' gridColumnGap='1rem' gridRowGap='1rem'>
            {options.map(({ description, image }, index) => (
              <BoxOption key={description+"-"+String(index)} active={index === activeBox} onClick={() => setActiveBox(index)}>
                {<img src={image} alt={description} height='auto' width='auto' />}
                {description}
              </BoxOption>
            ))}
          </Grid>

          <Flex justifyContent='center' marginTop='3rem' marginBottom='6rem'>
            <Button variant='cta'>{getProcessMsg(actualProcess).toUpperCase()}</Button>
          </Flex>
        </Flex>
      </Container>
      <Menu />
    </>
  ) : (
    <div>Next steps</div>
  )
}

export default Profile
