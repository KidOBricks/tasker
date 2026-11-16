package crypto

import (
	"crypto/rand"
	"encoding/hex"
	"testing"
)

func TestEncryptDecryptRoundTrip(t *testing.T) {
	rawKey := make([]byte, 32)
	if _, err := rand.Read(rawKey); err != nil {
		t.Fatal(err)
	}
	key, err := ParseKey(hex.EncodeToString(rawKey))
	if err != nil {
		t.Fatalf("ParseKey failed: %v", err)
	}

	secret := "1//0gRefreshTokenExample_XYZ"
	enc, err := Encrypt(secret, key)
	if err != nil {
		t.Fatalf("Encrypt failed: %v", err)
	}
	if enc == secret || enc == "" {
		t.Fatalf("expected non-empty encrypted output different from plaintext")
	}

	dec, err := Decrypt(enc, key)
	if err != nil {
		t.Fatalf("Decrypt failed: %v", err)
	}
	if dec != secret {
		t.Fatalf("expected %q, got %q", secret, dec)
	}
}

func TestParseKeyRejectsEmpty(t *testing.T) {
	if _, err := ParseKey("   "); err == nil {
		t.Fatal("expected error for empty key")
	}
}
