# Github action, reads KV from vault and write envfile, to be imported with source command

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
| `env_filename` | `string` | `.env_file` | Filename of environmental variables file | .env |
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
        env_filename: <env filename> 
```


## Test locally

Create a file named ".env" in the root of this project with the following content:

`````
INPUT_VAULT_ADDRESS=<Vault address>
INPUT_VAULT_TOKEN=<Vault token>
INPUT_VAULT_NAMESPACE=<vault namespace>
INPUT_ENV_FILENAME=<name of the env file>
INPUT_BASE_PATHS=<paths to secrets in vault separated by commas>
`````

**Build Docker Image**

````
docker build  -t  vault-to-env .
````

**Docker run**

````
docker run -it --env-file=.env vault-to-env
````