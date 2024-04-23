import datetime
from cryptography import x509
from cryptography.hazmat.primitives.asymmetric import rsa
from cryptography.hazmat.backends import default_backend
from cryptography.hazmat.primitives import serialization
from cryptography.hazmat.primitives.hashes import SHA256
from cryptography.x509.oid import NameOID

KEY_SIZE = 3072
PUBLIC_EXPONENT = 65537
COMMON_NAME = "Self TLS"
ORGANIZATION_NAME = "Self TLS Inc."
COUNTRY_NAME = "VN"
CERTIFICATE_DURATION_DAYS = 3650

root_private_key = rsa.generate_private_key(
      public_exponent=PUBLIC_EXPONENT,
      key_size=KEY_SIZE,
      backend=default_backend()
)
subject = x509.Name([
      x509.NameAttribute(NameOID.COMMON_NAME, "Self TLS"),
      x509.NameAttribute(NameOID.ORGANIZATION_NAME, "Self TLS Inc."),
      x509.NameAttribute(NameOID.COUNTRY_NAME, "VN")
  ])  
issuer = x509.Name([
      x509.NameAttribute(NameOID.COMMON_NAME, "Self TLS")
  ])
root_certificate = x509 \
      .CertificateBuilder() \
      .subject_name(subject) \
      .issuer_name(issuer) \
      .public_key(root_private_key.public_key()) \
      .serial_number(x509.random_serial_number()) \
      .not_valid_before(datetime.datetime.now()) \
      .not_valid_after(datetime.datetime.now() + datetime.timedelta(days=3650)) \
      .sign(root_private_key, SHA256(), default_backend())
private_key = rsa.generate_private_key(
      public_exponent=PUBLIC_EXPONENT,
      key_size=KEY_SIZE,
      backend=default_backend()
)
csr = x509.CertificateSigningRequestBuilder() \
      .subject_name(x509.Name([
          x509.NameAttribute(NameOID.COMMON_NAME, "*")
      ])) \
      .sign(private_key, SHA256(), default_backend())
certificate = x509.CertificateBuilder() \
      .subject_name(csr.subject) \
      .issuer_name(root_certificate.issuer) \
      .public_key(csr.public_key()).serial_number(x509.random_serial_number()) \
      .not_valid_before(datetime.datetime.now()) \
      .not_valid_after(datetime.datetime.now() + datetime.timedelta(days=3650)) \
      .add_extension(x509.SubjectAlternativeName([x509.DNSName("*")]), critical=False) \
      .sign(root_private_key, SHA256(), default_backend())
with open("rootCA.key", "wb") as file:
    file.write(root_private_key.private_bytes(
        encoding=serialization.Encoding.PEM,
        format=serialization.PrivateFormat.PKCS8,
        encryption_algorithm=serialization.NoEncryption()
    ))
with open("rootCA.crt", "wb") as file:
    file.write(root_certificate.public_bytes(serialization.Encoding.PEM))
with open("ssl.key", "wb") as file:
    file.write(private_key.private_bytes(
        encoding=serialization.Encoding.PEM,
        format=serialization.PrivateFormat.PKCS8,
        encryption_algorithm=serialization.NoEncryption()
    ))
with open("ssl.crt", "wb") as file:
    file.write(certificate.public_bytes(serialization.Encoding.PEM))
    