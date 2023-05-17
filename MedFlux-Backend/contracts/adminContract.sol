pragma solidity ^0.6.12;

import "ipfs://QmRX19GLCr9UkTfyq3J33ywKhSJYxaroWaA86u4tb5HTd7";
import "https://github.com/ipfs/interface-ipfs-core/blob/master/src/iface/ICore.sol";

contract EHRSystem {

    address public admin;
    ICore public ipfs;

    mapping(address => bool) public isDoctor;
    mapping(address => bool) public isPatient;

    struct Patient {
        string id;
        string name;
        string contact;
        string username;
        string password;
        string ipfsHash;
        address referredDoctor;
    }

    struct Doctor {
        string id;
        string name;
        string contact;
        string specialty;
        string department;
        string username;
        string password;
    }

    mapping(address => Patient) public patients;
    mapping(address => Doctor) public doctors;

    constructor (address ipfsAddress) public {
        admin = msg.sender;
        ipfs = ICore(ipfsAddress);
    }

    function registerDoctor(string memory doctorId, string memory doctorName, string memory doctorContact, string memory doctorSpecialty, string memory doctorDepartment, string memory doctorUsername, string memory doctorPassword) public {
        require(msg.sender == admin, "Only the admin can register a new doctor.");
        address doctorAddress = address(bytes20(sha256(abi.encodePacked(doctorId))));
        doctors[doctorAddress] = Doctor(doctorId, doctorName, doctorContact, doctorSpecialty, doctorDepartment, doctorUsername, doctorPassword);
        isDoctor[doctorAddress] = true;
    }

    function registerPatient(string memory patientId, string memory patientName, string memory patientContact, string memory patientUsername, string memory patientPassword) public {
        require(msg.sender == admin, "Only the admin can register a new patient.");
        address patientAddress = address(bytes20(sha256(abi.encodePacked(patientId))));
        patients[patientAddress] = Patient(patientId, patientName, patientContact, patientUsername, patientPassword, "", address(0));
        isPatient[patientAddress] = true;
    }

    function setMedicalRecord(address patientAddress, string memory ipfsHash) public {
        require(msg.sender == admin || isDoctor[msg.sender], "no Access");
        require(isPatient[patientAddress], "The specified address does not belong to a registered patient.");
        patients[patientAddress].ipfsHash = ipfsHash;
    }

    function getMedicalRecord(address patientAddress) public view returns (bytes memory) {
        require(msg.sender == admin || isDoctor[msg.sender], "No Access.");
        require(isPatient[patientAddress], "The specified address does not belong to a registered patient.");
        string memory ipfsHash = patients[patientAddress].ipfsHash;
        return ipfs.cat(ipfsHash);
    }

    function referDoctor(address patientAddress, address doctorAddress) public {
        require(msg.sender == admin || isDoctor[msg.sender], "No Access");
        require(isPatient[patientAddress], "The specified address does not belong to a registered patient.");
        require(isDoctor[doctorAddress], "The specified address does not belong to a registered doctor.");
        patients[patientAddress].referredDoctor = doctorAddress;
    }

    function getReferredDoctor(address patientAddress) public view returns (address) {
        require(msg.sender == admin || isDoctor[msg.sender], "No Access.");
        require(isPatient[patientAddress], "The specified address does not belong to a registered patient.");
        return patients[patientAddress].referredDoctor;
    }
}