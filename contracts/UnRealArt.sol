//SPDX-License-Identifier: MIT
pragma solidity 0.8.9;

import "@boringcrypto/boring-solidity/contracts/libraries/BoringAddress.sol";
import "@boringcrypto/boring-solidity/contracts/libraries/Base64.sol";
import "@boringcrypto/boring-solidity/contracts/ERC1155.sol";

// Simple contract for registering series of NFT artworks
// Contract isn't very flexible on purpose. Trying to keep it as simple as possible, since no audits are done and minimal testing.
contract UnRealArt is ERC1155 {
    using BoringAddress for address;
    using Base64 for bytes;

    function supportsInterface(bytes4 interfaceID) public pure override returns (bool) {
        return super.supportsInterface(interfaceID) || interfaceID == 0x2a55205a; // EIP-2981 NFT Royalty Standard
    }

    struct Series {
        address creator;
        string author; // Twitter handle or name
        string name; // Short name of the series
        string description; // Description of the series, such as inspiration, etc
        string process; // Describe the tools & prompts used
        uint128 price; // Price
        // Each image should be added to IPFS **individually**. This means that anyone owning the
        // NFT only needs to keep a copy of their picture to proof ownership in the (far) future,
        // not the entire series as is the case with a lot of PFP NFTs :D
        string[] artworks; // List of IPFS v0 CIDs of the artworks "Qm...."
    }

    Series[] public series;

    // Keeping track of artworks that are sold. Instead of storing just a boolean, we store the address it was sold
    // to because gas cost is the same.
    mapping(uint256 => address) public soldTo;

    function getSerie(uint256 serie) public view returns (Series memory) {
        return series[serie];
    }

    function seriesCount() public view returns (uint256) {
        return series.length;
    }

    event LogCreateSeries(uint256 indexed index);
    event LogBuy(uint256 indexed serie, uint256 indexed artwork, uint128 price, address indexed gallery);

    function createSeries(
        string calldata author,
        string calldata name,
        string calldata description,
        string calldata process,
        uint128 price,
        string[] calldata imageUrls
    ) public returns (uint32 index) {
        // Get the index of the new series in the array
        index = uint32(series.length);

        // Initialize a new series with name and description.
        // Creator is set to the sender
        Series memory s;
        s.creator = msg.sender;
        s.author = author;
        s.name = name;
        s.description = description;
        s.process = process;
        s.price = price;

        series.push(s);

        for (uint256 i = 0; i < imageUrls.length; i++) {
            uint256 id = index * 1e18 + series[index].artworks.length;
            _mint(msg.sender, id, 1);
            series[index].artworks.push(imageUrls[i]);
        }

        emit LogCreateSeries(index);
    }

    // Reentrancy guard on the buy function
    bool private buying = false;

    function buy(
        uint32 serie,
        uint32 artwork,
        address gallery
    ) public payable {
        require(!buying, "Not again!");
        buying = true;
        uint256 id = uint32(serie) * 1e18 + uint32(artwork);

        require(soldTo[id] == address(0), "Already sold"); // Can only be sold once by the creator
        require(balanceOf[series[serie].creator][id] == 1, "Not for sale"); // Has to be owned by the creator (series owner), could have been transferred
        uint128 price = series[serie].price;
        // Check if enough ETH was sent. Not really needed as we attempt the actual transfer later.
        require(msg.value >= price, "Not enough funds sent");
        require(msg.sender != series[serie].creator, "Cannot buy own work");

        // Flag as sold
        soldTo[id] = msg.sender;

        _transferSingle(series[serie].creator, msg.sender, id, 1);

        // Refund any excess ETH by sending any remaining ETH on the contract back.
        msg.sender.sendNative(address(this).balance - price);

        // The creator gets the remaining 90%
        series[serie].creator.sendNative((price * 90) / 100);

        // The gallery that sold the artwork gets 10% commission
        // Sure, the buyer could redirect this back to themselves when they bypass the UI, but like
        // royalty payments, we rely on some honesty/convenience here. If no gallery is given, the 10%
        // goes to the platform
        (gallery != address(0) ? gallery : 0x9e6e344f94305d36eA59912b0911fE2c9149Ed3E).sendNative((price * 10) / 100);

        emit LogBuy(serie, artwork, price, gallery);
        buying = false;
    }

    function royaltyInfo(uint256 id, uint256 price) public view returns (address receiver, uint256 royaltyAmount) {
        return (series[id / 1e18].creator, price / 10);
    }

    function uri(uint256 id) external view override returns (string memory) {
        uint256 serie = id / 1e18;
        uint256 artwork = id % 1e18;

        // solhint-disable quotes
        return
            string(
                abi.encodePacked(
                    "data:application/json;base64,",
                    abi
                        .encodePacked(
                            '{"name":"',
                            series[serie].name,
                            '","description":"',
                            series[serie].description,
                            '","image":"ipfs://ipfs/',
                            series[serie].artworks[artwork],
                            '","decimals":0,"properties":{"author":"',
                            series[serie].author,
                            '","process":"',
                            series[serie].process,
                            '"}}'
                        )
                        .encode()
                )
            );
    }
}
