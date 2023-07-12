// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

library Pause {
    error ErrPaused();
    error ErrUnpause();

    event Paused(bytes4 indexed funcSig);
    event Unpaused(bytes4 indexed funcSig);
    event GloballyPaused();
    event GloballyUnpaused();

    struct PauseData {
        bool _globalPauseCB;
        mapping(bytes4 => bool) _pausedFunctions;
    }

    function whenNotPaused(PauseData storage self) internal view {
        if (self._globalPauseCB || self._pausedFunctions[msg.sig]) {
            revert ErrPaused();
        }
    }

    function globalPaused(PauseData storage self) public view returns (bool) {
        return self._globalPauseCB;
    }

    function paused(PauseData storage self, bytes4 funcSig_) public view returns (bool) {
        if (self._pausedFunctions[funcSig_]) {
            return true;
        }
        return false;
    }

    function _globalPause(PauseData storage self) internal {
        self._globalPauseCB = true;
        emit GloballyPaused();
    }

    function _globalUnpause(PauseData storage self) internal {
        self._globalPauseCB = false;
        emit GloballyUnpaused();
    }

    function _pause(PauseData storage self, bytes4 funcSig_) internal {
        if (self._pausedFunctions[funcSig_]) {
            return;
        }
        self._pausedFunctions[funcSig_] = true;
        emit Paused(funcSig_);
    }

    function _unpause(PauseData storage self, bytes4 funcSig_) internal {
        if (!self._pausedFunctions[funcSig_]) {
            return;
        }
        self._pausedFunctions[funcSig_] = false;
        emit Unpaused(funcSig_);
    }
}

abstract contract Pauseable {
    using Pause for Pause.PauseData;
    Pause.PauseData private _pauseData;

    modifier whenNotPaused() {
        _pauseData.whenNotPaused();
        _;
    }

    modifier whenPaused() {
        if (!_pauseData.globalPaused() && !_pauseData.paused(msg.sig)) {
            revert Pause.ErrUnpause();
        }
        _;
    }

    modifier whenGloballyPaused() {
        if (!_pauseData.globalPaused()) {
            revert Pause.ErrUnpause();
        }
        _;
    }

    function globalPaused() public view returns (bool) {
        return _pauseData.globalPaused();
    }

    function paused(bytes4 funcSig_) public view returns (bool) {
        return _pauseData.paused(funcSig_);
    }

    function _pause(bytes4 funcSig_) internal {
        _pauseData._pause(funcSig_);
    }

    function _unpause(bytes4 funcSig_) internal {
        _pauseData._unpause(funcSig_);
    }

    function _globalPause() internal {
        _pauseData._globalPause();
    }

    function _globalUnpause() internal {
        _pauseData._globalUnpause();
    }
}
