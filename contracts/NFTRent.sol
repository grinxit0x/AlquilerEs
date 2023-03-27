// SPDX-License-Identifier: MIT
// It's j-u-s-t-a-t-e-s-t-!

pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC721/IERC721.sol";
import "@openzeppelin/contracts/token/ERC721/utils/ERC721Holder.sol";
import "./AlquilerEs.sol";

contract NFTRent is ERC721Holder {

    address alquilerEsAddress;
    IERC721 nft;

    mapping(address => mapping(uint256 => CasaNFT.Casa)) public rents;
    mapping(address => uint256[]) public ownedTokens;

    constructor(address _alquilerEsAddress) {
        alquilerEsAddress = _alquilerEsAddress;
        nft = IERC721(alquilerEsAddress);
    }

function startRent(uint256 _tokenId, uint256 _price, uint256 _duration) external {
    require(nft.ownerOf(_tokenId) == msg.sender, "No eres el propietario del token");
    require(rents[alquilerEsAddress][_tokenId].rented == false, "El token ya esta alquilado");
    
    CasaNFT.Casa memory casa = CasaNFT(nft).getCasa(_tokenId);
    
    require(casa.datosVenta.enAlquiler == true, "La casa no esta en alquiler");
    require(casa.datosVenta.precio == _price, "El precio especificado no es correcto");
    
    rents[alquilerEsAddress][_tokenId] = casa;
    ownedTokens[alquilerEsAddress].push(_tokenId);
    
    nft.safeTransferFrom(msg.sender, address(this), _tokenId);
}



    function extendRent(
        uint256 _tokenId,
        uint256 _duration
    ) external payable {
        CasaNFT.Casa memory casa = rents[alquilerEsAddress][_tokenId];
        require(casa.rented == true, "El token no esta alquilado");
        require(casa.renter == msg.sender, "No eres el arrendatario del token");
        require(msg.value == casa.price, "El valor enviado no es correcto");

        casa.endTime = casa.endTime + _duration;
    }

    function endRent(address _nftAddress, uint256 _tokenId) external {
        CasaNFT.Casa memory casa = rents[_nftAddress][_tokenId];
        require(casa.rented == true, "El token no esta alquilado");
        require(casa.renter == msg.sender, "No eres el arrendatario del token");
        require(
            block.timestamp >= casa.endTime,
            "El alquiler aun no ha finalizado"
        );

        nft.safeTransferFrom(address(this), casa.renter, _tokenId);

        // Transferir el pago correspondiente al alquiler al arrendatario
        payable(casa.renter).transfer(casa.price);

        casa.rented = false;
    }

    function getOwnedTokens(address _owner)
        external
        view
        returns (uint256[] memory)
    {
        return ownedTokens[_owner];
    }
}
