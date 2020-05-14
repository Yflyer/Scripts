import calendar
import urllib.request
import os

print("downloading with urllib")
url0 = "http://dap.ceda.ac.uk/thredds/fileServer/neodc/esacci/soil_moisture/data/daily_files/COMBINED/v02.2/"

for year in range(2000, 2015):
    for month in range(1, 13):
        num_days = calendar.monthrange(year, month)[1]
        for day in range(1, num_days+1):
            file = "ESACCI-SOILMOISTURE-L3S-SSMV-COMBINED-%.d%.2d%.2d000000-fv02.2.nc" % (year, month, day)
            url = url0 + str(year)+'/'+file
            print("downloading with " + url)
            LocalPath = os.path.join('D:/META_database/Soil_Moisture', file)
            urllib.request.urlretrieve(url, LocalPath)



#20040353 is missing