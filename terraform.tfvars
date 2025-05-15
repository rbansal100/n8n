# When you launch your Schematics workspace, you get prompted to enter the variable values in the IBM Cloud console
# put the values there - not in this file. 

ssh_public_key  = "ssh-rsa AAAAB3...yourkey"
ssh_private_key = <<EOF
-----BEGIN OPENSSH PRIVATE KEY-----
...your private key here...
-----END OPENSSH PRIVATE KEY-----
EOF

n8n_user = "admin"
n8n_pass = "supersecret"
