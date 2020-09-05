# Manage Debian Content with Red Hat Satellite

This documentation explains how to install Red Hat Satellite and manage debian content. 


## Prerequisites 
- 1 physical server / virtual machine 
- 4 CPus and 32 GB RAM  (recommanded) 
- Red Hat Satellite subscription. 


:information_source: 
```
Note: Enabling foreman and katello debian plugin is not supported by Red Hat**, 
check the following solution: https://access.redhat.com/solutions/1519433 |
```


## Installation 

1. Registering server to Red Hat CDN and enabling repositories for Satellite 

```
[root@satellite]# subscription-manager register
[root@satellite]# subscription-manager list --all --available --matches 'Red Hat Satellite Infrastructure Subscription'
[root@satellite]# subscription-manager attach --pool=<pool_id>
[root@satellite]# subscription-manager repos --disable "*"
[root@satellite]# subscription-manager repos --enable=rhel-7-server-rpms \
                                             --enable=rhel-server-7-satellite-6-beta-rpms \
                                             --enable=rhel-7-server-satellite-maintenance-6-beta-rpms \  
                                             --enable=rhel-server-rhscl-7-rpms \
                                             --enable=rhel-7-server-ansible-2.9-rpms

```




2. Installing additional content for debian content management 

***Note*** This content is not manged into Red Hat repositories and will be pulled from upstream repositories 

```
[root@satellite]# yum install  https://repos.fedorapeople.org/pulp/pulp/stable/latest/7Server/x86_64/pulp-deb-plugins-1.10.1-1.el7.noarch.rpm  \
                               https://repos.fedorapeople.org/pulp/pulp/stable/latest/7Server/x86_64/python-pulp-deb-common-1.10.1-1.el7.noarch.rpm \  
                               https://repos.fedorapeople.org/pulp/pulp/stable/latest/7Server/x86_64/python2-debpkgr-1.1.0-1.el7.noarch.rpm 
```

*NOTE*: if packages are not found in the given URIs you can find them in the packages directory in this git repository 


3. installing Red Hat Satellite packge 

```
[root@satellite]# yum update -y && yum install satellite
```



4. Run Red Hat Satellite first configuration and enable Debian plugins 

```
[root@satellite]# satellite-installer --scenario satellite --foreman-initial-admin-username admin --foreman-initial-admin-password redhat --foreman-initial-location Paris --foreman-initial-organization RedHat  --foreman-proxy-content-enable-deb true --katello-enable-deb true
```

## Synchronizing APT content in Red Hat Satellite 

- Go to **content** > **products** and create a new product 
- In the new created prodcut add a new repository , choose **apt** as the repository type 
- Add the the repository URL of debian content in the upstream_url field (exemple: http://ftp.debian.org/debian) and choose the release in the release(s) field (for example **stable**) 
- Save the repository configuration 
- On the top right of the page goto **chose action** > **sync_now**



![Alt Text](gifs/sync_deb.gif)


[Show as video](https://youtu.be/wSt3ezm3QCs "Riadh's Videos")
