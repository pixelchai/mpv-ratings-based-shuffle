ratings-based-shuffle
=====================

Simple mpv script to easily customize random playlist song selection.

Usage
-----

Every file initially has a 'rating' of `0.5`. Using the upvote/downvote keybindings, the rating of the currently playing file can be increased by decreased by 0.5.
Use the shortcut Alt+r (by default) to advance to a new file from the rated files, randomly selected weighted on its rating.

Installation and configuration
------------------------------

Place `ratings-based-shuffle.lua` in your `~/.config/mpv/scripts`.

Copy `ratings-based-shuffle.conf` into `~/.config/mpv/script-opts` and adjust the option values: set `directory` to the location of the files you want to play. Ratings will be saved in the file specified by `ratings_file`. Example:

```
directory=/home/username/Music/BigPlaylist
ratings_file=/home/username/.config/mpv/rbs-ratings.txt
```

Set up the keybindings in your `input.conf` (usually located in `~/.config/mpv`) as per the example in `input.conf`