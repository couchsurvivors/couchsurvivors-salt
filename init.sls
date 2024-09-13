# Ensure Docker is installed
docker_software:
  pkg.installed:
    - name: docker.io

docker_compose:
  cmd.run:
    - name: |
        curl -L "https://github.com/docker/compose/releases/download/2.17.0/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose &&
        chmod +x /usr/local/bin/docker-compose
    - shell: /bin/bash
    - unless: test -x /usr/local/bin/docker-compose
    - require:
      - pkg: docker_software

# Ensure the Docker service is enabled and running
docker_service:
  service.running:
    - name: docker
    - enable: True

# Add `nougatbyte` to the `docker` group
docker_group:
  user.present:
    - name: nougatbyte
    - groups:
      - docker

# Install additional packages
additional_packages:
  pkg.installed:
    - pkgs:
      - vim
      - tree
      - htop