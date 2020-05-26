#!/usr/bin/env python
# -*- coding:utf-8 -*-
# Yufei, 5/24/2020, zengyf93@qq.com
import time
import os
import sys
import subprocess
import psutil

start = time.time()
Pj_path = os.getcwd()
input_path = Pj_path+'/'+'00_rawdata'
trim_path = Pj_path+'/'+'01_cleandata'
#manifest = 'manifest.csv'
#map = open('map.tsv','r')
barcode = 'TruSeq3-PE.fa'
threads = 4
trimlog = False

def getProcess(pName):
    all_pids  = psutil.pids()

    # iterate all pid
    for pid in all_pids:
        p = psutil.Process(pid)
        if (p.name() == pName):
            process_lst.append(p)

    return process_lst



def get_linux_version():
        print("system version---- %s" % ", ".join(sys.version.split("\n")))


def get_cpu_info():
        processor_cnt = 0
        cpu_model = ""
        f_cpu_info = open("/proc/cpuinfo")
        try:
                for line in f_cpu_info:
                        if (line.find("processor") == 0):
                                processor_cnt += 1
                        elif (line.find("model name") == 0):
                                if (cpu_model == ""):
                                        cpu_model = line.split(":")[1].strip()


                print("cpu counts: %s, cpu model: %s" % (processor_cnt, cpu_model))
        finally:
                f_cpu_info.close()


def get_mem_info():
        mem_info = ""
        f_mem_info = open("/proc/meminfo")
        try:
                for line in f_mem_info:
                        if (line.find("MemTotal") == 0):
                                mem_info += line.strip()+ ", "
                        elif (line.find("SwapTotal") == 0):
                                mem_info += line.strip()
                                break
                print("mem_info---- {:s}".format(mem_info))
        finally:
                f_mem_info.close()


def get_disc_info():
        #disc_info = os.popen("df -h").read()
        #disc_info = subprocess.Popen("df -h", shell=True).communicate()[0]
        #print(disc_info)
        pipe = subprocess.Popen("df -h", stdout=subprocess.PIPE, shell=True)
        disc_info = pipe.stdout.read()

print '{} is completed'.format(sys.argv[0])

end = time.time()
print("Comsuming time:{}".format(end-start))
