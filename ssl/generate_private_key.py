from cryptography.hazmat.primitives.asymmetric import rsa
from cryptography import x509
from cryptography.hazmat.primitives import serialization, hashes

PUBLIC_EXPONENT = 65537
KEY_SIZE = 4096

def generate_private_key(public_exponent=PUBLIC_EXPONENT, key_size=KEY_SIZE):
  private_key = rsa.generate_private_key(public_exponent=public_exponent, key_size=key_size)
  return private_key

if __name__=="__main__":
  private_key = generate_private_key()
  with open("root_ca.key", "wb") as key_file:
    key_file.write(private_key.private_bytes(
        encoding=serialization.Encoding.PEM,
        format=serialization.PrivateFormat.TraditionalOpenSSL,
        encryption_algorithm=serialization.NoEncryption(),
    ))
