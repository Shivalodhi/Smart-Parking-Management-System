from machine import Pin, PWM, I2C
from ssd1306 import SSD1306_I2C
import time

# for connecting cloud
import network
import urequests

# connecting with wifi
ssid = "Redmi note 8"
password = "[{(SM)}]"
sta = network.WLAN(network.STA_IF)
if not sta.isconnected():
    print('connecting to network.....')
    sta.active(True)
    
    sta.connect(ssid, password)
    while not sta.isconnected():
        pass
print('network config : ',sta.ifconfig())

# firebase url
firebase_url = "https://smart-parking-5d33c-default-rtdb.asia-southeast1.firebasedatabase.app/"


# Initialize PWM for the servo motor
servo_pin = Pin(5)
pwm = PWM(servo_pin, freq=50)  # 50 Hz frequency for standard servo

# Initialize I2C for the OLED display
i2c = I2C(scl=Pin(22), sda=Pin(21))
oled = SSD1306_I2C(128, 64, i2c)

# Initialize LED pins
led_red = Pin(12, Pin.OUT)
led_green = Pin(14, Pin.OUT)

# Initialize buzzer pin
buzzer_pin = Pin(13, Pin.OUT)
#buzzer_pwm = PWM(buzzer_pin)

# Initialize IR sensor pins
ir_in = Pin(18, Pin.IN)
ir_out = Pin(4, Pin.IN)

count = 2

def update_display():
    oled.fill(0)
    oled.text("Welcome to Parking", 0, 0)
    oled.text("Available: " + str(count), 0, 20)
    if count == 0:
        oled.text("Parking is FULL", 0, 40)
    oled.show()

def activate_buzzer():
    buzzer_pwm.freq(2000)  # Set a frequency for the buzzer sound
    buzzer_pwm.duty(1023)   # Set a duty cycle for medium volume
    time.sleep(2)        # Keep the buzzer on for 0.5 seconds
    buzzer_pwm.duty(0)

update_display()
pwm.duty(77)
led_red.value(1)
led_green.value(0)

while True:
    led_red.value(1)
    led_green.value(0)
    ir1 = ir_in.value()
    ir2 = ir_out.value()
    if ir1 == 0 and count > 0:
        led_red.value(0)
        led_green.value(1)
        buzzer_pin.value(1)
        time.sleep(1)
        buzzer_pin.value(0)
        pwm.duty(128)  # Corresponds to 90-degree angle
        time.sleep(4)
        led_red.value(1)
        led_green.value(0)
        buzzer_pin.value(1)
        time.sleep(1)
        buzzer_pin.value(0)
        pwm.duty(77)  # Corresponds to 0-degree angle
        count -= 1
        update_display()
    elif ir1 == 0 and count == 0:
        oled.fill_rect(0, 40, 128, 20, 0)
        oled.text("Parking is FULL", 0, 40)
        oled.show()
    elif ir2 == 0 and count < 5:
        led_red.value(0)
        led_green.value(1)
        buzzer_pin.value(1)
        time.sleep(1)
        buzzer_pin.value(0)
        pwm.duty(128)  # Corresponds to 90-degree angle
        time.sleep(4)
        led_red.value(1)
        led_green.value(0)
        buzzer_pin.value(1)
        time.sleep(1)
        buzzer_pin.value(0)
        pwm.duty(77)  # Corresponds to 0-degree angle
        count += 1
        update_display()
    elif ir2 == 0 and count == 5:
        update_display()
    else:
        update_display()
    
    data = {"count": count}
    try:
        response = urequests.put(firebase_url+"parking.json", json=data)
        print('Data sent successfully')
        print(response.text)
        response.close()
    
    except Exception as e:
        print('Error sending data:', e)
        
    time.sleep(2)
