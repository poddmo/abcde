# Introduction
This is a fork of [abcde](https://abcde.einval.com/wiki/):
> abcde version 2.9.3 is the most recent download and was released on February 5th 2019.
The starting point for this GitHub repository was [2.9.4-DEV](https://git.einval.com/git/abcde.git) with the last commit dated 2021-02-14.

I've ripped many hundreds of CD's with abcde and wanted to fix some bugs and have a go at some enhancements - now up to version 2.12.1 released on 6th February, 2026.

My objective is to create music tracks, especially lossless flacs, for listening and also to record as much information from the read process as possible for archival posterity, such as TOC, cue sheet, CD-TEXT, enhanced CD directory listing, media read progress/status/errors and metadata downloaded. Ideally the info should be stored in the audio file metadata. It is still possible to read once and output to several music file formats but I mostly focus on flac.

Your feedback is very welcome. Please open an issue or pull request and I will look at it.

# Features
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
- Read hidden track one audio tracks, if they exist
- Enhanced whole disk flac archives with hidden track one audio and cue sheet with track titles.
  - Whole disk flac archives are now a format of focus due to their ability to capture an entire album and all the metadata in a single file. Additionally, more music players are able to handle them correctly.
- Generate a MusicBrainz URL that can be used to submit CD Table of Contents (TOC) if they are not found during the lookup
- Album art selection and handling improvements

## Bug fixes, patches and pull requests
- applied many patches from GitHub issues and pull requests
- applied many patches from bug reports: https://abcde.einval.com/bugzilla/query.cgi
- applied many patches from the mailing list: https://lists.einval.com/cgi-bin/mailman/listinfo/abcde-users
  - rip one track CDs
  - show release year in cddb choices
  - provide help option in cddb choices
    - explain how to diff
    - provide option to re-list choices

## Todo
- Move these Todo items from here to enhancement Issues
- Improve CDDB selection dialogue:
  - improve the diff display: show cddb entry number and source (ie musicbrainz, cddb, cd-text, local) in the header
  - highlight CDDB entries with extended info and provide a way to view it
  - make the CDDB entry choice prompt for locally cached (line ~2618) the same as in do_cddbedit (line ~3031)
  - add `q` quit immediately and `x` exit cleanly options
- archive metadata action
  - log the output of the ripping utility (cdparanoia)
  - create a completion report a la rubyrip that shows if any tracks have read errors (adding the `-l` option to cdparanoia logs the progress bar that can be used for analysis and reporting)
- FLACTAGSTARTCASE and SIMPLIFYPUNCTUATION should probably apply globally to tags and names
- review playlist generation
  - add a new playlist option: `s` sort. Keep the existing playlist, append the new tracks, sort numerically, replace the existing playlist with the new sorted playlist. This new option will permit ripping discs in sets in any order and in parallel. Currently discs in sets need to be ripped sequentially for the generated playlist to make sense.
  - or just make a new playlist every time from the files in the directory sorted numerically - this makes most sense and represents current on-disk truth

# Known issues
- tested primarily with flac encoding

# Installation Instructions
- The latest package or source code can be found here: https://github.com/poddmo/abcde/releases/latest
- See the [Testing section](https://github.com/poddmo/abcde?tab=readme-ov-file#testing) below for configuration file and command line examples

## Debian-based systems
- These instructions are for Debian, Ubuntu, Mint, Pop OS, Raspberry Pi OS and other Debian or Ubuntu-derived Linux distributions:
  - https://en.wikipedia.org/wiki/Category:Debian-based_distributions
  - https://en.wikipedia.org/wiki/Category:Ubuntu_derivatives

### Package Installation
Install the distribution version of abcde first to pull in the recommended dependencies and be set up for converting to flac and mp3:
```
sudo apt install abcde flac eject eyed3 glyrc imagemagick
```
Then install my latest updated version from the github repo with all the bug fixes, workflow and metadata improvements:
```
wget https://github.com/poddmo/abcde/releases/download/2.12.1/abcde_2.12.1-1_all.deb
sudo dpkg -i abcde_2.12.1-1_all.deb
```

### Build the package from source
Download the source, extract it, create a package from it and then install the fresh package:
```
wget -O abcde_2.12.1.tar.gz https://github.com/poddmo/abcde/archive/refs/tags/2.12.1.tar.gz
tar zxf abcde_2.12.1.tar.gz
cd abcde-2.12.1
dpkg-buildpackage -us -uc --build=binary
cd ..
sudo dpkg -i abcde_2.12.1-1_all.deb
```

## Red Hat-based Distributions
Sorry we don't have a package or specific instructions yet. If you're handy at building rpm packages, a pull request would be greatly appreciated by this Debian-derived bloke.

## Install from source
```
wget -O abcde_2.12.1.tar.gz https://github.com/poddmo/abcde/archive/refs/tags/2.12.1.tar.gz
tar zxf abcde_2.12.1.tar.gz
cd abcde-2.12.1
chmod 755 abcde abcde-musicbrainz-tool cddb-tool
sudo cp abcde abcde-musicbrainz-tool cddb-tool /usr/local/bin
sudo cp abcde.1 cddb-tool.1 /usr/local/share/man/man1/
```
There will be dependencies that you will need to satisfy so I suggest to begin trying to rip a CD and install those that make themselves known. For reference, these are the dependency details from the Debian package configuration:
```
Depends: cd-discid, wget, cdparanoia | icedax, vorbis-tools (>= 1.0beta4-1) | lame | flac | speex | musepack-tools | opus-tools, libmusicbrainz-discid-perl, libwebservice-musicbrainz-perl (>= 1.0.4-1.1), sensible-utils
Recommends: vorbis-tools, libdigest-sha-perl, bsd-mailx, glyrc, imagemagick
Suggests: eject, distmp3, id3 (>= 0.12), id3v2, eyed3 (<< 0.7~), normalize-audio, vorbisgain, mkcue, mp3gain, atomicparsley
```

# Configuration
- Configuration is a process you will refine over time as you rip more CDs and play the files on a variety of music players
- I recommend to get started, just put a disc in your optical drive and type:
```
abcde -V -G -o flac -d /dev/sr0
```
This should rip a CD to flac and retrieve the cover art. Then you'll start to get an idea of what to set in the configuration file

- I don't recommend using the system-wide configuration file: `/etc/abcde.conf`
- Use the default per-user configuration: `$HOME/.abcde.conf` or specify your own configuration file location with the `-c` command line option
- Use the system config file as a starting template:
```
cp /etc/abcde.conf $HOME/.abcde.conf
```
and look at my configuration file below.

# Example Command lines
```
(1) abcde -V -G -o flac -d /dev/sr0
(2) abcde -V -G -o flac -d /dev/sr0 -W 1,2
(3) abcde -V -o flac -d /dev/sr1 -W 2,2
```
- Line 1: Verbose rip (`-V`), download albumart (`-G`), output to FLAC (`-o flac`) from CDROM drive (`-d /dev/sr0`)
- Line 2: The CD in my first optical drive (`-d /dev/sr0`) is the first disc of a set (`-W 1,2`)
- Line 3: I only try to download albumart for the first disc in a set. Disc 2 of 2 (`-W 2,2`) is in my second optical drive (`-d /dev/sr1`)

# Config file example
This is my `$HOME/.abcde.conf`:
```
export LC_ALL=en_AU.UTF-8		# define locale
READHIDDENTRACK=y
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
