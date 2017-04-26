#!/bin/bash

sourcery --sources Sources/Meow --templates Templates/MeowInternal.ejs --output Sources/Meow/Generated.swift "$@"