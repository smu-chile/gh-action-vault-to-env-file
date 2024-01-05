# Github action, reads secret from vault and write envfile, to be imported with source command

This Action allows you to create an enviroment variable file to be with source.

`````
source env_filename
`````


## File example
`````
export FOO='BAR'
`````

## Parameters
| Parameter | Type | Default | Description | Example |
|-----------|------|---------|-------------|-------------|
| `file_name` | `string` | `.env_file` | Filename of output secrets | .env |
| `file_format` | `string` | `` | Format of the contents | toJson |
| `vault_secret_paths` | `string` | `` |  Path to secret in Vault, can be multiple secrets separated by space | kv/app/develop/input kv/app/develop/output | 
| `vault_token` | `string` | `` | Vault Token | |
| `vault_address` | `string` | | URL Vault | https://vault:8200 |

## Usage
```yaml
name: Ansible usage
jobs:
  BuildClusterAnsible:
    - name: Checkout ansible prerequisites action repo
      uses: actions/checkout@v2
      with:
        repository: 'smu-chile/gh-action-vault-to-env-file'
        ref: 'master'
        token: ${{ secrets.ACTION_PAT }} 
        path: ./.github/actions/gh-action-vault-to-env-file
        
    - name: Create filenames
      uses: ./.github/actions/gh-action-vault-to-env-file
      with:
        vault_addr: <vault server address>
        vault_token: <vault_token>
        vault_namepsace: <vault_namepsace>
        vault_secret_paths: <separated by space paths>
        file_name: <output filename> 
        file_format: <content format>
```


## Test locally

Create a file named ".env" in the root of this project with the following content:

`````
INPUT_VAULT_ADDR=<Vault address>
INPUT_VAULT_TOKEN=<Vault token>
INPUT_VAULT_NAMESPACE=<Vault namespace>
INPUT_SECRET_PATHS=<Paths to secrets in vault separated by commas>
INPUT_FILE_NAME=<Name of the output file with the secrets>
INPUT_FILE_FORMAT=<Content type of the output. Could be toJson, json or env>
`````

**Build Docker Image**

````
docker build  -t  vault-to-env .
````

**Docker run**

````
docker run -it --env-file=.env vault-to-env
````