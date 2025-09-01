# AI-AI Collaboration Command Reference

## Core File Operations
- `cat`: Display file content.
- `echo`: Write text to files or stdout.
- `printf`: Formatted output.
- `tee`: Read from stdin and write to stdout and files.
- `ls`: List directory contents.
- `tree`: Display directory structure.
- `mkdir`: Create directories.
- `touch`: Create empty files or update timestamps.
- `cp`: Copy files and directories.
- `mv`: Move or rename files and directories.
- `chmod`: Change file permissions.

## Text Processing and Analysis
- `grep`: Search for patterns in files.
- `sed`: Stream editor for text transformation.
- `awk`: Pattern scanning and processing language (use with caution for complex parsing).
- `sort`: Sort lines of text files.
- `uniq`: Report or omit repeated lines.
- `wc`: Count lines, words, and characters.
- `cut`: Remove sections from each line of files.
- `diff`: Compare files line by line.
- `find`: Search for files in a directory hierarchy.

## System Information and Utilities
- `date`: Print or set the system date and time.
- `df`: Report file system disk space usage.
- `du`: Estimate file space usage.
- `stat`: Display file or file system status.
- `file`: Determine file type.
- `uname`: Print system information.
- `hostname`: Show or set the system's host name.
- `pwd`: Print name of current/working directory.
- `cd`: Change directory.
- `env`: Run a program in a modified environment.
- `printenv`: Print all or part of the environment.
- `sleep`: Delay for a specified amount of time.
- `timeout`: Run a command with a time limit.

## Scripting and Execution
- `bash`, `sh`, `source`, `.`: Execute shell scripts or commands.
- `eval`: Evaluate a string as a shell command.
- `exec`: Replace the current process image with a new one.
- `command`: Execute a shell built-in or external command.
- `if`, `then`, `else`, `fi`, `case`, `esac`, `for`, `while`, `until`, `do`, `done`: Shell control structures.
- `function`, `return`, `break`, `continue`, `exit`: Shell function and control flow commands.
- `set`: Set or unset shell options and positional parameters.
- `export`: Mark other variables or functions for export into the environment.
- `alias`: Create command aliases.
- `history`: Display command history.

## Archiving and Compression
- `tar`: Manipulate tape archives.
- `zip`, `unzip`: Package and unpack specified files.
- `gzip`, `gunzip`: Compress or expand files.
- `bzip2`, `bunzip2`: Compress or expand files using bzip2.
- `xz`: Compress or decompress files using the xz algorithm.
- `7z`: File archiver with high compression ratio.

## Version Control
- `git`: Distributed version control system.
- `svn`: Apache Subversion.
- `hg`: Mercurial distributed SCM.

## Programming Languages and Package Managers
- `node`, `npm`, `npx`, `yarn`, `pnpm`: Node.js runtime and package managers.
- `python`, `python3`, `pip`, `pip3`: Python runtime and package managers.
- `ruby`, `gem`, `bundle`: Ruby runtime and package managers.
- `perl`, `cpan`: Perl runtime and package managers.
- `go`, `cargo`: Go language and Rust package manager.
- `gcc`, `g++`, `clang`: C/C++ compilers.
- `make`, `cmake`: Build automation tools.
- `java`, `javac`, `mvn`, `gradle`: Java Development Kit and build tools.
- `php`, `composer`: PHP runtime and dependency manager.
- `R`: R programming language.
- `julia`, `octave`, `scilab`: Scientific computing languages.

## Data Transformation and Querying
- `jq`: Lightweight and flexible command-line JSON processor.
- `yq`: Portable YAML processor.
- `xmllint`, `xpath`: XML processing tools.

## Networking and Web
- `curl`: Transfer data from or to a server.
- `wget`: Non-interactive network downloader.
- `nc`, `netcat`: Arbitrary TCP and UDP connections and listener.
- `telnet`: User interface to the TELNET protocol.
- `ping`: Send ICMP ECHO_REQUEST to network hosts.
- `traceroute`: Print the network hop path to a network host.
- `dig`, `nslookup`, `host`: DNS lookup utilities.
- `openssl`: Secure Sockets Layer toolkit.
- `ssh`, `scp`, `sftp`, `rsync`: Secure remote access and file transfer.
- `ftp`: File Transfer Protocol client.

## Image and Media Manipulation
- `ffmpeg`: Process multimedia streams.
- `convert`, `identify`, `exiftool`: ImageMagick utilities for image manipulation.

## Documentation and Formatting
- `pandoc`: Universal document converter.
- `latex`, `pdflatex`: LaTeX document preparation system.

## Containers and Orchestration
- `docker`, `docker-compose`: Containerization platform.
- `kubectl`: Kubernetes command-line tool.
- `helm`: Package manager for Kubernetes.

## Cloud and Infrastructure
- `aws`, `gcloud`, `az`, `doctl`: Cloud provider CLIs.

## Security and Hashing
- `gpg`: GNU Privacy Guard.
- `base64`: Encode/decode data and text files using Base64.
- `md5sum`, `sha1sum`, `sha256sum`, `sha512sum`: Compute and check message digest (hash) values.

## Process and System Monitoring
- `ps`: Report a snapshot of the current processes.
- `top`, `htop`: Display Linux processes.
- `jobs`, `bg`, `fg`: Job control.
- `kill`, `killall`, `pkill`, `pgrep`: Signal processes.
- `free`, `vmstat`, `iostat`: Report virtual memory and I/O statistics.
- `netstat`, `ss`, `lsof`: Network and open file reporting.
- `watch`: Execute a program periodically, showing output fullscreen.

## Permissions and Ownership
- `chown`, `chgrp`: Change file owner and group.
- `umask`: Set file mode creation mask.

## Parallel Processing
- `xargs`: Build and execute command lines from standard input.
- `parallel`: Parallelize execution of shell commands.
