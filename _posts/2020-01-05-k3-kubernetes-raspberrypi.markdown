---
layout: single
title:  "K3 for Running Kubernetes on Raspberry pi"
date:   2020-01-05 20:20:32 -0500
categories:
  - dev-ops
tags:
  - raspberrypi
  - kubernetes
  - k3
---

[Rachers K3 Github Repository](https://github.com/rancher/k3s#k3s---5-less-than-k8s) describes K3 as a *Lightweight Kubernetes. Easy to install, half the memory, all in a binary less than 40mb.* These characteristics make K3 ideal for in use in ARM deployments like Raspberry Pi. I've been using K3 at home for several weeks now and have found it to be a suitable replacement for a full Kubernetes deployment.

In my experience installation can be performed with simple scripting and takes about two minutes.

{% highlight shell %}
  # install k3 service on controller machine
  curl -sfL https://get.k3s.io | sh -

  # get token from the controller
  K3S_TOKEN="$(cat /var/lib/rancher/k3s/server/node-token)"

  # set server url
  K3S_URL="https://myserver:6443"

  # install k3 agent on node machine
  curl -sfL https://get.k3s.io | K3S_TOKEN=$K3S_TOKEN K3S_URL=$K3S_URL sh -
{% endhighlight %}

Once you've installed the controller the cluster's Kubeconfig may be obtained form the `/etc/rancher/k3s/k3s.yaml` file

{% highlight shell %}
  export KUBECONFIG=/etc/rancher/k3s/k3s.yaml && kubectl get nodes
{% endhighlight %}
