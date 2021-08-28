import pandas as pd
import math
import numpy as np
import matplotlib.pyplot as plt

def readFiles(folderName) : 
    files = []
    for i in range(1,11) : 
        f = open("tr/" + folderName + "/" + folderName + str(i) + ".tr", "r")
        currFile = f.readlines()
        for i in range(len(currFile)) : 
            currFile[i] = currFile[i].split()
        files.append(currFile)
    return files

def readTrs() : 
    renoFiles = readFiles("reno")
    print("reading Reno files done!")
    tahoeFiles = readFiles('tahoe')
    print("reading Tahoe files done!")
    vegasFiles = readFiles("vegas")
    print("reading Vegas files done!")
    
    return [renoFiles, tahoeFiles, vegasFiles]
    
[renoFiles, tahoeFiles, vegasFiles] = readTrs()

def getTrimmedList(fileLists, outNode1, outNode2) : 
    lines = len(fileLists[0])
    files = len(fileLists)
    cwnds1 = []
    cwnds2 = []
    drop1 = []
    drop2 = []
#     rtt and goodput not implemented yet
    for i in range(lines) : 
        if (fileLists[0][i][5] == 'cwnd_' and (int(fileLists[0][i][3]) == outNode1 or int(fileLists[0][i][3]) == outNode2)) : 
    
            outNode = int(fileLists[0][i][3])
            avgCwnd = 0
            for j in range(files) :
                avgCwnd += float(fileLists[j][i][6])
            avgCwnd = avgCwnd / files
            if (outNode == outNode1) : 
                cwnds1.append([fileLists[0][i][0], avgCwnd])
            elif (outNode == outNode2) : 
                cwnds2.append([fileLists[0][i][0], avgCwnd])
        elif (fileLists[0][i][0] == 'd' and (int(float(fileLists[0][i][9])) == outNode1 or int(float(fileLists[0][i][9])) == outNode2)) :
            outNode = int(float(fileLists[0][i][9]))
            avgItem10 = 0
            avgItem11 = 0
            for j in range(files) :
                avgItem10 += int(fileLists[j][i][10])
                avgItem11 += int(fileLists[j][i][11])
            avgItem10 = int(avgItem10 / files)
            avgItem11 = int(avgItem11 / files)
            if (outNode == outNode1) : 
                drop1.append([fileLists[0][i][1], avgItem10, avgItem11])
            elif (outNode == outNode2) : 
                drop2.append([fileLists[0][i][1], avgItem10, avgItem11])
    return [cwnds1, cwnds2, drop1, drop2]

[renoCwnds1, renoCwnds2, renoRtts1, renoRtts2, renoGoodPuts1, renoGoodPuts2, renoDrops1, renoDrops2] = getTrimmedList(renoFiles, 4, 5)
[tahoeCwnds1, tahoeCwnds2, tahoeRtts1, tahoeRtts2, tahoeGoodPuts1, tahoeGoodPuts2, tahoeDrops1, tahoeDrops2] = getTrimmedList(tahoeFiles, 4, 5)
[vegasCwnds1, vegasCwnds2, vegasRtts1, vegasRtts2, vegasGoodPuts1, vegasGoodPuts2, vegasDrops1, vegasDrops2] = getTrimmedList(vegasFiles, 4, 5)

