// SPDX-License-Identifier: MIT
pragma solidity ^0.8.25;

contract compagny {
    struct compagnyInfo {
        string CompagnyName;
        uint256 CompagnySIREN;
        uint256 RequestAmount;
        address CompagnyAddress;
    }
}

contract RequestDonation is compagny {
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
}

contract FactoryRequestDonation is compagny {
    uint256 public id;

    mapping(uint256 => compagnyInfo) public SIRENToCompagny;
    mapping(address => uint256) public donorAddressToAmount;
    mapping(uint256 => RequestDonation) public idToRequestDonation;

    modifier onlyNotRegister(uint256 _CompagnySIREN) {
        require(
            SIRENToCompagny[_CompagnySIREN].CompagnySIREN == 0,
            "Compagny already register"
        );
        _;
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
        RequestDonation requestDonation = new RequestDonation();
        requestDonation.createRequestDonation(
            _ProjectName,
            _ProjectDescription,
            _ProjectQuote,
            _ProjectAmount,
            _CreationDate,
            _LimiteDate
        );
        idToRequestDonation[id] = requestDonation;
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
}
