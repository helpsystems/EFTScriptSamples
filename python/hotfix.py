# No Touchy
file_list = []
build_list = True

# Change to what ever you would like the extention of the name to be in the instructions.
rn_ext = '.old'

while build_list:
    file_name = input('Name of file? If done, type d: ')
    if file_name == 'd':
        build_list = False
    else:
        file_list.append(file_name)

header_line = 'Hotfix Instructions:'
print(header_line)
line_counter = 1
service_off = f'{line_counter}.WARNING: Shut off the service on all nodes!'
print(service_off)

line_counter += 1
for fn in file_list:
    if fn == file_list[0]:
        main_line_rn = f'{line_counter}.Rename {fn} to {fn}{rn_ext} on all nodes. You can determine the location of this file by looking at the registry here:\n\t(HKEY_LOCAL_MACHINE\\SOFTWARE\WOW6432Node\\GlobalSCAPE Inc.\\EFT Server Enterprise) \n\tThe default location for this file is in the "C:\\Program Files (x86)\\Globalscape\\EFT Server Enterprise\\ directory".'
        print(main_line_rn)
    else:
        alt_line_rn = f'{line_counter}.Rename {fn} to {fn}{rn_ext} in that same folder on all nodes.'
        print(alt_line_rn)
    line_counter += 1
for fnc in file_list:
    alt_line_c = f'{line_counter}.Copy the {fnc} file into the respective directories on all nodes.'
    print(alt_line_c)
    line_counter += 1

validate_hotfix = f'{line_counter}.Verify the hotfix has been deployed by right clicking on the files in the destination and going to the details tab. Confirm the "Product version" property has a hotfix number.'
print(validate_hotfix)
line_counter += 1
service_on = f'{line_counter}.Start the service.'
print(service_on)