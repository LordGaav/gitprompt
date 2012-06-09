A simple Bash prompt for Git and SVN
====================================

Changes your normal Bash prompt which may look something like this:

```
user@hostname:~/project$
```

into this:

```
user@hostname ~/project git::master u= $
```

How it works
------------

This script relies on the functions provided by subversion (for the SVN prompt) and git-completion (for the Git prompt). The script will automatically detect if the current directory is part of a SVN or Git checkout, and change accordingly. The script also uses grep, (g)awk and sed.
