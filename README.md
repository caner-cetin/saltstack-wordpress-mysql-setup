### Kartaca SysAdmin Internship Case Study
The easiest way to run is carrying /srv/ folder entirely to the master machine.
```bash
sudo salt '*' test.ping
```
For WordPress config, you might need to change the MySQL host. Please check out the `wp-config.php` file.
```bash
sudo salt 'ubuntu22' kartaca-mysql.sls
```
```bash
sudo salt 'centos9' kartaca-wordpress.sls
```
After all, go to CentOS minion's IP address `/wp-admin` to see the results. 

### Notes
- If MySQL salt state errors out at `wordpressdb_remote_access` step, depending on the error, there is no error. If it reports "Duplicate key", then it is okay. As SaltStack can only execute one statement per `query.run`, there is no chance to know if that key is already created. So there is no update, nothing. It is just a warning. This could be solved by `query.run_file` and a seperate SQL file, buut, another problem! `run_file` state tries to create the database I am pointing the query at, even through it exists, and I cant command the Salt to not do that. So I can't use `run_file`, I can't use `cmd.run` because `-p` flag exposes the password. So, I have to use `query.run` and live with the warning disguised in the error.
- Parts of the wordpress may not work. If you test the MySQL connection from CentOS machine by 
  ```bash
  yum install mysql
  mysql -ppassword -hhost -uuser kartaca
  ``` 
  you will see that there is no problem in connection for MySQL between the Ubuntu <-> CentOS, but still, some parts of Wordpress may not work and `nginx.conf` may be incomplete.
- If you want to use Vagrant with my Vagrantfile and the same IP ranges:
  - Be sure that the `VirtualBox Guest Additions` package is installed, `/etc/vbox/networks.conf` contains the following:
    ```bash
    * 10.0.0.0/8 192.168.0.0/16
    ```
  - You have the `./scripts` folder relative to the location of the Vagrantfile. The folder contents are the same as in this repo.
  - The first argument in the provision script corresponds to the IP address of the master machine:
    ```bash
        ubuntu22.vm.provision "shell", path: "./scripts/install-minion.sh", args: ["10.10.28.69", "ubuntu22"]
    ```
  The second argument is the name of the minion machine.
  - If you want to change the boxes, please test them thoroughly. I have tested EuroLinux's Centos 9 Stream,  minion running in the machine was hanging whenever I executed a command. Only CentOS 9 Stream working was generic CentOS 9 Stream.
    So please be careful with the boxes.
  - If you see the warning "Remote connection disconnected, retrying..." while Ubuntu is being provisioned, please wait. It is a false warning, and it does not block the creation of the machine or the setup of the minion.

I have spent so many hours on this project within these three days, and, there is always a room for improvement, as there is in every project. I am open to any feedback, and I am willing to improve myself. I hope you like my work. Thank you for this opportunity. And, thank you for your time. 

Peace <3