#!/bin/sh

export ANSIBLE_HOST_KEY_CHECKING=False
export ANSIBLE_SSH_ARGS="-o ForwardAgent=yes"

sudo pip install dopy

echo 'Install the Travis CI SSH key'
chmod 400 travis.ssh
eval `ssh-agent`
ssh-add travis.ssh

echo 'Touch local temp files'
touch privatehosts
sudo touch /etc/rc6.d/K10do_destroy.sh
sudo chmod +x /etc/rc6.d/K10do_destroy.sh

echo 'Run ansible-playbook after_success.yml'
ansible-playbook -i after_success_hosts --extra-vars "api_key_password=$DO_API_KEY client_id=$DO_CLIENT_ID" after_success.yml

sleep 10

cp travis.ssh.pub bootstrap/ansible_rsa.pub
cd bootstrap
echo 'Run ansible-playbook -i hosts -u root bootstrap.yml'
ansible-playbook -i hosts -u root bootstrap.yml
cd ..

echo 'Run ansible-playbook -i hosts --extra-vars "accelerate=true" site.yml'
ansible-playbook -i hosts --extra-vars "accelerate=true" site.yml

echo 'Destroying DigitalOcean instances...'
sudo /etc/rc6.d/K10do_destroy.sh