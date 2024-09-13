# Ensure Docker is installed
docker_software:
  pkg.installed:
    - name: docker.io

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