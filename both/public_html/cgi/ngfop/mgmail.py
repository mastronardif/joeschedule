import requests 

def send_simple_message():
	return requests.post(
		"https://api.mailgun.net/v3/joeschedule.mailgun.org/messages",
		auth=("api", "pubkey-36p3stmhiyt4sfdw-c2392jcvatcwn64"),
		data={"from": "mastronardif@gmail.com>",
			"to": ["mastronardif@gmail.com", "mastronardif@netcarrier.com"],
			"subject": "FM Hello",
			"text": "Testing some Mailgun awesomeness!"})

# Call the function to send the message
response = send_simple_message()

# Print the response from the Mailgun API
print(response.text)