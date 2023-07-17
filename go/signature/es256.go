package signature

import (
	"crypto/ecdsa"
	"crypto/rand"
	"crypto/sha256"
	"crypto/x509"
	"encoding/base64"
	"encoding/pem"
	"io/ioutil"
	"math/big"
	"strings"
	"log"
)

type EcdsaSignature struct {
	R, S *big.Int
}

func Sign(header string, payload string, keyfile string) (string, error) {
	// Sign with SHA256 hash algorithms
	h := sha256.New()
	h.Write([]byte(header + "." + payload))
	hash := h.Sum(nil)
	// Read private key content from file
	data, err := ioutil.ReadFile(keyfile)
	if nil != err {
		log.Println("Sign with SHA256 hash")
		return "", err
	}

	block, _ := pem.Decode(data)
	priv, err := x509.ParsePKCS8PrivateKey(block.Bytes) // Parse an unencrypted, PKCS#8 private key
	if nil != err {
		log.Println("decoding key")
		return "", err
	}

	// Do Sign
	ecdsaKey, _ := priv.(*ecdsa.PrivateKey)
	if r, s, err := ecdsa.Sign(rand.Reader, ecdsaKey, hash); err == nil {

		curveBits := ecdsaKey.Curve.Params().BitSize

		keyBytes := curveBits / 8
		if curveBits%8 > 0 {
			keyBytes += 1
		}

		rBytes := r.Bytes()
		rBytesPadded := make([]byte, keyBytes)
		copy(rBytesPadded[keyBytes-len(rBytes):], rBytes)

		sBytes := s.Bytes()
		sBytesPadded := make([]byte, keyBytes)
		copy(sBytesPadded[keyBytes-len(sBytes):], sBytes)

		out := append(rBytesPadded, sBytesPadded...)

		return strings.TrimRight(base64.URLEncoding.EncodeToString(out), "="), nil

	} else {

		return "", err

	}

}
