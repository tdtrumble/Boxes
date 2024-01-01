import csv
import os
import shutil

# Function to check if a folder exists
def folder_exists(folder_path):
    return os.path.exists(folder_path) and os.path.isdir(folder_path)

# Function to create a folder if it doesn't exist
def create_folder(folder_path):
    if not folder_exists(folder_path):
        os.makedirs(folder_path)

# Function to copy a file to a destination folder
def copy_file(source_path, destination_folder, new_filename):
    destination_path = os.path.join(destination_folder, new_filename)

    try:
        with open(source_path, 'r', encoding='utf-16le') as source_file:
            source_content = source_file.read()

        with open(destination_path, 'w', encoding='utf-16le') as destination_file:
            destination_file.write(source_content)

        print(f"File copied to {destination_path}")
        return destination_path

    except Exception as e:
        print(f"Error during file copy: {str(e)}")
        return None

# Function to perform find/replace in a file
def find_replace_in_file(file_path, find_str, replace_str):
    with open(file_path, 'r', encoding='utf-16le') as file:
        file_content = file.read()
        updated_content = file_content.replace(find_str, replace_str)
    
    with open(file_path, 'w', encoding='utf-16le') as file:
        file.write(updated_content)

# Specify the path to the CSV file
csv_file_path = '/App Box/_template/applist_for_script.csv'

# Specify the directory where the folders should exist
base_directory = '/App Box/Apps'

# Specify the path to the file to be copied
source_file_path = '/App Box/_template/_template.ini'

# Initialize an array to store CSV data
csv_data = []

# Read the CSV file and store data in the array
with open(csv_file_path, 'r') as csv_file:
    csv_reader = csv.DictReader(csv_file)
    for row in csv_reader:
        csv_data.append(row)

# Check if folders exist for each entry in the array
for entry in csv_data:
    app_name = entry.get('APPNAME', None)
    app_link = entry.get('APPLINK', None)
    app_icon = entry.get('APPICON', None)

    if app_name:
        folder_path = os.path.join(base_directory, app_name)

        if folder_exists(folder_path):
            print(f"Folder for {app_name} exists: {folder_path}")

        else:
            print(f"Folder for {app_name} does not exist.")

            # Create the folder if it doesn't exist
            create_folder(folder_path)

            # Copy the file into the new folder
            copy_file(source_file_path, folder_path, (app_name + ".ini"))
            print(f"File copied to {folder_path}")

            # Perform find/replace in the copied file
            file_to_replace = os.path.join(folder_path, (app_name + ".ini"))

            print(file_to_replace)
                
            find_replace_in_file(file_to_replace, '[[APPNAME]]', app_name)

            find_replace_in_file(file_to_replace, '[[APPLINK]]', app_link)

            find_replace_in_file(file_to_replace, '[[APPICON]]', app_icon)

