import boto3
from util.format import print
from datetime import datetime

if __name__ == '__main__':
    dynamodb_client = boto3.client('dynamodb')
    paginator = dynamodb_client.get_paginator("scan")
    ttls = []
    table_name = 'bi-glue-table-partitions'
    for items in paginator.paginate(TableName=table_name):
        for item in items['Items']:
            if 'ttl' in item:
                ttls.append(int(item['ttl']['N']))
    print(datetime.fromtimestamp(min(ttls)).strftime('%H:%M'))
    print(datetime.fromtimestamp(max(ttls)).strftime('%H:%M'))
