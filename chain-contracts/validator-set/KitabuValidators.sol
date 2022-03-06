// Author: Mohamed Sohail <mohamedsohailazim@gmail.com>
// SPDX-License-Identifier:	GPL-3.0-or-later

pragma solidity >= 0.6.12;

contract KitabuValidators {
    address constant SYSTEM_ADDRESS = 0xffffFFFfFFffffffffffffffFfFFFfffFFFfFFfE;
    address public admissionController = 0x289DeFD53E2D96F05Ba29EbBebD9806C94d04Cb6;

    address[] bootstrapValidators = [
        0x8bEDFA3Af524911b9E57b33D3982c2b73D1e20e1,
        0xb0dCcC83B5AF0F36Bd525a1549eec27928D802cc,
        0xA26049EDdC0EABA16b010ec509Db6046AE56B0CD
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
