// SPDX-License-Identifier: Unlicense
pragma solidity 0.8.15;

import "@openzeppelin/contracts/token/ERC1155/ERC1155.sol";

contract FnftContract is ERC1155 {
    address public immutable admin = 0xB28333cab47389DE99277F1A79De9a80A8d8678b;
    string public name;
    string public symbol;
    uint TotalSupply = 1;

    constructor() ERC1155("") {
        name = "MonsterReview";
        symbol = "MONR";
    }

    modifier onlyOwner {
        require(msg.sender == admin, "ERR : Not Authorized");
        _;
    }

    function mint(address _to, uint _amount, string memory _uri) external returns (uint) {
        _mint(_to, TotalSupply, _amount, "");
        _setURI(_uri);
        TotalSupply++;
        return TotalSupply-1;
    }

    function burn(uint _tokenId, uint _amount) external onlyOwner {
        _burn(admin, _tokenId, _amount);
    }

    function transferFrom(
        address _from,
        address _to,
        uint256 _id,
        uint256 _amount
    ) 
        external payable
    {
        safeTransferFrom(_from, _to, _id, _amount, bytes("blockreview"));
    }
}