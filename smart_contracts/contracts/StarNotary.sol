pragma solidity ^0.4.23;

import './ERC721Token.sol';

contract StarNotary is ERC721Token { 

    struct Star { 
        string name;
        string starStory;
        string ra;
        string dec;
        string mag;		
    }
	
    //map the 3 star coordinates
	mapping(string => bool) private raCoordinate;
	mapping(string => bool) private decCoordinate;
	mapping(string => bool) private magCoordinate;
		
    mapping(uint256 => Star) public tokenIdToStarInfo;
    mapping(uint256 => uint256) public starsForSale;

    function createStar(string _name, string _story, string _ra, string _dec, string _mag, uint256 _tokenId) public { 
		//require one of the coordinate is not taken
		require(raCoordinate[_ra] != true || decCoordinate[_dec] != true || magCoordinate[_mag] != true, 
		"The coordinates for that star is already taken!");
		
		//concatenate the strings
		string memory raCoord = concateStrings("ra", _ra);
		string memory decCoord = concateStrings("dec", _dec);
		string memory magCoord = concateStrings("mag", _mag);
		
		//create struct in memory
        Star memory newStar = Star(_name, _story, raCoord, decCoord, magCoord);
		// create mapping for tokenId to the new struct star
        tokenIdToStarInfo[_tokenId] = newStar;

		//mint a token
        ERC721Token.mint(_tokenId);
		
		//create a bool var
		bool value = true;
		
		//invoke the setCoordinateMapping function
		this.setCoordinateMapping(_ra, _dec, _mag, value);
    }
	
	//func to concatenate strings
	function concateStrings(string _prefix, string _str) internal pure returns (string) {
		//found from eth stack exchange
		return string(abi.encodePacked(_prefix, "_", _str));
	}
	
	//function to set coordinate mapping
	function setCoordinateMapping(string _ra, string _dec, string _mag, bool _taken) external {
		raCoordinate[_ra] = _taken;
		decCoordinate[_dec] = _taken;
		magCoordinate[_mag] = _taken;
	}

    function putStarUpForSale(uint256 _tokenId, uint256 _price) public { 
        require(this.ownerOf(_tokenId) == msg.sender);

        starsForSale[_tokenId] = _price;
    }

    function buyStar(uint256 _tokenId) public payable { 
        require(starsForSale[_tokenId] > 0);

        uint256 starCost = starsForSale[_tokenId];
        address starOwner = this.ownerOf(_tokenId);

        require(msg.value >= starCost);

        clearPreviousStarState(_tokenId);

        transferFromHelper(starOwner, msg.sender, _tokenId);

        if(msg.value > starCost) { 
            msg.sender.transfer(msg.value - starCost);
        }

        starOwner.transfer(starCost);
    }

    function clearPreviousStarState(uint256 _tokenId) private {
        //clear approvals 
        tokenToApproved[_tokenId] = address(0);

        //clear being on sale 
        starsForSale[_tokenId] = 0;
    }
}