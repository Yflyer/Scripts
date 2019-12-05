import requests
import urllib.request
import os


print("downloading with urllib")
url0 = "http://files.ntsg.umt.edu/data/NTSG_Products/MOD17/GeoTIFF/MOD17A2/GeoTIFF_0.05degree/"

for item1 in range(5, 15):
    for item2 in range(0, 45):
        file = "MOD17A2_GPP.A" + str((item1 * 1000)+(item2 * 8) + 2000001) + ".tif"
        url = url0 + file
        print("downloading with " + url)
        LocalPath = os.path.join('D:/META_database/Soil_Moisture', file)
        urllib.request.urlretrieve(url, LocalPath)

#20040353 20050009 is missing