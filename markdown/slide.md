





### MATHSENSEI 概览



1. **CoT 提示**：
   - 文本生成模块采用 CoT（Chain-of-Thought）提示。
2. **代码生成与执行**：
   - 参考 (Gao et al., 2023) 的方法，根据上下文和数学问题生成 Python 代码（使用Sympy 等库），并通过 Python 解释器执行代码。
3. **代码自我修正**：
   -  使用 **self-refine**，根据代码解释器返回的错误消息，通过代码精炼模块迭代修正生成代码中的语法错误。












具体有两种修正策略：



1. **Without refinement：**
   - 当生成的代码出现语法错误时，直接忽略本次代码生成器的输出，在后续模块中不再使用该输出作为上下文。
2. **Code-Refinement, CR：**
   - 将错误的程序代码和错误信息一起输入给一个专门用于代码修正的 LLM。
   - LLM 生成修正后的 Python 代码，并提供“错误修复”的理由。
   - system prompt 中有常见的错误信息。



![image-20241219164042056](https://raw.githubusercontent.com/Lanthanum1/my_images/main/img/202412191641612.png)







![image-20241219164149272](https://raw.githubusercontent.com/Lanthanum1/my_images/main/img/202412191641465.png)











### 实验结果





#### MMLU 上的实验结果

![image-20241219203223863](https://raw.githubusercontent.com/Lanthanum1/my_images/main/img/202412192032997.png)



形式逻辑中的问题最好仅使用SG解决。PG+SG设置的性能下降（53.9 -> 49.5）是由于PG无法通过Python代码充分表示谓词逻辑和一阶逻辑（FOL）句子。





类似的情况在 GSM-8K 上也有体现

![image-20241220125805035](https://raw.githubusercontent.com/Lanthanum1/my_images/main/img/202412201258136.png)

PG+SG（+）中的错误很大一部分可以归因于在简单问题上应用Sympy，而WA和BS在处理简单问题时往往会在SG的上下文中引入无关的信息。



wolframalpha api 举例：

![](https://raw.githubusercontent.com/Lanthanum1/my_images/main/img/202412201355872.png)







wolframalpha api的不足之处：

- LLM 在编写 WA 的查询语句时可能出错
- 问题可能需要拆解成多个步骤，但是这种方法只调用一次 WA API，可能得不到正确的结果

![image-20241220155911184](https://raw.githubusercontent.com/Lanthanum1/my_images/main/img/202412201559368.png)





