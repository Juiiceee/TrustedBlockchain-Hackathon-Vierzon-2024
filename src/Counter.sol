// SPDX-License-Identifier: MIT
pragma solidity ^0.8.25;

contract RequestDonation {
    struct compagny {
        string CompagnyName;
        uint256 CompagnySIREN;
        uint256 RequestAmount;
        address CompagnyAddress;
    }

    struct requestDonation {
        string ProjectName;
        string ProjectDescription;
        string ProjectQuote;
        uint256 ProjectAmount;
        uint256 CreationDate;
        uint256 LimiteDate;
        compagny[] Compagny;
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
            compagny(
                _CompagnyName,
                _CompagnySIREN,
                _RequestAmount,
                _CompagnyAddress
            )
        );
    }
}

contract FactoryRequestDonation {
    uint256 public id;

    struct compagny {
        string CompagnyName;
        uint256 CompagnySIREN;
        uint256 RequestAmount;
        address CompagnyAddress;
    }

    mapping(uint256 => compagny) public SIRENToCompagny;
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
        SIRENToCompagny[_CompagnySIREN] = compagny(
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

}
