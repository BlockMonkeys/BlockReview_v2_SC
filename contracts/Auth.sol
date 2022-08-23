// SPDX-License-Identifier: Unlicense
pragma solidity 0.8.15;

contract Auth {
    address public admin = 0xB28333cab47389DE99277F1A79De9a80A8d8678b;
    uint public registerFee;
    bool public lock;

    struct User {
        address eoa;
        string email;
    }

    // Signature => User;
    mapping(bytes => User) public whiteList; 

    event userRegistered(User user, uint fee, bytes sig);

    modifier onlyAdmin {
        require(msg.sender == admin, "ERR : Only Admin");
        _;
    }

    // Register User 검증 (Caller : New EOA) [Return : void]
    function registerUser(bytes memory _signature, User memory _user) external payable {
        require(registerFee <= msg.value, "ERR : Register Fee not Enough");
        require(verify(msg.sender, _signature, _user), "ERR : Verify Failed");

        whiteList[_signature] = _user;
        (bool sent, ) = admin.call{ value : registerFee }("");
        require(sent, "ERR : Fail To Sent Value");
        emit userRegistered(_user, msg.value, _signature);
    }

    // WhiteList Check (Caller : Service Contract) [Return : bool]
    function authCheck (bytes memory _signature) external view returns (bool) {
        if(whiteList[_signature].eoa == address(0)) {
            return false;
        } else {
            return true;
        }
    }

    // @ EC Verification Feature
    function verify (address _signer, bytes memory _sig, User memory _user) internal pure returns (bool) {
        bytes32 msgHash = getMsgHash(_user);
        bytes32 ethSignedMsgHash = _getEthSignedMsg(msgHash);
        return _recover(ethSignedMsgHash, _sig) == _signer;
    }

    function _getEthSignedMsg (bytes32 _msgHash) internal pure returns (bytes32) {
        return keccak256(abi.encodePacked(
              "\x19Ethereum Signed Message:\n32",
              _msgHash
            ));
    }

    function _recover (bytes32 _ethSignedMessageHash, bytes memory _sig) internal pure returns (address) {
        (bytes32 r, bytes32 s, uint8 v) = _split(_sig);
        return ecrecover(_ethSignedMessageHash, v, r, s);
    }

    function _split(bytes memory _sig) internal pure returns(bytes32 r, bytes32 s, uint8 v) {
        require(_sig.length == 65, "Invalid Signature length");

        assembly {
            r := mload(add(_sig, 32))
            s := mload(add(_sig, 64))
            v := byte(0, mload(add(_sig, 96)))
        }

        return (r, s, v);
    }

    function getMsgHash (User memory _user) public pure returns(bytes32 _msgHash) {
        _msgHash = keccak256(abi.encodePacked(
            _user.eoa, 
            _user.email
        ));
    }

    // Emergency Stop (Caller : Admin) [Return : void]
    function haltingContract() external onlyAdmin returns(bool){
        lock = !lock;
        return lock;    
    }
}