// SPDX-License-Identifier: MIT
pragma solidity ^0.8.10;

// - A Subscription service is started
// -  Payment can be deducted after a period of 30 days , and anyone can trigger it 
// - Payment is done from a particular ERC20 token , and approval needs to be given by payee

///  instance of an ERC20 token , which allows the function like transfer and approve
// import "https://github.com/OpenZeppelin/openzeppelin-contracts/blob/v4.0.0/contracts/token/ERC20/IERC20.sol" ;

contract SubscriptionPlan {

    // IERC20 token; 
    address public owner ;
    // uint256 public frequency; 
    // uint256 public amount ;
    /// frequency of payment

    struct Plan{
        address creator;
        uint amount;
        uint frequency;
    } 

    struct Subscription{
        address subscriber;
        uint planId ;
        uint start;
        uint nextPayment ;
    }

    /// intialize a subscriptions for a creator
    /// mapping from user address-->creator address--> Subscription taken
    mapping(address => mapping(address =>Subscription)) public subscriptions ;

    /// mapping from creator --> planID --> Plan
    mapping(address => mapping(uint => Plan)) public plans ;

     //mapping from the creator id to the creator address
    mapping(uint => address) creators;

    uint planId = 1;

    /// events for subscription creation , cancellation and payment 

    event subscriptionCreated(
        address subscriber,
        uint date
    ) ; 

    event subscriptionCancelled(
        address subscriber,
        uint date
    ) ;

    event paymentSent(
        address from ,
        address to ,
        uint amount,
        uint date
    ) ;


    /// costructor to take all the details needed for a subscription plan 
    constructor() {
        // token = IERC20(_token) ;
        owner = msg.sender ;
    

    }

    modifier onlyOwner() {
        require(msg.sender == owner ,"You are not owner");
        _;
    }

    modifier onlyCreator(uint _id) {
        require(creators[_id] == msg.sender ,"You are not a creator");
        _;
    }

    function addCreator(address _creator) public onlyOwner  {
        require(_creator != address(0),"Please enter a valid address");
        creators.push(_creator) ;
    }

    function creatPlan(uint id ,uint planAmount, uint frequency) public onlyOwner onlyCreator(id) returns(uint planId) {
        require(planAmount>0, "The amount for the plan should be > 0 ");
        require(frequency >0,"Time peroid should be > 0");
        plans[planId] = Plan(
            creators[id],
            planAmount,
            frequency
        ) ;
    }

    /// @dev to subscribe for the plan
    function subscribe(address _creator,uint _planId) external {
        Plan _plan = plans[_creator][_planId];
        uint amount = _plan.amount ;
        uint _frequency = _plan.frequency;
        require(msg.value >= amount,"Incorrect Amount");
        // token.transferFrom(msg.sender,merchant, amount) ;
        emit paymentSent(msg.sender, _creator, amount, block.timestamp);
        subscriptions[msg.sender] = Subscription(
            msg.sender,
            _planId,
            block.timestamp,
            block.timestamp + 30 days
        ) ;
        emit subscriptionCreated(msg.sender, block.timestamp);
    }


    /// @dev to cancel the subscription plan
    function cancel(address _creator, address _planId) external {
        Subscription storage subscription = subscriptions[msg.sender][_creator] ;
        require(subscription.subscriber != address(0), "This subscription does not exsist");
        require(subscription.planId == _planId,"Incorrect Plan Id");
        /// to delete any record , use delete 
        delete subscriptions[msg.sender][_creator] ;
        emit subscriptionCancelled(msg.sender, block.timestamp);
    }

    ///to pay the amount after the peroid   
    function pay(address subscriber ,address _creator , address _planId) external {
        Subscription storage subscription = subscriptions[subscriber][_creator] ;
        require(subscription.subscriber != address(0), "This subscription does not exsist");
        require(block.timestamp > subscription.nextPayment,"Not due yet");
        Plan _plan = plans[_creator][_planId];
        uint amount = _plan.amount ;
        require(msg.value == amount,"Incorrect amount")
        // token.transferFrom(subscriber, merchant , amount) ;
        emit paymentSent(subscriber, _creator , amount, block.timestamp);
        subscription.nextPayment += frequency ;
    }

}