# Introduction
I've ripped hundreds of CD's with abcde and before I embark on the next few hundred, I want to fix some bugs and have a go at some enhancements.

My ripping objective is to create lossless music tracks (flac) for listening and also to record as much information from the read process as possible for archival posterity, such as TOC, cue sheet, CD-TEXT, enhanced CD directory listing, media read progress/status/errors and metadata downloaded. Ideally the info should be stored in the audio file metadata.

# Features
- applied many patches from bug reports: https://abcde.einval.com/bugzilla/query.cgi
- applied many patches from the mailing list: https://lists.einval.com/cgi-bin/mailman/listinfo/abcde-users
  - rip one track CDs
  - show release year in cddb choices
  - provide help option in cddb choices
    - explain how to diff
    - provide option to re-list choices

## Enhancements
- Improved handling of CD sets. The -W option is expanded to optionally add the total number of discs in the set. These details are recorded in the metadata and there are some improvements to the workflow, eg create playlist defaults to append instead of erase when the disc number is greater than 1.
- Define a default local album art directory/file location. If the album artwork download fails or the user chooses to overide the downloaded art, abcde will look for ALBUMARTDIR/ALBUMARTFILE before asking the user to manually enter the filename.
- Created munge helper functions:
  - munge_fs-safe: remove characters that are not Windows and Linux file-system safe or sane
  - munge_Startcase: capitalise the first letter of every word
  - munge_unicodetoascii: transliterate Unicode to ASCII
  - munge_collapsewhitespace: replace multiple spaces with a single space
- Add new mungefilename config example to use munge helper functions
- Create new config option STARTCASEFLACTAGS to use munge_Startcase for FLAC tags artist name, album title and track titles
  - This helps to prevent artist duplication due to inconsistent capitalisation

## Todo
- quit immediately and exit cleanly options
- archive metadata action
- highlight CDDB entries with extended info and provide a way to view it
- create a completion report a la rubyrip that shows if any tracks have read errors
- STARTCASEFLACTAGS should probably apply globally to tags and names, eg STARTCASENAMES

# Known issues
- tested only with flac encoding
- one-track flacs: embedded cue sheet does not include track titles
- not patched or tested for genre issues
- unicode characters are not displayed

# Testing
- OS: Ubuntu 22.04.4
- Hardware: x64 with two SATA CDROMs
## Command line
```
abcde -V -G -o flac -d /dev/sr0
```
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
FLACOPTS='-s -e -V -8'
OUTPUTTYPE="flac"
CDROMREADERSYNTAX=cdparanoia
CDPARANOIA=cdparanoia
CDPARANOIAOPTS="-v -L --never-skip=2"
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
STARTCASEFLACTAGS=y
mungefilename ()
{
        echo "$@" | \
                munge_unicodetoascii | \
                munge_Startcase      | \
                munge_collapsewhitespace | \
                munge_fs-safe
}
```
