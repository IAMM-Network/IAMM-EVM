const { expect } = require("chai");

describe("Claim Verifier", function () {
  let UserIdentity, ClaimIssuer, ClaimVerifier
  let addr1, addr2, addr3, addr4
  let prvSigner, pubSigner


  before(async function() {
    [addr1, addr2, addr3, addr4] = await ethers.getSigners()

    //Create randomeHex of 32 bytes to generate a Private Key
    prvSigner = web3.utils.randomHex(32)
    //From the previous PrivateKey generate a new Account and then use the address acount
    pubSigner = web3.eth.accounts.privateKeyToAccount(prvSigner).address

    //Import ClaimHolderABI
    const ClaimHolderABI = await ethers.getContractFactory("ClaimHolder")
    //Import ClaimVerifierABI
    const ClaimVerifierABI = await ethers.getContractFactory("ClaimVerifier")

    /**
     * Deployments
     * - Deploy
     * - Wait for deployment in order to get Address
     */
    //User identity - ClaimHolder
    UserIdentity = await ClaimHolderABI.connect(addr1).deploy()
    await UserIdentity.deployed()

    //ClaimIssuer - ClaimHolder
    ClaimIssuer = await ClaimHolderABI.connect(addr2).deploy()
    await ClaimIssuer.deployed()

    //ClaimVerifier - ClaimVerifier (This is the contract that has the business logic and it trust on Claim Issuer)
    // This needs the claim Issuer address in the constructor when contract is created 
    ClaimVerifier = await ClaimVerifierABI.connect(addr3).deploy(
      String(ClaimIssuer.address)
    )
    await ClaimVerifier.deployed()
  })

  it('should new wallets access to collector-profile', async function() {
    
  })

  it('should allow verifier owner to addKey', async function() {
    //Hash key content - in this case the address derivated from the prvSigner
    const key = web3.utils.sha3(
      String(pubSigner)
    )

    //Add key to verifier called from the verifier owner
    await ClaimIssuer.connect(addr2).addKey(key, 3, 1)

    //Check that the key was added
    const keyCreated = await ClaimIssuer.getKey(key)
    
    expect(Number(keyCreated.purpose)).to.be.equal(3)
    expect(Number(keyCreated.keyType)).to.be.equal(1)
    expect(String(keyCreated.key)).to.be.equal(key)
  })

  it('should not allow new listing without identity claim', async function() {
    //Check if User has a valid PROFILE_CREATOR claim
    const res = await ClaimVerifier.connect(addr1).checkClaim(UserIdentity.address, 7)
    expect(res).to.be.equal(false)
  })

  it('should allow identity owner to addClaim', async function() {
    //Get HEX of a given message
    const data = web3.utils.asciiToHex('Verified OK')

    const claimType = 5 // PROFILE_CREATOR
    //Get hash of the data (User Address, Claim-Type, data parsed to HEX)
    const hashed = web3.utils.soliditySha3(UserIdentity.address, claimType, data)
    //Sign the hashed data with the privateKey
    const signed = await web3.eth.accounts.sign(hashed, prvSigner)

    await expect(
      UserIdentity
        .connect(addr1)
        .addClaim(
          claimType,
          2,
          ClaimIssuer.address,
          signed.signature,
          data,
          'iamm.com'
        )).to.emit(UserIdentity, "ClaimAdded")
  })

  it('should not allow new listing without identity claim', async function() {
    const res = await ClaimVerifier
      .connect(addr1)
      .checkClaim(UserIdentity.address, 3)
    
    expect(res).to.be.equal(false)
  })
})