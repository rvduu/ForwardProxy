FROM registry.fedoraproject.org/fedora:latest

RUN dnf -y install httpd; dnf clean all
COPY httpdproxy.conf /etc/httpd/conf.d/httpdproxy.conf
COPY htdigest /var/www/.htdigest

CMD /usr/sbin/httpd -DFOREGROUND
