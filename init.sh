#!/bin/bash

# 目标目录
TARGET_DIR=$1

# 复制所需的文件和目录
cp -r 0.tex 1.tex 2.tex 3.tex CCNU.sty Makefile ref.bib slide.pdf slide.synctex.gz slide.tex "$TARGET_DIR"

# 创建目标目录中的 pic 目录并复制 logo
mkdir -p "$TARGET_DIR/pic"
cp -r pic/logo "$TARGET_DIR/pic"