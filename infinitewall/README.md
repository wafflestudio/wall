Infinite Wall Play Framework Project
=====================================

Enable HTTPS
-----------------

Certificate

- Create a free certificate and key following the instruction on StartSSL.com

- May need to encrypt using `openssl rsa -in ssl.key -out ssl.key`

Convert to Java Key Store (need to create password)

- $ keytool -importkeystore -srckeystore server.p12 -destkeystore scalableidea_com.jks -srcstoretype pkcs12 

Assign (the keystore and password) as arguments to 'start' command (use the created password)

- Refer to build.sh
