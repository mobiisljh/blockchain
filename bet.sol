pragma solidity ^0.4.24;

contract RandomNumber {
    function generateRandomNumber(uint _max) constant public returns (uint) {
        uint _mod = 1;
        uint _block_timestamp = block.timestamp * block.timestamp;
        _mod = _mod * _block_timestamp % _max + 1;
        
        return (_mod);
    }
}

contract Team {
    
    string private name;
    
    uint private statsAttack;
    uint private statsDefence;
    uint private statsSpeed;
    uint private statsOrganization ;
    uint private statsSkill;
    
    uint Max = 100;
    
    
    RandomNumber RN = new RandomNumber();
        
    
    
    constructor (string _name) public {
        name = _name;
        
        statsAttack = RN.generateRandomNumber(Max);
        statsDefence = RN.generateRandomNumber(Max);
        statsSpeed = RN.generateRandomNumber(Max);
        statsOrganization = RN.generateRandomNumber(Max);
        statsSkill = RN.generateRandomNumber(Max);
        
    }
    
    function getName() public view returns(string) {
        return name;
    }
    
    function setStats (uint _statsAttack, uint _statsDefence, uint _statsSpeed, uint _statsOrganization, uint _statsSkill) public {
        statsAttack = _statsAttack;
        statsDefence = _statsDefence;
        statsSpeed = _statsSpeed;
        statsOrganization = _statsOrganization;
        statsSkill = _statsSkill;
    }
    
    function getStats ()  public view returns (uint, uint, uint, uint, uint) {
        return (statsAttack, statsDefence, statsSpeed, statsOrganization, statsSkill);
    }
    
    function getTotalStat() public view returns (uint){
        uint _totalstat = statsAttack + statsDefence + statsSpeed + statsOrganization + statsSkill;
        return _totalstat;
    }
}

contract Game {
    string Name;
    
    address[] TeamAddrList;
    address public WinTeamAddress;
    uint public totalBalance;
    uint public ratio;
    //mapping (address => Team) public Teams;
    mapping (address => uint) public teamBalance;
    
    constructor (string _Name) public {
        Name = _Name;
    }
    function getGameName() public view returns (string) {
        return Name;
    }
    function setWinTeamAddr (address _WinTeamAddress) public {
        WinTeamAddress = _WinTeamAddress;
    }
    
    function getWinTeamAddr () public view returns (address){
        return WinTeamAddress;
    }
    
    function addTeam(address _TeamAddr) public {
        TeamAddrList.push(address(_TeamAddr));
        //Teams[address(_team)]=_team;
    }
    
    function getTeam(Team _team) public {
        TeamAddrList.push(address(_team));
        //Teams[address(_team)]=_team;
    }
    
    function getTeamAddrList() public view returns (address[]) {
        return TeamAddrList;
    }
    
    function betting (address _teamaddr, uint _value) public payable {
        bettingBalance(_teamaddr, _value);
    }
    
    function bettingBalance (address _teamaddr, uint _value) private {
        teamBalance[_teamaddr] += _value;
        totalBalance += _value;
    }
    
    function getTeamBalance (address _teamaddr) view public returns(uint) {
        return teamBalance[_teamaddr];
    }
    
    function calcRatio (address _teamaddr) public returns (uint) {
        return ratio = totalBalance * 1000 / teamBalance[_teamaddr];
    }
}

contract Main {
    address[] private GameAddrList;
    address[] private TeamAddrList;
    mapping (address => Game) private Games;
    mapping (address => Team) private Teams;
    mapping (address => uint) private UserBalance;
    mapping (address => BettingInfo[]) private UserBettingInfo;
    uint Max = 100;
    
    struct BettingInfo {
        address GameAddr;
        address TeamAddr;
        uint BettingValue;
        bool withdrawn;
    }
    
    uint private feerate = 10;
    uint private feeBalance=0;
    address private Owner;
    
    
    constructor () public {
        Owner = msg.sender;
    }
    
    function getWinRate(address _GameAddr) public view returns (uint, uint, uint) {
        address _team1Address = Games[_GameAddr].getTeamAddrList()[0];
        address _team2Address  = Games[_GameAddr].getTeamAddrList()[1];
        
        uint _Team1Stat = Teams[_team1Address].getTotalStat();
        uint _Team2Stat = Teams[_team2Address].getTotalStat();
        uint _Team1WinRate = _Team1Stat * Max / (_Team1Stat + _Team2Stat) ;
        
        return (_Team1Stat, _Team2Stat, _Team1WinRate);
        
    }
    
    function teamsbelongtogame(address _GameAddr) public view returns(address[]){
        address[] memory gamebelongteamList = Games[_GameAddr].getTeamAddrList();
        return gamebelongteamList;
    }
    
    function setWinTeam(address _GameAddr) public {
        uint _Team1Stat;
        uint _Team2Stat;
        uint _Team1WinRate;
        (_Team1Stat, _Team2Stat, _Team1WinRate) = getWinRate(_GameAddr);
        
        RandomNumber RN = new RandomNumber();
        
        if (RN.generateRandomNumber(Max) < _Team1WinRate) {
            Games[_GameAddr].setWinTeamAddr(Games[_GameAddr].getTeamAddrList()[0]);
        } else {
            Games[_GameAddr].setWinTeamAddr(Games[_GameAddr].getTeamAddrList()[1]);
        }
    }
    
    function getWinTeam(address _GameAddr) public view returns (address){
        address _winTeam;
        _winTeam = Games[_GameAddr].getWinTeamAddr();
        return _winTeam;
    }
    
    modifier checkAddress (address _checkaddress) {
        require(
            msg.sender == _checkaddress,
            "go away!!"
            );
        _;
    }
    
    function changeOwner (address _nextOwner) public checkAddress(Owner){
        Owner = _nextOwner;
    }
    
    function getOwner () public view checkAddress(Owner) returns (address) {
        return Owner;
    }
    
    function contbalance () view public checkAddress(Owner) returns(uint) {
        return address(this).balance;
    }
    
    function test1_create_game_teams() public {
        address _gameaddress = createGame("Game1");
        address _teamaddress1 = createTeam("Team1");
        address _teamaddress2 = createTeam("Team2");
        addTeamToGame(_gameaddress, _teamaddress1);
        addTeamToGame(_gameaddress, _teamaddress2);
    }
    function test2_betting_to_first_team() public payable {
        betting(GameAddrList[0], TeamAddrList[0] );
    }
    function test3_betting_to_second_team() public payable {
        betting(GameAddrList[0], TeamAddrList[1]);
    }
    
    function createGame (string _geamName) public checkAddress(Owner) returns (address){
        Game newGame = new Game(_geamName);
        GameAddrList.push(address(newGame));
        Games[address(newGame)] = newGame;
        return address(newGame);
    }
    
    function createTeam(string _teamName) public checkAddress(Owner) returns (address){
        Team newTeam = new Team(_teamName);
        TeamAddrList.push(address(newTeam));
        Teams[address(newTeam)] = newTeam;
        return address(newTeam);
    }
    
    function addTeamToGame (address _GameAddr, address _TeamAddr) public checkAddress(Owner){
        Games[_GameAddr].addTeam(_TeamAddr);
    }
    
    function calcFee (uint _value) private returns (uint) {
        
        uint _fee = _value * feerate / 100;
        uint _bettingValue = _value * (100-feerate) / 100;
        feeBalance += _fee;
        
        return (_bettingValue);
    }
    
    function betting (address _GameAddr, address _TeamAddr) public payable {
        uint _value = msg.value;
        if (_value > 0) {
            uint _bettingValue = calcFee(_value);
            UserBalance[msg.sender] += _bettingValue;
            UserBettingInfo[msg.sender].push(BettingInfo(_GameAddr, _TeamAddr, _bettingValue, false));
        
            Games[_GameAddr].betting(_TeamAddr, _bettingValue);
        }
    }
    
    function withdrawal (uint BettingNumber) public payable {
        
        bool _withdrawn = UserBettingInfo[msg.sender][BettingNumber].withdrawn;
        if (_withdrawn == false) {
            msg.sender.transfer(calcWithdrawableAmount(BettingNumber));
            UserBettingInfo[msg.sender][BettingNumber].withdrawn = true;
        }
    }
    
    function getFeeBalance () public view checkAddress(Owner) returns (uint){
        return feeBalance;
    }
    
    function withdrawAll () public payable checkAddress(Owner) {
        Owner.transfer(address(this).balance);
    }
    
    function withdrawFee () public payable checkAddress(Owner) {
        Owner.transfer(feeBalance);
        feeBalance = 0;
    }
    
    function getUserBettingInfo(uint BettingNumber) public view returns(uint){
        uint _bettingValue = UserBettingInfo[msg.sender][BettingNumber].BettingValue;
        return _bettingValue;
    }
    
    function getUsetBettingCount() public view returns(uint) {
        uint _bettingCount = UserBettingInfo[msg.sender].length;
        return _bettingCount;
    }
    
    function calcWithdrawableAmount (uint BettingNumber) private returns (uint){
        address _GameAddr = UserBettingInfo[msg.sender][BettingNumber].GameAddr;
        address _TeamAddr = UserBettingInfo[msg.sender][BettingNumber].TeamAddr;
        uint _BettingValue = UserBettingInfo[msg.sender][BettingNumber].BettingValue;

        if (Games[_GameAddr].getWinTeamAddr() == _TeamAddr) {
            uint _ratio = Games[_GameAddr].calcRatio(_TeamAddr);
            uint _WithdrawableAmount = _BettingValue / 1000 * _ratio;
            return _WithdrawableAmount;
        } else {
            return 0;
        }
        
    }
    
    function getTeamStats(address _TeamAddr) view public returns (uint, uint, uint, uint, uint) {
        return Teams[_TeamAddr].getStats();
    }
    
    function getTeamName(address _TeamAddr) view public returns (string){
        return Teams[_TeamAddr].getName();
    }
    
    function getUserBalance (address _userAddress) view public returns (uint) {
        return UserBalance[_userAddress];
    }
    
    function getGameAddrList () view public returns (address[]) {
        return GameAddrList;
    }
    
    function getGameName(address _gameAddress) public view returns (string){
        return  Games[_gameAddress].getGameName();
    }
    
    function getTeamAddrList () view public returns (address[]) {
        return TeamAddrList;
    }
}
