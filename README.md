## Basic Information
> Website Demo - https://github.com/LimChaeJune/Block-Jobs-API  
> Front-End Github -
> Back-End Github -


## Contract Information (Goerli TestNet)
### BlockJobs
0x5aD2765319620bab2777c3E23F47145113818530
### BlockJobsCoin
0x58BB470CF9d85fe769A2DA244FC8B4039A1C86d1
### BlockJobsNFT
0xd6310A71d1241970E0a61041C124D663FD24822F

---

# [BlockReview V2](blockreview.monstercoders.io) 소개
악성리뷰와 허위리뷰 문제는 여러 곳에서 일어난다. 이에 기업은 인공지능과 인력배치 등을 활용해 악성리뷰와 허위리뷰 문제를 완화하고 있다. 하지만 간혹 악성리뷰 또는 허위리뷰가 아닌 좋지 못한 평가의 솔직한 리뷰 또한 존재하는데 이를 악성리뷰로 오인해 삭제하고는 한다. 여기서 소비자는 충분한 표현의 자유를 보장받지 못하는 문제가 발생한다. 이에 본 프로젝트에서는 블록체인 기술을 활용해 투명성있고 신뢰성있는 리뷰 Dapp 구축을 했다. 프로젝트 V1과의 차이점은 Gas Station Network 를 활용해 트랜잭션시 발생하는 가스 비용 대리 지불을 어뷰징이 문제가 야기될 수 있기에 제거하였으며 Call Static과 Estimate Gas를 통해 트랜잭션 유효성 검사 후 트랜잭션을 보내 트랜잭션 실패 확률을 대폭 낮추었다. 또한 Auth Smart Contract를 통해 소비자의 personal_sign 서명값으로 WhiteList를 만들고 Service 영역의 Contract에 대하여 WhiteList 상에 있는 유저만 사용이 가능하도록 권한을 조정했다. 이에 따라 Web3에서 회원가입부분을 web2 영역과 web3 영역 양쪽에서 진행하고 Contract에 WhiteList를 둠으로써 Public Blockchain의 특성 중 하나인 `익명성` 부분을 현대사회의 요구에 맞추어 제외시켰으며 토큰 ERC-20을 활용한 Cost와 Reward제공 에서 Goerli Network의 코인인 Ethereum으로 변경했다. 토큰 -> 코인 으로 변경함에따라 Contract Admin이 코인 시장의 불장과 베어장에 맞추어 유동적으로 가격을 조절할 수 있게 구성했다. 또한 V1에서는 ERC721로 리뷰가 구성되었으나, V2에서는 ERC1155를 활용한 Fractional NFT로 리뷰 NFT를 구성했다. 좋아요에 참여한 유저들은 ERC1155 NFT를 1개씩 나누어 가질 수 있으며 이에 각 리뷰 NFT는 공동소유권을 가진 NFT가 된다는 점이 특징이다.

---

# Dapp Architecture
![ㅋㅇㄴㅍ](https://user-images.githubusercontent.com/66409384/186609149-b5f41b86-4780-4414-9d3c-02afb5a3693a.png)

# Consturction Skills
- `Ethereum Testnet (Goerli)` : Blockchain Network
- `IPFS` : Decentralized Object Storage
- `Solidity` : Smart Contract Language
- `Remix` : Solidity IDE & Deploy Tool
- `Openzepplin` : Solidity Library
- `web3.js` : web3 interaction javascript library (using in, Server)
- `ethers.js` : web3 interaction javascript library (using in, Client)
- `Nest.js` : Server Development
- `PostgreSQL` : Database
- `TypeORM` : Object-Relational Mapping for RDB
- `React` : Client Development

---

# Token Economy
![blockreview_v2Token](https://user-images.githubusercontent.com/66409384/186613588-3bbb6b37-4fe5-43ab-82f1-f730491f2862.png)


