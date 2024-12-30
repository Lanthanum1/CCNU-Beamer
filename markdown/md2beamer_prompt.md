转换为latex beamer，
有以下要求：
1. 尽量多分frame，以免装不下；

2. 图片用./pic/1.png , ./pic/2.png等代替；

3. 图片需要放在 figure 环境内，并且需要假设图片装不下，需要设置 width=0.6\textwidth 或者 width=0.7\textwidth；

4. 如果有表格，可以使用两种方式减小表格大小，不至于overbox，一是在出现表格前使用\scriptsize减小字体大小，二是\scalebox来缩放；

5. 尽量不修改原语言；

6. 需要有 \section，不过 \subsection 是可选的，不是必须，标题内容你可以自己总结。