// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import {ForgeHelper, console2} from "DevKit/common/ForgeHelper.sol";

import {DevUtils} from "DevKit/common/DevUtils.sol";
import {FuncInfo} from "./FuncInfo.sol";
import "DevKit/common/Errors.sol";
import {Debug} from "DevKit/common/Debug.sol";

/**====================
    🧺 Bundle Info
======================*/
using BundleInfoUtils for BundleInfo global;
struct BundleInfo {
    string name;
    FuncInfo[] functionInfos;
    address facade;
}

using BundleInfoUtils for mapping(bytes32 => BundleInfo);
library BundleInfoUtils {
    using DevUtils for *;

    /**---------------------------
        📥 Assign BundleInfo
    -----------------------------*/
    string constant safeAssign_ = "Safe Assign to BundleInfo";

    function safeAssign(BundleInfo storage bundleInfo, string memory name) internal returns(BundleInfo storage) {
        bundleInfo.name = name.assertNotEmpty();
        return bundleInfo;
    }

    function safeAssign(BundleInfo storage bundleInfo, address facade) internal returns(BundleInfo storage) {
        bundleInfo.facade = facade.assertIsContract();
        return bundleInfo;
    }

    string constant safeAdd_ = "Safe Add FunctionInfo to BundleInfo";

    function safeAdd(BundleInfo storage bundleInfo, FuncInfo storage functionInfo) internal returns(BundleInfo storage) {
        bundleInfo.functionInfos.push(
            functionInfo.assertNotIncludedIn(bundleInfo)
                        .assertImplIsContract()
        );
        return bundleInfo;
    }

    function safeAdd(BundleInfo storage bundleInfo, FuncInfo[] storage functionInfos) internal returns(BundleInfo storage) {
        for (uint i; i < functionInfos.length; ++i) {
            bundleInfo.safeAdd(functionInfos[i]);
        }
        return bundleInfo;
    }


    /**-------------------------------
        🧐 Inspectors & Assertions
    ---------------------------------*/
    function has(BundleInfo storage bundleInfo, FuncInfo storage functionInfo) internal returns(bool flag) {
        FuncInfo[] memory _functionInfos = bundleInfo.functionInfos;
        bytes32 functionInfoHash = keccak256(abi.encode(functionInfo));
        for (uint i; i < _functionInfos.length; ++i) {
            if (DevUtils.isEqual(functionInfo.name, _functionInfos[i].name)) throwError("Same Keyword");
            if (functionInfo.selector == _functionInfos[i].selector) throwError("Same Selector");
            bytes32 _functionInfoHash = keccak256(abi.encode(_functionInfos[i]));
            if (functionInfoHash == _functionInfoHash) flag = true;
        }
    }

    function isComplete(BundleInfo storage bundleInfo) internal returns(bool) {
        return  bundleInfo.name.isNotEmpty() &&
                bundleInfo.functionInfos.length != 0 &&
                bundleInfo.facade.isContract();
    }
    function assertComplete(BundleInfo storage bundleInfo) internal returns(BundleInfo storage) {
        check(bundleInfo.isComplete(), "Bundle Info Not Complete");
        return bundleInfo;
    }

    function hasName(BundleInfo storage bundleInfo) internal returns(bool) {
        return bundleInfo.name.isNotEmpty();
    }
    function hasNotName(BundleInfo storage bundleInfo) internal returns(bool) {
        return bundleInfo.name.isEmpty();
    }

    function exists(BundleInfo storage bundleInfo) internal returns(bool) {
        return  bundleInfo.name.isNotEmpty() ||
                bundleInfo.functionInfos.length != 0 ||
                bundleInfo.facade.isNotContract();
    }
    function notExists(BundleInfo storage bundleInfo) internal returns(bool) {
        return bundleInfo.exists().isNot();
    }
    function assertExists(BundleInfo storage bundleInfo) internal returns(BundleInfo storage) {
        check(bundleInfo.exists(), "Bundle Info Not Exists");
        return bundleInfo;
    }
    function assertNotExists(BundleInfo storage bundleInfo) internal returns(BundleInfo storage) {
        check(bundleInfo.notExists(), "Bundle Info Already Exists");
        return bundleInfo;
    }

    /**
        Logging
     */
    function emitLog(BundleInfo storage bundleInfo) internal returns(BundleInfo storage) {
        if (Debug.shouldLog()) {
            console2.log(DevUtils.indent(bundleInfo.name));
            console2.log("\tFacade:", bundleInfo.facade);
            for (uint i; i < bundleInfo.functionInfos.length; ++i) {
                bundleInfo.functionInfos[i].parseAndLog();
            }
        }
        return bundleInfo;
    }
}
