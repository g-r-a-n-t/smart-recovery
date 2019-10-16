pragma solidity >=0.4.21 <0.6.0;

contract SmartRecovery {
  struct Account {
    uint8[] questions;
    uint256 balance;
    bytes32 target;
    bytes32 salt;
  }

  struct Proof {
    bytes32 key;
    bytes32 commit;
    uint256 time;
    bytes32 reveal;
    uint256 salt;
  }

  mapping(address => Proof) public proofs;
  mapping(bytes32 => Account) public accounts;
  string[] public questionPool;

  function createAccount(
    bytes32 key,
    uint8[] questions,
    bytes32 target
  )
    public
    payable
  {
    accounts[key] = Account(
      questions,
      msg.value,
      target
    )
  }

  function startRecovery(
    bytes32 key,
    bytes32 commit
  )
    public
  {
    proofs[msg.sender].key = key;
    proofs[msg.sender].commit = commit;
    proofs[msg.sender].reveal = reveal;
  }

  function finishRecovery(
    bytes32 reveal,
    uint256 salt
  )
    public
  {
    proofs[msg.sender].reveal = reveal;
    proofs[msg.sender].salt = salt;
    if validProof(msg.sender) {
      msg.sender.transfer(
        accounts[proofs[msg.sender].key].balance
      )
    }
  }

  function validProof(
    address proover
  )
    internal
    view
    returns (bool)
  {
    Proof proof = proofs[proover];
    Account account = accounts[proof.key];
    return now - proof.time > 2 minutes &&
           sha256(
             abi.encodePacked(proof.reveal, '-', proof.salt)
           ) == commit &&
           sha256(reveal) == account.target;
  }
}