#!/usr/bin/env python

# sudo apt install libpq-dev
# pip install psycopg2

import argparse
import sys
import csv

import psycopg2
from psycopg2 import OperationalError

def parse_args():
  parser = argparse.ArgumentParser()
  parser.add_argument('--db_host', required=True)
  parser.add_argument('--db_port', required=True)
  parser.add_argument('--db_user', required=True)
  parser.add_argument('--db_pass', required=True)
  parser.add_argument('--db_name', required=True)
  return parser.parse_args()


def create_connection(db_name, db_user, db_password, db_host, db_port):
  connection = None
  try:
    connection = psycopg2.connect(
      database=db_name,
      user=db_user,
      password=db_password,
      host=db_host,
      port=db_port
    )
  except OperationalError as e:
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
  except OperationalError as e:
    print('Query error {} occured'.format(e))
    exit(1)
    
def main():
  args = parse_args()
  
  query = raw_input()
  
  connection = create_connection(
    args.db_name,
    args.db_user,
    args.db_pass,
    args.db_host,
    args.db_port
  )
  [headers, query_result] = execute_query(connection, query)
  
  csvwriter = csv.writer(sys.stdout, delimiter=',', quotechar='|', quoting=csv.QUOTE_MINIMAL)
    
  csvwriter.writerow(headers)
  for line in query_result:
    csvwriter.writerow(line)
    
  
if __name__ == '__main__':
  main()