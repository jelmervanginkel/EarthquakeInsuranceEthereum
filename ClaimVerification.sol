pragma solidity ^0.5;
import "./contracts/provableAPI.sol";

contract ClaimVerification is usingProvable {
    // User input
    string Lat;
    string Lon;
    uint public ClaimScore;

    event LogNewOraclizeQuery(string description);
    event calculationResult(uint _result);
    
    // Interaction with Caller contract
    function getClaimScore() view public returns(uint) {
        return ClaimScore;
    }

    // Returns RiskScore of query 
    function __callback(bytes32 myid, string memory result, bytes memory proof) public {
        require (msg.sender == provable_cbAddress());
        emit calculationResult(parseInt(result));
        ClaimScore = parseInt(result);
    }
    
        // Sends query to Provable
    function ClaimCalculationQuery(string memory _Lat, string memory _Lon) payable public {
        provable_setProof(proofType_TLSNotary | proofStorage_IPFS);
        if (provable.getPrice("computation") > address(this).balance) {
            emit LogNewOraclizeQuery("Provable query was NOT sent, please add some ETH to cover for the query fee");
        } else {
            emit LogNewOraclizeQuery("Provable query was sent, standing by for the answer..");
            provable_query("computation",["QmQEpCpx23bLKG7YRJT5fE5ymr2nRvCnvj6KP9GocqUiRY",
            _Lat,
            _Lon]);
        }
    }
}