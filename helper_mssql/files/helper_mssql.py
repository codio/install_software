#!/usr/bin/env python

import argparse
import sys
import csv

import pyodbc

def is_python_2():
  return sys.version_info[0] == 2

def parse_args():
  parser = argparse.ArgumentParser()
  parser.add_argument('--db_host', required=True)
  parser.add_argument('--db_user', required=True)
  parser.add_argument('--db_pass', required=True)
  parser.add_argument('--db_name', required=True)
  return parser.parse_args()

def create_connection(db_host, db_user, db_password, db_name):
  connection = None
  try:
    connection = pyodbc.connect(
      'DRIVER={ODBC Driver 17 for SQL Server};SERVER='+ db_host +';DATABASE='+ db_name +';UID='+ db_user +';PWD='+ db_password
    )
  except pyodbc.Error as e:
    print('Create connection error {} occured'.format(e))
    exit(1)
  
  return connection

def execute_query(connection, query):
  cursor = connection.cursor()
  try:
    cursor.execute(query)
    result = cursor.fetchall()
    headers = [i[0] for i in cursor.description]
    return [headers, result]
  except pyodbc.Error as e:
    print('Query error {} occured'.format(e))
    exit(1)
    

def main():
  args = parse_args()
  
  query = raw_input() if is_python_2() else input()
  
  connection = create_connection(
    args.db_host,
    args.db_user,
    args.db_pass,
    args.db_name
  )
  [headers, query_result] = execute_query(connection, query)

  csvwriter = csv.writer(sys.stdout, delimiter=',', quotechar='|', quoting=csv.QUOTE_MINIMAL)
    
  csvwriter.writerow(headers)
  for line in query_result:
    csvwriter.writerow(line)
    
  
if __name__ == '__main__':
  main()
