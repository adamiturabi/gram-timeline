#!/usr/local/bin/bash
USE_LANG="ar" lualatex --jobname="grammarians_ar" diagram.tex
USE_LANG="en" lualatex --jobname="grammarians_en" diagram.tex
