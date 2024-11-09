//SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract BikeChain {
    address owner;

    constructor() {
        owner = msg.sender;
    }

    //Add yourself as a Renter.

    struct Renter {
        address payable walletAddress;
        string firstName;
        string lastName;
        bool canRent;
        bool active;
        uint balance;
        uint due;
        uint start;
        uint end;
    }
    mapping(address => Renter) public renters;

    function addRenter(
        address payable walletAddress,
        string memory firstName,
        string memory lastName,
        bool canRent,
        bool active,
        uint balance,
        uint due,
        uint start,
        uint end
    ) public {
        renters[walletAddress] = Renter(
            walletAddress,
            firstName,
            lastName,
            canRent,
            active,
            balance,
            due,
            start,
            end
        );
    }

    //Checkout Bike

    function checkOut(address walletAddress) public {
        require(renters[walletAddress].due == 0, "You have a pending Balance.");
        require(
            renters[walletAddress].canRent == true,
            "You cannot rent at this time."
        );
        renters[walletAddress].active = true;
        renters[walletAddress].start = block.timestamp;
        renters[walletAddress].canRent = false;
    }

    //Checkin a Bike

    function checkIn(address walletAddress) public {
        require(
            renters[walletAddress].active == true,
            "Please check out a bike first"
        );
        renters[walletAddress].active = false;
        renters[walletAddress].end = block.timestamp;
        setDue(walletAddress);
    }

    //Get total duration of bike use

    function renterTimespan(uint start, uint end) internal pure returns (uint) {
        return end - start;
    }

    function getTotalDuration(
        address walletAddress
    ) public view returns (uint) {
        if (
            renters[walletAddress].start == 0 || renters[walletAddress].end == 0
        ) {
            return 0;
        } else {
            uint timespan = renterTimespan(
                renters[walletAddress].start,
                renters[walletAddress].end
            );
            uint timespanInMinutes = timespan / 60;
            return timespanInMinutes;
        }
        // return 6;
    }

    //Get contract balance

    function balanceOf() public view returns (uint) {
        return address(this).balance;
    }

    //Get Renters Balance

    function balanceOfRenter(address walletAddress) public view returns (uint) {
        return renters[walletAddress].balance;
    }

    //Set Due amount

    function setDue(address walletAddress) internal {
        uint timespanMinutes = getTotalDuration(walletAddress);
        uint fiveMinuteIncrements = timespanMinutes / 5;
        renters[walletAddress].due = fiveMinuteIncrements * 500000000000000;
    }

    function canRentBike(address walletAddress) public view returns (bool) {
        return renters[walletAddress].canRent;
    }

    //Deposit
    function deposit(address walletAddress) public payable {
        renters[walletAddress].balance += msg.value;
    }

    //Make Payment

    function makePayment(address walletAddress) public payable {
        require(
            renters[walletAddress].due > 0,
            "You do not have a due this time"
        );
        require(
            renters[walletAddress].balance > msg.value,
            "You do not have enough balance"
        );
        renters[walletAddress].balance -= msg.value;
        renters[walletAddress].canRent = true;
        renters[walletAddress].due = 0;
        renters[walletAddress].start = 0;
        renters[walletAddress].end = 0;
    }

    function getDue(address walletAddress) public view returns (uint) {
        return renters[walletAddress].due;
    }

    function getRenter(
        address walletAddress
    )
        public
        view
        returns (
            string memory firstName,
            string memory lastName,
            bool canRent,
            bool active
        )
    {
        firstName = renters[walletAddress].firstName;
        lastName = renters[walletAddress].lastName;
        canRent = renters[walletAddress].canRent;
        active = renters[walletAddress].active;
    }

    function renterExists(address walletAddress) public view returns (bool) {
        if (renters[walletAddress].walletAddress != address(0)) {
            return true;
        }
        return false;
    }
}
