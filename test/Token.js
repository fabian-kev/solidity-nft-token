const { assert } = require("chai");

const Token = artifacts.require("Token");

// Start a test series named DevToken, it will use 10 test accounts 



contract("Galaxy Token", async accounts => {
    // each it is a new test, and we name our first test initial supply
    const owner = accounts[0];
    const EMPTY_ADDRESS = '0x0000000000000000000000000000000000000000';
    const TOTAL_SUPPLY = 500000 * 10**8;
    const MAX_SUPPLY = 1000000 * 10**8;
    function loadTokenContract(){
        return Token.deployed("Galaxy", "GAL", 8, 500000 * 10**8, 1000000 * 10**8);
    }

    it("All constructor parameters should match", async() => {
        const token = await loadTokenContract();

        const owner = await token.owner();

        assert(owner, accounts[0], "Owner of this token should equal to account 0")
    })

    it("All construtor parameters must match", async() => {
        const token = await loadTokenContract();


        const name = await token.name();
        const symbol = await token.symbol();
        const totalSupply = await token.totalSupply();
        const maxSupply = await token.maxSupply();

        assert(name, "Galaxy", "Token name is not matched");
        assert(symbol,"GAL", "Symbol is not matched");
        assert(totalSupply, TOTAL_SUPPLY, "Max supply is not matched");
        assert(maxSupply, MAX_SUPPLY, "Max supply is not matched");

    })


    it("Initial supply should match the supplied in the constructor", async () => {
        const token = await loadTokenContract();
        // wait until devtoken is deplyoed, store the results inside devToken
        // the result is a client to the Smart contract api
        // call our totalSUpply function
        let supply = await token.totalSupply()
        // Assert that the supply matches what we set in migration
        assert.equal(supply.toNumber(), 500000 * 10**8, "Initial supply was not the same as in migration")
        
    });

    it("minting", async() => {
        const token = await loadTokenContract();

        let intial_balance = await token.balanceOf(accounts[1]);

        assert.equal(intial_balance.toNumber(), 0, "intial balance for account 1 should be 0")

        let totalSupply = await token.totalSupply();
        const mintAmount = 4000;
        const account1 = accounts[1];
        await token.mint(account1, mintAmount);

        let afterBalance = await token.balanceOf(account1);
        let afterTotalSupply = await token.totalSupply();

        assert.equal(afterBalance.toNumber(), mintAmount, "The balance after minting 100 should be 100")
        assert.equal(afterTotalSupply.toNumber(), totalSupply.toNumber()+mintAmount, "The totalSupply should have been increasesd")

        try {
            await token.mint(EMPTY_ADDRESS, 100);
        } catch(error){
            assert.equal(error.reason, "Empty address is not allowed", "Failed to stop minting on zero address")
        }
        try {
            await token.mint(account1, 100);
        } catch(error){
            assert.equal(error.reason, "You've reached the max supply", "Failed to stop minting on over total supply")
        }
        
    });

    it("burn", async() => {
        const token = await loadTokenContract();


        const account = accounts[1];
        let initialBalance = await token.balanceOf(account);
    

        try{
            await token.burn(EMPTY_ADDRESS, 100);
        }catch(error){
            assert.equal(error.reason, "Empty address is not allowed", "Failed to notice burning on 0 address")
        }


        try {
            await token.burn(account, initialBalance+500);
        } catch(error){
            assert.equal(error.reason, "Cannot burn more than the account owns", "Failed to capture too big burns on an account")
        }

        let totalSupply = await token.totalSupply();
        try {
            await token.burn(account, 50);
        }catch(error){
            assert.fail(error);
        }

        let balance = await token.balanceOf(account);
           // Make sure balance was reduced and that totalSupply reduced
        assert.equal(balance.toNumber(), initialBalance-50, "Burning 50 should reduce users balance")


        let newSupply = await token.totalSupply();
        assert.equal(newSupply.toNumber(), totalSupply.toNumber()-50, "Total supply not properly reduced")

    })


    it("transferring tokens", async() => {
        const token = await loadTokenContract();



        const account = accounts[1];
        // const recipient = accounts[2];
        let initialBalance = await token.balanceOf(account);

        
        // transfer tokens from account 0 to 1 
        await token.transfer(account, 100);

        let afterBalance = await token.balanceOf(account);
        assert.equal(afterBalance.toNumber(), initialBalance.toNumber()+100, "Balance should have increased on reciever")


        let account2_initial_balance = await token.balanceOf(accounts[2]);

        await token.transfer(accounts[2], 20, {from: account});

        let account2_after_balance = await token.balanceOf(accounts[2]);
        let account1_after_balance = await token.balanceOf(account);

        
        assert.equal(account1_after_balance.toNumber(), afterBalance.toNumber()-20, "Should have reduced account 1 balance by 20");
        assert.equal(account2_after_balance.toNumber(), account2_initial_balance.toNumber()+20, "Should have given account 2 20 tokens");
    

    })

    it ("allow account some allowance", async() => { 
        const token = await loadTokenContract();


        try{
            // Give account(0) access too 100 tokens on creator
            await token.approve(EMPTY_ADDRESS, 100);    
        }catch(error){
            assert.equal(error.reason, 'DevToken: approve cannot be to zero address', "Should be able to approve zero address");
        }
        

        try{
            // Give account 1 access to 100 tokens on zero account
            await token.approve(accounts[1], 100, {from: accounts[0]});    
        }catch(error){
            assert.fail(error); // shold not fail
        }

        let allowance = await token.allowance(accounts[0], accounts[1]);
        assert.equal(allowance.toNumber(), 100, "Allowance was not correctly inserted");

    });

    it("transfering with allowance", async() => {
        const token = await loadTokenContract();

        let init_allowance = await token.allowance(accounts[0], accounts[1]);
        try{
            // Account 1 should have 100 tokens by now to use on account 0 
            // lets try using more 
            //1 spender
            //2 receiver
            //3 amount
            //4 account used
            let success = await token.transferFrom(accounts[0], accounts[2], init_allowance+10, { from: accounts[1] } );
            //should not success
            assert.equal(success, false, 'transferFrom should should return false or throw an exception')
        } catch(error){
            assert.equal(error.reason, "You cannot spend that much on this account", "Failed to detect overspending")
        }
        init_allowance = await token.allowance(accounts[0], accounts[1]);
        console.log("init balalnce: ", init_allowance.toNumber())


        try{
            // Account 1 should have 100 tokens by now to use on account 0 
            // lets try using more 
            let worked = await token.transferFrom(accounts[0], accounts[2], 50, {from:accounts[1]});
        }catch(error){
            assert.fail(error);
        }


        let allowance = await token.allowance(accounts[0], accounts[1]);
    
        assert.equal(allowance.toNumber(), init_allowance - 50, "The allowance should have been decreased by 50")
    });

});

