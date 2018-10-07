pragma solidity ^0.4.24;

import "./ERC725.sol";
import "openzeppelin-solidity/contracts/token/ERC721/ERC721.sol";

contract Wrapped725 is ERC721 {

    mapping(uint256 => address) nftToIdentity;

    bytes32 public KEY

    constructor() {
        KEY = keccak256(address(this));
    }

    modifier onlyTokenHolder() {
        require(msg.sender == ownerOf(_token));
        _;
    }

    /// mint/burn Functions ///

    function mintIdentityToken(address _identity) public {
        ERC725 memory identity = ERC725(_identity);
        uint256 token = uint256(_identity);

        // check for permission
        require(identity.keyHasPurpose(KEY,1));

        // remove all other management Keys
        bytes32[] memory keys = identity.getKeysByPurpose(1);
        for (uint256 i=0; i<keys.length; i++) {
            if (keys[i] != KEY) {
                require(identity.removeKey(keys[i],1));
            }
        }

        // mint721
        nftToIdentity[token] = _identity;
        _mint(msg.sender,token);
    }

    function burnIdentityToken(uint256 _token, address _newOwner) public onlyTokenHolder {
        ERC725 memory identity = ERC725(nftToIdentity[_identity]);

        // check for permission
        require(identity.keyHasPurpose(KEY,1));

        // add permission
        require(identity.addKey(keccak256(_newOwner),1));

        // burn721
        delete nftToIdentity[_token];
        _burn(msg.sender,_token);
    }

    /// 725 Functions ///

    function addKey(uint256 _token, bytes32 _key, uint256 _purpose, uint256 _keyType) public onlyTokenHolder returns (bool success) {
        require(_purpose != 1);
        return ERC725(nftToIdentity[_token]).addKey(_key, _purpose, _type);
    }

    function removeKey(uint256 _token, bytes32 _key, uint256 _purpose) public onlyTokenHolder returns (bool success) {
        require(_purpose != 1);
        return ERC725(nftToIdentity[_token]).removeKey(_key, _purpose);
    }

    function execute(uint256 _token, address _to, uint256 _value, bytes _data) public onlyTokenHolder returns (uint256 executionId) {
        return ERC725(nftToIdentity[_token]).execute(_to, _value, _data);
    }

    function approve(uint256 _token, uint256 _id, bool _approve) public onlyTokenHolder returns (bool success) {
        return ERC725(nftToIdentity[_token]).approve(_id, _approve);
    }

}
