# 本地部署DeepSeek-R1-671B-q4_K_M完全指南

## 硬件环境

CPU：AMD EPYC 7742 64-Core Processor * 2

GPU：NVIDIA A100-SXM4-80GB * 8

RAM：1.5 TB



## 软件环境

OS：Ubuntu 22.04.5 LTS

Container：Docker 26.1.3

LLM Backend：Ollama 0.5.7 （Python Version) 

LLM Chat UI：Open WebUI 0.5.7 （Docker Version）



## 前期准备

如果是一个空白机器，并且具有 Docker 权限，推荐直接使用 Docker 版本的 Ollama + Open Webui。

1. 安装 Docker

如果有 sudo 权限，推荐直接使用 1panel 的安装脚本，在安装 1panel 的同时会自动安装好 Docker + Docker Compose，并且如果是中国大陆境内的机器会自动使用镜像地址安装，免去网络的烦恼。

```bash
curl -sSL https://resource.fit2cloud.com/1panel/package/quick_start.sh -o quick_start.sh && sudo bash quick_start.sh
```

如果不喜欢 1panel 或者没有权限安装面板，也可以直接安装 docker

```bash
export DOWNLOAD_URL="https://mirrors.tuna.tsinghua.edu.cn/docker-ce" # 非中国大陆区域可取消这行

curl -fsSL https://get.docker.com -o get-docker.sh
sudo sh get-docker.sh
```

2. 安装 Ollama + Open Webui

​		2.1 安装 Ollama

本服务器已有 Ollama，但需要升级到最新版本，否则可能不支持 Deepseek R1 架构，升级脚本和安装脚本是一样的。

```bash
curl -fsSL https://ollama.com/install.sh | sh
```





​	2.2 安装 Open Webui

​			2.2.1 uv pip 方式安装 Open Webui

Open Webui 不建议使用 pip 安装，升级 pip 安装的 Open Webui 出现过数据丢失的情况，建议使用 Docker 安装。

如果服务器本身处在 Docker 容器内，或者无法处理后面的网络问题，也可以使用 pip 安装，建议使用 uv。

```bash
# 设置 pip 镜像，非中国大陆地区可跳过这个步骤
vim ~/.pip/pip.conf

[global]
index-url = https://pypi.tuna.tsinghua.edu.cn/simple
[install]
trusted-host=pypi.tuna.tsinghua.edu.cn


# 安装 uv
pip install uv

# 创建虚拟环境
uv venv --python python3.11

# 激活虚拟环境
source .venv/bin/activate

# 安装 Open Webui 
uv pip install open-webui
```

​			2.2.2 Docker 方式安装运行 Open Webui

```bash
docker run -d -p 8080:8080 -e HF_ENDPOINT=https://hf-mirror.com/ --add-host=host.docker.internal:host-gateway -v open-webui:/app/backend/data --name open-webui --restart always swr.cn-north-4.myhuaweicloud.com/ddn-k8s/ghcr.io/open-webui/open-webui:latest
```

Open Webui 的 Docker image 不在 Docker 官方 hub.docker.com 中，而是在 ghcr.io 中，中国大陆境内无法访问 hub.docker.com，寻常 Docker 镜像站都是镜像于官方 hub.docker.com，可以访问渡渡鸟镜像站：https://docker.aityp.com/ 查询 Open Webui 的镜像，也可以使用南京大学的ghcr同步站：ghcr.nju.edu.cn （实测限速）



桥接模式下，容器内部访问宿主机网络可以使用 --add-host=host.docker.internal:host-gateway，但这样并不总是可行，例如机器网络比较复杂或者 Docker 版本比较低等等原因，可以这样做（前提是已经设置OLLAMA_HOST=0.0.0.0）：

```bash
# 查看容器所属网络的网关地址
docker inspect -f '{{range .NetworkSettings.Networks}}{{.Gateway}}{{end}}' <容器名称或ID>

# 172.17.0.0/

# 在容器内部测试访问
curl http://172.17.0.0/:宿主机端口
```

但是这样也未必可联通，很有可能会被防火墙阻挡，需要添加放行规则：

```bash
sudo ufw allow proto tcp from 172.17.0.0/16 to any port 11434
sudo ufw reload
```



如果你的 Ollama 和 Open Webui 分属不同的 Docker 容器，可以通过添加到同一个网络的方式，然后通过容器名:port 联通

```bash
docker network create llm
docker network connect llm < ollama_id >
docker network connect llm < openwebui_id >
```



### 安装运行

1. 运行 Ollama：

```bash
export OLLAMA_MODELS=/usr/share/ollama/.ollama/models
export OLLAMA_HOST=0.0.0.0
export OLLAMA_SCHED_SPREAD=1
export CUDA_VISIBLE_DEVICES=0,1,2,3,4,5,6,7


nohup sh -c 'ollama serve' > ollama.log 2>&1 &
```

注意：

OLLAMA_HOST 要设置为 0.0.0.0，否则后续 Open Webui 无法访问 Ollama

OLLAMA_SCHED_SPREAD 要设置为 1，否则无法多卡运行单一模型



2. 拉取 DeepSeek R1

```
ollama pull deepseek-r1:671b # 默认就是 q4_K_M 量化
```



3. 使用 Open Webui 进行对话

首先介绍一下 Open Webui 的配置

注册登录完账号后，在 Admin Panel-Settings 中设置 Ollama 后端地址

![image-20250211204956463](https://raw.githubusercontent.com/Lanthanum1/my_images/main/img/202502112050602.png)

Open Webui 默认的Context Length和Max Tokens是比较低的，但是可以自由调整

Open Webui 的配置分为三层，分别是模型级、账户级、聊天级

简单来说，优先级排序为：模型级 > 账户级 > 单次聊天级

单次聊天级 (Per-Chat) 在对话右侧 Chat Controls 中设定，仅对当前会话生效，但不能覆盖模型预设（管理员锁定项）

模型级 (Per-Model) Admin Panel-Settings-Models在适用于所有使用该模型的聊天，普通用户无权修改且优先级最高

账户级 (Per-Account) 在 Settings-Advanced Parameters 中设定，会被模型级配置覆盖。

8 卡 A100 在设定Context Length和Max Tokens都为8k后可正常推理，每张卡显存占用约为50-60GB

默认情况下，5min内如果没有新的对话，模型会从 GPU 中 offload，重新加载至显存需要很长时间。可以在

Settings-Advanced Parameters 中设定 Keep Alive 参数，设为 -1 则用不卸载。

如果显存不够，可以调整 num_gpu 参数灵活调整在CPU中推理和在GPU推理的比例（按层划分，例如设为60则60层加载到GPU，剩余加载在CPU） 

至此可以直接在Open Webui中对话了





### 其他尝试

使用 Ollama 并不是最优选择，无论是速度还是显存占用都是不佳的，OLLAMA_SCHED_SPREAD=1 本来也是不建议开启的，Ollama 只能用单一的 gguf 格式的模型参数进行推理，但是对于 671 B 这么大的模型来说，全部加载在同一张 GPU 上是不太现实的，只能分担在多张GPU上，Ollama 对于一个模型在多卡中推理优化较差，这样做增加了GPU之间通信的成本，即使所有参数全部在GPU中推理，速度也只有 10-40 tokens/s。

vllm是很好的选择，原生支持 safetensor 格式，但是 671B fp8 太大了，8卡a100也装不下，考虑量化，vllm官网中有一句话，Please note that GGUF support in vLLM is highly experimental and under-optimized at the moment, it might be incompatible with other features. 测试了一下 1.58 bit动态量化的版本，结果也确实是这样，报错

ValueError: GGUF model with architecture deepseek2 is not supported yet.

使用 INT4 W4A16 进行量化可能是可行的，未尝试。

另外，在拉取1.58 bit动态量化模型时hf mirror没有速度，还经常断联，modelscope 则限速15MB/s

对于 671B 这么大的模型，可以使用 snapshot_download 只下载部分文件夹，如：

```python
from huggingface_hub import snapshot_download
snapshot_download(repo_id='unsloth/DeepSeek-R1-GGUF', allow_patterns='DeepSeek-R1-UD-IQ1_S/*', cache_dir='./')

# modelscope

from modelscope.hub.snapshot_download import snapshot_download
model_dir = snapshot_download(repo_id='unsloth/DeepSeek-R1-GGUF', allow_patterns='DeepSeek-R1-UD-IQ1_S/*',cache_dir='./')
```





### 对话实例

#### 2024 AIME I Problems/Problem 4

![2025111213628794bfffad10-50a3-4725-8f85-5af54d4c91d8_1](https://raw.githubusercontent.com/Lanthanum1/my_images/main/img/202502112140491.png)

![2025111213628794bfffad10-50a3-4725-8f85-5af54d4c91d8_2](https://raw.githubusercontent.com/Lanthanum1/my_images/main/img/202502112140334.png)

![2025111213628794bfffad10-50a3-4725-8f85-5af54d4c91d8_3](https://raw.githubusercontent.com/Lanthanum1/my_images/main/img/202502112143713.png)




![2025111213628794bfffad10-50a3-4725-8f85-5af54d4c91d8_4](https://raw.githubusercontent.com/Lanthanum1/my_images/main/img/202502112140123.png)

![2025111213628794bfffad10-50a3-4725-8f85-5af54d4c91d8_5](https://raw.githubusercontent.com/Lanthanum1/my_images/main/img/202502112141458.png)





#### 2025 考研数学一 T18

![2025111214533776aec034cf-4085-48be-9752-bb2b5728ba4f_1](https://raw.githubusercontent.com/Lanthanum1/my_images/main/img/202502112148578.png)

![2025111214533776aec034cf-4085-48be-9752-bb2b5728ba4f_2](https://raw.githubusercontent.com/Lanthanum1/my_images/main/img/202502112148449.png)

![2025111214533776aec034cf-4085-48be-9752-bb2b5728ba4f_3](https://raw.githubusercontent.com/Lanthanum1/my_images/main/img/202502112148194.png)

![2025111214533776aec034cf-4085-48be-9752-bb2b5728ba4f_4](https://raw.githubusercontent.com/Lanthanum1/my_images/main/img/202502112148036.png)

![2025111214533776aec034cf-4085-48be-9752-bb2b5728ba4f_5](https://raw.githubusercontent.com/Lanthanum1/my_images/main/img/202502112148381.png)

![2025111214533776aec034cf-4085-48be-9752-bb2b5728ba4f_6](https://raw.githubusercontent.com/Lanthanum1/my_images/main/img/202502112148208.png)

![2025111214533776aec034cf-4085-48be-9752-bb2b5728ba4f_7](https://raw.githubusercontent.com/Lanthanum1/my_images/main/img/202502112156900.png)

![2025111214533776aec034cf-4085-48be-9752-bb2b5728ba4f_8](https://raw.githubusercontent.com/Lanthanum1/my_images/main/img/202502112148042.png)

![2025111214533776aec034cf-4085-48be-9752-bb2b5728ba4f_9](https://raw.githubusercontent.com/Lanthanum1/my_images/main/img/202502112147432.png)

![2025111214533776aec034cf-4085-48be-9752-bb2b5728ba4f_10](https://raw.githubusercontent.com/Lanthanum1/my_images/main/img/202502112149476.png)
