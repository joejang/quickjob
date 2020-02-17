#!/bin/bash

YOUR_PASSWORD=''
DAYS=99999

echo 1.Generate RootCA certificates
keytool -genkey -alias RootCA1 -keyalg RSA -keysize 2048 -dname "CN=RootCA1,O=XXX Technologies Co.\, Ltd,L=ChengDu,ST=Sichuan,C=CN" -ext KU:true=keyCertSign,cRLSign,DigitalSignature,nonRepudiation, -ext basicConstraints=CA:true -keypass ${YOUR_PASSWORD} -storepass ${YOUR_PASSWORD} -keystore RootCA1.keystore -validity ${DAYS}

echo 2.Export RootCA certificate from RootCA keystore
keytool -export -alias RootCA1 -keystore RootCA1.keystore -storepass ${YOUR_PASSWORD} -file RootCA1.cer

echo 3.Generate device certificate keystore
keytool -genkeypair -alias DeviceCert1  -keyalg RSA -keysize 2048 -dname "CN=RootCA1,O=XXX Technologies Co.\, Ltd,L=ChengDu,ST=Sichuan,C=CN" -keypass ${YOUR_PASSWORD} -storepass ${YOUR_PASSWORD} -keystore DeviceCert1.keystore -validity ${DAYS}

echo 4.Generate device certificaes request file
keytool -certreq -file DeviceCert1.csr -alias DeviceCert1 -keystore DeviceCert1.keystore -storepass ${YOUR_PASSWORD}

echo 5.Sign device certificates with RootCA
keytool -gencert -infile DeviceCert1.csr -outfile DeviceCert1.cer -alias RootCA1 -keystore RootCA1.keystore -storepass ${YOUR_PASSWORD} -validity ${DAYS}

echo 6.Import root certificates into keystore
keytool -importcert -alias RootCA1 -file RootCA1.cer -keystore DeviceCert1.keystore -storepass ${YOUR_PASSWORD} -noprompt -trustcacerts

echo 7.Import RootCA into trust keystore (used to accept ssl connection)
keytool -importcert -alias RootCA1 -file RootCA1.cer -keystore DeviceCert1_Trust.keystore -storepass ${YOUR_PASSWORD} -noprompt -trustcacerts -validity ${DAYS}

echo 8.Import deivce certificates into keystore
keytool -importcert -alias DeviceCert1 -file DeviceCert1.cer -keystore DeviceCert1.keystore -storepass ${YOUR_PASSWORD} -noprompt

echo Done.