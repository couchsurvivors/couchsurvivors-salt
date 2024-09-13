# Ensure Docker's official GPG key is added
docker_gpg_key:
  file.managed:
    - name: /etc/apt/keyrings/docker.asc
    - source: https://download.docker.com/linux/debian/gpg
    - mode: 0644
    - skip_verify: True

# Add Docker repository to Apt sources
docker_repository:
  file.managed:
    - name: /etc/apt/sources.list.d/docker.list
    - contents: |
        deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.asc] https://download.docker.com/linux/debian $(lsb_release -cs) stable
    - require:
      - file: docker_gpg_key

# Update apt cache
apt_update:
  pkg.update

# Install Docker packages
docker_install:
  pkg.installed:
    - pkgs:
      - docker-ce
      - docker-ce-cli
      - containerd.io
      - docker-buildx-plugin
      - docker-compose-plugin
    - require:
      - pkg: apt_update

# Ensure Docker service is enabled and running
docker_service:
  service.running:
    - name: docker
    - enable: True
    - require:
      - pkg: docker_install

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

# Ensure the Docker Compose directory exists
docker_compose_directory:
  file.directory:
    - name: /opt/supabase/docker
    - user: root
    - group: root
    - mode: 0755

# Clone the Supabase repository
supabase_repo:
  git.latest:
    - name: https://github.com/supabase/supabase
    - target: /opt/supabase
    - rev: master  # Specify a branch or tag
    - require:
      - file: docker_compose_directory

# Copy the .env.example to .env
copy_env_file:
  file.managed:
    - name: /opt/supabase/docker/.env
    - source: /opt/supabase/docker/.env.example
    - require:
      - git: supabase_repo

# Pull the latest Docker images
pull_docker_images:
  cmd.run:
    - name: docker compose pull
    - cwd: /opt/supabase/docker
    - require:
      - file: copy_env_file

# Start Docker services in detached mode
start_docker_services:
  cmd.run:
    - name: docker compose up -d
    - cwd: /opt/supabase/docker
    - require:
      - cmd: pull_docker_images
