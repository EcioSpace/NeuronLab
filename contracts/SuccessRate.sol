// SPDX-License-Identifier: MIT
pragma solidity ^0.8.7;

import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/utils/Strings.sol";
import "@openzeppelin/contracts/utils/math/SafeMath.sol";

contract SuccessRate is Ownable {
    using Strings for string;

    //Star
    uint16 private constant ONE_STAR = 1;
    uint16 private constant TWO_STAR = 2;
    uint16 private constant THREE_STAR = 3;
    uint16 private constant FOUR_STAR = 4;

    uint16 private constant ONE_CARD = 1;
    uint16 private constant TWO_CARD = 2;
    uint16 private constant THREE_CARD = 3;
    uint16 private constant FOUR_CARD = 4;
    uint16 private constant FIVE_CARD = 5;

    uint16 private constant SUCCEEDED = 0;
    uint16 private constant FAILED = 1;

    mapping(uint16 => mapping(uint16 => uint16[])) SWPoolResults;
    mapping(uint16 => mapping(uint16 => uint16[])) SWPoolValues;
    mapping(uint16 => mapping(uint16 => uint256[])) SWPoolPercentage;

    function setSWPoolValues(
        uint16 numberOfStar,
        uint16 numberOfCard
    ) internal {
         for (
            uint16 p = 0;
            p < SWPoolPercentage[numberOfStar][numberOfCard].length;
            p++
        ) {
            uint256 qtyItem = (100 * SWPoolPercentage[numberOfStar][numberOfCard][p]) /
                10000;
            for (uint16 i = 0; i < qtyItem; i++) {
                SWPoolValues[numberOfStar][numberOfCard].push(
                    SWPoolResults[numberOfStar][numberOfCard][p]
                );
            }
        }
    }

    function initial() public onlyOwner {
        //------------------------ STARS TIER PROBABILITY ------------------------------\\

        //------------------ ONE STAR ----------------\\

        //ONE_STAR + ONE_CARD = 30%
        SWPoolResults[ONE_STAR][ONE_CARD] = [0, 1];
        SWPoolPercentage[ONE_STAR][ONE_CARD] = [uint256(3000), uint256(7000)];
        setSWPoolValues(ONE_STAR, ONE_CARD);


        // ONE_STAR + TWO_CARD = 60%
        SWPoolResults[ONE_STAR][TWO_CARD] = [0,1];
        SWPoolPercentage[ONE_STAR][TWO_CARD] = [uint256(6000), uint256(4000)];
        setSWPoolValues(ONE_STAR, TWO_CARD);

        // ONE_STAR + THREE_CARD = 90%
        SWPoolResults[ONE_STAR][THREE_CARD] = [0,1];
        SWPoolPercentage[ONE_STAR][THREE_CARD] = [uint256(9000), uint256(1000)];
        setSWPoolValues(ONE_STAR, THREE_CARD);

        // ONE_STAR + FOUR_CARD = 100%
        SWPoolResults[ONE_STAR][FOUR_CARD] = [0];
        SWPoolPercentage[ONE_STAR][FOUR_CARD] = [uint256(10000)];
        SWPoolValues[ONE_STAR][FOUR_CARD] = [SUCCEEDED];

        //------------------ TWO STAR ----------------\\

        // TWO_STAR + ONE_CARD = 40%
        SWPoolResults[TWO_STAR][ONE_CARD] = [0, 1];
        SWPoolPercentage[TWO_STAR][ONE_CARD] = [uint256(4000), uint256(6000)];
        setSWPoolValues(TWO_STAR, ONE_CARD);

        // TWO_STAR + TWO_CARD = 80%
        SWPoolResults[TWO_STAR][TWO_CARD] = [0, 1];
        SWPoolPercentage[TWO_STAR][TWO_CARD] = [uint256(8000), uint256(2000)];
        setSWPoolValues(TWO_STAR, TWO_CARD);

        // TWO_STAR + THREE_CARD = 100%
        SWPoolResults[TWO_STAR][THREE_CARD] = [0];
        SWPoolPercentage[TWO_STAR][THREE_CARD] = [uint256(10000)];
        SWPoolValues[TWO_STAR][THREE_CARD] = [SUCCEEDED];

        //------------------ THREE STAR ----------------\\
        
        // THREE_STAR + ONE_CARD = 50%
        SWPoolResults[THREE_STAR][ONE_CARD] = [0, 1];
        SWPoolPercentage[THREE_STAR][ONE_CARD] = [uint256(5000), uint256(5000)];
        setSWPoolValues(THREE_STAR, ONE_CARD);

        // THREE_STAR + TWO_CARD = 100%
        SWPoolResults[THREE_STAR][TWO_CARD] = [0, 1];
        SWPoolPercentage[THREE_STAR][TWO_CARD] = [uint256(10000)];
        SWPoolValues[THREE_STAR][TWO_CARD] = [SUCCEEDED];

        //------------------ FOUR STAR ----------------\\

        // FOUR_STAR + ONE_CARD = 60%
        SWPoolResults[FOUR_STAR][ONE_CARD] = [0, 1];
        SWPoolPercentage[FOUR_STAR][ONE_CARD] = [uint256(6000), uint256(4000)];
        setSWPoolValues(FOUR_STAR, ONE_CARD);
    

        // FOUR_STAR + TWO_CARD = 100%
        SWPoolResults[FOUR_STAR][TWO_CARD] = [0];
        SWPoolPercentage[FOUR_STAR][TWO_CARD] = [uint256(10000)];
        SWPoolValues[FOUR_STAR][TWO_CARD] = [SUCCEEDED];

        //-----------------END UPGRADE RATE --------------------------------
    }

    function getSuccessRate(
        uint16 starNum,
        uint16 cardNum,
        uint16 _number
    ) public view returns (uint16) {
        uint16 _modNumber = uint16(_number) %
            uint16(SWPoolValues[starNum][cardNum].length);
        return SWPoolValues[starNum][cardNum][_modNumber];
    }
}
