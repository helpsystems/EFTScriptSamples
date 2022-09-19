# You can change these, make suure file_path always has forward slashes
# and make sure to double up backslashes in the output folder
file_path = 'C:/Users/klowery/Desktop/reports/'
#output_folder = '\\\\file.core.windows.net\\gsbshared\\AdminSite\\ARMDB-Output'
output_folder = 'C:\\Users\\klowery\\Desktop\\reports'
user = 'a'
ipaddress = '8.8.8.8'

#Dont change these
file_list = ['ActivityAdhocDetailed','EventRulesActivityDetailed','TransactionsTable',
            'AuthenticationsTable','ExecutiveSummary','TroubleshootingEventRuleFailures',
            'AdminActions','FailedLogins','WorkspacesActivity',
            'AdminActivitySummary','ProtocolCommandsTable','TrafficIpWiseConnections',
            'AllFiles','TrafficConnectionsSummary','ActivityByUserDetailed','TroubleshootingIpAddressActivityDetailed']
additional_parameter = ''
additional_value = ''
additional_string = f',"{additional_parameter}":"{additional_value}"'

for file_name in file_list:
    fobj = file_path + file_name + '.json'
    with open(fobj, 'w') as f:
        if file_name == 'ActivityByUserDetailed':
            additional_parameter = 'User'
            additional_value = user
            file_contents = f'{{"Days":"1","Report":"{file_name}","UseInterimFile":true,"OutputFolder":"{output_folder}"{additional_string}}}'
        elif file_name == 'TroubleshootingIpAddressActivityDetailed':
            file_contents = f'{{"Days":"1","Report":"{file_name}","UseInterimFile":true,"OutputFolder":"{output_folder}"{additional_string}}}'
            additional_parameter = 'ipAddress'
            additional_value = ipaddress
        else:
            file_contents = f'{{"Days":"1","Report":"{file_name}","UseInterimFile":true,"OutputFolder":"{output_folder}"}}'
        f.write(file_contents)