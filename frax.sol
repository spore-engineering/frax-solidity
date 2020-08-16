pragma solidity ^0.6.0;

import "./Context.sol";
import "./IERC20.sol";
import "./SafeMath.sol";
import "./fxs.sol";




contract FRAXStablecoin is ERC20 {
    using SafeMath for uint256;
    string public symbol;
    uint8 public decimals = 18;
    address[] public owners;
    uint256 ownerCount; //number of different addresses that hold FRAX
    mapping(address => uint256) public balances;

    
    //an array of frax pool addresses for future use
    //the addresses in this array are added by the oracle and these contracts are able to mint frax
    address[] frax_pools_array;

    //mapping is also used for faster verification
    mapping(address => bool) public frax_pools; 
    
    mapping(address => uint256) public pool_prices;
    //add frax hop and backstep contracts here and other future monetary policy contracts 
    mapping(address => bool) public frax_monetary_policy_contracts;

    

    uint256 public FRAX_price; //6 decimals of precision
    uint256 public FXS_price; //6 decimals of precision
    uint256 public global_collateral_ratio; //6 decimals of precision, e.g. 924102 = 0.924102
    address oracle_address; //this is the address that can change the FRAX and FXS price
    uint256 public redemption_fee;
    uint256 public minting_fee;
    
    uint256 FRAX_amount;
    uint256 FXS_amount;

    
    FRAXShares FXS;
    
    ERC20 collateral_token;


    modifier onlyMonPol() {
       require(frax_monetary_policy_contracts[msg.sender] = true, "only frax expansion-retraction contracts can use this!");
        _;
    } 
     
    modifier onlyPools() {
       require(frax_pools[msg.sender] = true, "only frax pools can mint new FRAX");
        _;
    } 
    
    
    modifier onlyByOracle() {
        require(msg.sender == oracle_address, "you're not the oracle :p");
        _;
    }
    
    constructor(
    string memory _symbol, 
    address _oracle_address) 
    public 
    {
    symbol = _symbol;
    oracle_address = _oracle_address;
}

    //public implementation of internal _mint()
    function mint(uint256 amount) public virtual onlyMonPol {
        _mint(msg.sender, amount);
    }

    //used by pools when user redeems1t1
    function poolBurn(uint256 amount) public onlyPools {
        _burn(tx.origin,amount);
    }

    //adds collateral addresses supported, such as tether and busd, must be ERC20 
    function setNewPool(address pool_address) public onlyByOracle {
        frax_pools[pool_address] = true; 
        frax_pools_array.push(pool_address);
    }

    //adds the monetary policy contracts, hop, backstep etc 
    function setMonetaryPolicyContract(address con_address) public onlyByOracle {
        frax_monetary_policy_contracts[con_address] = true; 
    }



    // the updated price must be within 10% of the old price
    // this is to prevent accidental mispricings 
    // a change of greater than 10% requires multiple transactions
    //need to create this logic
    
    //whenever the oracle sets the price, the historical amount of FRAX and FXS should be logged in plaintext
    event mintFRAX(uint256 FRAX_amount, uint256 FXS_amount);
    function setPrices(uint256 FRAX_p,uint256 FXS_p) public onlyByOracle {

        FRAX_amount = totalSupply();
        FXS_amount = FXS.totalSupply();
        
        FRAX_price = FRAX_p;
        FXS_price = FXS_p;
        emit mintFRAX(FRAX_amount, FXS_amount); 
    }
    
    function setFXSAddress(address FXS_contract_address) public onlyByOracle {
        FXS = FRAXShares(FXS_contract_address);
    }
    
    function setGlobalCollateralRatio(uint256 coll_ra) public onlyByOracle {
        require(coll_ra < 1000000, "collateral ratio must have 6 decimals of precision and never go above 0.999999");
        global_collateral_ratio = coll_ra;
    }

    function setOracle(address new_oracle) public onlyByOracle {
        oracle_address = new_oracle;
    }

    function setRedemptionFee(uint256 red_fee) public onlyByOracle {
        redemption_fee = red_fee;
    }

    function setMintingFee(uint256 mint_fee) public onlyByOracle {
        minting_fee = mint_fee;
    }

    
    function n_collateral_ratio() public view returns (uint256) {
        return  collateral_token.balanceOf(address(this)).div(totalSupply());
        
    }
    
    
    
    //this function is what other frax pools will call to mint new FRAX 
    function pool_mint(address m_address, uint256 m_amount) public onlyPools {
        super._mint(m_address, m_amount);
    }
    


    
}
