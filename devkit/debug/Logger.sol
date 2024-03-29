// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

// Utils
import {console2, StdStyle, vm} from "../utils/ForgeHelper.sol";
import {StringUtils} from "../utils/StringUtils.sol";
// Debug
import {Debug, Process} from "./Debug.sol";

//================
//  📊 Logger
library Logger {
    using Logger for *;
    using StringUtils for string;
    using StdStyle for string;


    /**------------------
        💬 Logging
    --------------------*/
    function log(string memory message) internal {
        if (Debug.isDebug()) logDebug(message);
        if (Debug.isInfo()) logInfo(message);
        if (Debug.isWarm()) logWarn(message);
        if (Debug.isError()) logError(message);
        // if (Debug.isCritical()) logCritical(message);
    }

    function logDebug(string memory message) internal  {
        console2.log(message);
    }
    function logInfo(string memory message) internal  {
        console2.log(message);
    }
    function logWarn(string memory message) internal  {
        console2.log(message);
    }

    string constant ERR_HEADER = "\u2716 DevKit Error: ";
    function logError(string memory body) internal {
        console2.log(
            ERR_HEADER.red().br()
                .indent().append(body)
                .append(parseLocations())
        );
    }
    // function logCritical(string memory message) internal  {
    //     console2.log(message);
    // }


    /**-----------------------
        🎨 Log Formatting
    -------------------------*/
    function logProcess(string memory message) internal {
        log(message.underline());
    }
    function logProcStart(string memory message) internal {
        log((message.isNotEmpty() ? message : "Start Process").underline());
    }
    function logProcFin(string memory message) internal {
        log((message.isNotEmpty() ? message : "(Process Finished)").dim());
    }

    function insert(string memory message) internal {
        log(message.inverse());
    }

    function logBody(string memory message) internal {
        log(message.bold());
    }

    string constant START = "Starting... ";
    function logExecStart(uint pid, string memory libName, string memory funcName) internal {
        log(formatProc(pid, START, libName, funcName));
    }
    string constant FINISH = "Finished ";
    function logExecFinish(uint pid, string memory libName, string memory funcName) internal {
        log(formatProc(pid, FINISH, libName, funcName));
    }

    /**---------------
        📑 Parser
    -----------------*/
    function parseLocations() internal returns(string memory locations) {
        Process[] memory processes = Debug.State().processes;
        for (uint i = processes.length; i > 0; --i) {
            locations = locations.append(formatLocation(processes[i-1]));
        }
    }

    string constant AT = "\n\t    at ";
    function formatLocation(Process memory proc) internal returns(string memory) {
        return AT.append(proc.libName.dot().append(proc.funcName).parens().append(proc.params.italic())).dim();
    }

    string constant PID = "pid:";
    function formatPid(uint pid) internal returns(string memory message) {
        return message.brackL().append(PID).append(pid).brackR().sp().dim();
    }
    function formatProc(uint pid, string memory status, string memory libName, string memory funcName) internal returns(string memory) {
        return formatPid(pid).append(status).append(libName.dot().append(funcName)).parens();
    }

string constant ERR_STR_EMPTY = "Empty String";
string constant ERR_STR_EXISTS = "String Already Exist";


    /**-------------------
        💾 Export Log
    ---------------------*/
    function exportTo(string memory fileName) internal {}

}


