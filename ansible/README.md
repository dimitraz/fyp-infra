# Kafkaless installer

An ansible playbook for installing [Kafka](https://kafka.apache.org/) and [Kubeless](https://kubeless.io) on a running Openshift instance.

- Kubeless version: [`v1.0.2`](https://github.com/kubeless/kubeless/releases/tag/v1.0.2)
- Strimzi version: [`0.11.1`](https://github.com/strimzi/strimzi-kafka-operator/releases/tag/0.11.1)

## Why

Kubeless is a Kubernetes-native serverless solution which uses Apache Kafka for messaging under the hood. By default Kubeless runs a Kafka instance for you, but a custom cluster can be used instead (for example, if one already exists in the Kubernetes/Openshift cluster, or if a higher level of configuration is needed). This playbook handles the setup necessary to do this, and uses [Strimzi](https://strimzi.io/) for the Kafka cluster. Strimzi provides a way to run an Apache Kafka cluster on OpenShift and Kubernetes in various deployment configurations.

## Run

To start the playbook, make sure you have ansible installed, and run the following command:

```
ansible-playbook site.yml
```

### Variables

Can be edited in _group_vars/all_.

- `kubeless_namespace`: The name of the Kubeless namespace
- `kafka_namespace`: The name of the Strimzi/Kafka namespace
- `kafka_cluster_name`: The name of the Strimzi/Kafka cluster

## Kafka triggers

When setting up the Kubeless instance, a trigger controller is also created. This allows functions to be triggered whenever messages are published to given (trigger) topics in Kafka. To do this,

- Create a kubeless kafka trigger. This needs to associate a function with a topic that, when published to, will cause it to be invoked. For example, a `hello_world` function could be invoked whenever a producer publishes a message to the `hello` topic
- Produce a message to that topic (for testing I usually use [these Go producers/consumers](https://github.com/dimitraz/kafka-on-k8s))
- That's it! The function should be invoked.

A guided example can be found in [this blog post](https://dimitraz.github.io/blog/post/kubless-kafka/).
