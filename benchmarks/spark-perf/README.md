## Usage

#### Generate a config.py file for Local Execution

```bash
$ make generate-config-local
```

#### Generate a config.py file for Cluster Execution

```bash
$ make generate-config-cluster
```

#### Run Using the Current Configuration or Fetch Logs

The following command is used to both execute the spark-perf benchmarks and
fetch the logs.

If neither the .source.sh file or .timestamp_file exist then the benchmarks will
run. If both files exist then this command fetches the logs. If only one of them
exists then it returns an error.

```bash
$ make
```

#### Changing the Spark Folders

Just change the "spark-bin" variable in the source.sh file in local-hadoop to
your path and rerun. The script will resource the file for you. You will also
need to copy over the spark-defaults.conf file in local-hadoop/spark/conf to
your custom build.

#### Clean

In the event that you had to interrupt an execution, run `make clean`. This will
remove some temporary files that tell the script that an execution is underway.
While these files are present an execution of `make` will fetch logs instead of
executing.

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
