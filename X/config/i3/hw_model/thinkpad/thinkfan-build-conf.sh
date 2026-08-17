#!/bin/bash

if [[ $(id -u) -ne 0 ]]; then
    echo "Need to be root"
    exit 1
fi

CONF=/etc/thinkfan.conf

echo 'options thinkpad_acpi fan_control=1' > /etc/modprobe.d/99-fancontrol.conf

echo "
# GPU
tp_fan /proc/acpi/ibm/fan

$(find /sys/devices -type f -name 'temp*_input' | while read f; do cat $f > /dev/null && echo hwmon $f;done 2> /dev/null)

# level  temp_min   temp_max
(0,     0,      48)
(1,     45,     52)
(2,     48,     55)
(3,     52,     60)
(4,     58,     65)
(5,     62,     77)
(7,     73,     93)
(127,   85,     32767)
" > $CONF
