#!/bin/bash
# ldt.sh

prog="irl.exe"
src="src"
dest="buildwin"
files="*.c"
cc="i486-mingw32-gcc"
cflags="-Wall -std=c99 -O3"
libs="-lm -lpdcurses"

function info {
    echo -e "\033[1;32m$1\033[0m"
}

function note {
    echo -e "\033[36m$1\033[0m"
}

function fatal {
    echo -e "\033[1;31m$1\033[0m"
    echo -e "\033[1;31mFatal error; aborting\033[0m"
    exit 1
}

# That's a tab character between those quotes.
export PS4="	"

case $1 in
  help)
    echo -e "\033[1mL\033[0met's \033[1md\033[0mo" \
        "\033[1mt\033[0mhis\033[1;30m.\033[37ms\033[0mtuff" \
        "\033[1mh\033[0mere!"
    echo "usage: ldt.sh [subcommand]"
    echo "where subcommand is one of:"
    echo "  build (default): compile the project"
    echo "  clean: remove anything ldt.sh created"
    echo "  help: show this message"
    ;;
  clean)
    info "Let's clean this stuff here!"
    if [ -d "$dest" ]; then
        bash -xc "rm -r \"$dest\""
    fi
    if [ -f ".ldtwinsh_last" ]; then
        bash -xc "rm .ldtwinsh_last"
    fi
    ;;
  build | *)
    info "Let's build this stuff here!"

    if [ ! -d "$src" ]; then
        fatal "Source directory not found!"
    fi

    if [ ! -d "$dest" ]; then
        note "Destination directory not found; creating it now."
        mkdir "$dest"
    fi

    cwd=$PWD

    last="$cwd/.ldtwinsh_last"
    cf="last"
    if [ ! -f ".ldtwinsh_last" ]; then
        cf="f"
    fi

    f="$src"
    if [ "$src" -ot `eval echo \\$$cf` ]; then
        note "No change since last build."
        exit 0
    fi

    cd "$src"
    for f in $files; do
        # if it's a regular file that has been changed since last build
        if [ -f "$f" -a ! `eval echo \\$$cf` -nt "$f" ]; then
            filename="${f%.*}"
            cd "$cwd"
            # Okay, yeah, this is a dirty hack, but it gets the job done without
            # having to write the same command twice.
            bash -xc "$cc -o $dest/$filename.o -c $cflags $src/$f" || exit $?
            if [ $? -ne 0 ]; then
                fatal "Build error!"
            fi
            cd "$src"
        fi
    done

    cd "$cwd"
    bash -xc "$cc -o $dest/$prog $dest/*.o $libs"

    touch .ldtwinsh_last
    ;;
esac