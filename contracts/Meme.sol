pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC1155/ERC1155.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";

contract Meme is ERC1155, Ownable{
    
    struct NFT {
        string hash_;
        uint e_price_;
        uint d_price_;
    }
    NFT[] nft_list;
    struct Collection {
        string hash_;
        address creator_;
    }
    Collection[] collection_list;
    struct Sell {
        uint nft_id_;
        uint e_price_;
        uint d_price_;
        address payable owner_;
        uint amount_;
    }
    Sell[] sell_list;

    uint[] black_list;
    mapping (uint => bool) isBlacklist;

    address payable eth_receiver;

    IERC20 public dankToken;

    address[] public admin_list;

    constructor(
        address payable _ethReceiver,
        IERC20 dankToken_
    ) ERC1155("") Ownable() {
        require(_ethReceiver != address(0));
        require(address(dankToken_) != address(0), "Invalid token");
        eth_receiver = _ethReceiver;
        dankToken = dankToken_;
        admin_list.push(eth_receiver);
    }

    function Set_admin (address new_admin_) public onlyOwner returns (bool) {
        require(new_admin_ != address(0), "address can not be empty");
        // require(new_admin_ != eth_receiver, "main administrator can not be pushed");

        admin_list.push(new_admin_);

        return true;
    }

    function Get_admin () public view returns (address[] memory) {
        return admin_list;
    }

    function Remove_admin (uint id_) public onlyOwner returns (bool) {
        require(id_ < admin_list.length, "id_ has to be less than array capacity");

        delete admin_list[id_];

        return true;
    }

    function is_admin(address user_) public view returns (bool) {
        for (uint i = 0 ; i < admin_list.length ; i++) {
            if (admin_list[i] == user_)
                return true;
        }
        return false;
    }

    function Set_nft (string memory hash_, uint amount_, uint e_price_, uint d_price_) public {
        // require : hash_ can not be empty string
        require(bytes(hash_).length > 0, "hash_ can not be empty string");
        // require : amount can not be zero or less than zero
        require(amount_ > 0, "amount can not be zero or less than zero");
        _mint(msg.sender, nft_list.length, amount_, "");

        NFT memory temp = NFT(hash_, e_price_, d_price_);
        nft_list.push(temp);
    }
    //(bool platformTransferSuccess,) = platformFeeRecipient.call{value : platformFeeInETH}("");
    //require(platformTransferSuccess, "NFTAuction.resultAuction: Failed to send platform fee");
    function Batch_set_nft (string[] memory hashes_, uint[] memory amounts_, uint[] memory e_prices_, uint[] memory d_prices_) public {
        require(hashes_.length == amounts_.length, "have same amount");
        require(hashes_.length == e_prices_.length, "have same amount");
        require(hashes_.length == d_prices_.length, "have same amount");

        for (uint i = 0 ; i < hashes_.length ; i++) {
            Set_nft(hashes_[i], amounts_[i], e_prices_[i], d_prices_[i]);
        }
    }

    function Set_collection(string memory hash_) public {
        // require : hash_ can not be empty string
        require(bytes(hash_).length > 0, "hash_ can not be empty string");
        // require : msg.sender has to be admin list
        require(is_admin(msg.sender), "msg.sender has to become admin");

        Collection memory temp = Collection(hash_, msg.sender);
        collection_list.push(temp);
    }

    function Get_collection(uint id_) public view returns (string memory, address) {
        // require : id has to be less than the collection amount
        require( id_ < collection_list.length, "id has to be less than the collection amount");

        return (
            collection_list[id_].hash_,
            collection_list[id_].creator_
        );
    }

    function Remove_collection(uint id_) public returns (bool) {
        // require : id has to be less than the collection amount
        require( id_ < collection_list.length, "id has to be less than the collection amount");
        // require : msg.sender has to be admin list
        require(is_admin(msg.sender), "msg.sender has to become admin");

        delete collection_list[id_];

        return true;
    }

    function Get_nft (uint id_) public view returns (string memory, uint, uint) {
        return (
            nft_list[id_].hash_,
            nft_list[id_].e_price_,
            nft_list[id_].d_price_
        );
    }

    function Get_nft_amount () public view returns (uint) {
        return nft_list.length;
    }

    function Get_list_fee (uint price_) public view returns (uint) {
        return (price_/100);
    }
    function Set_sell (uint id_, uint e_price_, uint d_price_, uint amount_) public payable returns(uint){
        // require : id_ is avaliable 
        require( id_ < nft_list.length, "ID has to be less than nft list length");
        // require : set at least one of two coins
        require ( (e_price_ > 0) || (d_price_ > 0), "set at least one of two coins");
        // require : 1% fee
        if ( e_price_ == 0 && d_price_ > 0) {
            require(Get_list_fee(d_price_) * amount_ == msg.value, "1% fee");
            dankToken.transferFrom(msg.sender, eth_receiver, Get_list_fee(d_price_));
        } else if ( e_price_ > 0 && d_price_ == 0) {
            require(Get_list_fee(e_price_) * amount_ == msg.value, "1% fee");
            eth_receiver.call{value: Get_list_fee(e_price_)}("");
        } 

        // if ( e_price_ == 0 && d_price_ > 0) {
        //     require(Get_list_fee(d_price_) * amount_ == msg.value, "1% fee");
        //     dankToken.transferFrom(msg.sender, eth_receiver, Get_list_fee(d_price_));
        // } else if ( e_price_ > 0 && d_price_ == 0) {
        //     require(Get_list_fee(e_price_) * amount_ == msg.value, "1% fee");
        //     eth_receiver.call{value: Get_list_fee(e_price_)}("");
        // } else if ( e_price_ > 0 && d_price_ > 0) {
        //     require((Get_list_fee(e_price_) + Get_list_fee(d_price_)) * amount_ == msg.value, "1% fee");
        //     dankToken.transferFrom(msg.sender, eth_receiver, Get_list_fee(d_price_));
        //     eth_receiver.call{value: Get_list_fee(e_price_)}("");
        // }
        // require : amount_ has to be available
        require((amount_>0) && ( balanceOf(msg.sender, id_) >= amount_ ), "amount_ has to be available");
        // require :  token is not in the black list
        require(isBlacklist[id_] != true, "Token of black list can not be sold.");
        
        Sell memory sell_temp = Sell(id_, e_price_, d_price_, payable(msg.sender), amount_);
        sell_list.push(sell_temp);

        // if ( e_price_ == 0 && d_price_ > 0) {
        //     dankToken.transferFrom(msg.sender, eth_receiver, Get_list_fee(d_price_));
        // } else if ( e_price_ > 0 && d_price_ == 0) {
        //     eth_receiver.call{value: Get_list_fee(e_price_)}("");
        // } else if ( e_price_ > 0 && d_price_ > 0) {
        //     dankToken.transferFrom(msg.sender, eth_receiver, Get_list_fee(d_price_));
        //     eth_receiver.call{value: Get_list_fee(e_price_)}("");
        // }

        return (sell_list.length - 1);
    }

    function Update_sell (uint sell_id_, uint e_price_, uint d_price_, uint amount_) public {
        // require : id_ is avaliable 
        require( sell_id_ < sell_list.length, "ID has to be less than sell list length");
        // require : set at least one of two coins
        require ( (e_price_ > 0) || (d_price_ > 0), "set at least one of two coins");
        // require : amount_ has to be available
        require((amount_>0) && ( balanceOf(msg.sender, sell_list[sell_id_].nft_id_) >= amount_ ), "amount_ has to be available");
        sell_list[sell_id_].e_price_ = e_price_;
        sell_list[sell_id_].d_price_ = d_price_;
        sell_list[sell_id_].amount_ = amount_;
    }

    function Remove_selling (uint id_) public onlyOwner {
        // require : id_ is avaliable 
        require( id_ < sell_list.length, "ID has to be less than sell list length");
        delete sell_list[id_];
    }

    function Get_sell (uint id_) public view returns (uint, uint, address, uint) {
        // require : id_ is avaliable 
        require( id_ < sell_list.length, "ID has to be less than sell list length");
        return (
            sell_list[id_].e_price_,
            sell_list[id_].d_price_,
            sell_list[id_].owner_,
            sell_list[id_].amount_
        );
    }

    function Get_sell_fee (uint price_) public view returns(uint) {
        // require : price_ has to be available
        require( price_ > 0, "price_ has to be available");
        return price_ * 25 / 1000;
    }
    function Get_real_price (uint price_) public view returns (uint) {
        // require : price_ has to be available
        require( price_ > 0, "price_ has to be available");
        return price_ * 975 / 1000;
    }
    function Buying (uint sell_id_, uint amount_, uint token_kind_) public payable {
        // require : sell_id_ has to be less than sell list length
        require( sell_id_ < sell_list.length,  "sell_id_ has to be less than sell list length");
        // require : buying amount has to be avaliable
        require( amount_ <= sell_list[sell_id_].amount_, "amount has to less than capacity" );
        
        safeTransferFrom( msg.sender, sell_list[sell_id_].owner_, sell_list[sell_id_].nft_id_, amount_, "" );
        if (amount_ == sell_list[sell_id_].amount_) {
            Remove_selling(sell_id_);
        } else {
            sell_list[sell_id_].amount_ = sell_list[sell_id_].amount_ - amount_;
        }
        
        if( token_kind_ == 0 ){
            sell_list[sell_id_].owner_.transfer(Get_real_price(sell_list[sell_id_].e_price_));
            eth_receiver.call{value: Get_sell_fee(sell_list[sell_id_].e_price_)}("");
        } else {
            dankToken.transferFrom(msg.sender, eth_receiver, Get_sell_fee(sell_list[sell_id_].d_price_));
            dankToken.transferFrom(msg.sender, sell_list[sell_id_].owner_, Get_real_price(sell_list[sell_id_].d_price_));
            // sell_list[sell_id_].owner_.transfer(Get_real_price(sell_list[sell_id_].d_price_));
            // eth_receiver.call{value: Get_sell_fee(sell_list[sell_id_].d_price_)}("");
        }

    }
    
    function Set_blacklist (uint id_) public onlyOwner {
        // require : id_ has to be less than nft length
        require(id_ < nft_list.length, "id_ has to be less than nft length");
        // require : id_ has not already set in the black list
        require(isBlacklist[id_] == false, "id_ has not already set in the black list");
        black_list.push(id_);
        isBlacklist[id_] = true;
    }

    function check_blacklist (uint id_) public view returns (bool) {
        // require : id_ has to be less than nft length
        require(id_ < nft_list.length, "id_ has to be less than nft length");
        return isBlacklist[id_];
    }
    // receive() payable external {}
    // function getETH() external onlyOwner {
    //     payable(msg.sender).transfer(address(this).balance);
    // }
}