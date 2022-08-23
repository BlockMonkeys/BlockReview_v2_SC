// SPDX-License-Identifier: Unlicense
pragma solidity ^0.8.0;

import "./FNft.sol";
import "./Service.sol";

contract ProxyStorage {
    address public immutable admin = 0x5B38Da6a701c568545dCfcB03FcB875f56beddC4;
    uint256 public TotalSupply = 1;

    struct Review {
        uint256 id;
        uint256 nftId;
        string storeId;
        string title;
        string description;
        address owner;
        address[] likedUser;
        uint price;
    }

    mapping(uint => Review) public review_byId;
    mapping(address => uint[]) internal review_byOwner;
    mapping(string => uint[]) internal review_byStore;


    address public FnftAdrs;
    address public serviceAdrs;

    event create_review(Review);
    event like_reivew(uint reviewId, address likedUser);
    event sale_review(uint reviewId, uint nftId, address oldOwner, address newOwner, uint tokenTransfered, uint price);
    
    FnftContract public Fnft_contract;
    Service public service_contract;
    uint256 public createReviewPrice;
    uint256 public likeReviewPrice;

    constructor(address _serviceAdrs, address _FnftAdrs){
        serviceAdrs = _serviceAdrs;
        service_contract = Service(_serviceAdrs);
        FnftAdrs = _FnftAdrs;
        Fnft_contract = FnftContract(_FnftAdrs);
    }

    // 리뷰 작성 (Caller : Writer) [Return : Review Id];
    function writeReview(
        string memory _storeId,
        string memory _title,
        string memory _description, 
        string memory _uri
        )
        external 
        payable
        returns(Review memory)
    {
            // @ Checks
            require(createReviewPrice <= msg.value, "ERR : Not Enough Price");
            
            // @ Effects
            // Call Mint Function (-> F-NFT Contract )
            (bool _nftSuccess, bytes memory _nftData) = FnftAdrs.call(
                    abi.encodeWithSignature("mint(address,uint256,string)", msg.sender, 10000, _uri)
                );

            require(_nftSuccess, "ERR : Fail To Call Minitng Function");
            (uint nftId) = abi.decode(_nftData, (uint));

            // Delegate Call WriteReview Function (-> Service Contract )
            (bool _serviceSuccess, bytes memory _reviewData) = serviceAdrs.delegatecall(
                    abi.encodeWithSignature(
                    "writeReview(string,uint256,string,string)",
                    _storeId,
                    nftId,
                    _title,
                    _description
                ));

            require(_serviceSuccess, "ERR : Fail To Call Service Function");
            (Review memory reviewData) = abi.decode(_reviewData, (Review));

            // @ Interaction
            // Send Fee to Admin
            (bool sent, ) = admin.call{ value : createReviewPrice }("");
            require(sent, "ERR : Fail To Sent Value");

            emit create_review(reviewData);
            return reviewData;
    }

    // 리뷰 좋아요 (Caller : Like Action User) [Return : void];
    function likeReview(uint _id) external payable
    {
        // @ Validation Check
        require(TotalSupply > _id, "ERR : Review Not Exist");
        require(review_byId[_id].owner != msg.sender, "ERR : Can't Like Action Own Reivew");
        require(msg.value >= likeReviewPrice, "ERR : Not Enough Price");

        // @ Effects
        // Delegate Call LikeReview Function (-> Service Contract )
        (bool _serviceSuccess, ) = serviceAdrs.delegatecall(
                abi.encodeWithSignature(
                "likeReview(uint256)",
                _id
            ));

        require(_serviceSuccess, "ERR : Fail To Call Service Function");

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

            require(sentAdmin, "ERR : Send Coin To Admin error");
            require(sentWriter, "ERR : Send Coin To Writer error");

            // 10% To Liked Users;
            uint shareHolders_amount = (msg.value * 1/10) / len;

            for(uint i; i < len; i++) {
                // ERC 1155 - hold or not?
                if(Fnft_contract.balanceOf(review_byId[_id].likedUser[i], _id) != 0){
                    // ERC 1155 Token을 보유하고 있다면? : 지급 OR no reward;
                    (bool sentShareHolders, ) = payable(review_byId[_id].likedUser[i]).call{value : shareHolders_amount}("");
                    require(sentShareHolders, "ERR : Send Coin To sentShareHolders error");
                }
            }
        }

        emit like_reivew(_id, msg.sender);
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


}

   
    
        

    //     // Delegate Call WriteReview Function (-> Service Contract )
    //     (bool _serviceSuccess, bytes memory _reviewData) = serviceAdrs.delegatecall(
    //             abi.encodeWithSignature(
    //             "writeReview(string,uint256,string,string)",
    //             _storeId,
    //             nftId,
    //             _title,
    //             _description
    //         ));
    // }

    


    // function setContract(address _contractAdrs) external returns(address) {
    //     require(msg.sender == admin, "ERR : Not Authorized");
    //     serviceContract = Service(_contractAdrs);
    //     serviceAdrs = _contractAdrs;
    //     return serviceAdrs;
    // }
