# importing libaries
import mysql.connector
import csv
# database connection
try:
    mydb = mysql.connector.connect(
        host="localhost",
        database="flightdb",
        user="root",
        password="Nishan@2059"
)
    if mydb.is_connected():
        print("Connection is successful")
except mysql.connector.Error as e:
    print(f"Error connecting to mysql:{e}")
    
cursor = mydb.cursor()
# checking csv heading
with open("transformed_data.csv","r") as file:
    reader = csv.reader(file)
    headers=next(reader)
    # it escape col names which is reserved by sql
    escaped_header=[f"`{col}`" for col in headers]
    # creating table in database according to csv col heading
    columns =",".join([f"`{col}` VARCHAR(255)" for col in headers])
    create_table=f"""CREATE TABLE IF NOT EXISTS flight_data({columns})"""
    cursor.execute(create_table)
    # inserting data 
    insert=f"""INSERT INTO flight_data({','.join(escaped_header)})
    VALUES ({','.join(['%s']*len(headers))})"""
    
with open("transformed_data.csv","r",newline="") as file:
    reader=csv.reader(file)
    next(reader) 
    for row in reader:
        cursor.execute(insert,row)
mydb.commit()
cursor.close()
mydb.close()
print("csv imported successfully")


