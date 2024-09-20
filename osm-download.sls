geofabrik_download_and_unpack:
  file.directory:
    - name: /srv/osm
    - makedirs: True

  cmd.run:
    - name: wget -O /srv/osm/europe-latest.osm.bz2 https://download.geofabrik.de/europe-latest.osm.bz2
    - unless: test -f /srv/osm/europe-latest.osm.bz2
    - cwd: /srv/osm
    - require:
      - file: geofabrik_download_and_unpack

  cmd.run:
    - name: bunzip2 -k /srv/osm/europe-latest.osm.bz2
    - unless: test -f /srv/osm/europe-latest.osm
    - cwd: /srv/osm
    - require:
      - cmd: geofabrik_download_and_unpack