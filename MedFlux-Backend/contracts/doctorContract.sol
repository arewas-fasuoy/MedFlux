// SPDX-License-Identifier: MIT
pragma solidity ^0.6.12;
import "ipfs://QmRX19GLCr9UkTfyq3J33ywKhSJYxaroWaA86u4tb5HTd7";
import "ipfs://QmPbmyG6Hk38VNvUC8MrzWZDxjCYSz24YXq3h4K4LykUaC/contracts/cid-v1/CID.sol";

contract Doctor {
    
    struct Patient {
        string name;
        uint256 patientId;
        //string doctorName;
        string condition;
        string ipfsHash;
    }
    
    // mapping of patient addresses to medical records
    mapping(address => Patient) private patients;
    
    //authorized doctor addresses
    mapping(address => bool) private authorizedDoctors;

    // authorize the contract creator as doctor
    constructor() public {
        authorizedDoctors[msg.sender] = true;
        emit DoctorAuthorized(msg.sender);
    }
    
    // events to emit on diff functionalities
    event MedicalRecordAdded(address indexed patientAddress, string name, uint256 patientId, string condition, string ipfsHash);
    event MedicalRecordUpdated(address indexed patientAddress, string name, uint256 patientId, string condition, string ipfsHash);
    event MedicalRecordViewed(address indexed doctorAddress, address indexed patientAddress, string name, uint256 age, string condition, string ipfsHash);
    event DoctorAuthorized(address indexed doctorAddress);
    event DoctorRevoked(address indexed doctorAddress);
    
    //restrict access to authorized doctors only
    modifier onlyAuthorizedDoctor() {
        require(authorizedDoctors[msg.sender], "Only authorized doctors can perform this action.");
    }
    
    
    //add a new medical record
    function addMedicalRecord(string memory _name, uint256 _id, string memory _condition, string memory _ipfsHash) public onlyAuthorizedDoctor {
        patients[msg.sender] = Patient(_name, _id, _condition, _ipfsHash);
        // every time a new medical record is added
        emit MedicalRecordAdded(msg.sender, _name, _id, _condition, _ipfsHash);
    }
    
    //update medical record
    function updateMedicalRecord(string memory _name, uint256 _id, string memory _condition, string memory _ipfsHash) public onlyAuthorizedDoctor {
        // Retrieve the patient's record
        Patient storage patient = patients[msg.sender];
        patient.name = _name;
        patient.patientId = _id;
        patient.condition = _condition;
        patient.ipfsHash = _ipfsHash;
        // every time a record is updated
        emit MedicalRecordUpdated(msg.sender, _name, _id, _condition, _ipfsHash);
    }
    
    // view medical record
    function getMedicalRecord() public view returns (string memory, uint256, string memory, string memory) {
        Patient memory patient = patients[msg.sender];
        return (patient.name, patient.patientId, patient.condition, patient.ipfsHash);
    }
    
    //generate a CID for given data
    function getIPFSHash(string memory _data) internal pure returns (string memory) {
        // Hash the data
         bytes32 hash = keccak256(bytes(_data));
        // encode the hash as a base32 string
        return CID.toBase32(CID.V1, hash);
    }
    
    //function that returns the CID for the patient's record.
    function generateIPFSHash(string memory _name, uint256 _id, string memory _condition) public pure returns (string memory) {
        string memory data = string(abi.encodePacked(_name, _id, _condition));
        return getIPFSHash(data);
        }

    // view medical record, given the patient's Ethereum address as input.
    function viewMedicalRecord(address _patientAddress) public onlyAuthorizedDoctor returns (string memory, uint256, string memory, string memory) {
        // get patient's data
        Patient memory patient = patients[_patientAddress];
        // every time record is viewed
        emit MedicalRecordViewed(msg.sender, _patientAddress, patient.name, patient.patientId, patient.condition, patient.ipfsHash);
        return (patient.name, patient.patientId, patient.condition, patient.ipfsHash);
    }

    // authorize other doctors
    function authorizeDoctor(address _doctorAddress) public onlyAuthorizedDoctor {
            //give access to the specified doctor
            authorizedDoctors[_doctorAddress] = true;
            // everytime when the doctor is authorized
            emit DoctorAuthorized(_doctorAddress);
        }
}