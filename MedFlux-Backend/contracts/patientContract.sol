// SPDX-License-Identifier: MIT
pragma solidity ^0.6.12;

import "ipfs://QmRX19GLCr9UkTfyq3J33ywKhSJYxaroWaA86u4tb5HTd7";
import "https://ipfs.io/ipfs/QmRX19GLCr9UkTfyq3J33ywKhSJYxaroWaA86u4tb5HTd7?filename=ptbxl_database.csv";

contract MedicalRecords {
    // medical record
    struct MedicalRecord {
        string patientName;
        uint256 patientId;
        string doctorName;
        string diagnosis;
        uint256 timestamp;
    }

    //mapping of addresses to medical records
    mapping(address => MedicalRecord) private medicalRecords;

    // set values
   function setter(string memory _patientName, uint256 _patientId, string memory _doctorName, string memory _diagnosis) public {
        
        //require(msg.sender == doctorAddress);

        // Create a new medical record.
        MedicalRecord memory record = MedicalRecord({
            patientName: _patientName,
            patientId: _patientId,
            doctorName: _doctorName,
            diagnosis: _diagnosis,
          //  timestamp: block.timestamp
        });

        // Store the medical record
        medicalRecords[patientAddress] = record;
    }

    // function to view record
    function viewMedicalRecord() public view returns (string memory, uint256, string memory, string memory, uint256) {
        // Verify sender is patient
        require(msg.sender == patientAddress, "Invalid user");

        // Retrieve ipfs hash from the record
        string memory ipfsHash = getIpfsHash(patientAddress);

        // if hash is empty, return empty values for the record
        if (bytes(ipfsHash).length == 0) {
            return ("", 0, "", "", 0);
        }

        // Retrieve record from ipfs and return its values
        MedicalRecord memory record = getMedicalRecordFromIpfs(ipfsHash);
         // In case record does not exist
        require(record.timestamp > 0, "Patient has no medical record.");
    
        return (record.patientName, record.patientId, record.doctorName, record.diagnosis, record.timestamp);
    }

    //function to retrieve ipfs hash for a medical record
    function getIpfsHash(address _patientAddress) private view returns (string memory) {
        return medicalRecords[_patientAddress].ipfsHash;
    }

    //retrieve a medical record from ipfs
    function getMedicalRecordFromIpfs(string memory _ipfsHash) private view returns (MedicalRecord memory) {
        return MedicalRecord(ipfs[_ipfsHash]);
    }
}
