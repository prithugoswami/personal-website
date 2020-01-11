# This is an example post

When ever you think of static site generators, you think about something like -
Gatsby, Hugo, Jekyll, etc. But I think all these are overkill. I won't even use
majority of the features they provide for my simple blog. So the best thing to
do is to build something for yourself. This can be done with simple bash
scripts with the help of `pandoc`

## Example

```python
import tmdbsimple as tmdb
from imdbpie import Imdb
from mutagen.mp4 import MP4, MP4Cover

# The following subtitle codecs are ingored if found in the file as they are
# not supported by the mp4 container. These are mainly picture-based subtitles
sub_codec_blacklist = ("dvdsub", "dvd_subtitle", "pgssub", "hdmv_pgs_subtitle")

def collect_stream_metadata(filename):
    """
    Returns a list of streams' metadata present in the media file passed as 
    the argument (filename) 
    """
    command = 'ffprobe -i "{}" -show_streams -of json'.format(filename)
    args = shlex.split(command)
    p = subprocess.Popen(args, stdout=subprocess.PIPE, stderr=subprocess.PIPE,
                         universal_newlines=True)
    out, err = p.communicate()
    
    json_data = JSONDecoder().decode(out)
    
    return json_data
```

This is very simple code.

- I am going to pretend that I am explaing this piece of code in bullet points
- But let me tell you that you shouldn't expect anything like that. I am just
  doing this so that I can see how bullet points look.
- I am going to make this third bullet point a little bigger, because why not?
  I am now going to add some gibberish as I can't come up with something
  creative. asff kdjfh addf aitng hgjffg kfsdgye al;kjgj ghjadshnb gjhafg fgh
  fghf h3 g jbh dhandg hjafjg an


## Snippets

**Using awk, tr, to get the remote info of a git repo**

This will output the (fetch) remote of a git repository and
put the contents into the clipboard

    $ git remote -v | awk '{print $2}' | head -1 | tr -d '\n' | xsel -ib

## Here's an Image

![](https://i.stack.imgur.com/cv2wX.png)
