# tmbot
Demo web host monitoring bot for Telegram

## Prerequisites
 - The bot was tested for RHEL/Oracle/CentOS7.x linux. I can't guarantee if it works on other Linux distributives.
 - Suppose that python 3.6 is installed on your Linux box. And installed exactly standard python 3.6 from EPEL repo.
 - For this installation internet access is required on target system in order to download pip distrib by ansible playbook.
 - Ansible >= 2.4.3.0 is required for installation
 - Telegram bot has been created and added to the appropriate Telegram channel
 
## Installation
In order to install bot start ansible-playbook tmbot.yml from the git repo root directory. 
This playbook will configure python virtual environment and serivce for systemd

## Using
 - By default, configuration file for the bot is located in /usr/local/etc/tmbot.cfg. Set all required parameters here.
 - enable systemd service - "systemctl enable tmbot" (optional)
 - start systemd service - "systemctl start tmbot"
Limitation note - there is no any logging implemented for simplicity reasons

## Testing
Tests are started automaticaly by ansible playbook. In order to start them manually - run script test_tmbot.py in prepared python environment.
