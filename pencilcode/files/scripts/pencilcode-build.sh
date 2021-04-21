#!/usr/bin/env bash

cd /home/codio/pencilcode

npm --max_old_space_size=256 run test -- browserify:dist
npm --max_old_space_size=256 run test -- uglify
npm --max_old_space_size=256 run test -- less
npm --max_old_space_size=256 run test -- builddate