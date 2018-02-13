# TODO

## Rundeck CLI

* Default to localhost:4440 for the rundeck server?
* Source a ~/.config/rundeck-cli/config for config info, and create it if it does not exist?

## Rundeck Server

* Can build the server, need to be able to install it
* Because it takes so long to build, we should artificially cache the build for the formula development...
    - Maybe check for a ~/.cache/rundeck-server-homebrew-cache/ directory, and if it exists tar the build into it and untar instead of re-building?

