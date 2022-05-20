// SPDX-License-Identifier: Unlicense

pragma solidity ^0.8.7;

import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/interfaces/IERC721.sol";
import "@openzeppelin/contracts/interfaces/IERC20.sol";
import "@openzeppelin/contracts/utils/Counters.sol";
import "@openzeppelin/contracts/security/ReentrancyGuard.sol";

interface IECIONFTCore {
    function tokenInfo(uint256 _tokenId)
        external
        view
        returns (string memory, uint256);

    function ownerOf(uint256 _tokenId) external view returns (address);

    function burn(uint256 _tokenId) external;

    function safeMint(address _to, string memory partCode) external;

    function transferFrom(
        address from,
        address to,
        uint256 tokenId
    ) external;
}

interface IRandomWorker {
    function startRandom() external returns (uint256);
}

interface ISuccessRate {
    function getSuccessRate(
        uint16 starNum,
        uint16 cardNum,
        uint16 _number
    ) external view returns (uint16);
}

interface IGnenomRarity {
    function getGenomRarity(string memory genomPart) external view returns (uint16);
}

contract NeuronLab is Ownable, ReentrancyGuard {
    //Part Code Index
    uint256 constant PC_NFT_TYPE = 12;
    uint256 constant PC_KINGDOM = 11;
    uint256 constant PC_CAMP = 10;
    uint256 constant PC_GEAR = 9;
    uint256 constant PC_DRONE = 8;
    uint256 constant PC_SUITE = 7;
    uint256 constant PC_BOT = 6;
    uint256 constant PC_GENOME = 5;
    uint256 constant PC_WEAPON = 4;
    uint256 constant PC_STAR = 3;
    uint256 constant PC_EQUIPMENT = 2;
    uint256 constant PC_RESERVED1 = 1;
    uint256 constant PC_RESERVED2 = 0;

    //Genom Rarity Code
    uint16 constant GENOME_COMMON = 1;
    uint16 constant GENOME_RARE = 2;
    uint16 constant GENOME_EPIC = 3;
    uint16 constant GENOME_LIMITED = 4;
    uint16 constant GENOME_LEGENDARY = 5;

    //Stars tier string
    string constant ONE_STAR = "00";
    string constant TWO_STAR = "01";
    string constant THREE_STAR = "02";
    string constant FOUR_STAR = "03";
    string constant FIVE_STAR = "04";

    //Star
    uint16 private constant ONE_STAR_UINT = 1;
    uint16 private constant TWO_STAR_UINT = 2;
    uint16 private constant THREE_STAR_UINT = 3;
    uint16 private constant FOUR_STAR_UINT = 4;

    //FAILED OR SUCCESS
    uint16 private constant SUCCEEDED = 0;
    uint16 private constant FAILED = 1;

    uint16 public constant ECIO_FEE_TYPE = 1;
    uint16 public constant LAKRIMA_FEE_TYPE = 2;

    //rate being charged to upgrade stars
    mapping(uint16 => mapping(uint16 => uint256)) public FEE_PER_MATERIAL;

    IECIONFTCore public ECIO_NFT_CORE;
    IERC20 public ECIO_TOKEN;
    IERC20 public LAKRIMA_TOKEN;
    ISuccessRate public SUCCESS_RATE;
    IRandomWorker public RANDOM_WORKER;
    IGnenomRarity public GENOM_RARITY;

    address public _minter;

    // Initial fee
    function initialFee() public onlyOwner {
        FEE_PER_MATERIAL[ECIO_FEE_TYPE][ONE_STAR_UINT] = 5000000000000000000000; // 5000 ecio
        FEE_PER_MATERIAL[ECIO_FEE_TYPE][TWO_STAR_UINT] = 15000000000000000000000; // 15000 ecio
        FEE_PER_MATERIAL[ECIO_FEE_TYPE][THREE_STAR_UINT] = 40000000000000000000000; // 40000 ecio
        FEE_PER_MATERIAL[ECIO_FEE_TYPE][FOUR_STAR_UINT] = 50000000000000000000000; // 50000 ecio

        FEE_PER_MATERIAL[LAKRIMA_FEE_TYPE][ONE_STAR_UINT] = 5000000000000000000000; // 5000 lakrima
        FEE_PER_MATERIAL[LAKRIMA_FEE_TYPE][TWO_STAR_UINT] = 10000000000000000000000; // 10000 lakrima
        FEE_PER_MATERIAL[LAKRIMA_FEE_TYPE][THREE_STAR_UINT] = 15000000000000000000000; // 15000 lakrima
        FEE_PER_MATERIAL[LAKRIMA_FEE_TYPE][FOUR_STAR_UINT] = 20000000000000000000000; // 20000 lakrima
    }

    // Setup ECIO token Address
    function setupEcioToken(address ecioTokenAddress) public onlyOwner {
        ECIO_TOKEN = IERC20(ecioTokenAddress);
    }

    // Setup lakrima token Address
    function setupLakrimaToken(address lakrimaTokenAddress) public onlyOwner {
        LAKRIMA_TOKEN = IERC20(lakrimaTokenAddress);
    }

    // Setup ECIONFTcore address
    function setupECIONFTCore(IECIONFTCore ecioNFTCoreAddress) public onlyOwner {
        ECIO_NFT_CORE = ecioNFTCoreAddress;
    }

    // Setup success rate address
    function setupSuccessRate(ISuccessRate successRateAddress) public onlyOwner {
        SUCCESS_RATE = successRateAddress;
    }

    // Setup random worker address
    function setupRandomWorker(IRandomWorker randomWorkerAddress) public onlyOwner {
        RANDOM_WORKER = randomWorkerAddress;
    }

    // Setup success rate address
    function setupGenomRarity(IGnenomRarity genomRarityAddress) public onlyOwner {
        GENOM_RARITY = genomRarityAddress;
    }

    function setupMinter(address minter) public onlyOwner {
        _minter = minter;
    }

    // Setup fee
    function setupFee(uint16 tokenType, uint16[] memory starUnit, uint256[] memory newRate) public onlyOwner {
        require(starUnit.length == newRate.length, "Array data of star and rate is invalid");
        for (uint8 i = 0; i < starUnit.length; i++) {
            FEE_PER_MATERIAL[tokenType][starUnit[i]] = newRate[i];
        }
    }

    // Compare 2 strings
    function compareStrings(string memory a, string memory b)
        public
        pure
        returns (bool)
    {
        return (keccak256(abi.encodePacked((a))) ==
            keccak256(abi.encodePacked((b))));
    }

    // Get user Partcode and then split the code to check Genomic numbers
    function splitGenom(string memory partCode)
        public
        pure
        returns (string memory)
    {
        string[] memory splittedPartCodes = splitPartCode(partCode);
        string memory genType = splittedPartCodes[PC_GENOME];

        return (genType);
    }

    // Get user Partcode and then split the code to check stars numbers
    function splitPartcodeStar(string memory partCode)
        public
        pure
        returns (string memory)
    {
        string[] memory splittedPartCodes = splitPartCode(partCode);
        string memory starCode = splittedPartCodes[PC_STAR];

        return starCode;
    }

    // Convert from string to uint16
    function convertStarToUint(string memory starPart)
        public
        pure
        returns (uint16 stars)
    {
        if (compareStrings(starPart, ONE_STAR) == true) {
            return ONE_STAR_UINT;
        } else if (compareStrings(starPart, TWO_STAR) == true) {
            return TWO_STAR_UINT;
        } else if (compareStrings(starPart, THREE_STAR) == true) {
            return THREE_STAR_UINT;
        } else if (compareStrings(starPart, FOUR_STAR) == true) {
            return FOUR_STAR_UINT;
        } 

        return ONE_STAR_UINT;
    }

    // Split partcode for each part
    function splitPartCode(string memory partCode)
        public
        pure
        returns (string[] memory)
    {
        string[] memory result = new string[](bytes(partCode).length / 2);
        for (uint256 index = 0; index < bytes(partCode).length / 2; index++) {
            result[index] = string(
                abi.encodePacked(
                    bytes(partCode)[index * 2],
                    bytes(partCode)[(index * 2) + 1]
                )
            );
        }
        return result;
    }

    // Combine partcode
    function createPartCode(
        string memory equipmentCode,
        string memory starCode,
        string memory weapCode,
        string memory humanGENCode,
        string memory battleBotCode,
        string memory battleSuiteCode,
        string memory battleDROCode,
        string memory battleGearCode,
        string memory trainingCode,
        string memory kingdomCode,
        string memory nftTypeCode
    ) public pure returns (string memory) {
        string memory code = concateCode("", "00");
        code = concateCode(code, "00");
        code = concateCode(code, equipmentCode);
        code = concateCode(code, starCode);
        code = concateCode(code, weapCode);
        code = concateCode(code, humanGENCode);
        code = concateCode(code, battleBotCode);
        code = concateCode(code, battleSuiteCode);
        code = concateCode(code, battleDROCode);
        code = concateCode(code, battleGearCode);
        code = concateCode(code, trainingCode); //Reserved
        code = concateCode(code, kingdomCode); //Reserved
        code = concateCode(code, nftTypeCode); //Reserved
        return code;
    }

    // Concate code
    function concateCode(string memory concatedCode, string memory newCode)
        public
        pure
        returns (string memory)
    {
        concatedCode = string(abi.encodePacked(concatedCode, newCode));

        return concatedCode;
    }

    // Get number and mod
    function getNumberAndMod(
        uint256 _ranNum,
        uint16 digit,
        uint16 mod
    ) public view virtual returns (uint16) {
        if (digit == 1) {
            return uint16((_ranNum % 10000) % mod);
        } else if (digit == 2) {
            return uint16(((_ranNum % 100000000) / 10000) % mod);
        } else if (digit == 3) {
            return uint16(((_ranNum % 1000000000000) / 100000000) % mod);
        }

        return 0;
    }

    // Get card id and then burn them and mint a new one
    function gatherMaterials(uint256[] memory tokenIds, uint256 mainCardTokenId)
        external payable nonReentrant
    {
        string memory mainCardPartCode;
        (mainCardPartCode, ) = ECIO_NFT_CORE.tokenInfo(mainCardTokenId);

        // get main card genom rarity
        string memory mainCardGenom = splitGenom(mainCardPartCode);
        uint16 mainCardRarity = GENOM_RARITY.getGenomRarity(mainCardGenom);

        //get main part code star
        string memory mainCardStar = splitPartcodeStar(mainCardPartCode);
        uint16 starConverted = convertStarToUint(mainCardStar);

        // send fee to minter
        (bool sent, )= _minter.call{value: 0.0004 ether}("");
        require(sent, "Failed to send Ether");

        require(
            ECIO_TOKEN.balanceOf(msg.sender) >= FEE_PER_MATERIAL[ECIO_FEE_TYPE][starConverted]*tokenIds.length,
            "Token: your token is not enough"
        );

        require(
            LAKRIMA_TOKEN.balanceOf(msg.sender) >= FEE_PER_MATERIAL[LAKRIMA_FEE_TYPE][starConverted]*tokenIds.length,
            "Token: your token is not enough"
        );

        // get random number
        uint256 _randomNumber = RANDOM_WORKER.startRandom();
        uint16 _modRandomNumber = getNumberAndMod(_randomNumber, 3, 1000);

        // get success rate
        uint16 randomResult = SUCCESS_RATE.getSuccessRate(
            starConverted,
            uint16(tokenIds.length),
            _modRandomNumber
        );

        if (randomResult == SUCCEEDED) {
            burnAndCheckToken(starConverted, mainCardRarity, tokenIds, mainCardTokenId);
            upgradeSW(starConverted, mainCardPartCode);

            ECIO_NFT_CORE.transferFrom(
                msg.sender,
                address(this),
                mainCardTokenId
            );

        } else if (randomResult == FAILED) {
            burnAndCheckToken(starConverted, mainCardRarity, tokenIds, mainCardTokenId);
        }

        ECIO_TOKEN.transferFrom(
            msg.sender, 
            address(this), 
            FEE_PER_MATERIAL[ECIO_FEE_TYPE][starConverted]*tokenIds.length);

        LAKRIMA_TOKEN.transferFrom(
            msg.sender, 
            address(this), 
            FEE_PER_MATERIAL[LAKRIMA_FEE_TYPE][starConverted]*tokenIds.length);
    }

    // Burn and check token
    function burnAndCheckToken(uint16 mainCardStar,uint16 mainCardRarity, uint256[] memory tokenIds, uint256 mainTokenId)
        internal
    {
        for (uint32 i = 0; i < tokenIds.length; i++) {
            string memory tokenIdPart;
            (tokenIdPart, ) = ECIO_NFT_CORE.tokenInfo(tokenIds[i]);

            string memory tokenIdsGenom = splitGenom(tokenIdPart);
            uint16 tokenIdsRarity = GENOM_RARITY.getGenomRarity(tokenIdsGenom);

            string memory cardStar = splitPartcodeStar(tokenIdPart);
            uint16 tokenIdStar = convertStarToUint(cardStar);

            require(
                ECIO_NFT_CORE.ownerOf(tokenIds[i]) == msg.sender,
                "Ownership: you are not the owner"
            );

            require(
                tokenIds[i] != mainTokenId,
                "Your meterial token must not duplicate main token"
            );

            require(
                tokenIdStar == mainCardStar,
                "Star: your meterial must be equal main card"
            );

            if (mainCardRarity == GENOME_COMMON || mainCardRarity == GENOME_RARE) {
                require(
                    tokenIdsRarity == GENOME_COMMON,
                    "Rarity: your meterial must be common"
                );
            }else if (mainCardRarity == GENOME_LIMITED || mainCardRarity == GENOME_EPIC) {
                require(
                    tokenIdsRarity == GENOME_RARE,
                    "Rarity: your meterial must be rare"
                );
            }else if (mainCardRarity == GENOME_LEGENDARY) {
                require(
                    tokenIdsRarity == GENOME_EPIC,
                    "Rarity: your meterial must be epic"
                );
            }

            ECIO_NFT_CORE.burn(tokenIds[i]);
        }
    }

    // Upgrade space warrior
    function upgradeSW(uint16 mainCardStar, string memory mainCardPart)
        internal
    {
        if (mainCardStar <= FOUR_STAR_UINT) {
            // split part code
            string[] memory splittedPartCode = splitPartCode(mainCardPart);
            // update partcode
            string memory partCode = createPartCode(
                splittedPartCode[PC_EQUIPMENT], //equipmentTypeId
                upgradedStar(splittedPartCode[PC_STAR]), //upgrade combatStarCode
                splittedPartCode[PC_WEAPON], //WEAPCode
                splittedPartCode[PC_GENOME], //humanGENCode
                splittedPartCode[PC_BOT], //battleBotCode
                splittedPartCode[PC_SUITE], //battleSuiteCode
                splittedPartCode[PC_DRONE], //battleDROCode
                splittedPartCode[PC_GEAR], //battleGearCode
                splittedPartCode[PC_CAMP], //trainingCode
                splittedPartCode[PC_KINGDOM], //kingdomCode
                splittedPartCode[PC_NFT_TYPE] // nft Type
            );
            
            ECIO_NFT_CORE.safeMint(msg.sender, partCode);
        }
    }

    function upgradedStar(string memory currentStar) internal pure returns (string memory) {
        if (compareStrings(currentStar, ONE_STAR) == true) {
            return TWO_STAR;
        } else if (compareStrings(currentStar, TWO_STAR) == true) {
            return THREE_STAR;
        } else if (compareStrings(currentStar, THREE_STAR) == true) {
            return FOUR_STAR;
        } else if (compareStrings(currentStar, FOUR_STAR) == true) {
            return FIVE_STAR;
        }

        return currentStar; 
    }

    //*************************** transfer fee ***************************//

    // transfer fee
    function transferFee(address payable _to, uint256 _amount)
        public
        onlyOwner
    {
        (bool success, ) = _to.call{value: _amount}("");
        require(success, "Failed to send Ether");
    }

    // transfer reward
    function transferReward(
        address _contractAddress,
        address _to,
        uint256 _amount
    ) public onlyOwner {
        IERC20 _token = IERC20(_contractAddress);
        _token.transfer(_to, _amount);
    }
}
