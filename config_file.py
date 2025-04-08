import json

with open("config.json", "r",
          encoding='utf-8') as jsonfile:
    config_data = json.load(jsonfile)

session_config = {
    'msg': [
        {"role": "system", "content": config_data['gemini']['system_prompt']}
    ],
    'send_voice': False, 
    'new_bing': False
}