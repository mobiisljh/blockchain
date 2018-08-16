function onContentLoaded() {
  var accountSpan = document.getElementById("account");

  accountSpan.innerHTML =  
    (typeof web3 === "undefined" ? "undefined" : "OK");
  //web3.eth.accounts
}
document.addEventListener("DOMContentLoaded", onContentLoaded);
