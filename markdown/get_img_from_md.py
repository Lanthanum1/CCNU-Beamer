import aiohttp
import asyncio
import os
import re

async def download_image(session, url, folder, index):
    try:
        async with session.get(url) as response:
            response.raise_for_status()
            content = await response.read()
            with open(f"{folder}/{index+1}.png", "wb") as f:
                f.write(content)
            print(f"Downloaded {index+1}.png")
    except aiohttp.ClientError as e:
        print(f"Error downloading {url}: {e}")

async def main():
    # 读取Markdown文件内容
    with open("./get_img.md", "r", encoding="utf-8") as file:
        text = file.read()

    # 同时提取Markdown和HTML格式的图片链接，保持原始顺序
    image_urls = re.findall(r'(?:!\[.*?\]\((.*?)\)|<img.*?src="(.*?)".*?>)', text)
    image_urls = [url for match in image_urls for url in match if url and not url.startswith("#")]

    # 查找已有的文件夹编号
    existing_folders = [f for f in os.listdir("./pic") if f.startswith("pic_")]
    if existing_folders:
        next_folder_num = max([int(f.split("_")[1]) for f in existing_folders]) + 1
    else:
        next_folder_num = 1

    # 创建新的文件夹
    new_folder = f"./pic/pic_{next_folder_num}"
    os.makedirs(new_folder, exist_ok=True)

    # 使用aiohttp进行异步并发下载
    connector = aiohttp.TCPConnector(limit=100)  # 设置连接池大小
    timeout = aiohttp.ClientTimeout(total=30)  # 设置超时时间
    async with aiohttp.ClientSession(connector=connector, timeout=timeout) as session:
        tasks = [
            download_image(session, url, new_folder, i)
            for i, url in enumerate(image_urls)
        ]
        await asyncio.gather(*tasks)

if __name__ == "__main__":
    asyncio.run(main())