```shell
# deps
yay -S strace redshift aur/thinkfan xorg-xdpyinfo ffmpeg pavucontrol pulseaudio pulseaudio-alsa mpstat sysstat autofs feh

# xbacklight
sudo 10-xbacklight.rules /etc/udev/rules.d/

# thinkfan
yay -S thinkfan
cp thinkfan.service.d/override.conf /etc/systemd/system/thinkfan.service.d/override.conf

# trackpoint
❭ echo -n 200 > /sys/devices/platform/i8042/serio1/sensitivity
❭ xinput set-prop "TPPS/2 Synaptics TrackPoint" "libinput Accel Speed" -0.7
```
