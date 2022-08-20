const { expect } = require("chai");

describe('Identity', async function() {
    let ClaimHodlerABI, UserIdentity
    let acctSha3
    let addr1, addr2, addr3, addr4

    before(async function () {
        //get 4 accounts
        [addr1, addr2, addr3, addr4] = await ethers.getSigners()

        //Get ClaimHolder ABI
        const ClaimHolderABI = await ethers.getContractFactory("ClaimHolder")

        //Deploy ClaimHolder
        UserIdentity = await ClaimHolderABI.deploy()
        await UserIdentity.deployed()
        
        //Get the sha3 of the address of first account
        acctSha3 = web3.utils.keccak256(addr1.address)
    })

    describe('Pre-Auth Identity', async function() {
        it('should deploy successfully', async function() {
            //Get Identity ABI
            const IdentityABI = await ethers.getContractFactory("Identity")

            //Generate random sig, data and url of 10 digits each one
            const sig = web3.utils.randomHex(10)
            const data = web3.utils.randomHex(10)
            const url = "1234567890"

            //Deloy Identity from addr1 with
            // 8 = PROFILE_COLLECTOR
            // 3th Schema
            //issuer of the identity
            //sign data
            //data
            //url
            //sized of the las 3 parameters
            const deployedIdentity = await IdentityABI.connect(addr1).deploy([8], [3], [addr1.address], sig, data, url, [10], [10], [10])
            await deployedIdentity.deployed()
            
            expect(deployedIdentity.address).to.be.a("string")
        })
    })    

    describe('Keys', async function() {
        it('should set a default MANAGEMENT_KEY', async function() {
            const res = await UserIdentity.getKey(acctSha3)

            expect(Number(res.purpose)).to.be.equal(1)
            expect(Number(res.keyType)).to.be.equal(1)
            expect(String(res.key)).to.be.equal(acctSha3)
        })

        it('should respond to getKeyPurpose', async function() {
            const res = await UserIdentity.getKeyPurpose(acctSha3)
            expect(Number(res)).to.be.equal(1)
        })
        it('should respond to getKeysByPurpose', async function() {
            const res = await UserIdentity.getKeysByPurpose(1)
            expect(res[0]).to.be.equal(acctSha3)
        })
      
        it('should implement addKey', async function() {
            const newKey = web3.utils.randomHex(32)
            await expect(UserIdentity.addKey(newKey, 1, 1)).to.emit(UserIdentity, "KeyAdded")
      
            const getKey = await UserIdentity.getKey(newKey)
            expect(String(getKey.key)).to.be.equal(newKey)
        })
      
        it('should not allow an existing key to be added', async function() {
            await expect(UserIdentity.addKey(acctSha3, 1, 1)).to.be.revertedWith("Key already exists")
        })
    })
})
