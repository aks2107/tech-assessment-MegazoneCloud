import csv
import os

DATA_DIR = 'data-engineering/data'
OUTPUT_DIR = 'data-engineering/output'
MEMBERINFO_FILE = os.path.join(DATA_DIR, 'memberInfo.csv') # This allows the path to working on any OS such as Windows or Mac
MEMBERPAIDINFO_FILE = os.path.join(DATA_DIR, 'memberPaidInfo.csv')
OUTPUT_FILE = os.path.join(OUTPUT_DIR, 'cleanData.csv')

def check_directories():
    """
    This function checks to make sure the required directories are present. 
    If an output directory is missing it gets created.
    If the input files and directory is not present then the program terminates alerting the user that something is missing.
    """

    if not os.path.exists(OUTPUT_DIR):
        os.makedirs(OUTPUT_DIR)
    if not os.path.exists(DATA_DIR):
        print("The data directory is missing and the script will terminate.")
        exit(1)
    if not os.path.exists(MEMBERINFO_FILE):
        print("memberInfo.csv is missing and the script will terminate.")
        exit(1)
    if not os.path.exists(MEMBERPAIDINFO_FILE):
         print("memberPaidInfo.csv is missing and the script will terminate.")
         exit(1)

def read_member_info():
    """
    This function reads the information from the memberInfo.csv file into a dictionary for quick lookups.
    Returns: A dictionary with member ID as the key and the member full name as the value.
    """

    members = {} # Initialize empty members dictionary
    with open(MEMBERINFO_FILE, 'r') as file:
        reader = csv.DictReader(file) # First line in file gets treated as keys which are the columns and everything following as values for the keys
        for row in reader: 
            member_id = row['memberId'].strip() # Retrieve the 'memberID' value for that specific row
            first_name = row['firstName'].strip() # Retrieve the 'firstName' value for that specific row
            last_name = row['lastName'].strip() # Retrieve the 'lastName' value for that specific row
            full_name = f"{first_name} {last_name}".strip() # Combine first and last name into one string
            members[member_id] = full_name # Populate dictionary with key as member id and value as full name
    return members

def read_member_paid_info():
    """
    This function reads the information from the memberPaidInfo.csv file into a dictionary for quick lookups.
    Returns: A list of dictionaries with transaction data.
    """

    transactions = [] # Initialize list of dictionaries
    with open(MEMBERPAIDINFO_FILE, 'r') as file:
        reader = csv.DictReader(file)
        for row in reader:
            t_id = row['memberId'].strip()
            t_name = row['fullName'].strip()
            # Try and except block used to handle price data that may not be numerical
            try:
                t_price = float(row['paidAmount']) # Convert price to floating number
            except ValueError: # If the price value cannot be converted to floating number
                continue # Skip that data and move to next
            transactions.append({ # Append to transactions list
                'ID': t_id,
                'name': t_name,
                'paidAmount': t_price
            })
    return transactions

def main():
    """
    This function is the main function that does the following:
    1. Checks if the required directories and files exist
    2. Gets list of transactions
    3. Goes through list of transactions and finds if the member name and member ID exist
    4. Gets total paid amount
    5. Gets highest paying member
    6. Creates output file with the clean data
    7. Prints out some insights about the clean data
    """
    
    check_directories() # Check to make sure directories and files exist before moving on
    members = read_member_info() # Get dictionary of members
    transactions = read_member_paid_info() # Get list of transactions
    total_paid = 0.0
    clean_entries = []
    highest_payer = {'fullName': None, 'paidAmount': 0.0, 'memberID': None}
    for row in transactions:
        payment_id = row['ID']
        payment_name = row['name']
        payment_amount = row['paidAmount']
        if payment_id not in members: # Check if ID exists in member list
            continue # Skip ID if not associated with member
        if members[payment_id].upper() != payment_name.upper(): # Check if names match without capitalization issues
            continue # Skip name if not associated with member
        total_paid += payment_amount # Add to total paid count
        if payment_amount > highest_payer['paidAmount']:
            highest_payer = {'fullName': payment_name, 'paidAmount': payment_amount, 'memberID': payment_id} # Update highest payer data
        clean_entries.append({ # Add valid member transaction information to list of clean entries
            'memberId': payment_id,
            'fullName': payment_name,
            'paidAmount': payment_amount
        })
    with open(OUTPUT_FILE, 'w', newline='') as file:
        columns = ['memberID', 'fullName', 'paidAmount']
        writer = csv.DictWriter(file, columns)
        writer.writeheader() # Make the first line in the file the column names
        writer.writerows(clean_entries) # The rest of the rows in the file are the clean entries
    # Print out some insights about the clean entires
    print(f"Total clean rows: {len(clean_entries)}")
    print(f"Total Paid Amount: ${total_paid}")
    print(f"Highest Payer: {highest_payer['fullName']}, ID: {highest_payer['memberID']}, Amount: {highest_payer['paidAmount']}")

if __name__ == "__main__":
    main()