# Simple 3 node Apache Cassandra setup
I was recently handed a rush request to get a 3 node Cassandra cluster with replication factor of 2 working for a development job. I had little idea what that meant but needed to figure it out - a typical day in a sysadmin's job.

We'll quickly cover the steps here to set up a basic 3 node Cassandra cluster from scratch with some extra bits for replication and future node expansion.

## Basic nodes needed
To start this, you need some basic Linux machines. For a production install, you would likely be designing physical machines into racks, datacenters, and diverse locations. For development, you just need something suitably sized for the scale of our development.  In our case, we used three CentOS 7 virtual machines on VMware having 20g thin provisioned disks, 2 processors, 4g of RAM.  These three machines will be referred to as CS1 (192.168.0.110), CS2 (192.168.0.120), and CS3 (192.168.0.130).

The three machines got the minimal CentOS7 install. To run this in production with CentOS, you would need to consider tweaking firewalld and selinux. Since this was only to be used for initial development, we turned those off.  The only other special need was an OpenJDK 1.8 instsllstion.

## Installation
Each machine had a user account 'cass' created. Apache Cassandra was [downloaded from here](https://cassandra.apache.org/download/) with the current version at time of this writing being 3.11.4. The Cassandra archive was extracted in the 'cass' home directory like this:
```
$ tar zfvx apache-cassandra-3.11.4-bin.tar.gz
```
The complete software will be contained in `~cass/apache-cassandra-3.11.4`. For a quick developement trial this was fine. The data files will be contained there and the `conf/` directory has the important bits we need to tune these nodes into a real cluster.

## Configuration
Out of the box, Cassandra will run as a localhost one node cluster. That is convenient for a quick look, but we need a real cluster that external clients can access.  We are also looking to add in additional nodes when our development and test needs broaden.  The two configuration files we need to look at are `conf/cassandra.yaml` and `conf/cassandra-rackdc.properties`. 

First we need to edit `conf/cassandra.yaml` in order to set the cluster name, the network and rpc interfaces, define peers, and change the strategy for routing requests and replication.

Edit `conf/cassandra.yaml` on each of the cluster nodes.

Change the cluster name to be the same on each node:
`cluster_name: 'DevClust'`

Change the following 2 entries to match the primary IP address of the node you are working on:
```
listen_address: 192.168.0.110
rpc_address:  192.168.0.110
```

Find the "seed_provider" entry and look for the '- seeds:' configuration line. On each node, edit this to include all your nodes:
```
        - seeds: "192.168.0.110, 192.168.0.120, 192.168.0.130"
```
That entry will get the local Cassandra instance to see all of its peers (including itself).

Look for the `endpoint_snitch` setting and change it to this:
```
endpoint_snitch: GossipingPropertyFileSnitch
```

The `endpoint_snitch` setting is what will give us flexibility later on if new nodes need to be joined. The Cassandra documentation indicates that "GossipingPropertyFileSnitch" is the preferred setting for production use and is necessary to help set the replication strategy we'll see in later example.

Save and close the cassandra.yaml file.

Open the `conf/cassandra-rackdc.properties` file and change the default values for `dc=` and `rack=`. You can make these be anything unique that will not conflict with other local installs. For production, you would put more thought into how to organize your racks and datacenters. I used some generic names like:
```
dc=NJDC
rack=rack001
```

## Start the cluster
On each node, log into the account Cassandra is installed in ("cass" in this example), `cd apache-cassandra-3.11.4/bin` and run `./cassandra`.  You will see a long list of messages print to the terminal, and the java process will run in the background.

## Confirm the cluster
While logged into the Cassandra user account, go to the bin directory and run the following:
`$ ./nodetool status`
If all went well you will see something similar to the following:
```
$ ./nodetool status
INFO  [main] 2019-08-04 15:14:18,361 Gossiper.java:1715 - No gossip backlog; proceeding
Datacenter: NJDC
================
Status=Up/Down
|/ State=Normal/Leaving/Joining/Moving
--  Address       Load       Tokens       Owns (effective)  Host ID                               Rack
UN  192.168.0.110  195.26 KiB  256          69.2%             0abc7ad5-6409-4fe3-a4e5-c0a31bd73349  rack001
UN  192.168.0.120  195.18 KiB  256          63.0%             b7ae87e5-1eab-4eb9-bcf7-4d07e4d5bd71  rack001
UN  192.168.0.130  117.96 KiB  256          67.8%             b36bb943-8ba1-4f2e-a5f9-de1a54f8d703  rack001
```
This means the cluster sees all the nodes and prints some interesting information.

One thing to note, if the cassandra.yaml uses the default `endpoint_snitch: SimpleSnitch`, the `nodetool` command above will indicate the default locations as Datacenter: datacenter1, and the racks as rack1. In the example output above, the cassandra-racdc.properties values are evident.

## Run some CQL
This is where the replication factor setting finally comes in.

First I need to create a keystore with a replication factor of 2. From any one of the cluster nodes go to the bin directory and run `./cqlsh 192.168.0.130 ` (substitute an appropriate cluster node IP address). You can see the default administratve keyspaces with the following:
```
cqlsh> SELECT * FROM system_schema.keyspaces;

 keyspace_name      | durable_writes | replication
--------------------+----------------+-------------------------------------------------------------------------------------
        system_auth |           True | {'class': 'org.apache.cassandra.locator.SimpleStrategy', 'replication_factor': '1'}
      system_schema |           True |                             {'class': 'org.apache.cassandra.locator.LocalStrategy'}
 system_distributed |           True | {'class': 'org.apache.cassandra.locator.SimpleStrategy', 'replication_factor': '3'}
             system |           True |                             {'class': 'org.apache.cassandra.locator.LocalStrategy'}
      system_traces |           True | {'class': 'org.apache.cassandra.locator.SimpleStrategy', 'replication_factor': '2'}
```

Let's create a new keyspace with replication factor 2, insert some rows and then recall some data:
```
cqlsh> CREATE KEYSPACE TestSpace WITH replication = {'class': 'NetworkTopologyStrategy', 'NJDC' : 2};
cqlsh> select * from system_schema.keyspaces where keyspace_name='testspace';

 keyspace_name | durable_writes | replication
---------------+----------------+--------------------------------------------------------------------------------
     testspace |           True | {'NJDC': '2', 'class': 'org.apache.cassandra.locator.NetworkTopologyStrategy'}
cqlsh> use testspace;
cqlsh:testspace> create table users ( userid int PRIMARY KEY, email text, name text );
cqlsh:testspace> insert into users (userid, email, name) VALUES (1, 'jd@somedomain.com', 'John Doe');
cqlsh:testspace> select * from users;

 userid | email             | name
--------+-------------------+----------
      1 | jd@somedomain.com | John Doe
```

Now we have a basic 3 node Cassandra cluster running, ready for some development and testing work. The CQL syntax looks close to standard SQL as you can see from the familiar commands above to create a table, insert, and query data.

## Conclusion
Apache Cassandra sounds like an intersting NoSQL clustered database and I'm looking forward to diving deeper into its use. This simple setup only scratches the surface of the options available. I hope this three node primer will help you get started playing with this as well.