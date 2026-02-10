// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

contract RealEstateContract {

    // --------------- Variables ---------------

    address public admin;
    uint256 public propertyCounter;
    uint256 public leaseCounter;

    // --------------- Structs ---------------

    struct Property {
        uint256 id;
        string propertyAddress;
        address payable owner;
        uint256 price;
        bool forSale;
        bool exists;
        uint256 registrationDate;
    }

    struct LeaseAgreement {
        uint256 id;
        uint256 propertyId;
        address payable landlord;
        address payable tenant;
        uint256 monthlyRent;
        uint256 securityDeposit;
        uint256 leaseStart;
        uint256 leaseEnd;
        uint256 lastPaymentDate;
        bool active;
        bool depositReturned;
    }

    // --------------- Mappings ---------------

    mapping(uint256 => Property) public properties;
    mapping(uint256 => LeaseAgreement) public leases;
    mapping(address => uint256[]) public ownerProperties;
    mapping(address => uint256[]) public tenantLeases;

    // --------------- Events ---------------

    event PropertyRegistered(uint256 indexed propertyId, address indexed owner, string propertyAddress);
    event PropertyListed(uint256 indexed propertyId, uint256 price);
    event PropertyUnlisted(uint256 indexed propertyId);
    event PropertySold(uint256 indexed propertyId, address indexed from, address indexed to, uint256 price);
    
    event LeaseCreated(uint256 indexed leaseId, uint256 indexed propertyId, address indexed tenant, uint256 monthlyRent);
    event RentPaid(uint256 indexed leaseId, address indexed tenant, uint256 amount, uint256 paymentDate);
    event LeaseTerminated(uint256 indexed leaseId);
    event DepositReturned(uint256 indexed leaseId, address indexed tenant, uint256 amount);
    
    // --------------- Modifiers ---------------

    modifier onlyAdmin() {
        require(msg.sender == admin, "Only admin can call this function");
        _;
    }
modifier onlyPropertyOwner(uint256 _propertyId) {
        require(properties[_propertyId].owner == msg.sender, "Not the property owner");
        _;
    }
    
    modifier propertyExists(uint256 _propertyId) {
        require(properties[_propertyId].exists, "Property does not exist");
        _;
    }
    
    modifier leaseExists(uint256 _leaseId) {
        require(leases[_leaseId].active, "Lease does not exist or is inactive");
        _;
    }

    // --------------- Constructors ---------------

    constructor() {
        admin = msg.sender;
    }

    // --------------- Property Transaction Functions ---------------

    function registerProperty(string memory _propertyAddress, uint256 _price) external returns (uint256) {
        propertyCounter++;
        
        properties[propertyCounter] = Property({
            id: propertyCounter,
            propertyAddress: _propertyAddress,
            owner: payable(msg.sender),
            price: _price,
            forSale: false,
            exists: true,
            registrationDate: block.timestamp
        });
        
        ownerProperties[msg.sender].push(propertyCounter);
        
        emit PropertyRegistered(propertyCounter, msg.sender, _propertyAddress);
        
        return propertyCounter;
    }

    function listPropertyForSale(uint256 _propertyId, uint256 _price) external propertyExists(_propertyId) onlyPropertyOwner(_propertyId) {
        require(_price > 0, "Price must be greater than 0");
        
        properties[_propertyId].price = _price;
        properties[_propertyId].forSale = true;
        
        emit PropertyListed(_propertyId, _price);
    }

    function unlistProperty(uint256 _propertyId) external propertyExists(_propertyId) onlyPropertyOwner(_propertyId) {
        properties[_propertyId].forSale = false;
        
        emit PropertyUnlisted(_propertyId);
    }

    function purchaseProperty(uint256 _propertyId) external payable propertyExists(_propertyId) {
        Property storage property = properties[_propertyId];
        
        require(property.forSale, "Property is not for sale");
        require(msg.value == property.price, "Incorrect payment amount");
        require(msg.sender != property.owner, "Owner cannot buy their own property");
        
        address payable previousOwner = property.owner;
        
        // Transfer ownership
        property.owner = payable(msg.sender);
        property.forSale = false;
        
        // Update owner mappings
        ownerProperties[msg.sender].push(_propertyId);
        
        // Transfer funds to previous owner
        previousOwner.transfer(msg.value);
        
        emit PropertySold(_propertyId, previousOwner, msg.sender, msg.value);
    }

    // --------------- Lease Agreement Functions ---------------

    function createLease(
        uint256 _propertyId,
        address payable _tenant,
        uint256 _monthlyRent,
        uint256 _securityDeposit,
        uint256 _leaseDurationMonths
    ) external payable propertyExists(_propertyId) onlyPropertyOwner(_propertyId) {
        require(_tenant != address(0), "Invalid tenant address");
        require(_monthlyRent > 0, "Rent must be greater than 0");
        require(_leaseDurationMonths > 0, "Lease duration must be greater than 0");
        require(!properties[_propertyId].forSale, "Property is listed for sale");
        
        leaseCounter++;
        
        uint256 leaseEnd = block.timestamp + (_leaseDurationMonths * 30 days);
        
        leases[leaseCounter] = LeaseAgreement({
            id: leaseCounter,
            propertyId: _propertyId,
            landlord: payable(msg.sender),
            tenant: _tenant,
            monthlyRent: _monthlyRent,
            securityDeposit: _securityDeposit,
            leaseStart: block.timestamp,
            leaseEnd: leaseEnd,
            lastPaymentDate: 0,
            active: true,
            depositReturned: false
        });
        
        tenantLeases[_tenant].push(leaseCounter);
        
        emit LeaseCreated(leaseCounter, _propertyId, _tenant, _monthlyRent);
    }

    function payRent(uint256 _leaseId) external payable leaseExists(_leaseId) {
        LeaseAgreement storage lease = leases[_leaseId];
        
        require(msg.sender == lease.tenant, "Only tenant can pay rent");
        require(block.timestamp <= lease.leaseEnd, "Lease has expired");
        require(msg.value == lease.monthlyRent, "Incorrect rent amount");
        
        lease.lastPaymentDate = block.timestamp;
        
        // Transfer rent to landlord
        lease.landlord.transfer(msg.value);
        
        emit RentPaid(_leaseId, msg.sender, msg.value, block.timestamp);
    }

    function paySecurityDeposit(uint256 _leaseId) external payable leaseExists(_leaseId) {
        LeaseAgreement storage lease = leases[_leaseId];
        
        require(msg.sender == lease.tenant, "Only tenant can pay deposit");
        require(msg.value == lease.securityDeposit, "Incorrect deposit amount");
        
        // Deposit is held in contract
    }

    function terminateLease(uint256 _leaseId) external leaseExists(_leaseId) {
        LeaseAgreement storage lease = leases[_leaseId];
        
        require(msg.sender == lease.landlord || msg.sender == lease.tenant, "Only landlord or tenant can terminate");
        
        lease.active = false;
        
        emit LeaseTerminated(_leaseId);
    }

    function returnDeposit(uint256 _leaseId) external {
        LeaseAgreement storage lease = leases[_leaseId];
        
        require(msg.sender == lease.landlord, "Only landlord can return deposit");
        require(!lease.active, "Lease is still active");
        require(!lease.depositReturned, "Deposit already returned");
        require(address(this).balance >= lease.securityDeposit, "Insufficient contract balance");
        
        lease.depositReturned = true;
        
        lease.tenant.transfer(lease.securityDeposit);
        
        emit DepositReturned(_leaseId, lease.tenant, lease.securityDeposit);
    }

    // --------------- View Functions ---------------

    function getProperty(uint256 _propertyId) external view propertyExists(_propertyId) returns (Property memory) {
        return properties[_propertyId];
    }

    function getPropertiesByOwner(address _owner) external view returns (uint256[] memory) {
        return ownerProperties[_owner];
    }
    
    function getLease(uint256 _leaseId) external view returns (LeaseAgreement memory) {
        return leases[_leaseId];
    }

    function getLeasesByTenant(address _tenant) external view returns (uint256[] memory) {
        return tenantLeases[_tenant];
    }

    function getContractBalance() external view returns (uint256) {
        return address(this).balance;
    }

    function verifyOwnership(uint256 _propertyId, address _claimedOwner) external view propertyExists(_propertyId) returns (bool) {
        return properties[_propertyId].owner == _claimedOwner;
    }
}