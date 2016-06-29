## Usage

#### Generate a config.py file for Local Execution

```bash
$ make generate-config-local
```

#### Generate a config.py file for Local Execution and Run

```bash
$ make run-local
```

#### Generate a config.py file for Cluster Execution

```bash
$ make generate-config-cluster
```

#### Generate a config.py file for Cluster Execution and Run

```bash
$ make run-cluster
```

#### Just Run with the current Config

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
