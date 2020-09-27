pragma solidity 0.5.2;

// import dependencies
import "browser/Ownable.sol";
import "browser/SafeMath.sol";

contract EarthquakeInsurance is Ownable {
    using SafeMath for uint256;
    using SafeMath for bytes32;

//   Callable logs printed to EVM console accessed by emit()
  // event LogRiskScore(uint256 RiskScore);
  // event LogRequestQuote(_premium);
  event LogRequestUnderwriter(bytes32 applicationId);
  event LogApplicationUnderwritten(bytes32 applicationId, bytes32 policyId);
  event LogApplicationDeclined(bytes32 applicationId);
  event LogRequestClaimsManager(bytes32 policyId, bytes32 claimId);
  event LogClaimDeclined(bytes32 claimId);
  event LogRequestPayout(bytes32 payoutId);
  event LogPayout(bytes32 claimId, uint256 amount);
 
 //  Sets the names for the constructor
 //   bytes32 public constant NAME = "EarthquakeInsurance";
//    bytes32 public constant POLICY_FLOW = "PolicyFlowDefault";
    address addrRisk =  0xcb2777CB31de9Ba9F6B398a26884D8d33E309834;
    address addrClaim = 0xa02e29c92D864E1967ECe47A386D264e0B66387F;
    
    address addrApplicant;
    uint public RiskScore;
    uint public ClaimScore;    
//    bytes32 public payoutOptions;

// Launches product to etherisc if address is accepted with the following names
  constructor() public {}
// Request premium--------------------------------------------------------------------------------------------------------------------------------------
// transactions 
    function withdraw(uint256 amount) public {
        msg.sender.transfer(amount);
    }

    function deposit(uint256 amount) payable public {
        require(msg.value == amount);
    }
// Caller towards query: 


function setRiskScore(string memory _Lat, string memory _Lon) public returns(uint) {
    RiskAssessment c = RiskAssessment(addrRisk);
    c.RiskCalculationQuery(_Lat, _Lon);
    return c.getRiskScore();
    }
    
// Time needed to perform query and provide RiskScore via callback function. Should be handled in the interface due to computation cost. Might not be safe tho .... 
// calculate premium for the customer by multiplying Coverage and RiskScore
function getQuote(uint256 _Coverage) public returns (uint256 _premium) {
    RiskAssessment c = RiskAssessment(addrRisk);
    RiskScore = c.getRiskScore();
    require(RiskScore > 0, "ERROR::INVALID RISKSCORE");
//    emit LogRiskScore(RiskScore);
    
    // Needs some refining
    _premium = _Coverage.mul(RiskScore);
    _premium = _premium.div(1000);
    require(_premium > 0, "ERROR::INVALID PREMIUM PRICE");
    //emit LogRequestQuote(_premium);
  }


// Application policy--------------------------------------------------------------------------------------------------------------------------------------
function applyForPolicy (
  uint256 _Coverage,
  uint256 _premium
) payable external {
  require(_premium > 0, "ERROR:INVALID_PREMIUM");
  require(getQuote(_Coverage) == _premium, "ERROR::INVALID_PREMIUM");
//  require(msg.value == _premium);

uint256[] memory payoutOptions = new uint256[](1);
    payoutOptions[0] = _Coverage;
    
    deposit(_premium);
    addrApplicant = msg.sender;

// expiration = now + duration;

bytes32 applicationId = keccak256(abi.encodePacked(RiskScore, _Coverage, _premium, payoutOptions));

emit LogRequestUnderwriter(applicationId);
}

// Sandbox functions for demo.
function underwriteApplication(bytes32 _applicationId) external onlyOwner {
  require(_applicationId != 0);
  bytes32 policyId = keccak256(abi.encodePacked(_applicationId));
  //uint256 underwrite = 1;

emit LogApplicationUnderwritten(_applicationId, policyId);
}

function declineApplication(bytes32 _applicationId) external onlyOwner {
  require(_applicationId != 0);
  //uint256 underwrite = 0;

emit LogApplicationDeclined(_applicationId);
}

// Cancel 
//    function kill() public {
//        require(msg.sender == owner);
//        selfdestruct(msg.sender);
//    }

//Claims handeling--------------------------------------------------------------------------------------------------------------------------------------
function setClaimScore(string memory _Lat, string memory _Lon) public {
    ClaimVerification c = ClaimVerification(addrClaim);
    c.ClaimCalculationQuery(_Lat, _Lon);
    }

// Pref created by oracle trigger.
function createClaim(bytes32 _policyId) external {
  require(_policyId != 0);
  ClaimVerification c = ClaimVerification(addrClaim);
  ClaimScore = c.getClaimScore();
  
  require(ClaimScore > 0, "ERROR::INVALID CLAIM");
  bytes32 claimId = keccak256(abi.encodePacked(_policyId));

emit LogRequestClaimsManager(_policyId, claimId);
}

// Automatic verification 
function confirmClaim(bytes32 _applicationId, bytes32 _claimId) external onlyOwner{
  require(_applicationId != 0);
  require(ClaimScore > 0);
     bytes32 payoutId = keccak256(abi.encodePacked(_claimId));
     emit LogRequestPayout(payoutId);
}

// Same here needs to be automised by Oracle (although a second check would not be a bad idea)
function confirmPayout(bytes32 _claimId, uint256 _amount) external onlyOwner{
require(_claimId != 0);
require(address(this).balance == _amount);
withdraw(_amount);
emit LogPayout(_claimId, _amount);
}
}

contract RiskAssessment {
    function getRiskScore() public returns(uint);
    function RiskCalculationQuery(string memory _Lat, string memory _Lon) public;
}

contract ClaimVerification {
    function getClaimScore() public returns(uint);
    function ClaimCalculationQuery(string memory _Lat, string memory _Lon) public;
}