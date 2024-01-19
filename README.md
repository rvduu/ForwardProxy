# ForwardProxy
Simple Apache HTTPD based non-caching Forward proxy - container on Fedora


### Requirements
This setup is based on running `httpd` in a Container on Fedora
1. Container tools

        $ sudo dnf install podman skopeo
        
1. Optional the Cockpit podman component

        $ sudo dnf install cockpit-podman

1. Allow incoming trafic for port 8080 in the firewall

        $ sudo firewall-cmd --add-port 8080/tcp --permanent
        $ sudo firewall-cmd --reload



### Build container
1. Download sources and create password to protect the proxy

        $ git clone https://github.com/rvanderwees/ForwardProxy
        $ cd ForwardProxy

1. Protect the proxy by creating a htdigest file with username and password
    1. If the [`htdigest`](https://httpd.apache.org/docs/2.4/programs/htdigest.html) utility is installed 

            $ htdigest -c htdigest proxy proxy
            Adding password for user in realm Proxy.
            New password: 
            Re-type new password: 

    1. Or alternatively, on other systems that do not hat `htdigest`, use the `md5sum` utility

            $ echo proxy:proxy:$(echo -n proxy:proxy:<password> | md5sum | cut -f1 -d ' ') > htdigest

1. Build the container

        $ podman build -t httpdproxy .


### Run container

    $ podman run -d --rm --name httpdproxy -p 8080:8080 localhost/httpdproxy


### Test
From a different host / network other than the proxy server hosting the container, run the following commands and notice the difference in IP address:

    $ curl https://ipinfo.io/ip
    $ curl --proxy-user "proxy:<password>" --proxy-digest -x http://<hostname_of_proxy_server>:8080/ https://ipinfo.io/ip


### Make persistent accross reboots
1. Generate a systemd unit file of the running container:

        $ podman generate systemd --name httpdproxy --new --files

1. Move unit file in place:

        $ mkdir -p ~/.config/systemd/user
        $ mv container-<container_id>.service ~/.config/systemd/user/httpdproxy.service

1. Make systemd recognise the new unit file and enable the service:

        $ systemctl --user daemon-reload
        $ systemctl --user enable --now httpdproxy.service
        $ systemctl --user status httpdproxy.service
        $ podman ps

1. Make sure the container keeps running after logout:

        $ loginctl enable-linger
        


### Rebuild / update
1. Pull updated httpd-24 container

        $ podman pull quay.io/fedora/httpd-24
        
1. Rebuild container

        $ cd ForwardProxy
        $ git pull
        $ podman build -t httpdproxy .
        $ systemctl --user restart httpdproxy.service
