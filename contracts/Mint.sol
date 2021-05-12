// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC1155/ERC1155.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

contract Mint is ERC1155, Ownable {
    // collection list uint(id) => string(hash)
    mapping (uint => string) collection_list;
    // collection already created string(hash) => bool()
    mapping (string => bool) collection_check;
    // collection counter
    uint collection_counter;

    // NFT card list uint (id) => string (hash) 
    // this list is according to cards, not collection
    mapping (uint => bytes32) nft_hash_list;
    // NFT card list every collection
    // uint (collection_id) => uint (nft_collection_id) => uint (nft_global_id)
    mapping (uint => mapping(uint => uint)) nft_per_collection;
    // nft global counter
    uint nft_counter;
    // NFT card counter every collection
    // uint (collection_id) => uint (collection_capacity)
    mapping (uint => uint) nft_counter_per_collection;

    // list of saling nft uint(saling_id) => uint (nft_global_id)
    mapping(uint => uint) selling_list;
    // selling list counter
    uint selling_list_counter;
    // constructor
    constructor() public ERC1155("") Ownable() {}

    // Create Collection
    function create_collection (string memory _hash) public returns (bool) {
        // require : collection name cannot be empty string
        require(bytes(_hash).length > 0, "collection name cannot be empty string");
        // require : collection can not be already created
        require(collection_check[_hash] == false, "collection can not be already created");

        collection_list[collection_counter] = _hash;
        collection_check[_hash] = true;
        collection_counter++;

        return true;
    }
    // return total amount of collection  
    function get_collection_count() public view returns (uint) {
        return collection_counter;
    }
    // get collection hash by collection id
    function get_collection_hash(uint _id) public view returns (string memory) {
        // require : collection ID _id is not external to the total amount of collection
        require(_id < collection_counter, "collection ID _id is not external to the total amount of collection");

        return collection_list[_id];
    }

    // mint single NFT 
    // params: NFT hash, collection ID, amount
    function single_mint (bytes32 _hash, uint _collection_id, uint _amount) public returns (uint) {
        // store hash value of the new nft
        nft_hash_list[nft_counter] = _hash;

        uint collection_capacity = nft_counter_per_collection[_collection_id];
        // store the nft global id with collection id and nft_collection_id
        nft_per_collection[_collection_id][collection_capacity] = nft_counter;
        nft_counter_per_collection[_collection_id]++;

        // _balances[id][account] = amount (@openzeppelin/contracts/ERC1155.sol)
        _mint(msg.sender, nft_counter, _amount, "");    
        nft_counter ++;

        return nft_counter;
    }

    // mint multiple nft
    // function one(bytes1[] memory names) public view returns (uint){
    //     uint len = names.length;
    //     bytes32[2] memory others = [bytes32("one"), bytes32("two")];
    //     return len;
    // }
    function batch_mint (bytes32[] memory _hashes, uint[] memory _collection_ids, uint[] memory _amounts) public returns (uint) {
        // require : length of _hashes and _collection_ids and _amounts have to equal
        require(_hashes.length == _collection_ids.length, "`_hashes` size has to be equal to `_collection_ids` size");
        // the size of nfts which has to be minted
        uint length = _hashes.length;
        for (uint i = 0 ; i < length ; i++) {
            single_mint(_hashes[i], _collection_ids[i], _amounts[i]);
        }
    }

    // Get nft hash by nft id
    function get_nft_hash (uint _nft_id) public view returns (bytes32) {
        // require : _nft_id is available, so can not be exceed to total nft counter
        require(_nft_id < nft_counter, "nft id can not be exceed to the total nft counter");

        return nft_hash_list[_nft_id];
    }

    // Get total nft counter
    function get_nft_counter () public view returns (uint) {
        return nft_counter;
    }

    // Get total nft counter every collection by collection_id
    function get_nft_counter_per_collection (uint _collection_id) public view returns (uint) {
        // require : _collection_id can not be exceed to the collection amount
        require(_collection_id < collection_counter, "_collection_id can not be exceed to the collection amount");

        return nft_counter_per_collection[_collection_id];
    }
    /////////////////////////////////////////
    //             Trading                 //
    /////////////////////////////////////////
    // add new nft on the selling list
    function set_selling_list (uint nft_global_id) public returns(uint) {
        // require : nft_global_id has to be available under the nft global counter
        require(nft_global_id < nft_counter, "nft id has to be under the nft global counter");

        selling_list[selling_list_counter] = nft_global_id;
        selling_list_counter++;
        return selling_list_counter;
    }
    // remove nft from selling list
    function remove_selling_item (uint nft_global_id) public returns(uint) {

    }
}