#!/usr/bin/env python3
# -*- coding: utf-8 -*-

import logging
import re
import sys
import json
import subprocess

LOG = logging.getLogger(__name__)


# pip3 install spotify-cli-linux
def get_spotify_status():
    artist_song = None
    try:
        output = subprocess.check_output(
            "~/.local/bin/spotifycli --status 2> /dev/null",
            shell=True
        )
        parse = re.findall(r"^(.*) - (.*)", output.decode('utf-8'))
        LOG.debug(parse)
        artist_song = parse[0]
    except Exception as e:
        LOG.exception(e)
        LOG.info("Spotify is not running")

    return artist_song


def read_line():
    """ Interrupted respecting reader for stdin. """
    # try reading a line, removing any extra whitespace
    try:
        line = sys.stdin.readline().strip()
        # i3status sends EOF, or an empty line
        if not line:
            sys.exit(3)
        return line
    # exit on ctrl-c
    except KeyboardInterrupt:
        sys.exit()


def print_line(message):
    """ Non-buffered printing to stdout. """
    sys.stdout.write(message + '\n')
    sys.stdout.flush()


if __name__ == '__main__':
    logging.basicConfig(level=logging.ERROR)

    # Skip the first line which contains the version header.
    print_line(read_line())
    # The second line contains the start of the infinite array.
    print_line(read_line())

    while True:
        line, prefix = read_line(), ''
        # ignore comma at start of lines
        if line.startswith(','):
            line, prefix = line[1:], ','

        spotify_status = get_spotify_status()
        if spotify_status:
            artist = spotify_status[0]
            song = spotify_status[1]
            j = json.loads(line)
            # insert information into the start of the json, but could be anywhere
            # CHANGE THIS LINE TO INSERT SOMETHING ELSE
            j.insert(0, {'color': '#9ec600', 'full_text': ' %s - %s ' % (artist, song), 'name': 'spotify'})
            # and echo back new encoded json
            print_line(prefix + json.dumps(j))
        else:
            j = json.loads(line)
            print_line(prefix + json.dumps(j))
