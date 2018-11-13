#!/usr/bin/env python
import os
#安装redis模块并导入
os.system("pip3 install redis")

import redis
from redis.sentinel import Sentinel
import time
import uuid

#定义sentinel服务器主机
sentinel=Sentinel([('192.168.100.101',26379),
                   ('192.168.100.102',26379),
                   ('192.168.100.103',26379)
])


#获取主库地址
master=sentinel.discover_master('mymaster')
print(master)

#获取从库地址
slave=sentinel.discover_slaves('mymaster')
print(slave)
time.sleep(2)

#获取主库进行写入测试
master=sentinel.master_for('mymaster') #socket_timeout=0.5)
#master.set('foo','bar')
#for n in range(1,1000000):
#    UUID=uuid.uuid1()
#    master.set(n,UUID)
#    print(master.get(n))

#    print("keyname is name: {}".format(master.get(n)))

#获取从库进行读取测试
slave=sentinel.slave_for('mymaster')
#slave=sentinel.slave_for('mymaster',socket_timeout=0.1)
for i in range(1,1000000):
    r_result=slave.get(i)
    print(r_result)
