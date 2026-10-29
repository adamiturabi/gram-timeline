#!/usr/local/bin/bash
USE_LANG="ar" lualatex --jobname="timeline_ar" timeline.tex
USE_LANG="en" lualatex --jobname="timeline_en" timeline.tex
