---
layout: single
title:  "Adding DNS entries to Pihole"
date:   2020-01-04 20:33:22 -0500
categories:
  - dev-ops
tags:
  - pihole
  - kubernetes
---

Adding static DNS entries to Pihole can be accomplished by adding entries to the Pihole server's hosts file `/etc/hosts`. For example:

{% highlight shell %}
    192.168.1.100    pihole.yourdomain
    192.168.1.100    blog.yourdomain
    192.168.1.101    foo.yourdomain
{% endhighlight %}

If you've deployed Pihole within a Kubernetes cluster then Kubernetes [Hosts Aliases](https://kubernetes.io/docs/concepts/services-networking/add-entries-to-pod-etc-hosts-with-host-aliases/) can be used to add static DNS entries to Pihole.

{% highlight yaml %}
    hostAliases:
    - ip: "192.168.1.100"
      hostnames:
      - "pihole.yourdomain"
      - "blog.yourdomain"
    - ip: "192.168.1.101"
      hostnames:
      - "foo.yourdomain"
{% endhighlight %}
