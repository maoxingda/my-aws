import sys
import time
from datetime import datetime

import boto3

from util.format import print

if __name__ == '__main__':
    redshift_client = boto3.client('redshift')

    cluster_id = 'bi-sandbox'

    for i in range(1):
        start_time = datetime(2022, 12, 9, 4)
        response = redshift_client.describe_cluster_snapshots(
            ClusterIdentifier=cluster_id,
            StartTime=start_time,
            MaxRecords=20,
            SortingEntities=[
                {
                    'Attribute': 'CREATE_TIME',
                    'SortOrder': 'ASC',
                },
            ]
        )

        snapshot_id = response['Snapshots'][0]['SnapshotIdentifier']
        print(snapshot_id)

        response = redshift_client.restore_table_from_cluster_snapshot(
            ClusterIdentifier=cluster_id,
            SnapshotIdentifier=snapshot_id,
            SourceDatabaseName='beta',
            SourceSchemaName='met',
            SourceTableName='user_transaction_meal_plan_agg',
            TargetDatabaseName='beta',
            TargetSchemaName='met',
            NewTableName=f'user_transaction_meal_plan_agg_{datetime.strftime(start_time, "%Y%m%d")}',
        )
        req_id = response['TableRestoreStatus']['TableRestoreRequestId']

        start = datetime.now()
        while (datetime.now() - start).total_seconds() / 60 < 5:
            response = redshift_client.describe_table_restore_status(
                ClusterIdentifier=cluster_id,
                TableRestoreRequestId=req_id,
            )

            status = response['TableRestoreStatusDetails'][0]['Status']

            print(status)

            if status in ['SUCCEEDED', 'FAILED', 'CANCELED']:
                print(response)
                break

            time.sleep(15)
