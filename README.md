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


## Adding  APT content to content View in Red Hat Satellite 

You can add a synchronized deb content to a content view in RedHat Satellite. 

**Note** At this moment you cannot apply filters on APT repositories in content views 

To add a content view with APT content: 

- Goto **Content** > **content views**
- Create a new content view
- Goto Apt repositories and add your apt repository 
- Publish the content view 

![Alt Text](gifs/add_deb_cv.gif)

[Show as video](https://youtu.be/8rE1vkyM3QU "Riadh's Videos")


https://github.com/theforeman/foreman_scap_client


## Adding new Debian / Ubuntu host to Red Hat Satellite 

The normal procedure to add a new host to Red Hat Satellite goes through subscription-manager. Unfortunately this binary is not available on Debian/Ubuntu hosts is only packaged as an rpm package. 

To add a new host as a foreman host you can go through the interface of your Red Hat Satellite: 

- Goto **Hosts** > **Create host**
- Add the host information (name, network[ip_address,domain], operating system) 
- After the node is created click on cancel build button so the node can appear as fully installed 

:information_source: 
```
Note: Make sure that an Operating System of type Debian/Ubuntu is created first.
This can be done by going to hosts > operating systems. 
if no operating system of type Debian is there create one
```
Here is an example to add a new Debian host to Satellite 

![Alt Text](gifs/add_deb_host.gif)

[Show as video](https://www.youtube.com/watch?v=gZzLsywnBlM&feature=youtu.be "Riadh's Videos")

## Running Ansible jobs on Debian/Ubuntu hosts 

After a node was successfully added to Red Hat Satellite you can run **Ansible** roles on it or simply do remote execution.

To run roles on a given node: 

- Add the role to the host by going to **Hosts** > **All hosts**
- Choose the host, click on the link to the host and then **edit**
- Goto Ansible Roles tab and swipe the chosen Role to the right 
- Click then on the button next to **Schedule remote job** and choose **Run Ansible Roles**



![Alt Text](gifs/run_ansible.gif)

[Show as video](https://youtu.be/n3NqjSh84P8 "Riadh's Videos")


