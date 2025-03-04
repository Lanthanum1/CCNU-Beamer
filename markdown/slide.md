基于工具增强的大语言模型数学推理框架

## R1 回顾

### CoT: 从入门到放弃
![a9b57c04a657d364d20fc52fa4b9c28b.png](https://raw.githubusercontent.com/Lanthanum1/my_images/main/img/202503032107607.png)
对于一些稍微需要思考的问题，通过让 LLM think step by step，可以取得比较不错的效果

---

但是 CoT 不是万能的，很多复杂问题不能简单地在在 prompt 中加一句“Lets' verify step by step” 就能够正确解答，因此我们才需要 Reasoning Model。

**2024 AIME I Problem 4** 
Jen enters a lottery by picking $4$ distinct numbers from $S = {1, 2, 3, \cdots, 9, 10}$. $4$ numbers are randomly chosen from $S$. She wins a prize if at least two of her numbers were $2$ of the randomly chosen numbers, and wins the grand prize if all four of her numbers were the randomly chosen numbers. The probability of her winning the grand prize given that she won a prize is $m/n$ where $m$ and $n$ are relatively prime positive integers. Find $m + n$.

**2025 考研数学一 T18**
已知函数 $f(u)$ 在区间 $(0, +\infty)$ 内具有二阶导数, 记 $g(x, y) = f(\frac{x}{y})$, 若 $g(x, y)$ 满足
$$x^2\frac{\partial^2 g}{\partial x^2} + xy\frac{\partial^2 g}{\partial x \partial y} + y^2\frac{\partial^2 g}{\partial y^2} = 1,$$
且 $g(x,y)=1$,$\frac{\partial g}{\partial x}\bigg|_{(x, y)} = \frac{2}{x}$ , 求 $f(u)$.


---

### R1 的训练流程
CoT 和 Reasoning Model 的本质区别在于 CoT 是我们让 LLM 搜索，而 Reasoning Model 则会自己搜索。
“自己搜索”的关键在于强化学习。

![05465b6b3a6484db21fcde6c8c0be792.png](https://ghfast.top/https://raw.githubusercontent.com/Lanthanum1/my_images/main/img/202503041422317.png)


