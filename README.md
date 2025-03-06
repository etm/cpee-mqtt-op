# CPEE MQTT OP

To install the instatiation service go to the commandline

```bash
 gem install cpee-mqtt-op
 cpee-mqtt-op new mqtt
 cd mqtt
 ./mqtt start
```

The service is running under port 9296. If this port has to be changed (or the
host, or local-only access, ...), create a file instatiation.conf and add one
or many of the following yaml keys:

```yaml
 :port: 9250
 :host: cpee.org
 :bind: 127.0.0.1
 :mqtt: mqtt://lab.bpm.cit.tum.de
```

To use the service try one of the following:

```bash
curl -XPUT http://localhost:8298/value -d topic=/lab-power/socket-1/cmnd/POWER -d value=off
curl -XPUT http://localhost:8298/time -d time=4 -d topic=/lab-power/socket-1/cmnd/POWER -d start=on -d stop=off
curl -XPUT http://localhost:8298/time2 -d time=4 -d start_topic=/lab-power/socket-1/cmnd/POWER -d start_value=on -d stop_topic=/lab-power/socket-1/cmnd/POWER -d stop_value=off
curl -XPUT http://localhost:8298/wait -d start_topic=/lab-power/socket-1/cmnd/POWER -d start_value=on -d stop_topic=/lab-power/socket-1/cmnd/POWER -d stop_value=off
```

