function onContentLoaded() {
  var accountSpan = document.getElementById("account");
  var account;
  var balance;

  
  account = web3.eth.accounts[0];
  balance = web3.eth.getBalance(account);
  
  if(typeof web3 === "undefined"){
    accountSpan.innerHTML =  
    "undefined";
  } else {
    accountSpan.innerHTML =  
    "account : " + account +"<br>"+ "balance : " + balance;
  }
  
document.addEventListener("DOMContentLoaded", onContentLoaded);
