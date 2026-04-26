file '/etc/systemd/system/flaskapp.service' do
  owner 'root'
  group 'root'
  mode '0644'
  content <<-EOH
[Unit]
Description=Fleet Flask Application
After=network.target

[Service]
User=www-data
WorkingDirectory=/opt/fleetapp
ExecStart=/usr/bin/python3 /opt/fleetapp/app.py
Restart=always
RestartSec=5

[Install]
WantedBy=multi-user.target
  EOH
  action :create
end

bash 'install_flask_deps' do
  code <<-EOH
    pip3 install flask psycopg2-binary --break-system-packages
  EOH
  action :run
end

service 'flaskapp' do
  action [:enable, :start]
  subscribes :restart, 'file[/opt/fleetapp/app.py]', :delayed
end

file '/opt/fleetapp/app.py' do
  owner 'www-data'
  group 'www-data'
  content <<-EOH
from flask import Flask, jsonify
import psycopg2
import time

app = Flask(__name__)

PRIMARY = "#{node['db']['primary']}"
REPLICA = "#{node['db']['replica']}"

def get_db():
    for host in [PRIMARY, REPLICA]:
        for attempt in range(3):
            try:
                return psycopg2.connect(
                    host=host,
                    database="fleetdb",
                    user="fleetapp",
                    password="fleetpass"
                ), host
            except Exception as e:
                print(f"DB connection failed for {host}: {e}")
                if attempt < 2:
                    time.sleep(2)
                else:
                    continue
    raise Exception("Both primary and backup databases are unreachable")

@app.route('/')
def index():
    try:
        conn, host = get_db()
        cur = conn.cursor()
        label = "primary" if host == PRIMARY else "backup"
        cur.execute("SELECT * FROM nodes;")
        rows = cur.fetchall()
        conn.close()
        return jsonify({
            "Database Source": f"{label} ({host})",
            "nodes": rows
        })
    except Exception as e:
        return jsonify({"error": str(e)}), 500

if __name__ == '__main__':
    app.run(host='0.0.0.0', port=5000)
  EOH
  action :create
end