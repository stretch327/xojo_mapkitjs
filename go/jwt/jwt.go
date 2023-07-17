package jwt

import (
	"MapKitSigner/signature"
	"log"
)

func Token(header Header, payload Payload, keyfile string) (string, error) {

	// Step 1: Build JWT Header
	header64, err := header.Base64Content()
	if nil != err {
		log.Println("error encoding header64: ")
		log.Println(header)
		return "", err
	}

	// Step 2: Build JWT Payload
	payload64, err := payload.Base64Content()
	if nil != err {
		log.Println("error encoding payload64: ")
		log.Println(payload)
		return "", err
	}

	// Step 3: Signature Header & Payload
	sign64, err := signature.Sign(header64, payload64, keyfile)
	if nil != err {
		log.Println(sign64)
		log.Println("error signing header & payload with keyfile")
		return "", err
	}

	token := header64 + "." + payload64 + "." + sign64
	return token, nil

}
