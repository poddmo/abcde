# Introduction
This is a fork of [abcde](https://abcde.einval.com/wiki/):
> abcde version 2.9.3 is the most recent download and was released on February 5th 2019.

I've ripped many hundreds of CD's with abcde and wanted to fix some bugs and have a go at some enhancements - now up to version 2.11.0 released on April 13th 2025.

My ripping objective is to create lossless music tracks (flac) for listening and also to record as much information from the read process as possible for archival posterity, such as TOC, cue sheet, CD-TEXT, enhanced CD directory listing, media read progress/status/errors and metadata downloaded. Ideally the info should be stored in the audio file metadata.

Your feedback is very welcome. Please open an issue or pull request and I will look at it.

# Features
- applied many patches from bug reports: https://abcde.einval.com/bugzilla/query.cgi
- applied many patches from the mailing list: https://lists.einval.com/cgi-bin/mailman/listinfo/abcde-users
  - rip one track CDs
  - show release year in cddb choices
  - provide help option in cddb choices
    - explain how to diff
    - provide option to re-list choices

## Enhancements
- Improved handling of CD sets:
  - The -W option is expanded to optionally add the total number of discs in the set. These details are recorded in the FLAC metadata tags DISCNUMBER and DISCTOTAL
  - Create playlist defaults to append instead of erase when the disc number is greater than 1
- Improved handling of FLAC COMMENT metadata:
  - comments added on the command line with the -w option are designated as USERCOMMENTS and added to every track
  - CDDB extended data (EXTD) are passed through to FLAC COMMENT tags and added to every track
  - CDDB extended track data (EXTTn) is passed through to FLAC COMMENT tags for the relevant track
  - see https://gnudb.org/gnudbformat.php for Gnudb xmcd file format
- Set the FLAC ALBUMARTIST="Various Artists" metadata tag for multi-artist CDs
- Define a default local album art directory/file location. If the album artwork download fails or the user chooses to overide the downloaded art, abcde will look for ALBUMARTDIR/ALBUMARTFILE before asking the user to manually enter the filename.
- Created munge helper functions:
  - munge_fs-safe: remove characters that are not Windows and Linux file-system safe or sane
  - munge_Startcase: capitalise the first letter of every word
  - munge_unicodetoascii: transliterate Unicode to ASCII
  - munge_collapsewhitespace: replace multiple spaces with a single space
  - munge_simplify_punctuation: helper function to standardise unicode and ascii punctuation like apostrophe's and ellipsis
- Add new mungefilename config example to use munge helper functions
- Create new config option FLACTAGSTARTCASE to use munge_Startcase for FLAC tags artist name, album title and track titles
  - This helps to prevent artist duplication due to inconsistent capitalisation

## Todo
- detect hidden track one audio (HTOA) and notify if it exists
- improve the diff display: show cddb entry number and source (ie musicbrainz, cddb, cd-text, local) in the header
- highlight CDDB entries with extended info and provide a way to view it
- make the CDDB entry choice prompt for locally cached (line ~2618) the same as in do_cddbedit (line ~3031)
  - add `q` quit immediately and `x` exit cleanly options
- archive metadata action
- create a completion report a la rubyrip that shows if any tracks have read errors (adding the `-l` option to cdparanoia logs the progress bar that can be used for analysis and reporting)
- FLACTAGSTARTCASE and SIMPLIFYPUNCTUATION should probably apply globally to tags and names
- add a new playlist option: `s` sort. Keep the existing playlist, append the new tracks, sort numerically, replace the existing playlist with the new sorted playlist. This new option will permit ripping discs in sets in any order and in parallel. Currently discs in sets need to be ripped sequentially for the generated playlist to make sense.

# Known issues
- tested only with flac encoding
- one-track flacs: embedded cue sheet does not include track titles (pre-existing issue)
- not patched or tested for genre issues

# Installation
- Download the latest package or source code from: https://github.com/poddmo/abcde/releases/latest
## Package Installation
```
wget https://github.com/poddmo/abcde/releases/download/2.11.0/abcde_2.11.0-1_all.deb
dpkg -i abcde_2.11.0-1_all.deb
```

## Source Installation
Download the source, extract it, create a package from it and then install your fresh package:
```
wget -O abcde_2.11.0.tar.gz https://github.com/poddmo/abcde/archive/refs/tags/2.11.0.tar.gz
tar zxf abcde_2.11.0.tar.gz
cd abcde-2.11.0
dpkg-buildpackage -us -uc --build=binary
cd ..
dpkg -i abcde_2.11.0-1_all.deb
```

# Testing
- OS: Ubuntu 22.04.4
- Hardware: x64 with two SATA CDROMs
## Example Command lines
```
(1) abcde -V -G -o flac -d /dev/sr0
(2) abcde -V -G -o flac -d /dev/sr0 -W 1,2
(3) abcde -V -o flac -d /dev/sr1 -W 2,2
```
- Line 1: Verbose rip (`-V`), download albumart (`-G`), output to FLAC (`-o flac`) from CDROM drive (`-d /dev/sr0`)
- Line 2: The CD in my first optical drive (`-d /dev/sr0`) is the first disc of a set (`-W 1,2`)
- Line 3: I only try to download albumart for the first disc in a set. Disc 2 or 2 (`-W 2,2`) is in my second optical drive (`-d /dev/sr1`)

## Config file
This is my $HOME/.abcde.conf
```
MAXPROCS=4                              # Run a few encoders simultaneously
PADTRACKS=y                             # Makes tracks 01 02 not 1 2
EXTRAVERBOSE=2                          # Useful for debugging
EJECTCD=y                               # Please eject cd when finished :-)
DIFFOPTS=-y
PAGEROPTS="-fM"
ALBUMARTFILE='cover.jpg'
ALBUMARTDIR="${HOME}/Music"
OVERRIDEALBUMARTDOWNLOAD=y
ANYASCIIBIN="$HOME/bin/anyascii"
LOWDISK=n
CDDBMETHOD=musicbrainz,cddb,cdtext
CDDBCOPYLOCAL="y"
CDDBLOCALDIR="$HOME/.cddb"
CDDBLOCALRECURSIVE="y"
CDDBUSELOCAL="y"
CDDBURL="http://gnudb.gnudb.org/~cddb/cddb.cgi"
CDDBSUBMIT=freedb-submit@freedb.org
NOSUBMIT=n
HELLOINFO="music@hostname"
FLACENCODERSYNTAX=flac
FLAC=flac
FLACOPTS='-s -8pV -j3'
FLACTAGSTARTCASE=y
FLACTAGALBUMARTISTTAGNAME="ALBUMARTIST"
FLACTAGALBUMARTISTVALUE="Various Artists"
AACENCODERSYNTAX=ffmpeg
FFMPEGENCOPTS="-c:a aac -b:a 192k"
OUTPUTTYPE="flac"
CDROMREADERSYNTAX=cdparanoia
CDPARANOIA=cdparanoia
CDPARANOIAOPTS="-L --never-skip=2"
CDDISCID=cd-discid
OUTPUTDIR="$HOME/Music"
ACTIONS=cddb,playlist,cue,read,encode,tag,move,clean
OUTPUTFORMAT='${ARTISTFILE}/${ALBUMFILE}/${TRACKNUM}.${TRACKFILE}'
VAOUTPUTFORMAT='Various-${ALBUMFILE}/${TRACKNUM}.${ARTISTFILE}-${TRACKFILE}'
ONETRACKOUTPUTFORMAT='${OUTPUT}/${ARTISTFILE}/${ARTISTFILE}-${ALBUMFILE}'
VAONETRACKOUTPUTFORMAT='${OUTPUT}/Various-${ALBUMFILE}/${ALBUMFILE}'
PLAYLISTFORMAT='${ARTISTFILE}/${ALBUMFILE}/${ARTISTFILE} - ${ALBUMFILE}.m3u'
VAPLAYLISTFORMAT='Various-${ALBUMFILE}/${ALBUMFILE}.m3u'
DOSPLAYLIST=y
DISPLAYCMDOPTS="-resize 900x900 -title abcde_album_art"
CONVERTOPTS="-resize 900x900>"
ALBUMARTALWAYSCONVERT="y"
SIMPLIFYPUNCTUATION="y"
munge_simplify_punctuation ()
{
        # list of targeted punctuation:
        # RIGHT SINGLE QUOTATION MARK, HORIZONTAL ELLIPSIS
        sed -e "s/\xE2\x80\x99/\'/g" \
            -e "s/\xe2\x80\xa6/.../g"
}
mungefilename ()
{
        echo "$@" | \
                munge_unicodetoascii | \
                munge_Startcase      | \
                munge_collapsewhitespace | \
                munge_fs-safe
}
```
