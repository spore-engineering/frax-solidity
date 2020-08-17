pragma solidity ^0.6.0;

import "./Context.sol";
import "./IERC20.sol";
import "./frax.sol";
import "./SafeMath.sol";


contract FRAXShares is ERC20 {
    using SafeMath for uint256;
    string public symbol;
    uint8 public decimals = 18;
    address public FRAXStablecoinAdd;
    
    uint256 genesis_supply;
    uint256 maximum_supply; //no FXS can be minted under any condition past this number

    address owner_address;
    
    mapping(address => bool) public frax_pools; //same mapping and variable in FRAXStablecoin 
    
    address oracle_address;
    
    FRAXStablecoin FRAX;

    constructor(
    string memory _symbol, 
    uint256 _genesis_supply,
    uint256 _maximum_supply,
    address _owner_address)
    
    public 
    {
    symbol = _symbol;
    genesis_supply = _genesis_supply;
    maximum_supply = _maximum_supply; 
    owner_address = _owner_address;
    
    _mint(owner_address, genesis_supply);


}

    function setOracle(address new_oracle) public onlyByOracle {
        oracle_address = new_oracle;
    }
    
    function setFRAXAddress(address frax_contract_address) public onlyByOracle {
        FRAX = FRAXStablecoin(frax_contract_address);
    }

    function mint(address to, uint256 amount) public {
        require(frax_pools[msg.sender] == true);
        _mint(to, amount);
    }
    

    modifier onlyPools() {
       require(frax_pools[msg.sender] == true, "only frax pools can mint new FRAX");
        _;
    } 
    
    modifier onlyByOracle() {
        require(msg.sender == oracle_address, "you're not the oracle :p");
        _;
    }
    
    //this function is what other frax pools will call to mint new FXS (similar to the FRAX mint) 
    function pool_mint(address m_address, uint256 m_amount) public onlyPools {
        super._mint(m_address, m_amount);
    }
    
}
