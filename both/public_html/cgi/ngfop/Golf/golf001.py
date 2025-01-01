# Download the helper library from https://www.twilio.com/docs/python/install
import os
from twilio.rest import Client

# Find your Account SID and Auth Token at twilio.com/console
# and set the environment variables. See http://twil.io/secure
client = Client(account_sid, auth_token)

message = client.messages.create(
    body="Join Earth's mightiest heroes. Like Kevin Bacon.",
    from_="+18335260542", # 18335260542
    to   ="+19088580954",
)

print(message.body)

# Test Test credentials
# ACe07439ff829625fccce7fbf6e1b4a34e
# 900ced00a05bd208874c86469b3ae1f8
