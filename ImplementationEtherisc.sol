pragma solidity 0.5.2;

// import Etherisc dependencies
//import "@etherisc/gif/contracts/Product.sol";
import "browser/Product.sol";

contract EarthquakeInsurance is Product {

//   Callable logs printed to EVM console accessed by emit()
  event LogRequestUnderwriter(uint256 applicationId);
  event LogApplicationUnderwritten(uint256 applicationId, uint256 policyId);
  event LogApplicationDeclined(uint256 applicationId);
  event LogRequestClaimsManager(uint256 policyId, uint256 claimId);
  event LogClaimDeclined(uint256 claimId);
  event LogRequestPayout(uint256 payoutId);
  event LogPayout(uint256 claimId, uint256 amount);
 
 //  Sets the names for the constructor
  bytes32 public constant NAME = "EarthquakeInsurance";
  bytes32 public constant POLICY_FLOW = "PolicyFlowDefault";
    uint public RiskScore;
    uint public ClaimScore;
    address addr;
    
// Defines risk doesn't have to be a struct I guess ???? 
  struct Risk {
    bytes32 Lat;
    bytes32 Lon;
    uint256 RiskScore;
  }
// Risks mapped don't know if it's needed now the Risk struct is usseless ????
  mapping(bytes32 => Risk) public risks;

// Launches product to etherisc if address is accepted with the following names
  constructor(address _productService)
    public
    Product(_productService, NAME, POLICY_FLOW) {}

// Request premium
// Caller towards query
    function setRiskScore(address addr, string memory _Lat, string memory _Lon) public {
        RiskAssessment c = RiskAssessment(addr);
        c.RiskCalculationQuery(_Lat, _Lon);
        //return c.getRiskScore();
    }
    
    // Needs time 5 min (I know it's to slow)
    function getRiskScore(address addr) public returns (uint){
        RiskAssessment c = RiskAssessment(addr);
        RiskScore = c.getRiskScore();
    }
    
// calculate premium for the customer by multiplying Coverage and RiskScore
function getQuote(uint256 _RiskScore, uint256 _Coverage) public pure returns (uint256 _premium) {
    require(_RiskScore > 0, "ERROR::INVALID PRICE");
    // Needs some refining
    _premium = _RiskScore.mul(_Coverage);
    _premium = _premium.div(100);
  }

// Application for the policy
function applyForPolicy(
  bytes32 _Lat,
  bytes32 _Lon,
  uint256 _RiskScore,
  uint256 _Coverage,
  uint256 _premium,
  bytes32 _currency,
  bytes32 _bpExternalKey
)external onlySandbox {
  require(_premium > 0, "ERROR:INVALID_PREMIUM");
  require(getQuote(_RiskScore, _Coverage) == _premium, "ERROR::INVALID_PREMIUM");

bytes32 riskId = keccak256(abi.encodePacked(_Lat,_Lon,_RiskScore));
  risks[riskId] = Risk(_Lat,_Lon,_RiskScore);

// Coverage is the pay-out coverage
uint256[] memory payoutOptions = new uint256[](1);
// (_Coverage) might not be workig due to the order in which functions are called as ClaimScore is still 0.
  payoutOptions[0] = ClaimScore.mul(_Coverage);

uint256 applicationId = _newApplication(_bpExternalKey, _premium, _currency, payoutOptions);

emit LogRequestUnderwriter(applicationId);
}

// Sandbox functions for demo.
function underwriteApplication(uint256 _applicationId) external onlySandbox 
{
  uint256 policyId = _underwrite(_applicationId);

emit LogApplicationUnderwritten(_applicationId, policyId);
}

function declineApplication(uint256 _applicationId) external onlySandbox {
  _decline(_applicationId);

emit LogApplicationDeclined(_applicationId);
}

// Pref created by oracle trigger.
function createClaim(uint256 _policyId) external onlySandbox {
  uint256 claimId = _newClaim(_policyId);

emit LogRequestClaimsManager(_policyId, claimId);
}
/// Claim interface for the caller / query contract
    function getClaimScore(address addr) public returns (uint){
        ClaimVerification c = ClaimVerification(addr);
         RiskScore = c.getClaimScore();
    }
    
    function setClaimScore(address addr, string memory _Lat, string memory _Lon) public {
        ClaimVerification c = ClaimVerification(addr);
        c.ClaimCalculationQuery(_Lat, _Lon);
        //return c.getRiskScore();
    }

// manually comformation?!??!?!
function confirmClaim(uint256 _applicationId, uint256 _claimId) external onlySandbox {
  uint256[] memory payoutOptions = _getPayoutOptions(_applicationId);
  uint256 payoutId = _confirmClaim(_claimId, payoutOptions[0]);

emit LogRequestPayout(payoutId);
}

// Same here needs to be automised by Oracle (although a second check would not be a bad idea)
function confirmPayout(uint256 _claimId, uint256 _amount) external
 onlySandbox {
  _payout(_claimId, _amount);

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