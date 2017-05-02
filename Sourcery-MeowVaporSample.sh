#!/bin/bash

sourcery --sources Sources/MeowVaporSample --templates Templates/MeowVapor.ejs --output Sources/MeowVaporSample/Generated.swift "$@"
