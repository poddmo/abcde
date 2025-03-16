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
- Improved handling of CD sets:
  - The -W option is expanded to optionally add the total number of discs in the set. These details are recorded in the FLAC metadata tags DISCNUMBER and DISCTOTAL
  - Create playlist defaults to append instead of erase when the disc number is greater than 1
- Improved handling of metadata: CDDB extended info (EXT*) are added passed through to FLAC tags
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
- improve the diff display: show cddb entry number in the header
- highlight CDDB entries with extended info and provide a way to view it
- make the CDDB entry choice prompt for locally cached (line ~2618) the same as in do_cddbedit (line ~3031)
- quit immediately and exit cleanly options
- archive metadata action
- create a completion report a la rubyrip that shows if any tracks have read errors
- FLACTAGSTARTCASE and SIMPLIFYPUNCTUATION should probably apply globally to tags and names

# Known issues
- tested only with flac encoding
- one-track flacs: embedded cue sheet does not include track titles (pre-existing issue)
- not patched or tested for genre issues

# Testing
- OS: Ubuntu 22.04.4
- Hardware: x64 with two SATA CDROMs
## Example Command lines
```
abcde -V -G -o flac -d /dev/sr0
abcde -V -G -o flac -d /dev/sr0 -W 1,2
abcde -V -o flac -d /dev/sr1 -W 2,2
```
Verbose rip (-V), download albumart (-G), output to FLAC (-o flac), CD is part of a set (-W 1,2). I only try to download albumart for the first disc in a set.

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
