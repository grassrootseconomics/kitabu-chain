// Author: Mohamed Sohail <mohamedsohailazim@gmail.com>
// SPDX-License-Identifier:	GPL-3.0-or-later

pragma solidity >= 0.6.12;

contract KitabuValidators {
    address constant SYSTEM_ADDRESS = 0xffffFFFfFFffffffffffffffFfFFFfffFFFfFFfE;
    address public admissionController = 0x9F57B4A25638F3bdfFcB1F3d2902860601a1Aa65;

    address[] bootstrapValidators = [
        0x7c5a36Cb43fC87fbB1de46eb6Cfd231c2ADe147b
    ];

    address[] validators;

    bool public finalized;

    mapping(address => uint256) validatorSetIndex;
 
    event NewAdmissionController(address indexed old, address indexed newController);
    event InitiateChange(bytes32 indexed parentHash, address[] newSet);
    event ChangeFinalized(address[] currentSet);

    modifier onlySystemChange {
        require(msg.sender == SYSTEM_ADDRESS);
        _;
    }    

    modifier alreadyFinalized {
        require(finalized);
        _;
    }    

    modifier onlyAdmissionController {
        require(msg.sender == admissionController);
        _;
    }    

    constructor() public {
        for (uint i = 0; i < bootstrapValidators.length; i++) {
            validators.push(bootstrapValidators[i]);
		    validatorSetIndex[bootstrapValidators[i]] = i; 
        }

        finalized = true;
    }

    function setNewAdmissionController(address newController) public onlyAdmissionController {
        emit NewAdmissionController(admissionController, newController);
        admissionController = newController;
    }

    function getValidators() public view returns(address[] memory) {
		return validators;
	}

    function initiateChange() private {
		finalized = false;
		emit InitiateChange(blockhash(block.number - 1), getValidators());
	}

    function finalizeChange() public {
        finalized = true;
        emit ChangeFinalized(validators);
    }


	function addValidator(address newValidator) public onlyAdmissionController alreadyFinalized{
        validators.push(newValidator);
        validatorSetIndex[newValidator] = validators.length - 1;
		initiateChange();
	}

	function removeValidator(address exValidator) public onlyAdmissionController alreadyFinalized{
        orderedRemoval(validatorSetIndex[exValidator]);
        delete validatorSetIndex[exValidator];
        initiateChange();
	}

    function orderedRemoval(uint index) private {
        for(uint i = index; i < validators.length-1; i++){
            validators[i] = validators[i+1];      
        }
        validators.pop();
    }
}
