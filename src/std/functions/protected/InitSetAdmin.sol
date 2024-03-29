// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.24;

// storage
import {Storage} from "../../storage/Storage.sol";

// predicates
import {ProtectionBase} from "./utils/ProtectionBase.sol";

/**
    < MC Standard Function >
    @title InitSetAdmin
    @custom:version 0.1.0
    @custom:schema v0.1.0
 */
contract InitSetAdmin is ProtectionBase {
    /// DO NOT USE STORAGE DIRECTLY !!!
    event AdminSet(address admin);

    function initSetAdmin(address admin) external initializer {
        Storage.Admin().admin = admin;
        emit AdminSet(admin);
    }
}
