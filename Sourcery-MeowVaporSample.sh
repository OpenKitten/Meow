#!/bin/bash

sourcery --sources Sources/MeowVaporSample --templates Templates/Meow.ejs --output Sources/MeowVaporSample/Generated.swift "$@"
