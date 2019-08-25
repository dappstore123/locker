/**
 *Submitted for verification at Etherscan.io on 2019-06-19
*/

pragma solidity ^0.5.0;

contract Lock {
    // address owner; slot #0
    // address unlockTime; slot #1
    constructor (address owner, uint256 unlockTime) public payable {
        assembly {
            sstore(0x00, owner)
            sstore(0x01, unlockTime)
        }
    }
    
    /**
     * @dev        Withdraw function once timestamp has passed unlock time
     */
    function () external payable { // payable so solidity doesn't add unnecessary logic
        assembly {
            switch gt(timestamp, sload(0x01))
            case 0 { revert(0, 0) }
            case 1 {
                switch call(gas, sload(0x00), balance(address), 0, 0, 0, 0)
                case 0 { revert(0, 0) }
            }
        }
    }
}

contract Lockdrop {
    enum Term {
        ZeroDay,
        OneDay,
        ThreeMo,
        SixMo,
        TwelveMo
    }
    
    // ETH locking events
    event Locked(address indexed owner, uint256 eth, Lock lockAddr, Term term, address toAddr, uint time);
    


    /**
     * @dev        Locks up the value sent to contract in a new Lock
     * @param      term         The length of the lock up
     * @param      toAddr  toAddr
     */
    function lock(Term term,address  toAddr)
        external
        payable
    {
        uint256 eth = msg.value;
        address owner = msg.sender;
        uint256 unlockTime = unlockTimeForTerm(term);
        // Create ETH lock contract
        Lock lockAddr = (new Lock).value(eth)(toAddr, unlockTime);
        // ensure lock contract has at least all the ETH, or fail
        assert(address(lockAddr).balance >= msg.value);
        emit Locked(owner, eth, lockAddr, term, toAddr, now);
    }

 
    function unlockTimeForTerm(Term term) internal view returns (uint256) {
        if (term == Term.ZeroDay) return now ;
        if (term == Term.OneDay) return now + 1 days;
        if (term == Term.ThreeMo) return now + 92 days;
        if (term == Term.SixMo) return now + 183 days;
        if (term == Term.TwelveMo) return now + 365 days;
        
        revert();
    }


}
