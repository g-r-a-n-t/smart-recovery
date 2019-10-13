# Smart Recovery

This tool allows people to store and recover funds in an Ethereum smart contract using personal information. It attempts to maximize and balance security and usability.

## Overview

Recovery questions is a method of recovering access to one's account in the event that the account owner has forgotten their login credentials. It involves storing personal information about an individual upon account creation and then asking the user to repeat the same information during recovery, if the user gets enough information correct, they gain access to the account.

This method of recovery has become less popular on traditional web-services with the introduction of multifactor authentication, but may be useful on smart contract platforms since it does not require a trusted third party.

The goal of this project is to create a fund recovery service that a user can confidently recover their funds from with a reasonable amount of security.

## Model

Let's say we have a malicious actor named *Alice* and a fund holder named *Bob*. Bob would like to store his funds behind a few recovery questions and Alice would like to steal these funds from Bob. For Alice to do so, she must obtain a set of answers to each of his recovery questions such that at least one answer is correct in each set. In order for her to compute the correct answer list, she must try every combination of the answer sets. So, if there are say, 6 questions, and each set has 10 possible answers, she will compute 1 million combinations. If she is completely confident in each answer, then she only needs to compute 1.

For Alice to narrow down the set of possible answers into something computable, she must do a certain amount of investigation into Bob's personal life. We will refer to the cost of investigating a single question as *C*. Of course, the actual value of C varies among each question and the threshold for what is considered "computable" is debatable, but for the sake of this writeup, we will assume it exists, and try to maximize the total cost. In the case above, where Bob uses 6 recovery questions, the total cost is 6C.

## Construction

### Proving Knowledge

Proving that someone knows the answers to a series of questions in a smart-contract is conceptually simple, as using either a proof-of-preimage or a commit-reveal scheme should suffice. With this being the case, the exact method of proving knowledge of the answers will not be discussed further.

### Obfuscating Questions

With the total cost being directly related to the number of questions Alice needs to investigate, it follows that the total cost of a successful attack could be increased by making it so that Alice needs to investigate more questions.

To accomplish this, a pool of questions is stored within the contract as an indexible list, and Bob's questions are stored within an ordered list of 8 bit unsigned integers, where the index of the next questions is masked by the digest of the answer to the previous question. This makes it so that uncertainty in any answer increases the number of questions Alice needs to investigate.

_Here are some trees to illustrate:_

    Legend:
      Q<n> = Question
      |    = Answer

                   Not Masked
                   ==========

                       Q1
          --------------------------
          |            |           |
          Q2           Q2          Q2
     -----------  -----------  ---------
     |    |    |  |    |    |  |   |   |
     Q3   Q3   Q3 Q3  Q3   Q3  Q3  Q3  Q3

                     Masked
                   ==========

                       Q1
          --------------------------
          |            |           |
          Q2           Q6          Q10
     -----------  -----------  ---------
     |    |    |  |    |    |  |   |   |
     Q3   Q4   Q5 Q7   Q8  Q9 Q11 Q12 Q13

In the trees above, Bob has used three recovery questions to store his funds and Alice has gathered answer sets of size 3 for each question. In the Not Masked version, the total cost of constructing the tree for Alice is 3C, since there are 3 questions that she must create answer sets for. In the Masked tree however, Alice must investigate 13 questions in total, leading to a total cost of 13C (Note: this number could be slightly smaller due to repeats).

In practice when using the Masked version, where more security questions are used by Bob, it's reasonable to assume that Alice will need to investigate every single question before constructing a tree. So in the case where Bob uses 6 questions and if the pool size is 32, the total cost for the Masked version would be 32C, while the total cost for Not Masked version would be 6C.

### Answer Length

To improve the recovery experience, the length of each answer could be stored in the 8 bit unsigned integer along with the question pool index (`5 bits` to an index 0-31 and `3 bits` to an answer length 3-11). This helps in situations such as: "Who was your childhood best friend?" where the user knows the answer is either "chris" or "christopher", but does not remember which one they originally entered.

Of course, this weakens the security somewhat, and for that reason could be an optional feature.

### Good Questions

Questions used for recovery should have the following properties:
- _Private_: Not something that could be found easily in public records.
- _Variable_: Has more than a few possible answers.
- _Static_: The answer does not change over time.

**Examples of bad questions:**
- What is your mothers maiden name? (not private)
- Have you ever gotten into a car accident, yes or no? (not variable)
- What is your favorite song? (not static)

**Examples of good questions:**
- Who had your first kiss?
- What was your first full-time annual salary rounded to the nearest thousandth?
- What was the name of your first pet?

## Contract Design

### Constants
- `POOL_SIZE: 32`
- `NUM_QUESTIONS: 5`
- `MIN_ANSWER_LENGTH: 3`
- `MAX_ANSWER_LENGTH: 11`

### Data Structures

#### Account
| value     | type                     |
| ---       | ----                     |
| questions | `[uint8, NUM_QUESTIONS]` |
| balances  | `address -> uint256`     |
| target    | `bytes32`                |

### Globals
- `users: bytes32 -> Account`
- `question_pool: [string, POOL_SIZE]`

### Methods
- `create_user(key: bytes32, questions: [uint8, NUM_QUESTION], target: bytes32)`
- `store_funds(key: bytes32, token: address, amount: uint256)`
- `recover_funds(...)`

## Frontend Design
Should look nice.
