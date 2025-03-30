# AI Agent with ChatGPT with PRIMER framework

## 🔧 PRIMER Framework

The PRIMER framework is designed to work with the OpenAI API, specifically the GPT-4 model. It allows for a structured interaction with the model, enabling it to plan, take invoke functions, and monitor results in a loop until a final output is generated. The framework is particularly useful for applications that require multi-step reasoning and decision-making, such as querying train status or PNR information. It is extensible, allowing for the addition of new tools and functions as needed.

| Step | New Step Name     | Description                 |
|------|-------------------|-----------------------------|
| P    | `prompt_input`    | User asks something         |
| R    | `reason_plan`     | AI reasons and plans        |
| I    | `invoke_action`   | Call function               |
| M    | `monitor_result`  | Observe output              |
| E    | `explain_output`  | Return result to user       |
| R    | `recover_error`   | Handle errors if any        |

### Example Usage

The following example demonstrates how the PRIMER framework can be used to query train running status:

1. **User Input**: The user provides a query, e.g., "get train running status for train 14682".
2. **Reason and Plan**: The AI decides which function to call, e.g., `getTrainStatus`.
3. **Invoke Action**: The function is called with the appropriate input.
4. **Monitor Result**: The output of the function is captured and observed.
5. **Explain Output**: The final answer is formatted and returned to the user.
6. **Recover Error**: If any issues occur, they are handled gracefully.

#### Example Interaction

```
>> get train running status for karnataka express
🤖: {'type': 'plan', 'plan': 'To find the train running status for Karnataka Express, I need to get its train number first. I will use getTrainNumberMapping to find the train number for Karnataka Express.'}
🤖: {'type': 'action', 'function': 'getTrainNumberMapping', 'input': ''}
🤖: {'type': 'action', 'function': 'getTrainStatus', 'input': '12627'}
🤖: {'type': 'output', 'output': 'The Karnataka Express (train number 12627) is currently departing from Bangalore City Junction (SBC). It left 5 minutes later than scheduled at 19:25. The train is running with minor delays on its route, such as a 5-minute delay at Hindupur and a 10-minute delay at Dharmavaram Junction.'}       
🤖: The Karnataka Express (train number 12627) is currently departing from Bangalore City Junction (SBC). It left 5 minutes later than scheduled at 19:25. The train is running with minor delays on its route, such as a 5-minute delay at Hindupur and a 10-minute delay at Dharmavaram Junction.
```

### Functions Used

1. **getTrainStatus(train_no: str)** - Fetches live train running status.
2. **getPNRStatus(pnr: str)** - Retrieves PNR ticket and seat status.
3. **getTrainNumberMapping()** - Maps train names to their respective numbers.

This structured approach ensures clarity, error handling, and extensibility for various use cases.

[The code of this project is available in here](./code/)

