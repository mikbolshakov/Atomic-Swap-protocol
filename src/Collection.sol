// SPDX-License-Identifier: MIT
pragma solidity ^0.8.9;

import "@openzeppelin/token/ERC721/ERC721.sol";
import "@openzeppelin/token/ERC721/extensions/ERC721URIStorage.sol";
import "@openzeppelin/utils/Counters.sol";

contract MyToken is ERC721, ERC721URIStorage {
    using Counters for Counters.Counter;

    Counters.Counter private _tokenIdCounter;

    struct Article {
        string title;
        string description;
        string tags;
        string uri;
    }

    mapping(uint256 => Article) articles;

    constructor() ERC721("MyToken", "MTK") {}

    function getArticleTitle(
        uint256 _articleId
    ) public view returns (string memory title) {
        return articles[_articleId].title;
    }

    function getArticleDescription(
        uint256 _articleId
    ) public view returns (string memory description) {
        return articles[_articleId].description;
    }

    function getArticleTags(
        uint256 _articleId
    ) public view returns (string memory tags) {
        return articles[_articleId].tags;
    }

    function getArticleUri(
        uint256 _articleId
    ) public view returns (string memory uri) {
        return articles[_articleId].uri;
    }

    function safeMint(
        string memory _uri,
        string memory _title,
        string memory _description,
        string memory _tags
    ) public returns (uint256) {
        require(bytes(_uri).length > 0, "Uri required");
        require(bytes(_title).length > 0, "Title required");
        require(bytes(_description).length > 0, "Description required");
        require(bytes(_tags).length > 0, "Tags required");
        uint256 tokenId = _tokenIdCounter.current();
        _tokenIdCounter.increment();
        _safeMint(msg.sender, tokenId);
        _setTokenURI(tokenId, _uri);
        articles[tokenId].title = _title;
        articles[tokenId].description = _description;
        articles[tokenId].tags = _tags;
        articles[tokenId].uri = _uri;
        return tokenId;
    }

    // The following functions are overrides required by Solidity.

    function _burn(
        uint256 tokenId
    ) internal override(ERC721, ERC721URIStorage) {
        super._burn(tokenId);
    }

    function tokenURI(
        uint256 tokenId
    ) public view override(ERC721, ERC721URIStorage) returns (string memory) {
        return super.tokenURI(tokenId);
    }

    function supportsInterface(
        bytes4 interfaceId
    ) public view override(ERC721, ERC721URIStorage) returns (bool) {
        return super.supportsInterface(interfaceId);
    }
}
