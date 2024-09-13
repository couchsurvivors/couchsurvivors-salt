# Clone the Supabase repository
supabase_repo:
  git.latest:
    - name: https://github.com/supabase/supabase
    - target: /opt/supabase
    - depth: 1

# Ensure the Docker folder exists
docker_directory:
  file.directory:
    - name: /opt/supabase/docker
    - user: root
    - group: root
    - mode: 755
    - require:
      - git: supabase_repo

# Copy the .env.example to .env
copy_env_file:
  cmd.run:
    - name: cp /opt/supabase/docker/.env.example /opt/supabase/docker/.env
    - cwd: /opt/supabase/docker
    - require:
      - git: supabase_repo
      - file: docker_directory

# Pull the latest Docker images
pull_docker_images:
  cmd.run:
    - name: docker compose pull
    - cwd: /opt/supabase/docker
    - require:
      - cmd: copy_env_file

# Start Docker services in detached mode
start_docker_services:
  cmd.run:
    - name: docker compose up -d
    - cwd: /opt/supabase/docker
    - require:
      - cmd: pull_docker_images
