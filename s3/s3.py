import sys
from pprint import pprint as print
from datetime import datetime, timedelta

import boto3

if __name__ == '__main__':
    s3_client = boto3.client('s3')

    nums = []
    for num in range(100):
        nums.append(str(num).zfill(3))

    objects = []
    start_partition = '2022/09/21/08'
    end_partition = '2022/09/21/12'
    start_partition = datetime(
        year=int(start_partition.split('/')[0]),
        month=int(start_partition.split('/')[1]),
        day=int(start_partition.split('/')[2]),
        hour=int(start_partition.split('/')[3])) - timedelta(hours=8)
    end_partition = datetime(
        year=int(end_partition.split('/')[0]),
        month=int(end_partition.split('/')[1]),
        day=int(end_partition.split('/')[2]),
        hour=int(end_partition.split('/')[3])) - timedelta(hours=8)
    for num in nums:
        bucket = 'bi-data-store'

        partition = start_partition

        while partition <= end_partition:
            prefix = f'realtime-cdc/general_subsidy/public/' \
                     f'balance_sub_account_{num}/{datetime.strftime(partition,"%Y/%m/%d/%H")}'

            # print(prefix)
            partition += timedelta(hours=1)

            response = s3_client.list_objects_v2(Bucket=bucket, Prefix=prefix)

            if 'Contents' in response:
                objects.extend([obj['Key'] for obj in response['Contents']])

            while response['IsTruncated']:
                response = s3_client.list_objects_v2(Bucket=bucket, Prefix=prefix)
                if 'Contents' in response:
                    objects.extend([obj['Key'] for obj in response['Contents']])

    if objects:
        print(objects)
