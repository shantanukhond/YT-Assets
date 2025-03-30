from models.openai import chat_with_gpt
from ntes_demo import getTrainStatus, getPNRStatus, getTrainNumberMapping
import json


# The PRIMER framework is designed to work with the OpenAI API, specifically the GPT-4 model.
# It allows for a structured interaction with the model, enabling it to plan, take invoke functions, and monitor results in a loop until a final output is generated.
# The framework is particularly useful for applications that require multi-step reasoning and decision-making, such as querying train status or PNR information.
# The framework is designed to be extensible, allowing for the addition of new tools and functions as needed.

SYSTEM_PROMPT = '''
    Follow the PRIMER steps to handle user requests using the available functions.

    Steps:
    - prompt_input: Wait for user input.
    - reason_plan: Decide which function to call.
    - invoke_action: Call the chosen function with input.
    - monitor_result: Capture and observe the output.
    - explain_output: Format and return the final answer.
    - recover_error: Handle any issues and respond clearly.

    Functions:
    1. getTrainStatus(train_no: str) - Live train running status.
    2. getPNRStatus(pnr: str) - PNR ticket & seat status.
    3. getTrainNumberMapping() - Get train number from name.

    Example:
    START
    { "type": "prompt_input", "prompt": "get train running status for train 14682" }
    { "type": "reason_plan", "plan": "Call getTrainStatus for 14682" }
    { "type": "invoke_action", "function": "getTrainStatus", "input": "14682" }
    { "type": "monitor_result", "result": "Train is at NEW DELHI, delayed by 10 mins." }
    { "type": "explain_output", "response": "Train 14682 is at NEW DELHI, delayed by 10 minutes." }
'''


# user_prompt = "get train running status for train 14682"


messages = [
    {"role": "system", "content": SYSTEM_PROMPT}
]



# Define the tools dictionary mapping function names to their implementations
tools = {
    "getTrainStatus": getTrainStatus,
    "getPNRStatus": getPNRStatus,
    "getTrainNumberMapping": getTrainNumberMapping
}

while True:
    query = input(">> ")
    prompt_msg = {"type": "prompt_input", "prompt": query}
    messages.append({"role": "user", "content": json.dumps(prompt_msg)})

    while True:
        result = chat_with_gpt(messages)
        messages.append({"role": "assistant", "content": result})
        
        try:
            step = json.loads(result)
            print(f"🤖: {step}")

            if step["type"] == "explain_output":
                print(f"🤖: {step['response']}")
                break

            elif step["type"] == "invoke_action":
                fn = tools[step["function"]]
                try:
                    output = fn(step["input"])
                    monitor_msg = {
                        "type": "monitor_result",
                        "result": output
                    }
                    messages.append({"role": "developer", "content": json.dumps(monitor_msg)})
                except Exception as e:
                    error_msg = {
                        "type": "recover_error",
                        "error": str(e)
                    }
                    messages.append({"role": "developer", "content": json.dumps(error_msg)})
                    break

        except Exception as e:
            print(f"⚠️ Invalid response from model: {e}")
            break