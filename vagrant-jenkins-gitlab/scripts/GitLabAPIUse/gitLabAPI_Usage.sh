#!/usr/bin/env bash

############### Users API #################
# Create user with the credentials which defined in the "userDeatils" file
curl -s -H "Content-Type:application/json" --request POST "http://10.1.42.212/api/v4/users?private_token=os9yy4NJdQxc-nsjbdzG" -d @userDeatils | jq

# Get GitLab Users List
curl -s --request GET "http://10.1.42.212/api/v4/users?private_token=os9yy4NJdQxc-nsjbdzG" | jq

# Get ID of the 'user123' username and add id in the 'deleteUser' file
id=$(curl -s --request GET "http://10.1.42.212/api/v4/users?private_token=os9yy4NJdQxc-nsjbdzG" | jq '.[] | select(.name=="user1") | .id')

# Delete User from GitLab
curl -s -H "Content-Type:application/json" --request DELETE "http://10.1.42.212/api/v4/users/$id?private_token=os9yy4NJdQxc-nsjbdzG" -d @deleteUser | jq



############### Projects API #################
# To create project for the specific username you need to gect access token of this username and then execute the followwing command
curl -s -H "Content-Type:application/json" --request POST "http://10.1.42.212/api/v4/projects?private_token=os9yy4NJdQxc-nsjbdzG" -d @projectName | jq

# Create new project with name 'pr2' for user id ${id} with its token
curl -s -H "Content-Type:application/json" --request POST "http://10.1.42.212/api/v4/projects/user/$id?private_token=os9yy4NJdQxc-nsjbdzG&name=pr2" | jq

# Get projects under userID "$id"
curl -s --request GET "http://10.1.42.212/api/v4/users/$id/projects?private_token=os9yy4NJdQxc-nsjbdzG" | jq

# Get list all projects
curl -s --request GET "http://10.1.42.212/api/v4/projects?private_token=os9yy4NJdQxc-nsjbdzG" | jq

# Get project ID with name 'CheckPR'
projectIDCheckPR=$(curl -s --request GET "http://10.1.42.212/api/v4/projects?private_token=os9yy4NJdQxc-nsjbdzG" | jq '.[] | select(.name=="CheckPR") | .id')

# GET all repository path for all users to use over SSH
curl -s --request GET "http://10.1.42.212/api/v4/projects?private_token=os9yy4NJdQxc-nsjbdzG" | jq '.[].ssh_url_to_repo'


############### GROUPS API ###################
# GET list of groups
curl -s --request GET "http://10.1.42.212/api/v4/groups?private_token=os9yy4NJdQxc-nsjbdzG" | jq

# Search group for group 'prospect'
curl -s --request GET "http://10.1.42.212/api/v4/groups?search=prospect&private_token=os9yy4NJdQxc-nsjbdzG" | jq

# GET group ID with name 'prospect'
groupIDprospect=$(curl -s --request GET "http://10.1.42.212/api/v4/groups?private_token=os9yy4NJdQxc-nsjbdzG" | jq '.[] | select(.name=="prospect") | .id')

# Update project name to the 'prospect' where id is '5'
curl -s --request PUT "http://10.1.42.212/api/v4/groups/5?name=prospect&private_token=os9yy4NJdQxc-nsjbdzG" | jq

# Transfer project 'CheckPR' under group 'prospect' 
curl -s -XPOST  "http://10.1.42.212/api/v4/groups/$groupIDprospect/projects/$projectIDCheckPR?private_token=os9yy4NJdQxc-nsjbdzG"


############### Members API ###################
# Access levels
10 => Guest access
20 => Reporter access
30 => Developer access
40 => Maintainer access
50 => Owner access # Only valid for groups

# Get members of group 'groupIDprospect' 
curl -s -H "PRIVATE-TOKEN: os9yy4NJdQxc-nsjbdzG" "http://10.1.42.212/api/v4/groups/$groupIDprospect/members" | jq

# Get members of project 'CheckPR'
curl -s -H "PRIVATE-TOKEN: os9yy4NJdQxc-nsjbdzG" "http://10.1.42.212/api/v4/projects/$projectIDCheckPR/members" | jq

# Add user wwith id '3' to the group with id 'groupIDprospect' with the access level '30'
curl -s -XPOST -H "PRIVATE-TOKEN: os9yy4NJdQxc-nsjbdzG" "http://10.1.42.212/api/v4/groups/$groupIDprospect/members?user_id=3&access_level=30" | jq

# Add user with id '$haqverdiid' under project '$projectIDCheckPR' with access level '30' 
curl -s -XPOST -H "PRIVATE-TOKEN: os9yy4NJdQxc-nsjbdzG" -d "user_id=$haqverdiid&access_level=30" "http://10.1.42.212/api/v4/projects/$projectIDCheckPR/members" | jq

# Change Access level of user with id '$haqverdiid' under project '$projectIDCheckPR' to the '40'
curl -s -XPUT -H "PRIVATE-TOKEN: os9yy4NJdQxc-nsjbdzG" -d "access_level=40" "http://10.1.42.212/api/v4/projects/$projectIDCheckPR/members/$haqverdiid" | jq

# Change Access Level of user with id '$haqverdiid' under group id '$groupIDprospect' to the access level '40'
curl -s -XPUT -H "PRIVATE-TOKEN: os9yy4NJdQxc-nsjbdzG" -d "access_level=40" "http://10.1.42.212/api/v4/groups/$groupIDprospect/members/$haqverdiid" | jq

# Remove user with id '$haqverdiid' under group 'groupIDprospect'
curl -s -XDELETE -H "PRIVATE-TOKEN: os9yy4NJdQxc-nsjbdzG" "http://10.1.42.212/api/v4/groups/$groupIDprospect/members/$haqverdiid" | jq

#
curl -i -XDELETE -H "PRIVATE-TOKEN: os9yy4NJdQxc-nsjbdzG" "http://10.1.42.212/api/v4/projects/$projectIDCheckPR/members/$rizvanid" 

# Add new deploy key
curl --request POST --header "PRIVATE-TOKEN: os9yy4NJdQxc-nsjbdzG" --header "Content-Type: application/json" --data '{"title": "My deploy key", "key": "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQCj6GheDvKV/6DJFJtsx5rZZz8ROm7+wXjeCc6y/W5RzW55RaQa/N8S7ao3PAeCaUJtjliyYBWF7gdVwPWmTDMT+GXlPybTRBWRCCPT8Hq1I88rYd3urDbxBzR2YE41rdl4/XAL5zJ4Zf7tHKDzHrTFnYOElW13cvgK1AgRQ6xJG8bgVj92eDg3CeLLibEFYK4umtOSWcX/dBvvhvrRwZb6fCd8vUZQAA+UkcYMGAJduVKsB44jtUiPVXNe/ZSKtcK2iPMLN5izdQ9DF1Ev051Ob27VnYZmMiShV4u/tqtv9tXro2k8CrLzpD7nkjtS/j4J31xAx2ftd0EUo4txoYR3 root@jenkins", "can_push": "true"}' "http://10.1.42.212/api/v4/projects/5/deploy_keys/"

# Execute from BASH code
curl --request POST --header "PRIVATE-TOKEN: os9yy4NJdQxc-nsjbdzG" --header "Content-Type: application/json" --data '{"title": "'"$1"'", "key": "'"$2"'", "can_push": "true"}' "http://10.1.42.212/api/v4/projects/5/deploy_keys/"

# DELETE deploy key
curl -s -XDELETE -H "PRIVATE-TOKEN: os9yy4NJdQxc-nsjbdzG" "http://10.1.42.212/api/v4/projects/4/deploy_keys/4" | jq

# Enable Deploy key
curl -s -XPOST -H "PRIVATE-TOKEN: os9yy4NJdQxc-nsjbdzG" "http://10.1.42.212/api/v4/projects/4/deploy_keys/2/enable" | jq

# Update title of deploy key with ID '5' in project with ID '4' to the new value "Zaur deploy key"
curl -XPUT -H "PRIVATE-TOKEN: os9yy4NJdQxc-nsjbdzG" -H "Content-Type: application/json" --data '{"title": "Zaur Deploy key", "can_push": true}' "http://10.1.42.212/api/v4/projects/4/deploy_keys/5"

# List Deploy Keys
curl -s --header "PRIVATE-TOKEN: os9yy4NJdQxc-nsjbdzG" "http://10.1.42.212/api/v4/deploy_keys" | jq
