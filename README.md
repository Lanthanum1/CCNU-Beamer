# CCNU-Beamer-Theme

## Overview

`CCNU`风格的 `Beamer`主题，可用于答辩、汇报、组会分享等.

使用校官网 `RGB(57, 130, 151)`作为底色.

使用方式和详细细节见源代码和 `slide`.

## Preview

![](./pic/1.png)

![](./pic/2.png)

![](./pic/3.png)

完整的编译后的 pdf 文件见 [slide.pdf](./slide.pdf)

## Example

具体的使用方法以及更加丰富的案例见 [sample_slides](./sample_slides/)


## Makefile

由于 LaTex Workshop 的清理脚本无法清除所有中间文件，编译文件时不要使用LaTex Workshop 的编译链，而应执行 `make` 命令会自动编译 slide.tex 并清理所有的中间文件 .

## Acknowledgements

本项目基于 [THU-Beamer-Theme](https://github.com/tuna/THU-Beamer-Theme)
