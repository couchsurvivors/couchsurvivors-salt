# Ensure Docker's official GPG key is added
docker_gpg_key:
  file.managed:
    - name: /etc/apt/keyrings/docker.asc
    - source: https://download.docker.com/linux/debian/gpg
    - mode: 0644
    - skip_verify: True

# Generate Docker repository file
docker_repository:
  cmd.run:
    - name: echo "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.asc] https://download.docker.com/linux/debian $(lsb_release -cs) stable" > /etc/apt/sources.list.d/docker.list
    - require:
      - file: docker_gpg_key

update_package_cache:
  pkg.uptodate:
    - refresh: True

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
      - pkg: update_package_cache

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

# Clone the Supabase repository and ensure /opt/supabase/docker exists
supabase_repo:
  git.latest:
    - name: git@github.com:couchsurvivors/couchsurvivors-supabase.git
    - target: /opt/supabase
    - rev: main
    - force_clone: True
    - force_fetch: True

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
