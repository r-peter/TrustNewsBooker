export TEST_NETWORK_PATH=/home/group_10/hyperledger-fabric/fabric-samples/test-network

CHANNEL_NAME="samplechannel"
CHAINCODE_NAME="TrustNewsBooker"
CHAINCODE_VERSION="1"
CHAINCODE_PATH="home/group_10/hyperledger-fabric/fabric-samples/chaincode/TrustNewsBooker/build/install/trustNewsBooker"
CHAINCODE_LANG="java"
CHAINCODE_LABEL="trustNewsBooker_1"

setEnvVars() {
	export PATH=${PWD}/../bin:${PWD}:$PATH
	export FABRIC_CFG_PATH=${PWD}/../config/
	export CORE_PEER_TLS_ENABLED=true
	export ORDERER_CA=${PWD}/organizations/ordererOrganizations/example.com/orderers/orderer.example.com/msp/tlscacerts/tlsca.example.com-cert.pem
	export ORDERER_ADDRESS=localhost:7050
	export CORE_PEER_TLS_ROOTCERT_FILE_ORG1=${PWD}/organizations/peerOrganizations/org1.example.com/peers/peer0.org1.example.com/tls/ca.crt
	export CORE_PEER_TLS_ROOTCERT_FILE_ORG2=${PWD}/organizations/peerOrganizations/org2.example.com/peers/peer0.org2.example.com/tls/ca.crt
}

setEnvVarsForPeer0Org1() {
    export CORE_PEER_LOCALMSPID="Org1MSP"
    export CORE_PEER_TLS_ROOTCERT_FILE=${CORE_PEER_TLS_ROOTCERT_FILE_ORG1}
    export CORE_PEER_MSPCONFIGPATH=${PWD}/organizations/peerOrganizations/org1.example.com/users/Admin@org1.example.com/msp
    export CORE_PEER_ADDRESS=localhost:7051
}

setEnvVarsForPeer0Org2() {
    export CORE_PEER_LOCALMSPID="Org2MSP"
    export CORE_PEER_TLS_ROOTCERT_FILE=$CORE_PEER_TLS_ROOTCERT_FILE_ORG2
    export CORE_PEER_MSPCONFIGPATH=${PWD}/organizations/peerOrganizations/org2.example.com/users/Admin@org2.example.com/msp
    export CORE_PEER_ADDRESS=localhost:9051

}

packageChaincode() {
    echo "===================== Started to package the Chaincode on peer0.org1 ===================== "
    rm -rf ${CHAINCODE_NAME}.tar.gz
    setEnvVarsForPeer0Org1
    peer lifecycle chaincode package ${CHAINCODE_NAME}.tar.gz --path ${CHAINCODE_PATH} --lang ${CHAINCODE_LANG} --label ${CHAINCODE_LABEL}
    echo "===================== Chaincode is packaged on peer0.org1 ===================== "
}

installChaincode() {
    echo "===================== Started to Install Chaincode on peer0.org1 ===================== "
    setEnvVarsForPeer0Org1
    peer lifecycle chaincode install ${CHAINCODE_NAME}.tar.gz\
    --peerAddresses $CORE_PEER_ADDRESS --tlsRootCertFiles $CORE_PEER_TLS_ROOTCERT_FILE_ORG1
    echo "===================== Chaincode is installed on peer0.org1 ===================== "
    
    echo "===================== Started to Install Chaincode on peer0.org2 ===================== "
    setEnvVarsForPeer0Org2
    peer lifecycle chaincode install ${CHAINCODE_NAME}.tar.gz\
    --peerAddresses $CORE_PEER_ADDRESS --tlsRootCertFiles $CORE_PEER_TLS_ROOTCERT_FILE_ORG2
    echo "===================== Chaincode is installed on peer0.org2 ===================== "
}

queryInstalled() {
    echo "===================== Started to Query Installed Chaincode on peer0.org1 ===================== "
    setEnvVarsForPeer0Org1
    peer lifecycle chaincode queryinstalled --peerAddresses $CORE_PEER_ADDRESS\
    --tlsRootCertFiles $CORE_PEER_TLS_ROOTCERT_FILE_ORG1 >&log.txt
    cat log.txt
    PACKAGE_ID=$(sed -n "/${CHAINCODE_LABEL}/{s/^Package ID: //; s/, Label:.*$//; p;}" log.txt)
    echo PackageID is ${PACKAGE_ID}
    echo "===================== Query installed successful on peer0.org1 ===================== "
}

approveForMyOrg1() {
    echo "===================== Started to approve chaincode definition from org 1 ===================== "
    setEnvVarsForPeer0Org1
    peer lifecycle chaincode approveformyorg -o $ORDERER_ADDRESS\
    --ordererTLSHostnameOverride orderer.example.com --tls --cafile $ORDERER_CA\
    --channelID ${CHANNEL_NAME} --name ${CHAINCODE_NAME} --version ${CHAINCODE_VERSION}\
    --init-required --package-id ${PACKAGE_ID} --sequence 1

    echo "===================== chaincode approved from org 1 ===================== "

}

checkCommitReadynessForOrg1() {
    echo "===================== Started to check commit readyness from org 1 ===================== "
    setEnvVarsForPeer0Org1
    peer lifecycle chaincode checkcommitreadiness --channelID ${CHANNEL_NAME}\
    --name ${CHAINCODE_NAME} --version ${CHAINCODE_VERSION} --sequence 1 --output json --init-required
    echo "===================== checking commit readyness from org 1 ===================== "
}

approveForMyOrg2() {
    echo "===================== Started to approve chaincode definition from org 2 ===================== "
    setEnvVarsForPeer0Org2
    peer lifecycle chaincode approveformyorg -o $ORDERER_ADDRESS\
    --ordererTLSHostnameOverride orderer.example.com --tls --cafile $ORDERER_CA\
    --channelID ${CHANNEL_NAME} --name ${CHAINCODE_NAME} --version ${CHAINCODE_VERSION}\
    --init-required --package-id ${PACKAGE_ID} --sequence 1
    echo "===================== chaincode approved from org 2 ===================== "
}

checkCommitReadynessForOrg2() {
    echo "===================== Started to check commit readyness from org 2 ===================== "
    setEnvVarsForPeer0Org2
    peer lifecycle chaincode checkcommitreadiness --channelID ${CHANNEL_NAME}\
    --name ${CHAINCODE_NAME} --version ${CHAINCODE_VERSION} --sequence 1 --output json --init-required
    echo "===================== checking commit readyness from org 1 ===================== "
}

commitChaincodeDefination() {
    echo "===================== Started to commit Chaincode definition on channel ===================== "
    setEnvVarsForPeer0Org1
    peer lifecycle chaincode commit -o $ORDERER_ADDRESS\
    --ordererTLSHostnameOverride orderer.example.com --tls $CORE_PEER_TLS_ENABLED\
    --cafile $ORDERER_CA --channelID ${CHANNEL_NAME} --name ${CHAINCODE_NAME}\
    --peerAddresses localhost:7051 --tlsRootCertFiles $CORE_PEER_TLS_ROOTCERT_FILE_ORG1\
    --peerAddresses localhost:9051 --tlsRootCertFiles $CORE_PEER_TLS_ROOTCERT_FILE_ORG2\
    --version ${CHAINCODE_VERSION} --sequence 1 --init-required
    echo "===================== Chaincode definition committed on channel ===================== "
}

queryCommitted() {
    echo "===================== Started to query commintted chaincode definition on channel ===================== "
    setEnvVarsForPeer0Org1
    peer lifecycle chaincode querycommitted --channelID ${CHANNEL_NAME} --name ${CHAINCODE_NAME}
    echo "===================== Queried the chaincode definition committed on channel ===================== "

}

chaincodeInvokeInit() {
    echo "===================== Started to Initilize chaincode===================== "
    setEnvVarsForPeer0Org1
    peer chaincode invoke -o $ORDERER_ADDRESS\
    --ordererTLSHostnameOverride orderer.example.com --tls $CORE_PEER_TLS_ENABLED\
    --cafile $ORDERER_CA -C ${CHANNEL_NAME} --name ${CHAINCODE_NAME}\
    --peerAddresses localhost:7051 --tlsRootCertFiles $CORE_PEER_TLS_ROOTCERT_FILE_ORG1\
    --peerAddresses localhost:9051 --tlsRootCertFiles $CORE_PEER_TLS_ROOTCERT_FILE_ORG2\
    --isInit -c '{"Args":[]}'
    echo "===================== Succesfully Initilized the chaincode===================== "
}

chaincodeAddTrustNews() {
    echo "===================== Started Add New Trust News Chaincode Function===================== "
    setEnvVarsForPeer0Org1
    peer chaincode invoke -o $ORDERER_ADDRESS\
    --ordererTLSHostnameOverride orderer.example.com --tls $CORE_PEER_TLS_ENABLED\
    --cafile $ORDERER_CA -C ${CHANNEL_NAME} --name ${CHAINCODE_NAME}\
    --peerAddresses localhost:7051 --tlsRootCertFiles $CORE_PEER_TLS_ROOTCERT_FILE_ORG1\
    --peerAddresses localhost:9051 --tlsRootCertFiles $CORE_PEER_TLS_ROOTCERT_FILE_ORG2\
    -c '{"Args":["addTrustNews","1","SecondTrustNews","Client"]}'
    echo "===================== Successfully Added New Trust News===================== "
}

chaincodeQueryTrustNewsById() {
    echo "===================== Started Query Query Trust News By Id Chaincode Function===================== "
    setEnvVarsForPeer0Org1
    peer chaincode invoke -o $ORDERER_ADDRESS\
    --ordererTLSHostnameOverride orderer.example.com --tls $CORE_PEER_TLS_ENABLED\
    --cafile $ORDERER_CA -C ${CHANNEL_NAME} --name ${CHAINCODE_NAME}\
    --peerAddresses localhost:7051 --tlsRootCertFiles $CORE_PEER_TLS_ROOTCERT_FILE_ORG1\
    --peerAddresses localhost:9051 --tlsRootCertFiles $CORE_PEER_TLS_ROOTCERT_FILE_ORG2\
    -c '{"Args":["queryTrustNewsById","1"]}'
    echo "===================== Successfully Invoked Query Trust News By Id Chaincode Function===================== "
}

chaincodeChangeTrustNews() {
    echo "===================== Started Change Trust News Chaincode Function===================== "
    setEnvVarsForPeer0Org1
    peer chaincode invoke -o $ORDERER_ADDRESS\
    --ordererTLSHostnameOverride orderer.example.com --tls $CORE_PEER_TLS_ENABLED\
    --cafile $ORDERER_CA -C ${CHANNEL_NAME} --name ${CHAINCODE_NAME}\
    --peerAddresses localhost:7051 --tlsRootCertFiles $CORE_PEER_TLS_ROOTCERT_FILE_ORG1\
    --peerAddresses localhost:9051 --tlsRootCertFiles $CORE_PEER_TLS_ROOTCERT_FILE_ORG2\
    -c '{"Args":["changeTrustNews", "1","Signature1"]}'
    echo "===================== Successfully Change Trust News Chaincode Function===================== "
}

cd ${TEST_NETWORK_PATH}
echo "Current working directory: ${PWD}"
setEnvVars
packageChaincode
installChaincode
queryInstalled
approveForMyOrg1
checkCommitReadynessForOrg1
approveForMyOrg2
checkCommitReadynessForOrg2
commitChaincodeDefination
queryCommitted
sleep 5
chaincodeInvokeInit
sleep 5
chaincodeAddTrustNews
sleep 5
chaincodeQueryTrustNewsById
sleep 5
chaincodeChangeTrustNews
