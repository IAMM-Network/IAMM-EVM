import { FC, useEffect, useContext } from 'react'
import { useLocation, useNavigate } from 'react-router-dom'
import { Flex, Grid } from '../../components/Box'
import { HomeWrapper, Title, HeadText, HeadImage } from './styles'
import { Container } from '../../components/Layout'

import { Button } from '../../components/Button'
import { WalletConnectIcon } from '../../components/Svg'
import { WalletUtil } from '../../util/walletUtil'
import { Context } from '../../contexts/UserProfile'

const IAMMGradientIcon = require('../../assets/images/iamm-home.png')

const Home: FC = () => {
  const location = useLocation()
  const navigate = useNavigate()
  const {isConnected, isCollector, setIsConnected, setUserAddress, setWalletConnectSession} = useContext(Context)

  useEffect(() => {
    // Check if user is connected to WalletConnect
    if(isConnected && isCollector && location.pathname === '/') navigate('/create-single-nft')
    //If user is not collector, then redirect to /profile-dashboard and initialize the profile (transaction logics)
    if (isConnected && !isCollector && location.pathname === '/') navigate('/profile-dashboard')
  }, [isConnected, location, navigate, isCollector])

  const onAuth = () => {
    WalletUtil.connectWallet(setIsConnected, setUserAddress, setWalletConnectSession)
  }

  return (
    <HomeWrapper>
      <Container>
        <Grid alignItems='end' justifyContent='center' marginBottom='-24px'>
          <Title>Create, collect, mix & pimp – libreNFT</Title>
        </Grid>
        <Grid alignItems='center' justifyContent='center'>
          <HeadImage width={280} src={IAMMGradientIcon} alt='IAMM-3d-gradient-icon' />
          <Flex justifySelf="center">
            <Button startIcon={<WalletConnectIcon fill="#8B40F4" />}  onClick={onAuth}>Connect Your Wallet</Button>
          </Flex>
        </Grid>
        <Grid alignItems='start' justifyContent='center' marginTop='32px'>
          <HeadText>Building libre and creative economies through impact meta-markets</HeadText>
        </Grid>
      </Container>
    </HomeWrapper>
  )
}

export default Home
