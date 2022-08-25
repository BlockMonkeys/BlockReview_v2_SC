## Basic Information
> Website Demo -  
> Back-End Github - https://github.com/BlockMonkeys/BlockReview_v2_BE
> Front-End Github - 

---

# [BlockReview V2](blockreview.monstercoders.io) 소개
악성리뷰와 허위리뷰 문제는 인터넷 상에서 어렵지 않게 찾을 수 있다. 이에 서비스 회사들에서는 인공지능과 인력배치 등을 통해 악성리뷰와 허위리뷰 문제를 완화하고 있다. 하지만 간혹 악성리뷰 또는 허위리뷰가 아닌 좋지 못한 평가의 솔직한 리뷰 또한 존재하는데 이를 악성리뷰로 오인해 삭제하고는 한다. 여기서 소비자는 충분한 표현의 자유를 보장받지 못하는 문제가 발생한다. 이에 본 프로젝트에서는 블록체인 기술을 활용해 투명성있고 신뢰성있는 리뷰 Dapp 구축을 했다. 악성리뷰와 허위리뷰는 Cost와 Reward를 통한 게임이론에 입각하여 자연스레 도태되고 노출이 적어지게 구성하였으며 좋아요가 많은 보다 믿을만한 리뷰는 상단에 배치되어 노출 빈도를 높였다 프로젝트 V1과의 차이점은 Gas Station Network 를 활용해 트랜잭션시 발생하는 가스 비용 대리 지불을 어뷰징이 문제가 야기될 수 있기에 제거하였으며 Call Static과 Estimate Gas를 통해 트랜잭션 유효성 검사 후 트랜잭션을 보내 트랜잭션 실패 확률을 대폭 낮추었다. 또한 Auth Smart Contract를 통해 소비자의 personal_sign 서명값으로 WhiteList를 만들고 Service 영역의 Contract에 대하여 WhiteList 상에 있는 유저만 사용이 가능하도록 권한을 조정했다. 이에 따라 Web3에서 회원가입부분을 web2 영역과 web3 영역 양쪽에서 진행하고 Contract에 WhiteList를 둠으로써 Public Blockchain의 특성 중 하나인 `익명성` 부분을 현대사회의 요구에 맞추어 제외시켰으며 토큰 ERC-20을 활용한 Cost와 Reward제공 에서 Goerli Network의 코인인 Ethereum으로 변경했다. 토큰 -> 코인 으로 변경함에따라 Contract Admin이 코인 시장의 불장과 베어장에 맞추어 유동적으로 가격을 조절할 수 있게 구성했다. 또한 V1에서는 ERC721로 리뷰가 구성되었으나, V2에서는 ERC1155를 활용한 Fractional NFT로 리뷰 NFT를 구성했다. 좋아요에 참여한 유저들은 ERC1155 NFT를 1개씩 나누어 가질 수 있으며 이에 각 리뷰 NFT는 공동소유권을 가진 NFT가 된다.

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
- `React` : Client Development
- `Nest.js` : Server Development
- `PostgreSQL` : Database
- `TypeORM` : Object-Relational Mapping for RDB Tool

---

# Token Economy
![blockreview_v2Token](https://user-images.githubusercontent.com/66409384/186613588-3bbb6b37-4fe5-43ab-82f1-f730491f2862.png)

# Smart Contract
![SmartContractERD](https://user-images.githubusercontent.com/66409384/186618712-e1927327-28fc-4dd8-8b56-088127cc6a7d.png)

### FNFT Contract
- Fractional NFT(ERC-1155) 템플릿

### Auth Contract
- 유저의 서명 생성
- 유저의 서명 검증

### Service Contract
- 리뷰 생성 기능
- 리뷰 좋아요 기능
- 리뷰 조회 기능
- 리뷰 NFT 판매 등록 및 철회 기능
- 리뷰 NFT 판매 기능
- 리뷰 작성 가격설정 (Only Admin)
- 리뷰 좋아요 가격설정 (Only Admin)
- Emergency Stop 기능 (Only Admin)

# DATABSE
![erd](https://user-images.githubusercontent.com/66409384/186615278-6b8ef518-41e8-4215-b8b0-a5299df1b360.png)

### User Entity
- `eoa` : 유저의 퍼블릭 키
- `signature` : eoa와 email을 묶은 personal_sign값
- `email` : 유저 이메일
- `phoneNumber` : 유저 전화번호
- `userType` : 일반유저, 점주유저
- `crnNumber` : Company Registration Number 사업자등록번호
- `registeredAt` : 등록일
- `storeId` : (점주유저) 상점 정보

### Store Entity
- `id` : uuid
- `name` : 점포 이름
- `description` : 점포 소개
- `address` : 점포 주소
- `tel` : 점포 전화번호
- `category` : 점포 카테고리
- `registeredAt` : 등록일
- `imgUrl` : s3상에 업로드한 점포 대표 이미지
