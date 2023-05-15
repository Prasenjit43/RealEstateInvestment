const RealEstateInvestment = artifacts.require("RealEstateInvestment");
const RealEstateToken = artifacts.require("RealEstateToken");
const chai = require('chai');
const BN = require('bn.js');

// Enable and inject BN dependency
chai.use(require('chai-bn')(BN));

contract("RealEstateInvestment", (accounts) => {
    const contractDeployer = accounts[0];
    const properyLister_01 = accounts[1];
    const investor_01 = accounts[2];
    const investor_02 = accounts[3];
    const investor_03 = accounts[4];
    const investor_04 = accounts[5];
    const properyLister_02 = accounts[6];

    const tenant_01 = accounts[8];
    const tenant_02 = accounts[8];

    let realEstateInvestmentContract;

    before(async () => {
        realEstateInvestmentContract = await RealEstateInvestment.deployed();
    });

    describe("Contract Deployement", () => {
        it("Should Deploy RealEstateInvestment Smart Contract", async () => {
            assert(realEstateInvestmentContract.address != "");
        });
    });

    describe("Raise Funding", () => {
        it("List First Property ", async () => {
            await realEstateInvestmentContract.listPropertyByOwner(
                web3.utils.toWei('1', 'ether'), 
                web3.utils.toWei('2', 'ether'),
                30,
                "TEST 01",
                "TST1",
                4,
                { from: properyLister_01 }
            );
            const property_01_details = await realEstateInvestmentContract.properties(0);
            expect(property_01_details.token).to.not.equal("");
            expect((property_01_details.minimumInvestmentInEther).toString()).to.equal(web3.utils.toWei('1', 'ether').toString());
            expect((property_01_details.maximumInvestmentInEther).toString()).to.equal(web3.utils.toWei('2', 'ether').toString());
            expect((property_01_details.openForInvertors).toNumber()).to.equal(30);
            expect(property_01_details.propertyOwner).to.equal(properyLister_01);
            expect((property_01_details.totalFundRaised).toNumber()).to.equal(0);
            expect((property_01_details.ICOCutOffPeriod).toNumber()).to.not.equal(0);

            const tokenContract = await RealEstateToken.at(property_01_details.token);
            expect(await tokenContract.name()).to.equal("TEST 01");
            expect(await tokenContract.symbol()).to.equal("TST1");
            expect((await tokenContract.totalSupply()).toString()).to.equal((4*(Math.pow(10,18))).toString());   
        });
    });


    describe("Invest in Property", () => {
        it("First Investor invested successfully ", async () => {
            await realEstateInvestmentContract.investInProperty(
                0,
                web3.utils.toWei('1', 'ether'),
                {   from: investor_01,
                    value : web3.utils.toWei('1', 'ether'), 
                }
            );
            const property_01_details = await realEstateInvestmentContract.properties(0);
            expect((property_01_details.totalFundRaised).toString()).to.equal(web3.utils.toWei('1', 'ether').toString());

        });

        it("Claim token before enddate - throw error ", async () => {
            try {
                await realEstateInvestmentContract.claimToken(0,{from: investor_01});
            } 
            catch (error) {
                if (error.message.includes("Investment raising is going on")) {
                    return;
                }
                throw error;
            }
        });    

        it("Waiting for investment to be complated ", async () => {
            await new Promise((resolve) => setTimeout(resolve, 11000)); // Wait for 1 second before checking again
        });

        it("Claim token after enddate - minimum investment completed", async () => {
            try {
                const receipt = await realEstateInvestmentContract.claimToken(0,{from: investor_01});
                // Get the logs from the receipt
                const logs = receipt.logs;

                // Find the emitted event in the logs
                const myEvent = logs.find((log) => log.event === "TokenClaimLog");

                // Assert that the event was emitted
                assert.exists(myEvent, "MyEvent should have been emitted");
                // Assert the value emitted in the event
                assert.equal(myEvent.args._msg.toString(),"Token claimed successfully", "Incorrect value emitted");

            } 
            catch (error) {
                throw error;
            }
            const property_01_details = await realEstateInvestmentContract.properties(0);
            const tokenContract = await RealEstateToken.at(property_01_details.token);
            const etherbalInTokenContract = await web3.eth.getBalance(property_01_details.token); 
            const tokenbalOfInvestor01 = await tokenContract.balanceOf(investor_01);
            const tokenbalOfBaseContract  = await tokenContract.balanceOf(realEstateInvestmentContract.address);
            expect(tokenbalOfInvestor01.toString()).to.equal((1*(Math.pow(10,18))).toString());
            expect(tokenbalOfBaseContract.toString()).to.equal((3*(Math.pow(10,18))).toString());
            expect(etherbalInTokenContract.toString()).to.equal(web3.utils.toWei('1', 'ether').toString());

        });    
    });


    describe("Deposit & Withdrawl", () => {
        it("Deposit Rent ", async () => {
            const property_01_details = await realEstateInvestmentContract.properties(0);
            const tokenContract = await RealEstateToken.at(property_01_details.token);
            const etherBalInTokenContract_before = await web3.eth.getBalance(property_01_details.token); 
            const receipt = await realEstateInvestmentContract.depositRent(
                0,
                {   from: tenant_01,
                    value : web3.utils.toWei('5', 'ether'), 
                }
            );
            let etherBalInTokenContract_after = await web3.eth.getBalance(property_01_details.token); 
            let tempCal = etherBalInTokenContract_after - web3.utils.toWei('5', 'ether');
            expect(etherBalInTokenContract_before.toString()).to.equal(tempCal.toString());
        });   
        
        it("Withdraw Dividend ", async () => {
            const property_01_details = await realEstateInvestmentContract.properties(0);
            const tokenContract = await RealEstateToken.at(property_01_details.token);
            const etherBalInTokenContract_before = await web3.eth.getBalance(property_01_details.token); 
            const etherBalOfInvestor_01_before = await web3.eth.getBalance(investor_01); 
            const dividendPerToken = (await tokenContract.dividendPerToken.call()).toNumber();
            await realEstateInvestmentContract.withDrawDividend(
                0,
                {   from: investor_01
                }
            );
            let etherBalOfInvestor_01_after = await web3.eth.getBalance(investor_01); 
            let etherBalInTokenContract_after = await web3.eth.getBalance(property_01_details.token);
            const dividendInEther = (await tokenContract.balanceOf(investor_01)) * dividendPerToken;
            expect((etherBalInTokenContract_before-dividendInEther).toString()).to.equal(etherBalInTokenContract_after.toString());
        });   
    });
}
);