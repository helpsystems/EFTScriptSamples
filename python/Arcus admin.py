import string
from random import choice

userlist = ['Firstname Lastname <example@example.com>',]
identifier = 'tstidt'
arcus_endpoint = '.arcusapp.globalscape.com'
print('***\n')
for user in userlist:
    ul = user.lower()
    characters = string.ascii_letters + '!#$+-?~'  + string.digits
    password =  "".join(choice(characters) for x in range(16))
    first, last, email = ul.split()
    print('RDGW:')
    print(first.title())
    print(last.title())
    print(first[0] + last + '_' + identifier )
    strip_email = email.strip('<')
    strip_email = strip_email.strip('>')
    print(password + '\n')
    print('Deployatron:')
    print(identifier + arcus_endpoint)
    print(strip_email)
    print(first[0] + last + '_' + identifier)
    print(password + '\n')
    print('***\n')