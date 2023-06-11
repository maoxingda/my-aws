import sys
import textwrap
from pprint import pprint as print

import boto3

if __name__ == '__main__':
    glue = boto3.client('glue')
    paginator = glue.get_paginator('get_partitions')
    sqls = []
    for partitions in paginator.paginate(DatabaseName='emr', TableName='bill_bill'):
        for partition in partitions['Partitions']:
            loc = partition['StorageDescriptor']['Location'].replace('realtime-cdc/bill', 'realtime-cdc/payment')
            sql = f"""alter table emr.bill_bill partition(event_time='{partition["Values"][0]}') set location '{loc}';"""
            sqls.append(sql)
    with open('emr.bill_bill.sql', 'w') as f:
        f.write('\n'.join(sqls))
