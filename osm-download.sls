geofabrik_osm_prep:
  file.directory:
    - name: /srv/osm
    - makedirs: True

  # Install osm2pgsql
  pkg.installed:
    - name: osm2pgsql

  cmd.run:
    - name: wget -O /srv/osm/europe-latest.osm.bz2 https://download.geofabrik.de/europe-latest.osm.bz2
    - unless: test -f /srv/osm/europe-latest.osm.bz2
    - cwd: /srv/osm
    - require:
      - pkg: geofabrik_osm_prep

  cmd.run:
    - name: bunzip2 -k /srv/osm/europe-latest.osm.bz2
    - unless: test -f /srv/osm/europe-latest.osm
    - cwd: /srv/osm
    - require:
      - cmd: geofabrik_osm_prep

osm2pgsql_command_execution:
  cmd.run:
    - name: osm2pgsql --slim --create --database your_database_name --username your_username --host your_host /srv/osm/europe-latest.osm
    - cwd: /srv/osm
    - require:
      - cmd: geofabrik_osm_prep
    - onlyif: test -f /srv/osm/europe-latest.osm