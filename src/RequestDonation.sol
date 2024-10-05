// SPDX-License-Identifier: MIT
pragma solidity ^0.8.25;

import "./DonationSBT.sol";

contract compagny {
    struct compagnyInfo {
        string CompagnyName;
        uint256 CompagnySIREN;
        uint256 RequestAmount;
        address CompagnyAddress;
    }
}

contract RequestDonation is compagny {
    uint256 public AmountPaid;
    DonationProofSBT public sbtContract;

    struct requestDonation {
        string ProjectName;
        string ProjectDescription;
        string ProjectQuote;
        uint256 ProjectAmount;
        uint256 CreationDate;
        uint256 LimiteDate;
        compagnyInfo[] Compagny;
    }

    requestDonation public requestdonation;

    mapping(address => uint256) public donorAddressToAmount;

    modifier onlyNotExcess() {
        require(msg.value + AmountPaid <= requestdonation.ProjectAmount, "Amount exceed the project amount");
        _;
    }

    event DonationMade(address indexed donor, uint256 amount, uint256 sbtTokenId);

    constructor(address _sbtContractAddress) {
        require(_sbtContractAddress != address(0), "Invalid SBT contract address");
        sbtContract = DonationProofSBT(_sbtContractAddress);
    }

    function createRequestDonation(
        string memory _ProjectName,
        string memory _ProjectDescription,
        string memory _ProjectQuote,
        uint256 _ProjectAmount,
        uint256 _CreationDate,
        uint256 _LimiteDate
    ) public {
        requestdonation.ProjectName = _ProjectName;
        requestdonation.ProjectDescription = _ProjectDescription;
        requestdonation.ProjectQuote = _ProjectQuote;
        requestdonation.ProjectAmount = _ProjectAmount;
        requestdonation.CreationDate = _CreationDate;
        requestdonation.LimiteDate = _LimiteDate;
    }

    function addCompagny(
        string memory _CompagnyName,
        uint256 _CompagnySIREN,
        uint256 _RequestAmount,
        address _CompagnyAddress
    ) public {
        requestdonation.Compagny.push(
            compagnyInfo(
                _CompagnyName,
                _CompagnySIREN,
                _RequestAmount,
                _CompagnyAddress
            )
        );
    }

    function getRequestDonationInfo()
        public
        view
        returns (
            string memory ProjectName,
            string memory ProjectDescription,
            string memory ProjectQuote,
            uint256 ProjectAmount,
            uint256 CreationDate,
            uint256 LimiteDate,
            compagnyInfo[] memory Companies
        )
    {
        return (
            requestdonation.ProjectName,
            requestdonation.ProjectDescription,
            requestdonation.ProjectQuote,
            requestdonation.ProjectAmount,
            requestdonation.CreationDate,
            requestdonation.LimiteDate,
            requestdonation.Compagny
        );
    }

    function getCompagnylength() public view returns(uint256) {
        return requestdonation.Compagny.length;
    }

    function donate() public payable onlyNotExcess() {
        AmountPaid += msg.value;
        donorAddressToAmount[msg.sender] += msg.value;

        uint256 sbtTokenId = sbtContract.mint(msg.sender, msg.value, address(this), block.number);

        emit DonationMade(msg.sender, msg.value, sbtTokenId);
    }

    function setSBTContract(address _newSBTContract) public {
        require(_newSBTContract != address(0), "Invalid SBT contract address");
        sbtContract = DonationProofSBT(_newSBTContract);
    }
}

contract FactoryRequestDonation is compagny {
    uint256 public id;
    address public sbtContractAddress;

    mapping(uint256 => compagnyInfo) public SIRENToCompagny;
    mapping(uint256 => RequestDonation) public idToRequestDonation;

    event RequestDonationCreated(uint256 indexed id, address requestDonationAddress);

    constructor(address _sbtContractAddress) {
        require(_sbtContractAddress != address(0), "Invalid SBT contract address");
        sbtContractAddress = _sbtContractAddress;
    }

    modifier onlyNotRegister(uint256 _CompagnySIREN) {
        require(
            SIRENToCompagny[_CompagnySIREN].CompagnySIREN == 0,
            "Compagny already register"
        );
        _;
    }

    function getNbCompagny(uint256 _id) public view returns(uint256) {
        return (idToRequestDonation[_id].getCompagnylength());
    }

    function createCompagny(
        string memory _CompagnyName,
        uint256 _CompagnySIREN,
        uint256 _RequestAmount,
        address _CompagnyAddress
    ) public onlyNotRegister(_CompagnySIREN) {
        SIRENToCompagny[_CompagnySIREN] = compagnyInfo(
            _CompagnyName,
            _CompagnySIREN,
            _RequestAmount,
            _CompagnyAddress
        );
    }

    function createRequestDonation(
        string memory _ProjectName,
        string memory _ProjectDescription,
        string memory _ProjectQuote,
        uint256 _ProjectAmount,
        uint256 _CreationDate,
        uint256 _LimiteDate
    ) public {
        RequestDonation requestDonation = new RequestDonation(sbtContractAddress);
        requestDonation.createRequestDonation(
            _ProjectName,
            _ProjectDescription,
            _ProjectQuote,
            _ProjectAmount,
            _CreationDate,
            _LimiteDate
        );
        idToRequestDonation[id] = requestDonation;
        emit RequestDonationCreated(id, address(requestDonation));
        id++;
    }

    function addCompagnyToRequestDonation(uint256 _SIREN, uint256 _id) public {
        idToRequestDonation[_id].addCompagny(
            SIRENToCompagny[_SIREN].CompagnyName,
            SIRENToCompagny[_SIREN].CompagnySIREN,
            SIRENToCompagny[_SIREN].RequestAmount,
            SIRENToCompagny[_SIREN].CompagnyAddress
        );
    }

    function getRequestDonation(
        uint256 _id
    )
        public
        view
        returns (
            string memory ProjectName,
            string memory ProjectDescription,
            string memory ProjectQuote,
            uint256 ProjectAmount,
            uint256 CreationDate,
            uint256 LimiteDate,
            compagnyInfo[] memory Companies
        )
    {
        return idToRequestDonation[_id].getRequestDonationInfo();
    }

    function setSBTContractAddress(address _newSBTContractAddress) public {
        require(_newSBTContractAddress != address(0), "Invalid SBT contract address");
        sbtContractAddress = _newSBTContractAddress;
    }

    function getSBTContractAddress() public view returns (address) {
        return sbtContractAddress;
    }
}