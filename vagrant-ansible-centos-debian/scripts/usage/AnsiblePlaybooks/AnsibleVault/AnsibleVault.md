#### Crypt value of **ansible_become_pass** variable which will be stored like as **password** (we will input crype password from console):
```bash
$ ansible-vault encrypt_string --ask-vault-pass --name 'ansible_become_pass' 'pasword'
New Vault password: Crypt_Password
Confirm New Vault password: Crypt_Password 
ansible_become_pass: !vault |
          $ANSIBLE_VAULT;1.1;AES256
          30343530656135636461653466303861333836653361616238623534613335373562323061336363
          3463613536323336626332366633343932313161623737300a666539396134313732643230633034
          39333537666263306164643265366332343835313761623933336461373862316331373634643138
          6162316130636665380a666239336666343566303833353564356435623064336266363432393061
          3861
Encryption successful
```

#### Put encrypted value to the **group_vars/debian** file and execute the following command:
```bash
$ cat group_vars/debian
---
ansible_become: true
ansible_become_pass: !vault |
          $ANSIBLE_VAULT;1.1;AES256
          31326165323430663735393637303539666365373438336364363864343966643039613635383333
          3334313530303265373738613363663366653838306330650a383462663633303865363331343231
          66303263646466343266363663356235666262616131316531336531356263386261663738633238
          3936303733623464320a363666363238333561376565376564633236663139343065623766303538
          3463
...
$ ansible --ask-vault-pass all -m ping -o
```

#### Encrypt **external_vault_vars.yml** playbook file:
```bash
$ ansible-vault --ask-vault-pass encrypt external_vault_vars.yml
New Vault password:
Confirm New Vault password:
Encryption successful
$ ansible-playbook --ask-vault-pass vault_playbook.yml
```

#### Decrypt file:
```bash
$ ansible-vault --ask-vault-pass decrypt external_vault_vars.yml
Vault password:
Decryption successful
```

#### Reset password:
```bash
$ ansible-vault --ask-vault-pass rekey external_vault_vars.yml
Vault password:
New Vault password:
Confirm New Vault password:
Rekey successful
```

#### Decrypt key:
```bash
$ echo '$ANSIBLE_VAULT;1.1;AES256
31326165323430663735393637303539666365373438336364363864343966643039613635383333
3334313530303265373738613363663366653838306330650a383462663633303865363331343231
66303263646466343266363663356235666262616131316531336531356263386261663738633238
3936303733623464320a363666363238333561376565376564633236663139343065623766303538
3463' | ansible-vault decrypt -
Vault password:
Decryption successful
vagrant
```

#### Show crypted data from **password_file** file:
```bash
$ echo password2 > password_file
$ ansible-vault --vault-id password_file view external_vault_vars.yml
external_vault_var: Example External Vault Var
$ ansible-vault --vault-id @password_file view external_vault_vars.yml
external_vault_var: Example External Vault Var
```

#### Decrypt file with **** file:
```bash
$ ansible-vault --vault-id @password_file decrypt external_vault_vars.yml
Decryption successful
```

#### Prompt password from CLI:
```bash
$ ansible-vault --vault-id @prompt view external_vault_vars.yml
Vault password (default):
external_vault_var: Example External Vault Var
```

#### Create **external_vault_vars.yml** file with **vars** variable and encrypt value with password from console:
```bash
$ cat external_vault_vars.yml
external_vault_var: Example External Vault Var
$ ansible-vault --vault-id vars@prompt encrypt external_vault_vars.yml
New vault password (vars):
Confirm new vault password (vars):
Encryption successful
```
```bash
$ ansible-vault encrypt_string --vault-id ssh@prompt --name 'ansible_become_pass' 'password'
New vault password (ssh):
Confirm new vault password (ssh):
ansible_become_pass: !vault |
          $ANSIBLE_VAULT;1.2;AES256;ssh
          63646633333864316438306534633634393466653834646433643661373066346231373338353030
          3736333962313463623630333339356237366438303433610a383661613938653230656234303964
          65353531613135363966383233646634376161666138386461393935613962346438663861373330
          6638363637636332390a323631626565623830626533666434636239353766323436343863353535
          3238
Encryption successful
```

#### Execute playbook from file:
```bash
$ ansible-playbook --vault-id password_file vault_playbook.yml
ansible-playbook --vault-id vars@prompt --vault-id ssh@prompt --vault-id playbook@prompt vault_playbook.yml
Vault password (vars):
Vault password (ssh):
Vault password (playbook):
```
