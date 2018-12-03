pragma solidity ^0.4.17;

contract Criptocerts{
    /*------ Data Models ------*/

    // Represents a certification issuer
    struct Issuer {
        address account;
        string name;
        string email;
        string description;
    }

    // Represents a certificate class
    struct CertificateClass {
        string name;
        string description;
        string criteria;
        address issuingInstitutionAddress;
    }

    // Represents an issued certificate
    struct IssuedCertificate {
        address issuingAddress;
        address recipientAddress;
        uint certificateId;
        bytes digitalSignature;
    }

    /*------ Data Storage ------*/

    // Stores an indexed list of registered issuers
    mapping(uint => Issuer) private registeredIssuers;
    uint public totalIssuers;

    // Stores an indexed list of certificate classes
    mapping(uint => CertificateClass) private registeredCertificates;
    uint public totalCertificates;

    // Stores an indexed list of registered isued certifications
    mapping(uint => IssuedCertificate) private issuedCertificates;
    uint public totalIssuedCertificates;

    // Stores an indexed list of the registered issuer's addresses, for easier access
    // This avoids having to recover issuing address information from the Issuer struct
    mapping(address => uint) private accounts;

    /*------ Events ------*/

    // Emmits events in order to log the operations performed in the system
    // event LogAddedIssuer(address issuingAccount, uint issuerId, string issuerName);
    // event LogAddedCertificate(address issuingAccount, uint certificateId, string certificateName, string certificateDescription);
    // event LogIssuedCertification(address issuingAccount, address recipientAddress, bytes digitalSignature, uint certificationId);    

    /*------ Modifiers ------*/
    modifier onlyCertificateIssuer(uint certificateId){
        require(isCertificateIssuer(msg.sender, certificateId));
        _;
    }

    modifier onlyIssuer(address issuerAccount){
        uint issuerId = accounts[issuerAccount];

        require(totalIssuers >= issuerId && issuerId > uint(0));
        _;
    }

    modifier onlyValidCertificate(uint certificateId){
        require(totalCertificates >= certificateId && certificateId > uint(0));
        _;
    }

    modifier onlyValidIssuedCertification(uint certificationId){
        require(totalIssuedCertificates >= certificationId && certificationId > uint(0));
        _;
    }

    /*------ Validation Functions ------*/
    function isCertificateIssuer(address account, uint certificateId)
      internal
      view
      returns(bool)
    {
        return registeredCertificates[certificateId].issuingInstitutionAddress == account;
    }

    /*------ Getter functions ----*/
    function getIssuer(uint issuerId)
        public
        view
        returns (string, string, string, address)
    {
        return (
        registeredIssuers[issuerId].name,
        registeredIssuers[issuerId].email,
        registeredIssuers[issuerId].description,
        registeredIssuers[issuerId].account);
    }

    function getIssuerCount()
        public
        view
        returns (uint)
    {
        return totalIssuers;
    }

    function getCertificate(uint certificateId)
        public
        view
        returns (string, string, string, address)
    {
        return (
            registeredCertificates[certificateId].name,
            registeredCertificates[certificateId].description,
            registeredCertificates[certificateId].criteria,
            registeredCertificates[certificateId].issuingInstitutionAddress);
    }

    function getCertificateCount()
        public
        view
        returns (uint)
    {
        return totalCertificates;
    }

    function getIssuedCerts(uint issuedCertId)
        public
        view
        returns (uint, address, address, bytes)
    {
        return (
            issuedCertificates[issuedCertId].certificateId,
            issuedCertificates[issuedCertId].issuingAddress,
            issuedCertificates[issuedCertId].recipientAddress,
            issuedCertificates[issuedCertId].digitalSignature);
    }

    function getIssuedCertsCount()
        public
        view
        returns (uint)
    {
        return totalIssuedCertificates;
    }

    function isIssuer(address userAccount)
        public
        view
        returns (bool)
    {
        uint issuerId = accounts[userAccount];
        if (issuerId > 0) {
            return true;
        } else {
            return false;
        }
    }

    /*------ Main Functions ------*/
    function addIssuer(string name, string email, string description)
      public 
    {
        // Sets the issuer address as the contract caller's address
        address issuingAccount = msg.sender;

        // Creates new Issuer object
        Issuer memory newIssuer = Issuer(issuingAccount, name, email, description);

        // Increments total issuers tracker
        totalIssuers = totalIssuers + 1;

        // Stores new issuer object on the last position of the mapping structure
        registeredIssuers[totalIssuers] = newIssuer;

        // Stores new valid emitting address on the accounts mapping structure
        accounts[issuingAccount] = totalIssuers;

        // Logs addition of this issuer      
        // emit LogAddedIssuer(issuingAccount, totalIssuers, issuerName);
    }

    function addCertificate(string name, string description, string criteria)
      public
      onlyIssuer(msg.sender)
    {
        // Sets the issuer institution's address as the contract caller's address
        address ownerInstitutionAddress = msg.sender;

        // Creates new certification object
        CertificateClass memory newCertificate = CertificateClass(name, description, criteria, ownerInstitutionAddress);
    
        // Icrements total certificates tracker
        totalCertificates = totalCertificates + 1;

        // Stores the new certificate object on the last position of the mapping structure
        registeredCertificates[totalCertificates] = newCertificate;

        // Log addition of new certificate
        // emit LogAddedCertificate(ownerInstitutionAddress, totalCertificates, name, description);
    }

    function issueCertificate(address recipientAddress, uint certificateId, bytes digitalSignature)
      public
      onlyValidCertificate(certificateId)
      onlyCertificateIssuer(certificateId)
      returns (uint issuedCertificateId)
    {
        // Sets issuing address as the contract caller's address
        address issuingAddress = msg.sender;

        // Creates new issued certificate object
        IssuedCertificate memory newCertification = IssuedCertificate(issuingAddress, recipientAddress, certificateId, digitalSignature);

        // Increments issued certifications tracker
        totalIssuedCertificates = totalIssuedCertificates + 1;

        // Stores new object on the last position of the mapping structure
        issuedCertificates[totalIssuedCertificates] = newCertification;

        // This ID value is returned to the front-end to be stored on the JSON certificate output
        issuedCertificateId = totalIssuedCertificates;

        // Log certificate issuing
        // emit LogIssuedCertification(issuingAddress, recipientAddress, digitalSignature, totalIssuedCertificates);
    }

    // Verification function draft - not working yet
    function verifyCertificate(uint issuingId, bytes calculatedHash)
      public
      onlyValidIssuedCertification(issuingId)
      view
      returns (bool validCertificate)
    {
        // Recovers the issued certificate object from the mapping structure
        IssuedCertificate memory certificate = issuedCertificates[issuingId];

        // Recovers digital signature from the issued certificate object
        bytes memory digSignature = certificate.digitalSignature;

        // @TODO: It is still necessary to implement the digital signature
        // verification.
        if(keccak256(digSignature) == keccak256(calculatedHash))
            return true;
        else
            return false;
    }

    function recoverAddr(bytes32 msgHash, uint8 v, bytes32 r, bytes32 s)
    public
    pure
    returns (address)
    {
        return ecrecover(msgHash, v, r, s);
    }
    
    function isSigned(address _addr, bytes32 msgHash, uint8 v, bytes32 r, bytes32 s)
    public
    pure
    returns (bool)
    {
        return ecrecover(msgHash, v, r, s) == _addr;
    }
}
