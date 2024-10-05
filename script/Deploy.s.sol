// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.25;

import "forge-std/Script.sol";
import "../src/DonationProofSBT.sol";
import "../src/RequestDonation.sol";

contract DeployScript is Script {
    function setUp() public {}

    function run() public {
        uint256 deployerPrivateKey = vm.envUint("PRIVATE_KEY");
        vm.startBroadcast(deployerPrivateKey);

        DonationProofSBT sbt = new DonationProofSBT();
        RequestDonation requestDonation = new RequestDonation(address(sbt));

        vm.stopBroadcast();
    }
}