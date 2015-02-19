# gist_directory

Create and maintain collections of public gists in a local directory

# Dependencies

```
npm install gulp-octodown-livereload
```

# Usage

Create a gist called `bacon.md` in a directory called `food`
under your home directory:

```shell
gist_directory create ~/food/bacon.md
```

Edit in your favourite editor (creating if necessary):

```shell
gist_directory edit ~/food/bacon.md
```

View compiled Markdown in your browser (ith livereload):

```shell
gist_directory view ~/food/bacon.md
