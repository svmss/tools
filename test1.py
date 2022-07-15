import requests
from requests.auth import HTTPBasicAuth
import json
import sys, getopt
import os
from pytz import timezone
from tzlocal import get_localzone
from datetime import datetime, timedelta
import urllib.parse

n = len(sys.argv)
SinceTimeInHours=1
state='running'
output=open("myOutFile.txt", "w")
for i in range(1, n):
    if sys.argv[i].upper() in ['-STATE']:
        state=sys.argv[i+1].lower()
    if sys.argv[i].upper() in ['-HOURS']:
        SinceTimeInHours=int(sys.argv[i+1])
    if sys.argv[i].upper() in ['-HELP']:
        print()
        print()
        print('Usage: python teamcity_buildRunning.py -STATE <state> -HOURS <hours>')
        print()
        print('-STATE is to determine the state of the build. Default option is running. Valid options are queued/running/finished')
        print()
        print()
        print('-HOURS is the number of hours you would like to go back in time and get the running builds which started  before that.')
        print()
        print('For Example: If you intend to see the builds with startdate before 1 hour which are still running, please specify hours as 1')
        print()
        exit()

format = "%Y%m%dT%H%M%S%z"
reqd_time = datetime.now(timezone('EST')) - timedelta(hours=SinceTimeInHours, minutes=00)
print(reqd_time.strftime(format))

try:
    username=os.environ['TC_AUTH_USERID']
except KeyError:
    sys.exit("TC_AUTH_USERID variable does not exist. Please set it to your domain user id or alias.")

try:
    password=os.environ['TC_AUTH_PASSWD']
except KeyError:
    sys.exit("TC_AUTH_PASSWD variable does not exist. Please set it to your domain password on your machine.")

def make_url(base_url , myquery, *res):
    url = base_url
    for r in res:
        url = '{}/{}'.format(url, r)
    if myquery:
        url = '{}?{}'.format(url, myquery)
    return url

print('teamcity_buildRunning.py -state '+state+' -HOURS '+str(SinceTimeInHours))
url="https://teamcity.bedford.progress.com"

myquery='locator=state:'+state+'&locator='+'startdate:(date:'+reqd_time.strftime(format)+',condition:before)'

complete_url=make_url(url, myquery, 'app', 'rest', 'builds')
print(complete_url)

try:
    response = requests.get(complete_url,auth=(username, password),headers={'Accept': 'application/json'})
    # If the response was successful, no Exception will be raised
    response.raise_for_status()
except HTTPError as http_err:
    print(f'HTTP error occurred: {http_err}')
except Exception as err:
    print(f'Other error occurred: {err}')
else:
    print('Success!')
# parse json data

print(response)
print()
print()
i=1
if(response):
    dict_data=response.json()
else:
    exit(11)
try:
    username=os.environ['TC_AUTH_USERID']
except KeyError:
    sys.exit("TC_AUTH_USERID variable does not exist. Please set it to your domain user id or alias.")

try:
    if(dict_data['count'] == 0):
        print("There are no running builds")
    else:
        print('No of builds running are', dict_data['count'])
        while(i<len(dict_data['build'])):
            myurl=""
            build_dict_data={}

            output.write('href: '+dict_data['build'][i]['href'])
            myurl=url+dict_data['build'][i]['href']
            try:
                build_response = requests.get(myurl,auth=(username, password),headers={'Accept': 'application/json'})
                # If the response was successful, no Exception will be raised
                build_response.raise_for_status()
            except HTTPError as http_err:
                print(f'HTTP error occurred: {http_err}')
            except Exception as err:
                print(f'Other error occurred: {err}')
            else:
                output.write('\n')
            build_dict_data=build_response.json()
            output.write('DisplayName: '+build_dict_data['buildType']['projectName']+" / "+build_dict_data['buildType']['name'])
            output.write('\n')
            output.write('webUrl: '+dict_data['build'][i]['webUrl'])
            output.write('\n\n')
            i=i+1
except:
    print("Please check the return values of the JSON. There seems to be a missing attribute from one og those.")
output.close()
