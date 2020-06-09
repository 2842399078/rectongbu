#!/usr/bin/env python
# coding: utf-8
# 导入urllib下的request模块
import urllib.request
# 导入正则匹配包
import re
# -*- encoding:utf-8 -*-
def getResouces(url):
    # 该网址的源码(以该网页的原编码方式进行编码，特殊字符编译不能编码就设置ignore)
    webSourceCode=urllib.request.urlopen(url).read().decode("utf-8","ignore")
    contentRe=re.compile(r'<span class="name">(.*?\.zip)</span>')
    content=contentRe.findall(webSourceCode)
    for c in content:
        print("axel -n 64 -o /Tongbumulu/ https://svwh.dl.sourceforge.net/project/orangefox/violet/"+c)
for i in range(0,1):
	# 下面是Sourceforge的地址
    getResouces(f"https://sourceforge.net/projects/orangefox/files/violet/")