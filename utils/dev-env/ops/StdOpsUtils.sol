// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import {console2} from "dev-env/common/ForgeHelper.sol";
import {DevUtils} from "dev-env/common/DevUtils.sol";
import {StdOps, OpInfo} from "dev-env/UCSDevEnv.sol";

// Ops
import {InitSetAdminOp} from "src/ops/InitSetAdminOp.sol";
import {GetDepsOp} from "src/ops/GetDepsOp.sol";
import {CloneOp} from "src/ops/CloneOp.sol";
import {SetImplementationOp} from "src/ops/SetImplementationOp.sol";
import {StdOpsFacade} from "src/interfaces/facades/StdOpsFacade.sol";
import {DefaultOpsFacade} from "src/interfaces/facades/DefaultOpsFacade.sol";

/****************************************************
    🧩 Std Ops Primitive Utils
        🗒 Set Deployed Standard Ops Info
        🐣 Deploy Standard Ops If Not Exists
        🔗 Set Standard Bundle Ops
        🔧 Helper Methods for each Standard Ops
*****************************************************/
library StdOpsUtils {
    /**-------------------------------------
        🗒 Set Deployed Standard Ops Info
    ---------------------------------------*/
    function setStdOpsInfoAndTrySetDeployedOps(StdOps storage stdOps) internal returns(StdOps storage) {
        DevUtils.logProcess("Setting StdOpsInfo... & Tring to set Deployed Ops...");
        stdOps  .setInitSetAdminInfo()
                .setGetDepsInfo()
                .setCloneInfo()
                .setSetImplementationInfo();
        return stdOps;
    }

    function setInitSetAdminInfo(StdOps storage stdOps) internal returns(StdOps storage) {
        stdOps.initSetAdmin .set("OP_INIT_SET_ADMIN")
                            .set(InitSetAdminOp.initSetAdmin.selector)
                            .trySetDeployedContract()
                            .emitLog();
        return stdOps;
    }

    function setGetDepsInfo(StdOps storage stdOps) internal returns(StdOps storage) {
        stdOps.getDeps  .set("OP_GET_DEPS")
                        .set(GetDepsOp.getDeps.selector)
                        .trySetDeployedContract()
                        .emitLog();
        return stdOps;
    }

    function setCloneInfo(StdOps storage stdOps) internal returns(StdOps storage) {
        stdOps.clone.set("OP_CLONE")
                    .set(CloneOp.clone.selector)
                    .trySetDeployedContract()
                    .emitLog();
        return stdOps;
    }

    function setSetImplementationInfo(StdOps storage stdOps) internal returns(StdOps storage) {
        stdOps.setImplementation.set("OP_SET_IMPLEMENTATION")
                                .set(SetImplementationOp.setImplementation.selector)
                                .trySetDeployedContract()
                                .emitLog();
        return stdOps;
    }


    /**----------------------------------------
        🐣 Deploy Standard Ops If Not Exists
    ------------------------------------------*/
    function deployStdOpsIfNotExists(StdOps storage stdOps) internal returns(StdOps storage) {
        DevUtils.logProcess("Deploying StdOps if not exists...");
        stdOps  .deployInitSetAdminIfNotExists()
                .deployGetDepsIfNotExists()
                .deployCloneIfNotExists()
                .deploySetImplementationIfNotExists();
        return stdOps;
    }

    function deployInitSetAdminIfNotExists(StdOps storage stdOps) internal returns(StdOps storage) {
        if (!stdOps.initSetAdmin.exists()) {
            stdOps.initSetAdmin.set(address(new InitSetAdminOp())).emitLog();
        }
        return stdOps;
    }

    function deployGetDepsIfNotExists(StdOps storage stdOps) internal returns(StdOps storage) {
        if (!stdOps.getDeps.exists()) {
            stdOps.getDeps.set(address(new GetDepsOp())).emitLog();
        }
        return stdOps;
    }

    function deployCloneIfNotExists(StdOps storage stdOps) internal returns(StdOps storage) {
        if (!stdOps.clone.exists()) {
            stdOps.clone.set(address(new CloneOp())).emitLog();
        }
        return stdOps;
    }

    function deploySetImplementationIfNotExists(StdOps storage stdOps) internal returns(StdOps storage) {
        if (!stdOps.setImplementation.exists()) {
            stdOps.setImplementation.set(address(new SetImplementationOp())).emitLog();
        }
        return stdOps;
    }


    /**-------------------------------
        🔗 Set Standard Bundle Ops
    ---------------------------------*/
    function setStdBundleOps(StdOps storage stdOps) internal returns(StdOps storage) {
        DevUtils.logProcess("Setting StdBundleOps...");
        stdOps  .setAllStdOps()
                .setDefaultOps();
        return stdOps;
    }

    function setAllStdOps(StdOps storage stdOps) internal returns(StdOps storage) {
        stdOps.allStdOps.set("BUNDLE_ALL_STD_OPS")
                        .set(stdOps.initSetAdmin)
                        .set(stdOps.getDeps)
                        .set(stdOps.clone)
                        .set(stdOps.setImplementation)
                        .set(address(new StdOpsFacade()))
                        .emitLog();
        return stdOps;
    }

    function setDefaultOps(StdOps storage stdOps) internal returns(StdOps storage) {
        stdOps.defaultOps   .set("BUNDLE_DEFAULT_OPS")
                            .set(stdOps.initSetAdmin)
                            .set(stdOps.getDeps)
                            .set(address(new DefaultOpsFacade()))
                            .emitLog();
        return stdOps;
    }


    /**--------------------------------------------
        🔧 Helper Methods for each Standard Ops
    ----------------------------------------------*/
    function getCalldataInitSetAdmin(address admin) internal pure returns(bytes memory) {
        return abi.encodeCall(InitSetAdminOp.initSetAdmin, admin);
    }

}
