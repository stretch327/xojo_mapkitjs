package main

import (
	"MapKitSigner/jwt"
	"os"
	"time"
	"strconv"
)

func main() {
	if len(os.Args[1:]) < 5 {
		writeError("Please specify the keyID, IssuerID, the path to the p8 certificate, the domain, and the expiration in minutes (default 2).")
		return	
	}
	
	keyid := os.Args[1];
	issuerid := os.Args[2];
	keyfile := os.Args[3];
	origin := os.Args[4];
	
	exp := int64(2); // default to 2 minutes
	
	if len(os.Args[1:]) > 4 {
		exp, _ = strconv.ParseInt(os.Args[5], 10, 64);
	}
	expSecs := exp * 60;
	
	now := time.Now();
	
	jwtHeader := jwt.Header{
		Alg: "ES256",
		Kid: keyid,
		Typ: "JWT",
	}
	jwtPayload := jwt.Payload{
		Iss: issuerid,
		Iat: now.Unix(),
		Exp: now.Unix() + int64(expSecs), // 2 minutes
		Origin: origin,
	}
		
	jwtToken, err := jwt.Token(jwtHeader, jwtPayload, keyfile);
	if nil != err {
		writeError("Build JWT token failure")
		return
	}

	os.Stdout.WriteString(jwtToken);
}

func writeError(msg string) {
	os.Stderr.WriteString(msg + "\n");
}
