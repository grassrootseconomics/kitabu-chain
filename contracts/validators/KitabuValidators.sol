// Author: Mohamed Sohail <mohamedsohailazim@gmail.com>
// SPDX-License-Identifier:	GPL-3.0-or-later

pragma solidity >=0.6.12;

contract KitabuValidators {
    address constant SYSTEM_ADDRESS =
        0xffffFFFfFFffffffffffffffFfFFFfffFFFfFFfE;
    address public admissionController =
        0x77Bea3320Fa46aFF3C7c128B83F5E436596Ba73D;

    address[] public validators;

    bool public finalized;

    mapping(address => uint256) validatorSetIndex;

    event NewAdmissionController(
        address indexed old,
        address indexed newController
    );
    event InitiateChange(bytes32 indexed parentHash, address[] newSet);
    event ChangeFinalized(address[] currentSet);

    modifier onlySystemChange() {
        require(msg.sender == SYSTEM_ADDRESS);
        _;
    }

    modifier pendingFinalization() {
        require(finalized);
        _;
    }

    modifier onlyAdmissionController() {
        require(msg.sender == admissionController);
        _;
    }

    constructor() {
        validators.push(admissionController);
        validatorSetIndex[admissionController] = 0;
    }

    function setNewAdmissionController(address newController)
        public
        onlyAdmissionController
    {
        emit NewAdmissionController(admissionController, newController);
        admissionController = newController;
    }

    function getValidators() public view returns (address[] memory) {
        return validators;
    }

    function initiateChange() private {
        finalized = false;
        emit InitiateChange(blockhash(block.number - 1), getValidators());
    }

    function finalizeChange() public onlySystemChange {
        finalized = true;
        emit ChangeFinalized(validators);
    }

    function addValidator(address newValidator)
        public
        onlyAdmissionController
        pendingFinalization
    {
        validators.push(newValidator);
        validatorSetIndex[newValidator] = validators.length - 1;
        initiateChange();
    }

    function removeValidator(address exValidator)
        public
        onlyAdmissionController
        pendingFinalization
    {
        orderedRemoval(validatorSetIndex[exValidator]);
        delete validatorSetIndex[exValidator];
        initiateChange();
    }

    function orderedRemoval(uint256 index) private {
        for (uint256 i = index; i < validators.length - 1; i++) {
            validators[i] = validators[i + 1];
        }
        validators.pop();
    }
}
