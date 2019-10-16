pragma solidity >=0.5.0 <0.6.0;

contract SmartRecovery {
  struct Account {
    uint8[] questions;
    uint256 balance;
    bytes32 target;
    uint256 salt;
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
    uint8[] memory questions,
    bytes32 target,
    uint256 salt
  )
    public
    payable
  {
    accounts[key] = Account(
      questions,
      msg.value,
      target,
      salt
    );
  }

  function startRecovery(
    bytes32 key,
    bytes32 commit
  )
    public
  {
    proofs[msg.sender].key = key;
    proofs[msg.sender].commit = commit;
    proofs[msg.sender].time = now;
  }

  function finishRecovery(
    bytes32 reveal,
    uint256 salt
  )
    public
  {
    proofs[msg.sender].reveal = reveal;
    proofs[msg.sender].salt = salt;
    if (validProof(msg.sender)) {
      msg.sender.transfer(
        accounts[proofs[msg.sender].key].balance
      );
    }
  }

  function validProof(
    address proover
  )
    internal
    view
    returns (bool)
  {
    Proof memory proof = proofs[proover];
    Account memory account = accounts[proof.key];
    return now - proof.time > 2 minutes &&
           sha256(
             abi.encodePacked(proof.reveal, '-', proof.salt)
           ) == proof.commit &&
           sha256(abi.encode(proof.reveal)) == account.target;
  }
}
