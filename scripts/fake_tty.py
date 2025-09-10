#!/usr/bin/env python3

# This script runs a command in a pseudo-terminal (PTY) to simulate a terminal environment.
# Required to run doctl in CI environments where it expects a TTY.
# Source: https://github.com/actions/runner/issues/241#issuecomment-2927427664

import os, pty, sys

os.environ['TERM'] = 'xterm'
status = pty.spawn(sys.argv[1:])
if os.WIFEXITED(status):
    exit(os.WEXITSTATUS(status))
if os.WIFSIGNALED(status):
    exit(-os.WTERMSIG(status))
raise ValueError(status)
