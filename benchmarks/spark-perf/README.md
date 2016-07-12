## Usage

#### Generate a config.py file for Local Execution

```bash
$ make generate-config-local
```

#### Generate a config.py file for Cluster Execution

```bash
$ make generate-config-cluster
```

#### Run Using the Current Configuration

```bash
$ make
```

Or:

```bash
$ make run
```


## SSH Setup

The ./bin/run script that is used to run the tests uses ssh. If you do not want
to have to type in your password several times, follow these steps to setup a
passwordless ssh to localhost.

```bash
$ cd ~
$ ssh-keygen -t rsa
# Press enter for all prompts (Even for the password prompt)
$ cat ~/.ssh/id_rsa.pub >> ~/.ssh/authorized_keys

# Optional for security:
$ chmod og-wx ~/.ssh/authorized_keys
```
