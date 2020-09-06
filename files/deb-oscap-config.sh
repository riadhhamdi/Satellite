#!/bin/bash 

apt install -y  ansible  git gem rubygems build-essential
gem install foreman_scap_client


cat > openscap_client_config.yaml.j2 << EOF1
# Foreman proxy to which reports should be uploaded
:server: '{{ capsule_hostname }}'
:port: {{ capsule_port }}

## SSL specific options ##
# Client CA file.
# It could be Puppet CA certificate (e.g., '/var/lib/puppet/ssl/certs/ca.pem')
# Or (recommended for client reporting to Katello) subscription manager CA file, (e.g., '/etc/rhsm/ca/katello-server-ca.pem')
:ca_file: '/etc/foreman_scap_client/certs/ca.crt'
# Client host certificate.
# It could be Puppet agent host certificate (e.g., '/var/lib/puppet/ssl/certs/myhost.example.com.pem')
# Or (recommended for client reporting to Katello) consumer certificate (e.g., '/etc/pki/consumer/cert.pem')
:host_certificate: '/etc/foreman_scap_client/certs/host.crt'
#
# Client private key
# It could be Puppet agent private key (e.g., '/var/lib/puppet/ssl/private_keys/myhost.example.com.pem')
# Or (recommended for client reporting to Katello) consumer private key (e.g., '/etc/pki/consumer/key.pem')
:host_private_key: '/etc/foreman_scap_client/certs/host.key'
# policy (key is id as in Foreman)

{{ policy.id }}:
  :profile: '{{ scap_content }}'
  :content_path: '/var/lib/openscap/content/{{scapcontents.json.digest}}.xml'
  # Download path
  # A path to download SCAP content from proxy
  :download_path: '/compliance/policies/{{policy.id}}/content/{{scapcontents.json.digest}}'
  {% if tailoring_file.json.total > 0 %}
  :tailoring_path: '/var/lib/openscap/tailoring/{{tailoring_file.json.digest}}.xml'
  :tailoring_download_path: '/compliance/policies/{{policy.id}}/tailoring/{{tailoring_file.json.digest}}'


EOF1

cat > scap_install.yml << EOF

- hosts: localhost 
  vars_files:
    - ./vars.yml 
  tasks: 
    - name: Create client directory 
      file: 
        path: /etc/foreman_scap_client
        state: directory 
    
    - name: Get Policy parameters
      uri:
        url: https://{{satellite_server}}/api/v2/compliance/policies?full=true
        method: GET
        user: "{{satellite_username}}"
        password:  "{{satellite_password}}"
        force_basic_auth: yes
        body_format: json
        validate_certs: false 
      register: policies
    
    - name: showing the list of policies and related configuration 
      debug:
        var: policies 
    
    - name: Build policy {{ policy_name }} parameters
      set_fact:
        policy: "{{ item }}"
      with_items: "{{policies.json.results}}"
      when: item.name == policy_name
    
    - name: Get the policy content 
      debug:
        var: policy
    
    - name: Fail if no policy found with required name
      fail:
      when: policy is not defined
    
    - name: Get scap content information
      uri:
        url: https://{{satellite_server}}/api/v2/compliance/scap_contents/{{policy.scap_content_id}}
        method: GET
        user: "{{satellite_username}}"
        password: "{{satellite_password}}"
        force_basic_auth: yes
        body_format: json
        validate_certs: false 
      register: scapcontents
    
    - name: Build Scap content parameters
      set_fact:
        scap_content: "{{ item.profile_id }}"
      with_items: "{{ scapcontents.json.scap_content_profiles }}"
      when: item.id == policy.scap_content_profile_id
    
    - name: Get the tailoring file location
      uri:
        url: https://{{satellite_server}}/api/v2/compliance/tailoring_files/{{policy.tailoring_file_id}}
        method: GET
        user: "{{satellite_username}}"
        password: "{{satellite_password}}"
        force_basic_auth: yes
        body_format: json
        validate_certs: false 
      register: tailoring_file
    
    - name: Apply openscap client configuration template
      template:
        src: ./openscap_client_config.yaml.j2
        dest: /etc/foreman_scap_client/config.yaml
        mode: 0644
        owner: root
        group: root
    
    - name: Configure execution crontab
      cron:
        name: "Openscap Execution"
        cron_file: 'foreman_openscap_client'
        job: '/usr/bin/foreman_scap_client {{policy.id}} > /dev/null'
        weekday: "{{crontab_weekdays}}"
        hour: "{{crontab_hour}}"
        minute: "{{crontab_minute}}"
        user: root
    - name: Configure file for certs 
      file: 
        path: /etc/foreman_scap_client/certs/
        state: directory

EOF


echo -n 'Provide Satellite FQDN : '
read  sat_fqdn
echo -n 'Provide Satellite IP : '
read  sat_ip
echo -n 'Provide OpenScap Policy name : '
read  scap_policy
echo -n 'Provide a valid Satellite username : '
read  sat_user
echo -n 'Provide a valid Satellite password : '
read  sat_pass

echo 

echo "satellite_username: $sat_user" >> vars.yml 
echo "satellite_password: $sat_pass" >> vars.yml
echo "satellite_server: $sat_ip"     >> vars.yml
echo "capsule_hostname: $sat_fqdn"   >> vars.yml
echo "capsule_port: '9090'"          >> vars.yml
echo "policy_name: $scap_policy"     >> vars.yml
echo "crontab_hour: '2'"             >> vars.yml
echo "crontab_minute: '0'"           >> vars.yml
echo "crontab_weekdays: '0'"         >> vars.yml



ansible-playbook scap_install.yml
# rm -rf vars.yml 
# rm -rf playbook.yml 