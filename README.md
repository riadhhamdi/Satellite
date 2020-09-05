# Manage Debian Content with Red Hat Satellite

This documentation explains how to install Red Hat Satellite and manage debian content. 


## Prerequisites 
- 1 physical server / virtual machine 
- 4 CPus and 32 GB RAM  (recommanded) 
- Red Hat Satellite subscription. 

:warning: **Caution: Enabling foreman and katello debian plugin is not supported by Red Hat**, check the following solution: https://access.redhat.com/solutions/1519433 



## Installation 

== Registering server to Red Hat CDN and enabling repositories for Satellite 

```
subscription-manager register
subscription-manager list --all --available --matches 'Red Hat Satellite Infrastructure Subscription'
subscription-manager attach --pool=<pool_id>
subscription-manager repos --disable "*"
subscription-manager repos --enable=rhel-7-server-rpms \
--enable=rhel-server-7-satellite-6-beta-rpms \
--enable=rhel-7-server-satellite-maintenance-6-beta-rpms \
--enable=rhel-server-rhscl-7-rpms \
--enable=rhel-7-server-ansible-2.9-rpms

```




== geting additional content for debian 

yum install  https://repos.fedorapeople.org/pulp/pulp/stable/latest/7Server/x86_64/pulp-deb-plugins-1.10.1-1.el7.noarch.rpm https://repos.fedorapeople.org/pulp/pulp/stable/latest/7Server/x86_64/python-pulp-deb-common-1.10.1-1.el7.noarch.rpm  https://repos.fedorapeople.org/pulp/pulp/stable/latest/7Server/x86_64/python2-debpkgr-1.1.0-1.el7.noarch.rpm

NOTE: if packages are not found in the given URIs you can find them in the packages directory 


==Installing Red Hat Satellite with deb plugins 



satellite-installer --scenario satellite --foreman-initial-admin-username admin --foreman-initial-admin-password redhat --foreman-initial-location Paris --foreman-initial-organization RedHat  --foreman-proxy-content-enable-deb true --katello-enable-deb true



== Troubleshooting 


