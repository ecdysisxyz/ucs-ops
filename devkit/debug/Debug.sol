// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

// Utils
import {console2, StdStyle} from "../utils/ForgeHelper.sol";
import {StringUtils} from "../utils/StringUtils.sol";
import {Logger} from "./Logger.sol";

bytes32 constant DEBUGGER = 0x03d3692c02b7cdcaf0187e8ede4101c401cc53a33aa7e03ef4682fcca8a55300;
/// @custom:storage-location erc7201:mc.devkit.debugger
struct DebugState {
    LogLevel logLevel;
    string[] errorLocationStack;
    Process[] processes;
    uint nextPid;
}
    enum LogLevel {
        Disable,
        Debug,
        Info,
        Warn,
        Error,
        Critical
    }
    struct Process {
        string libName;
        string funcName;
        string params;
    }

//=================
//  🐞 Debug
library Debug {
    using StringUtils for string;
    using StdStyle for string;


    /**+++++++++++++++++++++
        🔵 Debug State
    +++++++++++++++++++++++*/
    function State() internal pure returns(DebugState storage ref) {
        assembly { ref.slot := DEBUGGER }
    }

    /**-------------------------
        🕹️ Logging Control
    ---------------------------*/
    function startDebug() internal {
        setLogLevel(LogLevel.Debug);
    }
    function startInfo() internal {
        setLogLevel(LogLevel.Info);
    }
    function startWarn() internal {
        setLogLevel(LogLevel.Warn);
    }
    function startError() internal {
        setLogLevel(LogLevel.Error);
    }
    // function startCritical() internal {
    //     setLogLevel(LogLevel.Critical);
    // }
    function stopLog() internal {
        setLogLevel(LogLevel.Disable);
    }
    function setLogLevel(LogLevel level) internal {
        State().logLevel = level;
    }

    function isDisable() internal returns(bool) {
        return State().logLevel == LogLevel.Disable;
    }
    function isDebug() internal returns(bool) {
        return State().logLevel == LogLevel.Debug;
    }
    function isInfo() internal returns(bool) {
        return State().logLevel == LogLevel.Info;
    }
    function isWarm() internal returns(bool) {
        return State().logLevel == LogLevel.Warn;
    }
    function isError() internal returns(bool) {
        return State().logLevel == LogLevel.Error;
    }
    // function isCritical() internal returns(bool) {
    //     return State().logLevel == LogLevel.Critical;
    // }


    /**----------------------------
        📈 Execution Tracking
    ------------------------------*/
    function recordExecStart(string memory libName, string memory funcName, string memory params) internal returns(uint pid) {
        pid = State().nextPid;
        State().processes.push(Process(libName, funcName, params));
        Logger.logExecStart(pid, libName, funcName);
        State().nextPid++;
    }

    function recordExecFinish(uint pid) internal {
        Process memory current = State().processes[pid];
        Logger.logExecFinish(pid, current.libName, current.funcName);
    }
}
