### ToDo list:
* Add a proper README.md.
* Add Usage section to the Makefile.
* ~~Cleanup Vagrantfile.template for it to only include monitoring and application VMs.~~
* ~~Allow for configurable RAM/CPUs in Vagrantfile.template or better yet - move them into a separate config-file.~~
* ~~Finish transition to only two deployment roles.~~
* Cleanup roles from redundant files.
* Make grafana dashboard configurable.
* Properly override telegraf_config variable.


* If any time left: add unit-tests using molecule

### Concept

There are two virtual machines:
 * `log_generator`- generates logs into the local file and sends them to Kafka on `log_broker` via Vector Log Collector
 * `log_broker` - broker for the logs, with installed monitoring tools
 
`log_generator` and `log_broker` are communicating with each other over the private network.

You may ask a question: 
```
Why is done through virtual machines, and not from docker?
``` 
The main reasoning behind this - such setup is much closer how it will look like in the cloud. 
The only difference between Amazon and local env - is Amazon has `kvm`, and local setup uses `virtualbox`. 
Plus, such deployment provides separation of responsibilities.


Inside the `log_generator` there are:
* Flog is a log generator.
* Vector is a log collector.
* Telegraf is an aggregator of metrics.

Inside the `log_broker` there are:
* Zookeeper - 1 pc, for the work of kafka.
* Kafka is a confluent image, conveniently configured through environment variables. 
* Telegraf - collects metrics from Kafka and from the docker demon. Kafka takes the number of messages per second and the size of the topic in bytes.
* InfluxDB - takes metrics from telegraphs.
* Grafana - for rendering metrics.


### How to start environment?

In order to setup local environment you should have `python` installed on your machine as well as `virtualenv`. 
More details on how to  [install python](https://www.python.org/downloads/) and [install virtualenv](https://packaging.python.org/guides/installing-using-pip-and-virtual-environments/).

Additionally setup will require [vagrant](https://www.vagrantup.com/docs/installation/). 

Once all the requirements are met, navigate to the repository directory and run following commands:

```bash
make python_virtualenv_setup
source virtualenv/bin/activate
make base_box_build
make render_template
vagrant up
```

Running these commands for the first time will take a while, feel free to go and grab a cup of wonderful tea or 
flavourful coffee (or any other **non-alcoholic** drink of your choice).

Once the process is complete you will see something like this:
```
PLAY RECAP *********************************************************************
application                : ok=26   changed=15   unreachable=0    failed=0    skipped=4    rescued=0    ignored=0   
```

Additionally the following processes will be available: 

Grafana (login: admin, password: secret)

```
http://192.169.56.102:3000/
```
Zookeper

```
192.169.56.102:2181
```

Kafka cluster
```
192.169.56.102:9091,192.169.56.102:9092,192.169.56.102:9093
```
Additionally a plugin is connected to Kafka cluster, which gives JMX metrics via the REST API on port 8771 
(8772 and 8773 for two other brokers).

### How to connect to environment?

The flow is pretty simple - first you access virtual machine and afterwards you list docker processes and exec bash on it 
```
vagrant ssh log_generator # aleternatively log_broker
sudo su
docker ps -a
``` 

### How to stop/destroy environment?

To suspend virtual machines simply run:
```
vagrant suspend
```

To kill virtual machines simply run:

```
vagrant destroy
```