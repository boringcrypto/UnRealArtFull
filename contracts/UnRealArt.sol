//SPDX-License-Identifier: MIT
pragma solidity 0.8.9;

import "@boringcrypto/boring-solidity/contracts/libraries/BoringAddress.sol";
import "@boringcrypto/boring-solidity/contracts/libraries/Base64.sol";
import "@boringcrypto/boring-solidity/contracts/ERC1155.sol";

// Simple contract for registering series of NFT artworks
// Contract isn't very flexible on purpose. Trying to keep it as simple as possible, since no audits are done and minimal testing.
contract UnRealArtV2 is ERC1155 {
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
        uint256 price; // Price
        // Each image should be added to IPFS **individually**. This means that anyone owning the
        // NFT only needs to keep a copy of their picture to proof ownership in the (far) future,
        // not the entire series as is the case with a lot of PFP NFTs :D
        string[] artworks; // List of IPFS v0 CIDs of the artworks "Qm...."
    }

    Series[] public series;

    function getSerie(uint256 serie) public view returns (Series memory) {
        return series[serie];
    }

    function seriesCount() public view returns (uint256) {
        return series.length;
    }

    event LogCreateSeries(uint256 indexed index, address indexed to, uint256 editions);
    event LogBuy(uint256 indexed serie, uint256 indexed artwork, uint256 price, address indexed gallery);

    function createSeries(
        string calldata author,
        string calldata name,
        string calldata description,
        string calldata process,
        uint256 price,
        string[] calldata imageUrls,
        address to
    ) public returns (uint256 index) {
        // Get the index of the new series in the array
        index = series.length;

        // Initialize a new series with name and description.
        // Creator is set to the sender
        Series memory s;
        s.creator = to;
        s.author = author;
        s.name = name;
        s.description = description;
        s.process = process;
        s.price = price;

        series.push(s);

        for (uint256 i = 0; i < imageUrls.length; i++) {
            _mint(
                to,
                index * uint256(1e6) + series[index].artworks.length,
                1
            );
            series[index].artworks.push(imageUrls[i]);
        }

        emit LogCreateSeries(index, to, 1);
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
        uint256 id = uint256(uint32(serie)) * 1e6 + uint256(uint32(artwork));

        require(balanceOf[series[serie].creator][id] == 1, "Not for sale"); // Has to be owned by the creator (series owner), could have been transferred
        uint256 price = series[serie].price;
        // Check if enough ETH was sent. Not really needed as we attempt the actual transfer later.
        require(msg.value >= price, "Not enough funds sent");
        require(msg.sender != series[serie].creator, "Cannot buy own work");

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
        return (series[id / 1e6].creator, price / 10);
    }

    // From OpenZeppelin Math.sol
    function log10(uint256 value) internal pure returns (uint256) {
        uint256 result = 0;
        unchecked {
            if (value >= 10**64) {
                value /= 10**64;
                result += 64;
            }
            if (value >= 10**32) {
                value /= 10**32;
                result += 32;
            }
            if (value >= 10**16) {
                value /= 10**16;
                result += 16;
            }
            if (value >= 10**8) {
                value /= 10**8;
                result += 8;
            }
            if (value >= 10**4) {
                value /= 10**4;
                result += 4;
            }
            if (value >= 10**2) {
                value /= 10**2;
                result += 2;
            }
            if (value >= 10**1) {
                result += 1;
            }
        }
        return result;
    }

    // From OpenZeppelin Strings.sol
    bytes16 private constant _SYMBOLS = "0123456789abcdef";

    function toString(uint256 value) internal pure returns (string memory) {
        unchecked {
            uint256 length = log10(value) + 1;
            string memory buffer = new string(length);
            uint256 ptr;
            /// @solidity memory-safe-assembly
            assembly {
                ptr := add(buffer, add(32, length))
            }
            while (true) {
                ptr--;
                /// @solidity memory-safe-assembly
                assembly {
                    mstore8(ptr, byte(mod(value, 10), _SYMBOLS))
                }
                value /= 10;
                if (value == 0) break;
            }
            return buffer;
        }
    }

    function uri(uint256 id) external view override returns (string memory) {
        uint256 serie = id / 1e6;
        uint256 artwork = id % 1e6;

        // solhint-disable quotes
        string memory json_part1 = string(abi.encodePacked(
            '{"name":"',
            series[serie].name,
            " ", toString(artwork + 1),
            '","description":"',
            series[serie].description,
            '","image":"ipfs://ipfs/',
            series[serie].artworks[artwork]
        ));

        string memory json_part2 = string(abi.encodePacked(
            '","external_url": "https://un-real-art.com/#/image/', toString(serie), '/', toString(artwork), 
            '","decimals":0,"properties":{"author":"',
            series[serie].author,
            '","process":"',
            series[serie].process,
            '"}}'
        ));

        return
            string(
                abi.encodePacked(
                    "data:application/json;base64,",
                    abi
                        .encodePacked(json_part1, json_part2)
                        .encode()
                )
            );
    }
}
