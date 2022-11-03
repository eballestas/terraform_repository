# Network Load Balancer with Testing instances and Backend

## General File Structure:


```
eballest@cloudshell:~/github/L4ILB (eballest-sandbox)$ tree ./
./
|-- backend
|   |-- main.tf
|   |-- output.tf
|   |-- providers.tf
|   |-- terraform.tfstate
|   |-- terraform.tfstate.backup
|   `-- variables.tf
|-- backend.tf
|-- main.tf
`-- providers.tf
```


## Summary:

This is a template to implement the following infrastructure using terraform.

-  Backend on Google Cloud Storage
-  Internal TCP Load Balancer
-  Managed Instance Group
-  Health Check
-  Test VM

## Backend Module:

This module creates a Bucket on Google Cloud Storage to be used as backend for terraform

### Files:

-  Main: Google Storage Bucket Resource
-  Output: GCS bucket name
-  Providers: Required providers for this deployment, in this example GCP
-  Variables: Variables of the environment

## Root Module:

Note: To modify the port to which NGINX connects to modify the port assigned on the folder  /etc/nginx/sites-enabled/default 

Note: This is the server listening to port 80 TCP.


```
server {
        listen 80 default_server;
        listen [::]:80 default_server;
```

```
Note: To verify the port assigned
eballest@vm-g5ht:~$ sudo service nginx restart

eballest@vm-g5ht:~$ sudo service nginx status
● nginx.service - A high performance web server and a reverse proxy server
   Loaded: loaded (/lib/systemd/system/nginx.service; enabled; vendor preset: enabled)
   Active: active (running) since Thu 2022-11-03 19:28:08 UTC; 24min ago
     Docs: man:nginx(8)
 Main PID: 1344 (nginx)
    Tasks: 3 (limit: 2327)
   Memory: 2.4M
   CGroup: /system.slice/nginx.service
           ├─1344 nginx: master process /usr/sbin/nginx -g daemon on; master_process on;
           ├─1345 nginx: worker process
           └─1346 nginx: worker process

Nov 03 19:28:08 vm-g5ht systemd[1]: Starting A high performance web server and a reverse proxy server...
Nov 03 19:28:08 vm-g5ht systemd[1]: Started A high performance web server and a reverse proxy server.
```

```
eballest@vm-g5ht:~$ sudo netstat -antp
Active Internet connections (servers and established)
Proto Recv-Q Send-Q Local Address           Foreign Address         State       PID/Program name
tcp        0      0 0.0.0.0:80              0.0.0.0:*               LISTEN      1344/nginx: master
tcp        0      0 0.0.0.0:22              0.0.0.0:*               LISTEN      520/sshd
tcp        0      0 10.0.1.3:49382          169.254.169.254:80      ESTABLISHED 389/google_guest_ag
tcp        0      0 10.0.1.3:56222          216.239.34.174:443      ESTABLISHED 390/google_osconfig
tcp        0    320 10.0.1.3:22             35.235.243.226:43453    ESTABLISHED 1446/sshd: eballest
tcp6       0      0 :::80                   :::*                    LISTEN      1344/nginx: master
tcp6       0      0 :::22                   :::*                    LISTEN      520/sshd
```

This module creates the infrastructure for this deployment 

-  New VPC for this deployment
-  New Subnet for the Internal Load Balancer
-  Forwarding rule for the Load Balancer
-  Backend Service
-  Instance Template
    -  machine_type: "e2-small"
    -  NGINX Installed

-  Health Check
-  Managed Instance Group
    -  Size: 1 VM 

-  Firewall rule for Health Check
    -  Action 1:
        -  Source_ranges:  "130.211.0.0/22", "35.191.0.0/16"
        -  Default Action:  allow 
        -  Protocol: "tcp"    
        -  ports: "80", "443", "53"
        -  Target_tags :"allow-health-check"

-  Firewall rule for intra subnet connectivity
    -  Action 1:
        -  Default Action:  allow 
        -  Protocol:  "tcp"
        -  Ports: All

    -  Action 2:
        -  Default Action:  allow 
        -  Protocol:  "udp"
        -  ports: All

    -  Action 3:
        -  Default Action:  allow 
        -  Protocol:  "icmp"
        -  Ports: All

-  Firewall rule for ssh connection
    -  Action 1:
        -  Default Action:  allow 
        -  Protocol:  "tcp"
        -  ports: 22
        -  Target_tags: "allow-ssh"
        -   Source_ranges: "0.0.0.0/0"

-  Test Instance
    -  Name: "l4-ilb-test-vm"
    -  machine_type: "e2-small"

### Files:

-  Backend: Remote backend configuration
-  Main: Root module resources
-  Providers  Required providers for this deployment, in this example GCP