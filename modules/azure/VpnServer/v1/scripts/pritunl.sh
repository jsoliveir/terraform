

sudo tee /etc/apt/sources.list.d/pritunl.list << EOF
deb http://repo.pritunl.com/stable/apt focal main
EOF

# Import signing key from keyserver
sudo apt-key adv --keyserver hkp://keyserver.ubuntu.com --recv 7568D9BB55FF9E5287D586017AE645C0CF8E292A
# Alternative import from download if keyserver offline
curl https://raw.githubusercontent.com/pritunl/pgp/master/pritunl_repo_pub.asc | sudo apt-key add -

sudo apt update

# WireGuard server support
sudo apt -y install wireguard wireguard-tools

sudo ufw disable

sudo apt -y install pritunl

sudo systemctl enable pritunl

sudo systemctl start pritunl

sleep 15

curl -X PUT --url "https://127.0.0.1/setup/mongodb" \
  --header 'content-type: application/json' \
  --retry-connrefused \
  --retry-delay 5 \
  --retry 12 \
  --insecure \
  --data-raw "{
    \"setup_key\":\"$(sudo pritunl setup-key)\",
    \"mongodb_uri\":\"mongodb://habitushubeupritunl:LcbrLgR7AVTBAT6PcGCWM9pNgmiaFPRZ4FuuDloRXiBma7WcgaFJt3NuNAtTz0LKqpbNbsR2zY8GACDbHeK6jQ==@habitushubeupritunl.mongo.cosmos.azure.com:10255/?ssl=true&replicaSet=globaldb&retrywrites=false&maxIdleTimeMS=120000&appName=@habitushubeupritunl@/pritunl\"
  }"

sudo pritunl default-password

sudo systemctl restart pritunl
