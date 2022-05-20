// SPDX-License-Identifier: Unlicense

pragma solidity ^0.8.7;

import "@openzeppelin/contracts/access/Ownable.sol";

contract GenomRarity is Ownable {
    // Rarity
    uint16 private constant COMMON = 1;
    uint16 private constant RARE = 2;
    uint16 private constant EPIC = 3;
    uint16 private constant LIMITED = 4;
    uint16 private constant LEGENDARY = 5;

    string[] private genomRarityCommon;
    string[] private genomRarityRare;
    string[] private genomRarityEpic;
    string[] private genomRarityLimited;
    string[] private genomRarityLegendary;


    // Mapping Genom Rarity
    mapping(string => uint16) public genomRarity;

    function initial() public onlyOwner {
        // set initial genom rarity

        genomRarityCommon = ["00","01","02","03","04","05","06"];
        updateGenomRarity(COMMON,genomRarityCommon);

        genomRarityRare = ["07","08","09","10","11","12"];
        updateGenomRarity(RARE,genomRarityRare);

        genomRarityEpic = ["13","14","15","16","24"];
        updateGenomRarity(EPIC,genomRarityEpic);

        genomRarityLimited = ["20","21","22","23"];
        updateGenomRarity(LIMITED,genomRarityLimited);

        genomRarityLegendary = ["17","18","19"];
        updateGenomRarity(LEGENDARY,genomRarityLegendary);
    }

    function updateGenomRarity(uint16 rarity, string[] memory genoms) public onlyOwner { 
        for (
            uint16 i = 0;
            i < genoms.length;
            i++
        ) {
            genomRarity[genoms[i]] = rarity;
        }
    }

    // Get user Genomic Partcode and then split the code to check Genomic Rarity
    function getGenomRarity(string memory genomPart)
        public
        view
        returns (uint16)
    {
        uint16 rarity = genomRarity[genomPart];

        require(rarity != 0, "Unknown rarity");

        return rarity;
    }
}