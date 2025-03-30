
from openai import OpenAI
import os
from dotenv import load_dotenv

load_dotenv() 

client = OpenAI(
  api_key = os.getenv("OPENAI_API_KEY"),
)


def chat_with_gpt(prompt, model="gpt-4o"):
    completion = client.chat.completions.create(
    model=model,
    store=True,
    messages=prompt
    )
    return completion.choices[0].message.content

# chat = client.chat.completions.create(
#             model="gpt-4o",
#             messages=messages,
#             response_format="json_object"
#         )

#         result = chat.choices[0].message.content

