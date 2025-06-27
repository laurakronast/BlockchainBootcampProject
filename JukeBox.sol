// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;

contract Jukebox {
    //Varijable (bar 1 state)
    address payable public owner;
    uint public constant SONG_PRICE = 1 wei; //fiksirana cijena od 1 wei
    uint private songCount;
    
    struct Song {
        uint id;
        string title;
        string artist;
        address payable requester;
    }
    
    Song[] public songQueue;
    
    //eventi
    event SongAdded(uint id, string title, string artist, address requester);
    event SongPlayed(uint id, string title, string artist);
    
    //rukovanje greškama 
    error IncorrectPayment(uint sent, uint required);
    error EmptyString();
    
    //mod
    modifier onlyOwner() {
        require(msg.sender == owner, "Only owner can call this");
        _;
        //prvi require
    }
    
    //payable
    constructor() {
        owner = payable(msg.sender);
        songCount = 0;
    }
    
    //javna (public) funkcija za dodavanje pjesme
    function requestSong(string memory _title, string memory _artist) external payable {
        if (msg.value != SONG_PRICE) {
            revert IncorrectPayment(msg.value, SONG_PRICE);
        }
        if (bytes(_title).length == 0) {
            revert EmptyString();
        }
        if (bytes(_artist).length == 0) {
            revert EmptyString();
        }
        
        songCount++;
        songQueue.push(Song(songCount, _title, _artist, payable(msg.sender)));
        emit SongAdded(songCount, _title, _artist, msg.sender);
        //emit dodana pjesma
    }
    
    //vanjska (external) funkcija za puštanje pjesme (samo Owner)
    function playNextSong() external onlyOwner {
        require(songQueue.length > 0, "No songs in queue");
        //drugi require

        Song memory nextSong = songQueue[0];
        emit SongPlayed(nextSong.id, nextSong.title, nextSong.artist);
        //emit pjesma je puštena-odsvirana


        //ako je svirana makni iz reda čekanja
        for (uint i = 0; i < songQueue.length - 1; i++) {
            songQueue[i] = songQueue[i + 1];
        }
        songQueue.pop();
    }
    
    //duljina reda čekanja, view
    function getQueueLength() public view returns (uint) {
        return songQueue.length;
    }
    
    //trenutni red čekanja, view
    function getQueue() public view returns (Song[] memory) {
        return songQueue;
    }
    
    //isplata
    function withdraw() external onlyOwner {
        owner.transfer(address(this).balance);
    }
}
