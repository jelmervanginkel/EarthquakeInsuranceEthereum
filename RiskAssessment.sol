pragma solidity ^0.5;
import "./contracts/provableAPI.sol";

contract RiskAssessment is usingProvable {
    // User input 
    string Lat;
    string Lon;
    uint public RiskScore;

    event LogNewOraclizeQuery(string description);
    event calculationResult(uint _result);

    // Interaction with Caller contract
    function getRiskScore() view public returns(uint) {
        return RiskScore;
    }
    
    // Returns RiskScore of query
    function __callback(bytes32 myid, string memory result, bytes memory proof) public {
        require (msg.sender == provable_cbAddress());
        emit calculationResult(parseInt(result));
        RiskScore = parseInt(result);
    }
    
    // Sends query to Provable
    function RiskCalculationQuery(string memory _Lat, string memory _Lon) payable public {
        provable_setProof(proofType_TLSNotary | proofStorage_IPFS);
        if (provable.getPrice("computation") > address(this).balance) {
            emit LogNewOraclizeQuery("Provable query was NOT sent, please add some ETH to cover for the query fee");
        } else {
            emit LogNewOraclizeQuery("Provable query was sent, standing by for the answer..");
            provable_query("computation",["Qmb4kYSAHJgBFwMQekihpTn7cjiGxnZbzRvbN8t9RZ57k8",
            _Lat,
            _Lon]);
        }
    }
}