# Satellite


== Enabling repositories for Satellite 


== geting additional content for debian 

yum install  https://repos.fedorapeople.org/pulp/pulp/stable/latest/7Server/x86_64/pulp-deb-plugins-1.10.1-1.el7.noarch.rpm https://repos.fedorapeople.org/pulp/pulp/stable/latest/7Server/x86_64/python-pulp-deb-common-1.10.1-1.el7.noarch.rpm  https://repos.fedorapeople.org/pulp/pulp/stable/latest/7Server/x86_64/python2-debpkgr-1.1.0-1.el7.noarch.rpm

NOTE: if packages are not found in the given URIs you can find them in the packages directory 


==Installing Red Hat Satellite with deb plugins 



satellite-installer --scenario satellite --foreman-initial-admin-username admin --foreman-initial-admin-password redhat --foreman-initial-location Paris --foreman-initial-organization RedHat  --foreman-proxy-content-enable-deb true --katello-enable-deb true



== Troubleshooting 

https://access.redhat.com/solutions/1519433

