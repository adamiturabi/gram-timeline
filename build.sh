#!/usr/local/bin/bash
USE_LANG="ar" lualatex --jobname="timeline_ar" diagram.tex
USE_LANG="en" lualatex --jobname="timeline_en" diagram.tex
