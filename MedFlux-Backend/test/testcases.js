const DoctorContract = artifacts.require("DoctorContract");
const PatientContract = artifacts.require("PatientContract");
const AdminContract = artifacts.require("AdminContract");

contract("EHR System", (accounts) => {
  const adminAccount = accounts[0];
  const doctorAccount = accounts[1];
  const patientAccount = accounts[2];

  let adminContract;
  let doctorContract;
  let patientContract;

  before(async () => {
    adminContract = await AdminContract.new();
    doctorContract = await DoctorContract.new();
    patientContract = await PatientContract.new();
  });

  it("should allow the admin to register a new patient", async () => {
    // Call the registerPatient function in the admin contract
    await adminContract.registerPatient(patientAccount, "John Doe");

    // Retrieve the patient details and verify the registration
    const patientDetails = await adminContract.getPatientDetails(patientAccount);
    assert.equal(patientDetails.name, "John Doe", "Patient name does not match");
    assert.equal(patientDetails.isRegistered, true, "Patient is not registered");
  });

  it("should allow the admin to register a new doctor", async () => {
    // Call the registerDoctor function in the admin contract
    await adminContract.registerDoctor(doctorAccount, "Dr. Smith");

    // Retrieve the doctor details and verify the registration
    const doctorDetails = await adminContract.getDoctorDetails(doctorAccount);
    assert.equal(doctorDetails.name, "Dr. Smith", "Doctor name does not match");
    assert.equal(doctorDetails.isRegistered, true, "Doctor is not registered");
  });

  it("should allow the doctor to add new records for a patient", async () => {
    // Assume the doctor is logged in and authorized
    await doctorContract.addRecord(patientAccount, "Patient record #1");

    // Retrieve the records for the patient and verify the addition
    const patientRecords = await patientContract.getRecords(patientAccount);
    assert.equal(patientRecords.length, 1, "Record was not added");

    const record = patientRecords[0];
    assert.equal(record, "Patient record #1", "Record content does not match");
  });

  it("should allow the doctor to edit existing records for a patient", async () => {
    // Assume the doctor is logged in and authorized
    await doctorContract.editRecord(patientAccount, 0, "Updated patient record");

    // Retrieve the records for the patient and verify the modification
    const patientRecords = await patientContract.getRecords(patientAccount);
    assert.equal(patientRecords.length, 1, "Record count is incorrect");

    const record = patientRecords[0];
    assert.equal(record, "Updated patient record", "Record content was not updated");
  });

  it("should allow the patient to view their records", async () => {
    // Retrieve the records for the patient
    const patientRecords = await patientContract.getRecords(patientAccount);

    // Verify that the patient has access to their records
    assert.equal(patientRecords.length, 1, "Record count is incorrect");

    const record = patientRecords[0];
    assert.equal(record, "Updated patient record", "Record content does not match");
  });
});
