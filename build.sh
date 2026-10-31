#!/usr/local/bin/bash
USE_LANG="en" USE_COLOR="true" lualatex --jobname="timeline_en_color" timeline.tex
USE_LANG="ar" USE_COLOR="true" lualatex --jobname="timeline_ar_color" timeline.tex
USE_LANG="en" USE_COLOR="false" lualatex --jobname="timeline_en_bw" timeline.tex
USE_LANG="ar" USE_COLOR="false" lualatex --jobname="timeline_ar_bw" timeline.tex
pdftocairo -svg -noshrink timeline_en_color.pdf timeline_en_color.svg
pdftocairo -svg -noshrink timeline_ar_color.pdf timeline_ar_color.svg
pdftocairo -svg -noshrink timeline_en_bw.pdf timeline_en_bw.svg
pdftocairo -svg -noshrink timeline_ar_bw.pdf timeline_ar_bw.svg

