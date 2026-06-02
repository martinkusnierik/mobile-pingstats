#!/bin/sh
pkg update -y
pkg upgrade -y
pkg install -y inetutils
echo "Termux dependencies installed."
