from authlib.integrations.requests_client import OAuth2Session
from authlib.oauth2.rfc7523 import PrivateKeyJWT
from authlib.jose import JsonWebKey

import os
import json

# key.json obtained from iris.nersc -> settings
with open("key.json") as f:
    jwk_dict = json.load(f)
private_key = JsonWebKey.import_key(jwk_dict)

token_url = "https://oidc.nersc.gov/c2id/token"
client_id = "ahqjovxph6weg"

session = OAuth2Session(
    client_id, 
    private_key, 
    PrivateKeyJWT(token_url),
    grant_type="client_credentials",
    token_endpoint=token_url
)
token = session.fetch_token()

expires_in   = token["expires_in"]
access_token = token["access_token"]
print(access_token)
#print(f"Expires in {expires_in}s")

