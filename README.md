[![NPM version](https://badge.fury.io/js/avalanche-cli.svg)](https://npmjs.org/package/avalanche-cli)
[![Build Status](https://travis-ci.org/hsk81/avalanche-cli.svg?branch=master)](https://travis-ci.org/hsk81/avalanche-cli)

# A Command Line Interface for Avalanche APIs

```
Usage: avalanche-cli [OPTIONS] COMMMAND
```

## Options

```
-h --help                                         Show help information and quit.
-v --version                                      Print CLI version information and quit.
```

## Installation

First of all, it is possible to run `avalanche-cli` *without any installation* whatsoever, by simply invoking it via [`npx`] (aka the [`npm`] package executor):

```sh
$ npx avalanche-cli --help
```

But, if you decide to permanently install it via [`npm`], then do so with:

```sh
$ npm install avalanche-cli -g ## avoid `sudo` (see FAQ)
```

```sh
$ avalanche-cli -h ## show help info
```

Also, an installation via `npm` activates *command line completion* (i.e. hitting the TAB key after writing `avalanche-cli` should offer a list of available commands and options). Finally, for `avalanche-cli` to work properly your operating system needs to provide the dependencies below.

## Dependencies

```
Name            : curl
Version         : 7.70.0-1
Description     : An URL retrieval utility and library
```

```
Name            : zsh
Version         : 5.7.1
Description     : the Z shell
```

Or instead of `zsh`:
```
Name            : bash
Version         : 5.0.017-1
Description     : The GNU Bourne Again shell
```

Optional:
```
Name            : bash-completion
Version         : 2.10-2
Description     : Programmable completion for the bash shell
```

Only for installation (and for [`npx`]):
```
Name            : npm
Version         : 6.14.5-1
Description     : A package manager
```

## Usage

All CLI options of the `avalanche-cli` tool can also be set via environment variables. It assumes by default an [AVAX] node available at `127.0.0.1:9650` &ndash; although this can be changed by setting and exporting the `AVAX_NODE` variable *or* by using the corresponding `--node` (`-N`) option.

### User creation

Let's see how a new `keystore` user is created:

```sh
$ avalanche-cli keystore create-user -h
```
```
Usage: keystore create-user [-u|--username=${AVAX_USERNAME}] [-p|--password=${AVAX_PASSWORD}] [-N|--node=${AVAX_NODE-127.0.0.1:9650}] [-S|--silent-rpc|${AVAX_SILENT_RPC}] [-V|--verbose-rpc|${AVAX_VERBOSE_RPC}] [-Y|--yes-run-rpc|${AVAX_YES_RUN_RPC}] [-h|--help]
```

```sh
$ avalanche-cli keystore create-user -u MyUser -p MySecret-1453
```
```
curl --url '127.0.0.1:9650/ext/keystore' --header 'content-type:application/json' --data '{"jsonrpc":"2.0","id":3411,"method":"keystore.createUser","params":{"username":"MyUser","password":"…"}}'
```
By default, `avalanche-cli` does *not* run the command, but simply shows the corresponding `curl` request (without the `password`). If some parameter had been missing or unexpected, then the *usage* string would have been re-shown. To actually invoke the command the `-Y` option needs to be appended:

```sh
$ avalanche-cli keystore create-user -u MyUser -p MySecret-1453 -Y
```
```json
$ {"jsonrpc":"2.0","result":{"success":true},"id":21265}
```

Since most of the commands expect a username and a password, let's export them as environment variables, so they can be re-used:

```sh
$  export AVAX_USERNAME=MyUser AVAX_PASSWORD=MySecret-1453
```

Please note, that the line above starts with an *empty space* (`$__export AVAX_..`) to avoid the variables getting cached in the `bash` history! In general this is good practice when handling credentials via the CLI (but otherwise it is not required).

### User deletion

Let's delete the previously created user, where it is not required to provide the `-u` (`--username`) and `-p` (`--password`) options again, since the corresponding environment variables have been exported above:

```sh
$ avalanche-cli keystore delete-user
```
```
curl --url '127.0.0.1:9650/ext/keystore' --header 'content-type:application/json' --data '{"jsonrpc":"2.0","id":26347,"method":"keystore.deleteUser","params":{"username":"MyUser","password":"…"}}'
```

```sh
$ avalanche-cli keystore delete-user -Y
```
```json
{"jsonrpc":"2.0","result":{"success":true},"id":31641}
```

### JSON processing with [`jq`]

Since `avalance-cli` does not process any JSON reponses, it is recommended to use the excellent [`jq`] command line JSON processor to handle them. For example:

```sh
$ avalanche-cli info peers -YS | jq .result.peers[0]
```
```json
{
  "ip": "185.144.83.145:9651",
  "publicIP": "185.144.83.145:9651",
  "id": "F7qAwDMgFCJ1TG9U4sjFKeYNGKfbToGE5",
  "version": "avalanche/0.5.5",
  "lastSent": "2020-06-27T04:16:56+02:00",
  "lastReceived": "2020-06-27T04:16:38+02:00"
}
```
..where the `-S` (`--silent-rpc`) option tells the internal `curl` tool to not produce unnessary output, so we get the desired result from above. ;D

## [Admin API](https://docs.ava.network/v1.0/en/api/admin)

This API can be used for measuring node health and debugging.

```
admin alias                                       Assign an API an alias, a different endpoint for the API. The origina..
admin alias-chain                                 Give a blockchain an alias, a different name that can be used any pla..
admin start-cpu-profiler                          Start profiling the CPU utilization of the node. Will write the profi..
admin stop-cpu-profiler                           Stop the CPU profile that was previously started.
admin memory-profile                              Dump the current memory footprint of the node to the specified file.
admin lock-profile                                Dump the mutex statistics of the node to the specified file.
```

## [AVM (X-Chain) API](https://docs.ava.network/v1.0/en/api/avm)

The X-Chain, AVAX's native platform for creating and trading assets, is an instance of the AVAX Virtual Machine (AVM). This API allows clients to create and trade assets on the X-Chain and other instances of the AVM.

```
avm create-address                                Create a new address controlled by the given user.
avm list-addresses                                List addresses controlled by the given user.
avm get-balance                                   Get the balance of an asset controlled by a given address.
avm get-all-balances                              Get the balances of all assets controlled by a given address.
avm get-utxos                                     Get the UTXOs that reference a given address.
avm issue-tx                                      Send a signed transaction to the network.
avm sign-mint-tx                                  Sign an unsigned or partially signed transaction.
avm get-tx-status                                 Get the status of a transaction sent to the network.
avm get-tx                                        Returns the specified transaction.
avm send                                          Send a quantity of an asset to an address.
avm create-fixed-cap-asset                        Create a new fixed-cap, fungible asset. A quantity of it is created a..
avm create-variable-cap-asset                     Create a new variable-cap, fungible asset. No units of the asset exis..
avm create-mint-tx                                Create an unsigned transaction to mint more of a variable-cap asset (..
avm get-asset-description                         Get information about an asset.
avm export-avax                                   Send AVAX from the X-Chain to an account on the P-Chain. After callin..
avm import-avax                                   Finalize a transfer of AVAX from the P-Chain to the X-Chain. Before t..
avm export-key                                    Get the private key that controls a given address. The returned priva..
avm import-key                                    Give a user control over an address by providing the private key that..
avm build-genesis                                 Given a JSON representation of this Virtual Machine's genesis state, ..
```

## [EVM API](https://docs.ava.network/v1.0/en/api/evm)

This section describes the API of the C-Chain, which is an instance of the Ethereum Virtual Machine (EVM). **Note:** Ethereum has its own notion of `networkID` and `chainID`. The C-Chain uses `1` and `43110` for these values, respectively. These have no relationship to AVAX's view of `networkID` and `chainID`, and are purely internal to the C-Chain.

```
evm web3-client-version                           Returns the current client version. See: https://eth.wiki/json-r..
evm web3-sha3                                     Returns Keccak-256 (not the standardized SHA3-256) of the given data...
```
```
evm net-version                                   Returns the current network id. See: https://eth.wiki/json-rpc/A..
evm net-peer-count                                Returns number of peers currently connected to the client. See: ..
evm net-listening                                 Returns 'true' if client is actively listening for network connection..
```
```
evm eth-protocol-version                          Returns the current ethereum protocol version. See: https://eth...
evm eth-syncing                                   Returns an object with data about the sync status or 'false'. See: ..
evm eth-coinbase                                  Returns the client coinbase address. See: https://eth.wiki/json-..
evm eth-mining                                    Returns true if client is actively mining new blocks. See: https..
evm eth-hashrate                                  Returns the number of hashes per second that the node is mining with...
evm eth-gas-price                                 Returns the current price per gas in wei. See: https://eth.wiki/..
evm eth-accounts                                  Returns a list of addresses owned by client. See: https://eth.wi..
evm eth-block-number                              Returns the number of most recent block. See: https://eth.wiki/j..
evm eth-get-balance                               Returns the balance of the account of given address. See: https:..
evm eth-get-storage-at                            Returns the value from a storage position at a given address. See: ..
evm eth-get-transaction-count                     Returns the number of transactions sent from an address. See: ht..
evm eth-get-block-transaction-count-by-hash       Returns the number of transactions in a block from a block matching t..
evm eth-get-block-transaction-count-by-number     Returns the number of transactions in a block matching the given bloc..
evm eth-get-uncle-count-by-block-hash             Returns the number of uncles in a block from a block matching the giv..
evm eth-get-uncle-count-by-block-number           Returns the number of uncles in a block from a block matching the giv..
evm eth-get-code                                  Returns code at a given address. See: https://eth.wiki/json-rpc/..
evm eth-sign                                      The sign method calculates an Ethereum specific signature. See: ..
evm eth-sign-transaction                          Signs a transaction that can be submitted to the network at a later t..
evm eth-send-transaction                          Creates new message call transaction or a contract creation, if the d..
evm eth-send-raw-transaction                      Creates new message call transaction or a contract creation for signe..
evm eth-call                                      Executes a new message call immediately without creating a transactio..
evm eth-estimate-gas                              Generates and returns an estimate of how much gas is necessary to all..
evm eth-get-block-by-hash                         Returns information about a block by hash. See: https://eth.wiki..
evm eth-get-block-by-number                       Returns information about a block by block number. See: https://..
evm eth-get-transaction-by-hash                   Returns the information about a transaction requested by transaction ..
evm eth-get-transaction-by-block-hash-and-index   Returns information about a transaction by block hash and transaction..
evm eth-get-transaction-by-block-number-and-index Returns information about a transaction by block number and transacti..
evm eth-get-transaction-receipt                   Returns the receipt of a transaction by transaction hash. See: h..
evm eth-get-uncle-by-block-hash-and-index         Returns information about a uncle of a block by hash and uncle index ..
evm eth-get-uncle-by-block-number-and-index       Returns information about a uncle of a block by number and uncle inde..
evm eth-get-compilers                             Returns a list of available compilers in the client. See: https:..
evm eth-compile-lll                               Returns compiled LLL code. See: https://eth.wiki/json-rpc/API#et..
evm eth-compile-solidity                          Returns compiled solidity code. See: https://eth.wiki/json-rpc/A..
evm eth-compile-serpent                           Returns compiled serpent code. See: https://eth.wiki/json-rpc/AP..
evm eth-new-filter                                Creates a filter object, based on filter options, to notify when the ..
evm eth-new-block-filter                          Creates a filter in the node, to notify when a new block arrives. To ..
evm eth-new-pending-transaction-filter            Creates a filter in the node, to notify when new pending transactions..
evm eth-uninstall-filter                          Uninstalls a filter with given id. Should always be called when watch..
evm eth-get-filter-changes                        Polling method for a filter, which returns an array of logs which occ..
evm eth-get-filter-logs                           Returns an array of all logs matching filter with given id. See: ..
evm eth-get-logs                                  Returns an array of all logs matching a given filter object. See: ..
evm eth-get-work                                  Returns the hash of the current block, the seedHash, and the boundary..
evm eth-submit-work                               Used for submitting a proof-of-work solution. See: https://eth.w..
evm eth-submit-hashrate                           Used for submitting mining hashrate. See: https://eth.wiki/json-..
```
```
evm personal-ec-recover                           Returns the address associated with the private key that was used to ..
evm personal-list-accounts                        Returns all the Ethereum account addresses of all keys in the key sto..
evm personal-new-account                          Generates a new private key and stores it in the key store directory...
evm personal-sign                                 The sign method calculates an Ethereum specific signature. By adding ..
evm personal-import-raw-key                       Imports the given unencrypted private key (hex string) into the key s..
evm personal-lock-account                         Removes the private key with given address from memory. The account c..
evm personal-send-transaction                     Validate the given passphrase and submit transaction. The transaction..
evm personal-unlock-account                       Decrypts the key with the given address from the key store. Both pass..
```
```
evm txpool-content                                The 'content' inspection property can be queried to list the exact de..
evm txpool-inspect                                The 'inspect' inspection property can be queried to list a textual su..
evm txpool-status                                 The 'status' inspection property can be queried for the number of tra..
```

## [Health API](https://docs.ava.network/v1.0/en/api/health)

This API can be used for measuring node health.

```
health get-liveness                               Get health check on this node.
```

## [Info API](https://docs.ava.network/v1.0/en/api/info)

This API can be used to access basic information about the node.

```
info get-blockchain-id                            Given a blockchain's alias, get its ID. (See 'avm alias-chain' for mo..
info get-network-id                               Get the ID of the network this node is participating in.
info get-network-name                             Get the name of the network this node is running on.
info get-node-id                                  Get the ID of this node.
info get-node-version                             Get the version of this node.
info is-bootstrapped                              Check whether a given chain is done bootstrapping.
info peers                                        Get description of peer connections.
```

## [IPC API](https://docs.ava.network/v1.0/en/api/ipc)

The IPC API allows users to create a UNIX domain socket for a blockchain to publish to. When the blockchain accepts a vertex/block it will publish the vertex to the socket. A node will only expose this API if it is started with command-line argument `api-ipcs-enabled=true`.

```
ipcs publish-blockchain                           Register a blockchain so it publishes accepted vertices to a Unix dom..
ipcs unpublish-blockchain                         Deregister a blockchain so that it no longer publishes to a Unix doma..
```

## [Keystore API](https://docs.ava.network/v1.0/en/api/keystore)

Every node has a built-in keystore. Clients create users on the keystore, which act as identities to be used when interacting with blockchains. A keystore exists at the node level, so if you create a user on a node it exists only on that node. However, users may be imported and exported using this API.

```
keystore create-user                              Create a new user with the specified username and password.
keystore list-users                               List the users in this keystore.
keystore delete-user                              Delete a user.
keystore export-user                              Export a user. The user can be imported to another node with 'keystor..
keystore import-user                              Import a user. 'password' must match the user's password. 'username' ..
```

## [Metrics API](https://docs.ava.network/v1.0/en/api/metrics)

The API allows clients to get statistics about a node's health and performance.

```
metrics get-prometheus                            Get Prometheus compatible metrics.
```

## [Platform API](https://docs.ava.network/v1.0/en/api/platform)

This API allows clients to interact with the P-Chain (Platform Chain), which maintains AVAX's validator set and handles blockchain creation.

```
platform create-blockchain                        Create a new blockchain. Currently only supports creation of new inst..
platform get-blockchain-status                    Get the status of a blockchain.
platform create-address                           Create a new address controlled by the given user.
platform import-key                               Give a user control over an address by providing the private key that..
platform export-key                               Get the private key that controls a given address. The returned priva..
platform get-balance                              Get the balance of AVAX controlled by a given address.
platform list-addresses                           List the addresses controlled by the specified user.
platform get-current-validators                   List the current validators of the given Subnet.
platform get-pending-validators                   List the validators in the pending validator set of the specified Sub..
platform sample-validators                        Sample validators from the specified Subnet.
platform add-validator                            Add a validator to the primary network.
platform add-subnet-validator                     Add a validator to a subnet other than the primary network. The valid..
platform add-delegator                            Add a delegator to the primary network. A delegator stakes AVAX and s..
platform create-subnet                            Create an unsigned transaction to create a new Subnet. The unsigned t..
platform get-subnets                              Get all the Subnets that exist.
platform get-height                               Returns the height of the last accepted block.
platform validated-by                             Get the Subnet that validates a given blockchain.
platform validates                                Get the IDs of the blockchains a Subnet validates.
platform get-blockchains                          Get all the blockchains that exist (excluding the P-Chain).
platform export-avax                              Send AVAX from an account on the P-Chain to an address on the X-Chain..
platform import-avax                              Complete a transfer of AVAX from the X-Chain to the P-Chain. Before t..
```

## [Timestamp API](https://docs.ava.network/v1.0/en/api/timestamp)

This API allows clients to interact with the Timestamp Chain. The Timestamp Chain is a timestamp server. Each block contains a 32 byte payload and the timestamp when the block was created. The genesis data for a new instance of the Timestamp Chain is the genesis block's 32 byte payload.

```
timestamp get-block                               Get a block by its ID. If no ID is provided, get the latest block.
timestamp propose-block                           Propose the creation of a new block.
```

## Common Options

All commands share the following options and corresponding environment variables:

### `${AVAX_NODE-127.0.0.1:9650}` or `--node` (`-N`)

Can be used to set the [AVAX] node which the `avalanche-cli` tool will be communicating with &ndash; where the default is `127.0.0.1:9650`. For example:

```sh
$ avalanche-cli info peers -N=127.0.0.1:9650
```

```
$ avalanche-cli info peers --node=127.0.0.1:9650
```

```
$ AVAX_NODE=127.0.0.1:9650 avalanche-cli info peers
```

### `${AVAX_YES_RUN_RPC}` or `--yes-run-rpc` (`-Y`)

Can be used to actually execute the `curl` request the `avalanche-cli` tool puts together &ndash; where by default this is *off*, i.e. the corresponding `curl` request will only be shown but *not* executed. For example:

```sh
$ avalanche-cli info peers -Y
```

```sh
$ avalanche-cli info peers --yes-run-rpc
```

```sh
$ AVAX_YES_RUN_RPC=1 avalanche-cli info peers
```

### `${AVAX_SILENT_RPC}` or `--silent-rpc` (`-S`)

Can be used to make a `curl` request with its corresponding *silent* flag on &ndash; where by default it is *off*. However when *on*, this will *not* silence the actual response (if there is any):

```sh
$ avalanche-cli info peers -YS
```

```sh
$ avalanche-cli info peers -Y --silent-rpc
```

```sh
$ AVAX_SILENT_RPC=1 avalanche-cli info peers -Y
```

### `${AVAX_VERBOSE_RPC}` or `--verbose-rpc` (`-V`)

Can be used to make a `curl` request with its corresponding *verbose* flag on &ndash; where by default it is *off*. This is useful, if one wants to get a detailed view of an ongoing request:

```sh
$ avalanche-cli info peers -YV
```

```sh
$ avalanche-cli info peers -Y --verbose-rpc
```

```sh
$ AVAX_VERBOSE_RPC=1 avalanche-cli info peers -Y
```

## Common Variables

Further, all commands share the following two &ndash; very general &ndash; environment variables:

### `${AVAX_ARGS_RPC}`

Can be used to make a `curl` request with a corresponding argument (or arguments). This is useful, since it allows to access all of `curl`'s capabilities. For example:

```sh
$ export AVAX_ARGS_RPC="--no-progress-meter" ## if supported by curl implementation
```

```sh
$ avalanche-cli info peers -Y
```

Now, *each* request will be performed without a progress meter (which can be distracting in case one chooses to pipe a response through another command).

### `${AVAX_PIPE_RPC}`

Can be used to pipe a `curl` response through a command, where `AVAX_PIPE_RPC` needs to be an (implicit) associative array with content types as keys and corresponding commands as value entries. For example:

```sh
$ export AVAX_PIPE_RPC="declare -A AVAX_PIPE_RPC=([content-type:application/json]='jq -c')"
```

```sh
$ avalanche-cli info peers -Y
```

Now, *each* `application/json` response will be compactified and colorized by using the [`jq`] command line JSON processor. Further, to temporarily omit piping through any command, (unset or) set `AVAX_PIPE_RPC` to an empty string:

```
$ AVAX_PIPE_RPC='' avalanche-cli info peers -Y
```

## FAQ

### Can I install as a regular user instead as `root`?

It is actually *recommended* to avoid an installion as `root` (or via `sudo`). Instead, setup [`npm`] to install packages globally (per user) *without* breaking out of the `$HOME` folder:

```sh
$ export PATH="$PATH:$HOME/.node/bin" ## *also* put this e.g. into ~/.bashrc
$ echo 'prefix = ~/.node' >> ~/.npmrc ## use ~/.node for global npm packages
```

```sh
$ npm install avalanche-cli -g ## no sudo required
```

```sh
$ avalanche-cli -h ## show help info
```

While the recommendation above holds true for GNU/Linux users, it probably may be skipped for macOS users. Further, `zsh` users may also need to adjust the instructions accordingly (since they are for `bash` users).

## Copyright

(c) 2020, Hasan Karahan, MSc in CS, ETH Zurich. Twitter: [@notexeditor](https://twitter.com/notexeditor).

[AVAX]: https://docs.avax.network/v1.0/en/quickstart/ava-getting-started/
[`jq`]: https://stedolan.github.io/jq/
[`npm`]: https://github.com/npm/cli
[`npx`]: https://github.com/npm/npx
