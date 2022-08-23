// SPDX-License-Identifier: Unlicense
pragma solidity 0.8.15;

import "./Fnft.sol";
import "./interface/INft.sol";
import "./Auth.sol";

contract Service {
    address public immutable admin = 0xB28333cab47389DE99277F1A79De9a80A8d8678b;
    address public FnftContractAdrs;
    Auth internal AuthContract;
    uint public createReviewPrice;
    uint public likeReviewPrice;
    uint public TotalSupply = 1;
    bool lock = false;

    constructor(address _fNftAdrs, address _authAdrs){
        FnftContractAdrs = _fNftAdrs;
        AuthContract = Auth(_authAdrs);
    }

    struct Review {
        uint256 id;
        uint256 nftId;
        string storeId;
        string title;
        string description;
        address owner;
        address[] likedUser;
        uint price;
        uint crDate;
    }

    mapping(uint => Review) public review_byId;
    mapping(address => uint[]) internal review_byOwner;
    mapping(string => uint[]) internal review_byStore;

    modifier validationPipe(bytes memory _signature) {
        require(AuthContract.authCheck(_signature), "ERR : Not on WhiteList");
        require(!lock, "ERR : Currently Locked");
        lock = true;
        _;
        lock = false;
    }

    modifier onlyAdmin {
        require(msg.sender == admin, "ERR : Only Admin");
        _;
    }

    event create_review(Review);
    event like_reivew(uint reviewId, address likedUser);
    event sale_review(uint reviewId, uint nftId, address oldOwner, address newOwner, uint tokenTransfered, uint price);

    // 리뷰 작성 (Caller : Writer) [Return : Review Id];
    function writeReview(
        string memory _storeId, 
        string memory _title, 
        string memory _description, 
        string memory _uri,
        bytes memory _signature
        ) 
        external 
        payable
        validationPipe(_signature)
        returns(uint)
        {
            // @ Checks
            require(createReviewPrice <= msg.value, "ERR : Not Enough Price");

            // @ Effects
            // Call Mint Function
            (bool success, bytes memory data) = FnftContractAdrs.call(
                                                    abi.encodeWithSignature("mint(address,uint256,string)", msg.sender, 10000, _uri)
                                                );

            require(success, "ERR : Fail To Call Minitng Function");
            (uint nftId) = abi.decode(data, (uint));

            address[] memory liked;

            review_byId[TotalSupply] = Review(
                                        TotalSupply,
                                        nftId,
                                        _storeId, 
                                        _title, 
                                        _description,
                                        msg.sender,
                                        liked,
                                        0,
                                        block.timestamp
                                    );
                                    
            review_byOwner[msg.sender].push(TotalSupply);
            review_byStore[_storeId].push(TotalSupply);

            // @ Interaction
            // Send Fee
            (bool sent, ) = admin.call{ value : createReviewPrice }("");
            require(sent, "ERR : Fail To Sent Value");


            emit create_review(Review(
                                TotalSupply, 
                                nftId, 
                                _storeId, 
                                _title, 
                                _description, 
                                msg.sender, 
                                liked,
                                0,
                                block.timestamp
                            ));

            TotalSupply++;
            return TotalSupply-1;
        }

    // 리뷰 좋아요 (Caller : Like Action User) [Return : void];
    function likeReview(uint _id, bytes memory _signature) external payable validationPipe(_signature)
    {
        // @ Checks
        require(TotalSupply > _id, "ERR : Review Not Exist");
        require(review_byId[_id].owner != msg.sender, "ERR : Can't Like Action Own Reivew");
        require(msg.value >= likeReviewPrice, "ERR : Not Enough Price");

        // @ Effects
        review_byId[_id].likedUser.push(msg.sender);

        // @ Interactions
        // Transfer Coin
        uint len = review_byId[_id].likedUser.length;

        if(len == 0) {
            // 좋아요 한 유저가 아직 없다면? (운영자[20] : 글쓴이[80]);
            // 20% To Admin
            (bool sentAdmin, ) = payable(admin).call{value : msg.value * 2/10}("");
            // 80% To Writer
            (bool sentWriter, ) = payable(review_byId[_id].owner).call{value : msg.value * 8/10}("");

            require(sentAdmin, "ERR : Send Coin To Admin error");
            require(sentWriter, "ERR : Send Coin To Writer error");
        } else {
            // 좋아요 한 유저가 있다면? (운영자[10] : 글쓴이[80] : 좋아요 참여자[10]);
            // 10% To Admin
            (bool sentAdmin, ) = payable(admin).call{value : msg.value * 1/10}("");
            // 80% To Writer
            (bool sentWriter, ) = payable(review_byId[_id].owner).call{value : msg.value * 8/10}("");
            // 10% To Liked Users;
            uint shareHolders_amount = (msg.value * 1/10) / len;

            for(uint i; i < len; i++) {
                // ERC 1155 - 잔고체크
                if(INft(FnftContractAdrs).balanceOf(review_byId[_id].likedUser[i], _id) != 0){
                    // ERC 1155 Token을 보유하고 있다면? : 지급 & else no reward;
                    (bool sentShareHolders, ) = payable(review_byId[_id].likedUser[i]).call{value : shareHolders_amount}("");
                    require(sentShareHolders, "ERR : Send Coin To sentShareHolders error");
                }
            }

            require(sentAdmin, "ERR : Send Coin To Admin error");
            require(sentWriter, "ERR : Send Coin To Writer error");
            
            emit like_reivew(_id, msg.sender);
        }
    }
    // 리뷰 조회 - By Owner (Caller : AnyOne) [Return : Review[]]
    function getReview_ByOwner(address _owner) external view returns(Review[] memory) {
        Review[] memory result = new Review[](review_byOwner[_owner].length);

        for(uint i; i < review_byOwner[_owner].length; i++){
            result[i] = review_byId[review_byOwner[_owner][i]];
        }

        return result;
    }
    // 리뷰 조회 - By Store UUID (Caller : Anyone) [Return : Review[]]
    function getReview_ByStore(string memory _storeId) external view returns(Review[] memory) {
        Review[] memory result = new Review[](review_byStore[_storeId].length);

        for(uint i; i < review_byStore[_storeId].length; i++){
            result[i] = review_byId[review_byStore[_storeId][i]];
        }

        return result;
    }
    // 판매 등록 (Caller : Review Owner) [Return : void]
    function registerForSale(uint _reviewId, uint _price, bytes memory _signature) external validationPipe(_signature) {
        // @ Checks
        require(review_byId[_reviewId].owner == msg.sender, "ERR : Not Authorized");
        // @ Effects
        review_byId[_reviewId].price = _price;
    }
    // 판매 철회 (Caller : Review Owner) [Return : void]
    function withdrawSale(uint _reviewId, bytes memory _signature) external validationPipe(_signature) {
        // @ Checks
        require(review_byId[_reviewId].owner == msg.sender, "ERR : Not Authorized");

        // @ Effects
        review_byId[_reviewId].price = 0;
    }
    // 리뷰 구매 - (Caller : Buyer) [Return : void] <리뷰 보유자 : 97% & 어드민 : 3%>
    function saleReview(uint _reviewId, bytes memory _signature) external payable validationPipe(_signature) {
        // @ Checks
        // Owner Cannot Call;
        require(msg.sender != review_byId[_reviewId].owner, "ERR : Can't buy owns Review");
        // Review Price Check;
        require(review_byId[_reviewId].price > 0, "ERR : Not on Sale");
        // msg.value >= price;
        require(msg.value >= review_byId[_reviewId].price, "ERR : Not Enough Coin");
        
        // @ Effects
        address oldOwner = msg.sender;
        review_byId[_reviewId].owner = msg.sender;
        review_byId[_reviewId].price = 0;

        // Linear Search & Delete Element from "Review_byOwner"
        for(uint i; i < review_byOwner[review_byId[_reviewId].owner].length; i++){
            if(review_byOwner[review_byId[_reviewId].owner][i] == _reviewId){
                delete review_byOwner[review_byId[_reviewId].owner][i];
            }
        }

        // @ Interaction
        uint tokenBalance = INft(FnftContractAdrs).balanceOf(review_byId[_reviewId].owner, _reviewId);
        
        (bool sentNft, ) = FnftContractAdrs.call(
                        abi.encodeWithSignature("transferFrom(address,address,uint256,uint256)", 
                        review_byId[_reviewId].owner,
                        msg.sender, 
                        review_byId[_reviewId].nftId, 
                        tokenBalance
                        )
                    );

        require(sentNft, "ERR : Transfer NFT Failed");

        (bool sentWriter, ) = payable(review_byId[_reviewId].owner).call{value : msg.value * 97/100}("");
        (bool sentAdmin, ) = payable(review_byId[_reviewId].owner).call{value : msg.value * 3/100}("");

        require(sentWriter, "ERR : Send Coin to Writer Failed");
        require(sentAdmin, "ERR : Send Coin to Admin Failed");
        
        // @ Event
        emit sale_review(
            _reviewId, 
            review_byId[_reviewId].nftId,
            oldOwner,
            review_byId[_reviewId].owner,
            tokenBalance,
            msg.value
        );
    }

    // Write Review 가격설정 (Caller : Admin) [Return : void]
    function setWriteReviewPrice(uint _amount) external onlyAdmin {
        createReviewPrice = _amount;
    }
    // Like Review 가격설정 (Caller : Admin) [Return : void]
    function setLikeReviewPrice(uint _amount) external onlyAdmin {
        likeReviewPrice = _amount;
    }
    // Emergency Stop (Caller : Admin) [Return : void]
    function haltingContract() external onlyAdmin returns(bool){
        lock = !lock;
        return lock;
    }
}