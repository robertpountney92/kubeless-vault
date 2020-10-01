import os
import requests

vault_addr = os.environ['VAULT_ADDR']

jwt = requests.get('http://metadata/computeMetadata/v1/instance/service-accounts/default/identity',
    headers={'Metadata-Flavor':'Google'},
    params={'audience':'http://vault/apikey1', 'format':'full'})

auth = requests.post(vault_addr + '/v1/auth/gcp/login',
    json={'role':'apikey1', 'jwt':jwt.text})
token = auth.json()['auth']['client_token']

r = requests.get(vault_addr + '/v1/secret/apikeys/apikey1',
    headers={'x-vault-token': token})

apikey = r.json()['data']['value']

def F(request):
    return f'{apikey}'
