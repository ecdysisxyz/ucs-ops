// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import {ForgeHelper, console2, StdStyle, vm} from "dev-env/common/ForgeHelper.sol";
import {ERC7546Utils} from "@ucs-contracts/src/proxy/ERC7546Utils.sol";
import {MockProxy, MockDictionary} from "dev-env/UCSDevEnv.sol";
import {MockDictionaryUtils} from "dev-env/dictionary/MockDictionaryUtils.sol";

using DevUtils for address;
using DevUtils for string;
//============================================
//  📚 Development Utils
//      🔢 Utils for Primitives
//      📊 Utils for Logging
//      🚨 Utils for Errors & Assertions
library DevUtils {

    /**---------------------------
        🔢 Utils for Primitives
    -----------------------------*/
    function getHash(string memory name) internal pure returns(bytes32) {
        return keccak256(abi.encode(name));
    }

    function isEqual(string memory a, string memory b) internal pure returns(bool) {
        return keccak256(abi.encode(a)) == keccak256(abi.encode(b));
    }

    function exists(address addr) internal returns(bool) {
        return addr != address(0) && addr.code.length != 0;
    }

    function isEmpty(string memory str) internal returns(bool) {
        return bytes(str).length == 0;
    }

    function append(string memory name, string memory str) internal returns(string memory) {
        return string.concat(name, str);
    }


    /**-------------------------
        🧪 Utils for Testing
    ---------------------------*/
    function injectCode(address target, bytes memory runtimeBytecode) internal {
        // vm.assume(runtimeBytecode.length > 0);
        vm.etch(target, runtimeBytecode);
    }

    function injectDictionary(address target, address dictionary) internal {
        injectAddressToStorage(target, ERC7546Utils.DICTIONARY_SLOT, dictionary);
    }

    function injectAddressToStorage(address target, bytes32 slot, address addr) internal {
        vm.store(target, slot, bytes32(uint256(uint160(addr))));
    }



    /**-------------------------
        📊 Utils for Logging
    ---------------------------*/
    using StdStyle for string;

    /// @dev for settings
    /// 7201:ucs.settings.log
    bytes32 constant SETTINGS_LOG_TRANSIENT_SLOT = 0xbde0fdc5ed1ea0336c91994660ac4a36d1b140bbccd99d8aa6d980b60a25d200;
    function toggleLog() internal {
        assembly {
            switch tload(SETTINGS_LOG_TRANSIENT_SLOT)
            case 0 {
                tstore(SETTINGS_LOG_TRANSIENT_SLOT, 1)
            }
            default {
                tstore(SETTINGS_LOG_TRANSIENT_SLOT, 0)
            }
        }
    }
    function shouldLog() internal returns(bool flag) {
        assembly {
            flag := tload(SETTINGS_LOG_TRANSIENT_SLOT)
        }
    }
    function log(string memory message) internal {
        if (shouldLog()) {
            console2.log(message);
        }
    }
    function logProcess(string memory message) internal {
        log(message.underline());
    }


    /**-------------------------------------
        🚨 Utils for Errors & Assertions
    ---------------------------------------*/
    function revertWith(string memory errorBody) internal {
        revertWith(errorBody, "");
    }

    function revertWith(string memory errorBody, string memory errorLocation) internal {
        string memory errorString = string.concat(
            "UCS DevEnv Error: ",
            errorBody,
            string.concat(" at ", errorLocation.isEmpty() ? "UnknownLocation" : errorLocation)
        );
        console2.log(errorString);
        revert(errorString.bold());
    }

    function assertNotEmpty(string memory str, string memory errorLocation) internal returns(string memory) {
        if (str.isEmpty()) revertWith("Empty String", errorLocation);
        return str;
    }
    function assertNotEmpty(string memory str) internal returns(string memory) {
        return str.assertNotEmpty("");
    }

    function assertNotEmpty(bytes4 selector) internal returns(bytes4) {
        if (selector == bytes4(0)) {
            revertWith("Empty Selector");
        }
        return selector;
    }

    function assertContractExists(address contractAddr) internal returns(address) {
        if (!exists(contractAddr)) {
            revertWith("Contract does not exist");
        }
        return contractAddr;
    }

    function revertUnusedNameNotFound() internal {
        string memory revertReason =
            "Default names are automatically set up to 5. Please manually assign names beyond that.";
        revertWith(revertReason);
    }

    // TODO move to settings
    function getScanRange() internal returns(uint start, uint end) {
        return (1, 5);
    }
}
