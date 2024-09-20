geofabrik_osm_prep:
  # Create directory for OSM files
  file.directory:
    - name: /srv/osm
    - makedirs: True

install_osm2pgsql:
  # Install osm2pgsql
  pkg.installed:
    - name: osm2pgsql

download_osm_file:
  # Download the OSM file
  cmd.run:
    - name: wget -O /srv/osm/europe-latest.osm.bz2 https://download.geofabrik.de/europe-latest.osm.bz2
    - unless: test -f /srv/osm/europe-latest.osm.bz2
    - cwd: /srv/osm
    - require:
      - pkg: install_osm2pgsql

unpack_osm_file:
  # Unpack the OSM file
  cmd.run:
    - name: bunzip2 -k /srv/osm/europe-latest.osm.bz2
    - unless: test -f /srv/osm/europe-latest.osm
    - cwd: /srv/osm
    - require:
      - cmd: download_osm_file

osm2pgsql_command_execution:
  # Placeholder for command execution using osm2pgsql
  cmd.run:
    - name: osm2pgsql --slim --create --database your_database_name --username your_username --host your_host /srv/osm/europe-latest.osm
    - cwd: /srv/osm
    - require:
      - cmd: unpack_osm_file
    - onlyif: test -f /srv/osm/europe-latest.osm
