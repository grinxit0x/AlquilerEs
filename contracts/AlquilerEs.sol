// SPDX-License-Identifier: MIT
pragma solidity ^0.8.21;

import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/utils/Counters.sol";

contract CasaNFT is ERC721 {
    using Counters for Counters.Counter;
    Counters.Counter private _tokenIdCounter;

    address public goon;

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

    modifier onlyPropietario() {
        require(
            _propietarios[msg.sender],
            "Solo los propietarios pueden realizar esta operacion"
        );
        _;
    }

    modifier onlyTokenOwner(uint256 tokenId) {
        require(
            ownerOf(tokenId) == msg.sender,
            "Solo el propietario del tokenId puede realizar esta operacion"
        );
        _;
    }

    modifier onlyGoon() {
        require(msg.sender == goon, "Solo el pro");
        _;
    }

    constructor() ERC721("CasaNFT", "CASA") {
        goon = msg.sender;
    }

    function agregarPropietario(address propietario) public payable {
        require(msg.value >= tasaPropietario, "El pago es insuficiente");
        require(
            !_propietarios[propietario],
            "El propietario ya esta registrado"
        );
        require(propietario != address(0), "La direccion no puede ser 0x0");

        _propietarios[propietario] = true;
    }

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
        require(
            bytes(direccion).length > 0,
            "La direccion no puede estar vacia"
        );
        require(precio > 0, "El precio debe ser mayor que 0");
        require(area > 0, "El area debe ser mayor que 0");
        require(habitaciones > 0, "Debe tener al menos una habitacion");
        require(banos > 0, "Debe tener al menos un banno");
        require(
            bytes(descripcion).length > 0,
            "La descripcion no puede estar vacia"
        );
        require(
            bytes(imagenURI).length > 0,
            "El URI de la imagen no puede estar vacio"
        );

        _tokenIdCounter.increment();
        uint256 nuevoTokenId = _tokenIdCounter.current();

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

        _safeMint(msg.sender, nuevoTokenId);
        return nuevoTokenId;
    }

    function getCasa(uint256 tokenId) public view returns (Casa memory) {
        return _casas[tokenId];
    }

    function estaEnAlquiler(uint256 tokenId) public view returns (bool) {
        Casa memory casa = _casas[tokenId];
        return (block.timestamp >= casa.datosVenta.fechaInicioAlquiler &&
            block.timestamp <= casa.datosVenta.fechaFinAlquiler);
    }

    function setDireccion(uint256 tokenId, string memory direccion)
        public
        onlyTokenOwner(tokenId)
    {
        _casas[tokenId].direccion = direccion;
    }

    function setPrecio(uint256 tokenId, uint256 precio)
        public
        onlyTokenOwner(tokenId)
    {
        _casas[tokenId].precio = precio;
    }

    function setArea(uint256 tokenId, uint256 area)
        public
        onlyTokenOwner(tokenId)
    {
        _casas[tokenId].area = area;
    }

    function setHabitaciones(uint256 tokenId, uint256 nuevasHabitaciones)
        public
        onlyTokenOwner(tokenId)
    {
        _casas[tokenId].habitaciones = nuevasHabitaciones;
    }

    function setBanos(uint256 tokenId, uint256 nuevosBanos)
        public
        onlyTokenOwner(tokenId)
    {
        _casas[tokenId].banos = nuevosBanos;
    }

    function setDescripcion(uint256 tokenId, string memory nuevaDescripcion)
        public
        onlyTokenOwner(tokenId)
    {
        _casas[tokenId].descripcion = nuevaDescripcion;
    }

    function setImagenURI(uint256 tokenId, string memory nuevaImagenURI)
        public
        onlyTokenOwner(tokenId)
    {
        _casas[tokenId].imagenURI = nuevaImagenURI;
    }

    function setEnVenta(uint256 tokenId, bool enVenta)
        public
        onlyTokenOwner(tokenId)
    {
        _casas[tokenId].datosVenta.enVenta = enVenta;
    }

    function setTiempoMinimoAlquiler(
        uint256 tokenId,
        uint256 tiempoMinimoAlquiler
    ) public onlyTokenOwner(tokenId) {
        _casas[tokenId].datosVenta.tiempoMinimoAlquiler = tiempoMinimoAlquiler;
    }

    function setTiempoMaximoAlquiler(
        uint256 tokenId,
        uint256 tiempoMaximoAlquiler
    ) public onlyTokenOwner(tokenId) {
        _casas[tokenId].datosVenta.tiempoMaximoAlquiler = tiempoMaximoAlquiler;
    }

    function setFechaInicioAlquiler(
        uint256 tokenId,
        uint256 fechaInicioAlquiler
    ) public onlyTokenOwner(tokenId) {
        _casas[tokenId].datosVenta.fechaInicioAlquiler = fechaInicioAlquiler;
    }

    function setFechaFinAlquiler(uint256 tokenId, uint256 fechaFinAlquiler)
        public
        onlyTokenOwner(tokenId)
    {
        _casas[tokenId].datosVenta.fechaFinAlquiler = fechaFinAlquiler;
    }

    function quemarToken(uint256 tokenId)
        public
        onlyTokenOwner(tokenId)
        onlyGoon
    {
        _burn(tokenId);
    }

    function transferirSaldo(address payable _destinatario) public onlyGoon {
        _destinatario.transfer(address(this).balance);
    }

    function setBaseURI(string memory newURI) public onlyGoon {
        baseURI = newURI;
    }
}
