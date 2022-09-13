import time
import platform

full_list = True
results_value = 10
version = platform.architecture()
print(version[0])

start_time = time.time()
d = {}

print('Building username appearance totals...')
# 71.50.132.89 - -, [28/Jan/2021:00:44:22 +0530] "user root" 331 0,
with open('C:/Users/jbranan/Desktop/temp/h/Global_support/Logs/nc210121.log', encoding='utf8') as file_object:
    for line in file_object.readlines():
        if not '#' in line and '] "user ' in line:
            username = line.split('] "user ')[1].split('" ')[0]
            if not username in d and not username.startswith('-'):
                d[username] = 1
            elif not username.startswith('-'):
                d[username] += 1
            elif '/' in username:
                continue

d = sorted(d.items(), key=lambda x: x[1], reverse=True)

if full_list:
    for username in d:
        print(f'User: {username[0]} - Appearances: {username[1]}')

else:
    for username in d[:results_value]:
        print(f'User: {username[0]} - Appearances: {username[1]}')

print("--- %s seconds ---" % (time.time() - start_time))