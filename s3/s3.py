from pprint import pprint as print

import boto3

if __name__ == '__main__':
    s3 = boto3.client('s3')

    bucket = 'bi-data-store'
    prefix = 'realtime-cdc/order20/public/'

    paginator = s3.get_paginator('list_objects_v2')

    for objects in paginator.paginate(Bucket=bucket, Prefix=prefix):
        for obj in objects['Contents']:
            print(obj['Key'])
