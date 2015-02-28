# `gist_directory`

Create and maintain collections of public gists in a local directory

# Dependencies

In order to view files while you're editing them, you'll need
[gulp-octodown-livereload][gulp-octodown-livereload].

[gulp-octodown-livereload]: https://github.com/joeyates/gulp-octodown-livereload

(The following assumes you have a `~/bin` directory and that it's in your
`PATH`)

```shell
gem install octodown
npm install -g gulp-octodown-livereload
cd ~/bin
ln -s /usr/local/lib/node_modules/gulp-octodown-livereload/bin/gulp-octodown-livereload
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

View compiled Markdown in your browser (with livereload):

```shell
gist_directory view ~/food/bacon.md
