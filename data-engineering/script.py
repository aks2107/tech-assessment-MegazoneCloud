import csv
import os

DATA_DIR = 'data'
OUTPUT_DIR = 'output'
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
        print("memberinfo.csv is missing and the script will terminate.")
        exit(1)
    if not os.path.exists(MEMBERPAIDINFO_FILE):
         print("memberPaidInfo.csv is missing and the script will terminate.")
         exit(1)

def read_member_info():
    """
    This function reads the information from the memberInfo.csv file into a dictionary for quick lookups.
    Returns: A dictionary with member ID as the key and the member name as the value.
    """

    members = {} # Initialize empty members dictionary
    with open(MEMBERINFO_FILE, 'r') as file:
        reader = csv.DictReader(file) # First line in file gets treated as keys which are the columns and everything following as values for the keys
        for row in reader: 
            member_id = row['id'].strip() # Retrieve the 'id' value for that specific row
            member_name = row['name'].strip() # Retrieve the 'name' value for that specific row
            members[member_id] = member_name # Populate dictionary with key as member id and value as member name
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
            t_id = row['id'].strip()
            t_name = row['name'].strip()
            # Try and except block used to handle price data that may not be numerical
            try:
                t_price = float(row['price']) # Convert price to floating number
            except ValueError: # If the price value cannot be converted to floating number
                continue # Skip that data and move to next
            transactions.append({ # Append to transactions list
                'id': t_id,
                'name': t_name,
                'price': t_price
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
    clean_rows = []
    highest_payer = {'name': None, 'paid_amount': 0.0, 'id': None}
    for row in transactions:
        payment_id = row['id']
        payment_name = row['name']
        payment_amount = row['price']
        if payment_id not in members: # Check if ID exists in member list
            continue # Skip ID if not associated with member
        if members[payment_id].upper() != payment_name.upper(): # Check if names match without capitalization issues
            continue # Skip name if not associated with member
        total_paid += payment_amount # Add to total paid count
        if payment_amount > highest_payer['paid_amount']:
            highest_payer = {'name': payment_name, 'paid_amount': payment_amount, 'id': payment_id} # Update highest paid data
        clean_rows.append({ # Add valid member information to clean list
            'member_id': payment_id,
            'member_name': payment_name,
            'paid_amount': payment_amount
        })
    with open(OUTPUT_FILE, 'w', newline='') as file:
        columns = ['member_id', 'member_name', 'paid_amount']
        writer = csv.DictWriter(file, columns)
        writer.writeheader() # Make the first line in the file the column names
        writer.writerows(clean_rows) # The rest of the rows in the file are the clean data
    # Print out some insights about the clean data
    print(f"Total clean rows: {len(clean_rows)}")
    print(f"Total Paid Amount: ${total_paid}")
    print(f"Highest Payer: {highest_payer['name']}, ID: {highest_payer['id']}, Amount: {highest_payer['paid_amount']}")

if __name__ == "__main__":
    main()