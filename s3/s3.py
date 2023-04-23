# from pprint import pprint as print
import os
import sys

import boto3
import pandas
from prettytable import PrettyTable

if __name__ == '__main__':
    s3 = boto3.client('s3')

    bucket = 'bi-data-store' if os.getlogin() == 'root' else 'bi-data-lake'
    prefix = 'realtime-cdc/fan/fan/corporderuser/2023/04/03/03/'

    paginator = s3.get_paginator('list_objects_v2')

    for objects in paginator.paginate(Bucket=bucket, Prefix=prefix):
        for obj in objects['Contents']:
            df = pandas.read_parquet(f's3://{bucket}/{obj["Key"]}')
            df = df.query("id == 147385487")
            if not df.empty:
                print(obj['Key'])
                table = PrettyTable()
                table.field_names = df.columns
                table.add_rows(tuple(map(tuple, df.values)))
                print(table)
                sys.exit(0)
