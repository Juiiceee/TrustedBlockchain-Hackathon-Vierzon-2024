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

contract State{
		enum Status {
		cancelled,
		ongoing,
		completed
	}
}

contract RequestDonation is compagny, State {
    uint256 public AmountPaid;

    struct Location {
        string Longitude;
        string Latitude;
    }

    struct requestDonation {
        string ProjectName;
        string ProjectDescription;
        string ProjectQuote;
        string ProjectImage;
        uint256 ProjectAmount;
        uint256 CreationDate;
        uint256 LimiteDate;
        compagnyInfo[] Compagny;
        Location location;
		Status status;
    }

    requestDonation public requestdonation;

    mapping(address => uint256) public donorAddressToAmount;

    modifier onlyNotExcess() {
        require(
            msg.value + AmountPaid <= requestdonation.ProjectAmount,
            "Amount exceed the project amount"
        );
        _;
    }

    function createRequestDonation(
        string memory _ProjectName,
        string memory _ProjectDescription,
        string memory _ProjectQuote,
        string memory _ProjectImage,
        uint256 _ProjectAmount,
        uint256 _LimiteDate,
        string memory _Longitude,
        string memory _Latitude
    ) public {
        requestdonation.ProjectName = _ProjectName;
        requestdonation.ProjectDescription = _ProjectDescription;
        requestdonation.ProjectQuote = _ProjectQuote;
        requestdonation.ProjectQuote = _ProjectImage;
        requestdonation.ProjectAmount = _ProjectAmount;
        requestdonation.CreationDate = block.timestamp;
        requestdonation.LimiteDate = _LimiteDate;
        requestdonation.location = Location(_Longitude, _Latitude);
		requestdonation.status = Status.ongoing;
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
            string memory ProjectImage,
            uint256 ProjectAmount,
			uint256 alreadypaid,
			address RequestAdress,
            uint256 CreationDate,
            uint256 LimiteDate,
            compagnyInfo[] memory Companies,
            string memory Longitude,
            string memory Latitude,
			Status status
        )
    {
        return (
            requestdonation.ProjectName,
            requestdonation.ProjectDescription,
            requestdonation.ProjectQuote,
            requestdonation.ProjectImage,
            requestdonation.ProjectAmount,
			AmountPaid,
			address(this),
            requestdonation.CreationDate,
            requestdonation.LimiteDate,
            requestdonation.Compagny,
            requestdonation.location.Longitude,
            requestdonation.location.Latitude,
			requestdonation.status
        );
    }

    function getCompagnylength() public view returns (uint256) {
        return requestdonation.Compagny.length;
    }

    function donate() public payable onlyNotExcess {
        AmountPaid += msg.value;
        donorAddressToAmount[msg.sender] += msg.value;
        if (AmountPaid == requestdonation.ProjectAmount) {
            sendDonationToCompagny();
        }
    }

    function sendDonationToCompagny() public {
        for (uint256 i = 0; i < getCompagnylength(); i++) {
            payable(requestdonation.Compagny[i].CompagnyAddress).transfer(
                (requestdonation.Compagny[i].RequestAmount * 98) / 100
            );
        }
        payable(address(0x3e0892d280D1225c6774E3C7608349f6F896cc8C)).transfer(
            address(this).balance
        );
		requestdonation.status = Status.completed;
    }
}

contract FactoryRequestDonation is compagny, State {
    uint256 public id;

    mapping(uint256 => compagnyInfo) public SIRENToCompagny;
    mapping(uint256 => RequestDonation) public idToRequestDonation;

    modifier onlyNotRegister(uint256 _CompagnySIREN) {
        require(
            SIRENToCompagny[_CompagnySIREN].CompagnySIREN == 0,
            "Compagny already register"
        );
        _;
    }

    function getNbCompagny(uint256 _id) public view returns (uint256) {
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
            _RequestAmount * 1 ether,
            _CompagnyAddress
        );
    }

    function createRequestDonation(
        string memory _ProjectName,
        string memory _ProjectDescription,
        string memory _ProjectQuote,
        string memory _ProjectImage,
        uint256 _ProjectAmount,
        uint256 _LimiteDate,
        string memory _Longitude,
        string memory _Latitude
    ) public {
        RequestDonation requestDonation = new RequestDonation();
        requestDonation.createRequestDonation(
            _ProjectName,
            _ProjectDescription,
            _ProjectQuote,
            _ProjectImage,
            _ProjectAmount * 1 ether,
            _LimiteDate,
            _Longitude,
            _Latitude
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
            string memory ProjectImage,
            uint256 ProjectAmount,
			uint256 alreadypaid,
			address RequestAdress,
            uint256 CreationDate,
            uint256 LimiteDate,
            compagnyInfo[] memory Companies,
            string memory Longitude,
            string memory Latitude,
			Status status
        )
    {
        return idToRequestDonation[_id].getRequestDonationInfo();
    }
}
