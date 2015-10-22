#!/bin/bash

cd demo
bundle install
npm install
bin/rake spec SPEC_OPTS="--format documentation"
