import json

def getTrainNumberMapping(str_input) -> dict:
    """Reads JSON data from a file and returns it as a dictionary."""
    file_path = "./data/train_status.json"
    try:
        with open(file_path, "r", encoding="utf-8") as file:
            return json.load(file)
        
    except FileNotFoundError:
        print("Error: File not found.")
    
    except json.JSONDecodeError:
        print("Error: Invalid JSON format.")
    
    except Exception as e:
        print(f"Unexpected error: {e}")




def getTrainStatus(train_no:str) -> str:
    file_path = "./data/train_status.json"
    """Reads JSON data from a file and returns it as a dictionary."""
    try:
        with open(file_path, "r", encoding="utf-8") as file:
            train_data_list = json.load(file)
            for train in train_data_list:
                if train.get("TrainNumber") == train_no:
                    # To reduce the size of the response, due to cost constraints 
                    # train['TrainRoute'] = None
                    return train
            return None
        return data
    
    except FileNotFoundError:
        print("Error: File not found.")
    except json.JSONDecodeError:
        print("Error: Invalid JSON format.")
    except Exception as e:
        print(f"Unexpected error: {e}")

def getPNRStatus(pnr:str) -> str:
    pass

# print(getTrainStatus("14682"))