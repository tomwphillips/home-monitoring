# Home Environment Monitoring

We are planning a retrofit of our home to improve its energy efficiency, reduce CO2 emissions and improve indoor air quality.

In order to better understand the building we are monitoring the temperature and humidity of all the rooms and our energy consumption via our smart meters.
This data will also be useful for examining the effect of any measures we undertake.

Here's how I set it all up.
I took inspiration from the guide published by [Carbon Co-op](https://carbon.coop/2020/07/a-guide-to-monitoring-your-home-environment/), but made some different choices.

## Hardware

You will need:

* [A computer to run Home Assistant Container](https://www.home-assistant.io/installation/). I am using a [Raspberry Pi 4](https://www.raspberrypi.com/products/raspberry-pi-4-model-b/) with 4GB memory. I recommend the Pi because its popularity means there's a lot of help available online.
* [Conbee II](https://phoscon.de/en/conbee2) ZigBee gateway. I get a good signal throughout my house.
* [Aqara temperature and humidity sensors](https://www.aqara.com/us/temperature_humidity_sensor.html). These are great. You can get them cheaply on [AliExpress](https://www.aliexpress.com/item/32946812631.html).


## Set up

### Raspberry Pi OS & Docker

1. [Install Raspberry Pi OS](https://www.raspberrypi.com/software/) (formerly known as Raspbian). I use mine in headless mode, so I use Lite OS, which doesn't have a GUI. Make sure you enable SSH login in the Imager utility.
2. [Install Docker](https://docs.docker.com/engine/install/debian/#install-using-the-convenience-script). There are a few options for installing Docker on Linux, but only the convenience script is supported on RPi.
3. [Install Docker Compose](https://docs.docker.com/compose/install/#install-compose). I used the standalone binary method.
4. Clone this git repository to your computer.
5. Run `rm zigbee2mqtt/configuration.yaml` to remove my zigbee2mqtt configuration file (it contains all my devices) and then `cp zigbee2mqtt/configuration.yaml.template` to copy the template.
6. Run `docker-compose up -d` to start all the containers. It might take a while to pull the images.

### Pairing sensors

1. In your browser, go to `hostname:8080` to access the `zigbee2mqtt` UI.
2. Click "permit join", if joining isn't already permitted.
3. Press and hold the button on a sensor for 5 seconds until the light flashes.
4. After a short while it should then appear in the `zigbee2mqtt` web interface. I suggest you rename the sensor to something useful, like `room_name/air_sensor`.
5. Repeat for all your sensors.
6. Edit `zigbee2mqtt/configuration.yaml` so `permit_join: false` and no new devices can join your network.
7. In `zigbee2mqtt/configuration.yaml`, cut the value under `network_key` and replace it with `'!secret network_key'` (including the quotes). Create `zigbee2mqtt/secret.yml` containing:

```
network_key: YOUR_SECRET_KEY
```

8. If you want, you can track your `zigbee2mqtt/configuration.yaml` file in git. The secret file, for security, is excluded from git in the `.gitignore` file.

### Home Assistant

1. In your browser go to `hostname` to access the Home Assistant UI.
2. Follow the instructions to set up an account.
3. Click Configuration > Devices & Services > Add Integration and search for MQTT. Follow instructions to install.
4. In the broker options, set the broker to `mosquitto` and port to `1883`. Leave the username and password blank.
5. All the sensors should appear in Home Assistant as devices. Wait a while and you should start to see data in the History.

### InfluxDB

1. In your browser go to to `hostname:8086` and follow the setup instructions. Call your organisation whatever you want. I used my hostname.
2. Create a bucket called `home_assistant` (Data > Buckets).
3. Create an API token (Data > API Tokens) with read/write access to the `home_assistant` bucket. TODO: api token in HA secrets
4. Click Profile (top left in the UI) > Members > About and copy the organisation ID. TODO: HA secret


## Choices

* zigbee2mqtt over deConz
* containers
* InfluxDB - not a fan, but it's easy
