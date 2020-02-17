#!/bin/bash

SUBJECT='/C=CN/ST=Sichuan/L=ChengDu/O=XXX Technologies Co., Ltd'
DAYS=99999

echo Generate certificates using OpenSSL
openssl genrsa -out ca-key.pem 2048
openssl req -sha256 -new -x509 -nodes -days ${DAYS} -key ca-key.pem -out ca.pem -subj "${SUBJECT}/CN=XXXXCA"
openssl req -sha256 -newkey rsa:2048 -days ${DAYS} -nodes -keyout server-key.pem -out server-req.pem -subj "${SUBJECT}/CN=XXXXSERVER"
openssl rsa -in server-key.pem -out server-key.pem
openssl ca -in server-req.pem -md sha256 -out server-cert.pem -cert ca.pem -keyfile ca-key.pem -extensions v3_req -config openssl.cnf -batch
openssl req -sha256 -newkey rsa:2048 -days ${DAYS} -nodes -keyout client-key.pem -out client-req.pem -subj "${SUBJECT}/CN=XXXXCLIENT"
openssl rsa -in client-key.pem -out client-key.pem
openssl ca -in client-req.pem -md sha256 -out client-cert.pem -cert ca.pem -keyfile ca-key.pem -extensions v3_req -config openssl.cnf -batch

openssl verify -CAfile ca.pem server-cert.pem client-cert.pem

openssl x509 -noout -text -in server-cert.pem
openssl x509 -noout -text -in client-cert.pem

#list information in pem files:
openssl req/rsa -noout -text -in server-cert.pem
openssl req/rsa -noout -text -in client-cert.pem

#convert pem into keystore
openssl x509 -in ca.pem -out ca.crt
openssl x509 -in server-cert.pem -out server-cert.crt
openssl x509 -in client-cert.pem -out client-cert.crt

keytool -import file server-cert.crt -keystore server-cert.keystore
keytool -import file client-cert.crt -keystore client-cert.keystore

keytool -list -v server-cert.keystore
keytool -list -v client-cert.keystore