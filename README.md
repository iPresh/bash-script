## Create a bash script to automate user creation  

Your company has employed many new developers. As a SysOps engineer, write a bash script called `` create_users.sh `` that reads a text file containing the employee’s usernames and group names, where each line is formatted as 'user;groups.'  

The script should:  
- Create users and groups as specified.
- Set up home directories with appropriate permissions and ownership
- Generate random passwords for the users
- Log all actions to /var/log/user_management.log.
- Store the generated passwords securely in /var/secure/user_passwords.txt.

Example command to test the script:  
``
sudo ./create_users.sh user_list.txt
``
