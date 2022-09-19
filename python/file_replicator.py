from shutil import copyfile
templatefile = "C:/tmp/work/test_12722-16345_1gb.txt"
output_folder = "C:/tmp/work/output/"

fs, fl = templatefile.split('.')
if '/' in fs:
    fs = fs.split('/')[-1]
for i in range(16):
    destfilename = f'{output_folder}{i}{fs}.{fl}'
    copyfile(templatefile, destfilename)