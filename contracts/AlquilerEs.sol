// SPDX-License-Identifier: MIT
pragma solidity ^0.8.9;

import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/token/ERC721/extensions/ERC721Enumerable.sol";
import "@openzeppelin/contracts/token/ERC721/extensions/ERC721URIStorage.sol";
import "@openzeppelin/contracts/security/Pausable.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/token/ERC721/extensions/ERC721Burnable.sol";
import "@openzeppelin/contracts/utils/Counters.sol";
import "@openzeppelin/contracts/security/ReentrancyGuard.sol";

contract CasaNFT is
    ERC721,
    ERC721Enumerable,
    ERC721URIStorage,
    Pausable,
    Ownable,
    ERC721Burnable,
    ReentrancyGuard
{
    using Counters for Counters.Counter;

    Counters.Counter private _tokenIdCounter;

    struct Casa {
        string direccion;
        uint256 precio;
        uint256 area;
        uint256 habitaciones;
        uint256 banos;
        string descripcion;
        string imagenURI;
        address propietario;
        DatosVenta datosVenta;
    }

    struct DatosVenta {
        bool enAlquiler;
        bool enVenta;
        uint256 tiempoMinimoAlquiler;
        uint256 tiempoMaximoAlquiler;
        uint256 fechaInicioAlquiler;
        uint256 fechaFinAlquiler;
    }
    uint256 public tasaPropietario = 1 ether;
    string public baseURI = "https://setBaseURIhere/";

    mapping(uint256 => Casa) private _casas;
    mapping(address => bool) private _propietarios;

    // Este modificador de acceso solo permite que el propietario acceda a una función.
    modifier onlyPropietario() {
        require(
            _propietarios[msg.sender],
            "Solo los propietarios pueden realizar esta operacion"
        );
        _;
    }
    // Este modificador de acceso solo permite que el propietario de un token acceda a una función.
    modifier isPropietarioOf(uint256 tokenId) {
        require(_exists(tokenId), "Token ID no existe");
        require(
            ownerOf(tokenId) == msg.sender,
            "Solo el propietario puede realizar esta operacion"
        );
        _;
    }
    // Este modificador se asegura de que la casa con el ID especificado esté en alquiler antes de permitir el acceso a la función.
    modifier enAlquiler(uint256 _id) {
        require(
            _casas[_id].datosVenta.enAlquiler,
            "La casa no esta en alquiler"
        );
        _;
    }

    constructor() ERC721("CasaNFT", "CASA") {}

    // La función agregarPropietario permite agregar una nueva dirección de propietario a
    function agregarPropietario() public payable nonReentrant {
        require(msg.value == tasaPropietario, "El pago debe ser correcto");
        require(
            msg.sender != address(0),
            "La direccion del nuevo propietario no puede ser 0x0."
        );
        require(!_propietarios[msg.sender], "El propietario ya existe.");
        _propietarios[msg.sender] = true;
    }

    function setTasaPropietario(uint256 newTasa) public onlyOwner {
        tasaPropietario = newTasa;
    }

    // Función para crear una nueva casa con los datos proporcionados y asignar un token ID
    function crearCasa(
        string memory direccion,
        uint256 precio,
        uint256 area,
        uint256 habitaciones,
        uint256 banos,
        string memory descripcion,
        string memory imagenURI,
        DatosVenta memory datosVenta
    ) public onlyPropietario returns (uint256) {
        _tokenIdCounter.increment();

        uint256 nuevoTokenId = _tokenIdCounter.current();
        // Se guarda la información de la casa en un mapping con el nuevo Token ID
        _casas[nuevoTokenId] = Casa(
            direccion,
            precio,
            area,
            habitaciones,
            banos,
            descripcion,
            imagenURI,
            msg.sender,
            datosVenta
        );
        // Se emite el evento de creación de la casa y se asigna el token ID al propietario
        _safeMint(msg.sender, nuevoTokenId);
        _setTokenURI(nuevoTokenId, _baseURI());

        return nuevoTokenId;
    }

    // Función para obtener los datos de una casa a partir de su token ID
    function getCasa(uint256 tokenId) public view returns (Casa memory) {
        require(_exists(tokenId), "Token ID no existe");
        return _casas[tokenId];
    }

    // Función que devuelve un valor booleano indicando si la casa está en alquiler.
    function isEnAlquiler(uint256 _id)
        public
        view
        enAlquiler(_id)
        returns (bool)
    {
        return _casas[_id].datosVenta.enAlquiler;
    }

    // Funciones para actualizar los datos de una casa a partir de su token ID
    function setDireccion(uint256 tokenId, string memory direccion)
        public
        isPropietarioOf(tokenId)
    {
        _casas[tokenId].direccion = direccion;
    }

    function setPrecio(uint256 tokenId, uint256 precio)
        public
        isPropietarioOf(tokenId)
    {
        _casas[tokenId].precio = precio;
    }

    function setArea(uint256 tokenId, uint256 area)
        public
        isPropietarioOf(tokenId)
    {
        _casas[tokenId].area = area;
    }

    function setHabitaciones(uint256 tokenId, uint256 nuevasHabitaciones)
        public
        isPropietarioOf(tokenId)
    {
        _casas[tokenId].habitaciones = nuevasHabitaciones;
    }

    function setBanos(uint256 tokenId, uint256 nuevosBanos)
        public
        isPropietarioOf(tokenId)
    {
        _casas[tokenId].banos = nuevosBanos;
    }

    function setDescripcion(uint256 tokenId, string memory nuevaDescripcion)
        public
        isPropietarioOf(tokenId)
    {
        _casas[tokenId].descripcion = nuevaDescripcion;
    }

    function setImagenURI(uint256 tokenId, string memory nuevaImagenURI)
        public
        isPropietarioOf(tokenId)
    {
        _casas[tokenId].imagenURI = nuevaImagenURI;
    }

    function setEnAlquiler(uint256 tokenId, bool alqui)
        public
        isPropietarioOf(tokenId)
    {
        _casas[tokenId].datosVenta.enAlquiler = alqui;
    }

    function setEnVenta(uint256 tokenId, bool enVenta)
        public
        isPropietarioOf(tokenId)
    {
        _casas[tokenId].datosVenta.enVenta = enVenta;
    }

    function setTiempoMinimoAlquiler(
        uint256 tokenId,
        uint256 tiempoMinimoAlquiler
    ) public isPropietarioOf(tokenId) {
        _casas[tokenId].datosVenta.tiempoMinimoAlquiler = tiempoMinimoAlquiler;
    }

    function setTiempoMaximoAlquiler(
        uint256 tokenId,
        uint256 tiempoMaximoAlquiler
    ) public isPropietarioOf(tokenId) {
        _casas[tokenId].datosVenta.tiempoMaximoAlquiler = tiempoMaximoAlquiler;
    }

    function setFechaInicioAlquiler(
        uint256 tokenId,
        uint256 fechaInicioAlquiler
    ) public isPropietarioOf(tokenId) {
        _casas[tokenId].datosVenta.fechaInicioAlquiler = fechaInicioAlquiler;
    }

    function setFechaFinAlquiler(uint256 tokenId, uint256 fechaFinAlquiler)
        public
        isPropietarioOf(tokenId)
    {
        _casas[tokenId].datosVenta.fechaFinAlquiler = fechaFinAlquiler;
    }

    function transferirSaldo(address payable _destinatario) public onlyOwner {
        _destinatario.transfer(address(this).balance);
    }

    function _baseURI() internal view override returns (string memory) {
        return baseURI;
    }

    function setBaseURI(string memory newURI) public onlyOwner {
        baseURI = newURI;
    }

    function pause() public onlyOwner {
        _pause();
    }

    function unpause() public onlyOwner {
        _unpause();
    }

    function _beforeTokenTransfer(
        address from,
        address to,
        uint256 tokenId,
        uint256 batchSize
    ) internal override(ERC721, ERC721Enumerable) whenNotPaused {
        super._beforeTokenTransfer(from, to, tokenId, batchSize);
    }

    // The following functions are overrides required by Solidity.
    function _burn(uint256 tokenId)
        internal
        override(ERC721, ERC721URIStorage)
    {
        super._burn(tokenId);
    }

    function tokenURI(uint256 tokenId)
        public
        view
        override(ERC721, ERC721URIStorage)
        returns (string memory)
    {
        return super.tokenURI(tokenId);
    }

    function supportsInterface(bytes4 interfaceId)
        public
        view
        override(ERC721, ERC721Enumerable)
        returns (bool)
    {
        return super.supportsInterface(interfaceId);
    }
}
