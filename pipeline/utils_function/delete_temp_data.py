import os

def delete_temp(directory):
    try:
        
        # List all files in the directory
        files = os.listdir(directory)
        
        # Iterate and delete each files
        for file in files:
            file_path = os.path.join(directory, file)
            if os.path.isfile(file_path):
                os.remove(file_path)
                
    except Exception as e:
        print(f'An error occured: {e}')