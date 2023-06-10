import os
import sys
import time
from datetime import datetime, timedelta
from pprint import pprint

import boto3


def find_snapshot(start_time, end_time):
    start_time = datetime.strptime(start_time, '%Y/%m/%d %H:%M') - timedelta(hours=8)
    end_time = datetime.strptime(end_time, '%Y/%m/%d %H:%M') - timedelta(hours=8)

    paginator = client.get_paginator('describe_cluster_snapshots')

    for page in paginator.paginate(ClusterIdentifier=cluster_id, StartTime=start_time, EndTime=end_time):
        for snapshot in page['Snapshots']:
            print(snapshot['SnapshotIdentifier'])
            return snapshot['SnapshotIdentifier']


def restore_table_from_cluster_snapshot(src_table_name, dst_table_name):
    # 集群在连续两次恢复快照操作之间必须等待集群状态更新为：Available
    start = datetime.now()

    while True:
        response = client.describe_clusters(ClusterIdentifier=cluster_id)

        cluster_status = response['Clusters'][0]['ClusterAvailabilityStatus']

        print(f'cluster status: {cluster_status}', f'elapsed: {int((datetime.now() - start).total_seconds())} 秒')

        if cluster_status == 'Available':
            break

        time.sleep(15)

    # 从集群快照恢复表
    response = client.restore_table_from_cluster_snapshot(
        ClusterIdentifier=cluster_id,
        SnapshotIdentifier=snapshot_id,
        SourceDatabaseName=src_table_name.split('.')[0],
        SourceSchemaName=src_table_name.split('.')[1],
        SourceTableName=src_table_name.split('.')[2],
        TargetDatabaseName=dst_table_name.split('.')[0],
        TargetSchemaName=dst_table_name.split('.')[1],
        NewTableName=dst_table_name.split(".")[2],
    )
    req_id = response['TableRestoreStatus']['TableRestoreRequestId']

    start = datetime.now()
    while (datetime.now() - start).total_seconds() / 60 < 15:
        response = client.describe_table_restore_status(
            ClusterIdentifier=cluster_id,
            TableRestoreRequestId=req_id,
        )

        status = response['TableRestoreStatusDetails'][0]['Status']

        print(src_table_name, dst_table_name, status, f'elapsed: {int((datetime.now() - start).total_seconds())} 秒')

        if status in ['SUCCEEDED', 'FAILED', 'CANCELED']:
            print(response)
            break

        time.sleep(15)


def restore_from_cluster_snapshot():
    response = client.describe_clusters(ClusterIdentifier=cluster_id)

    client.restore_from_cluster_snapshot(
        ClusterIdentifier=restore_cluster_id,
        SnapshotIdentifier=snapshot_id,
        SnapshotClusterIdentifier=cluster_id,
        ClusterSubnetGroupName=response['Clusters'][0]['ClusterSubnetGroupName'],
        ClusterParameterGroupName=response['Clusters'][0]['ClusterParameterGroups'][0]['ParameterGroupName'],
        VpcSecurityGroupIds=[response['Clusters'][0]['VpcSecurityGroups'][0]['VpcSecurityGroupId']],
    )

    client.get_waiter('cluster_available').wait(ClusterIdentifier=restore_cluster_id)


if __name__ == '__main__':
    client = boto3.client('redshift')
    cluster_id, dbname = ('bi-sandbox', 'beta') if os.getlogin() == 'root' else ('bi-prod-hc', 'prod')

    # 查找集群快照
    snapshot_id = find_snapshot('2023/06/10 08:00', '2023/06/10 09:00')
    # snapshot_id = 'rs:bi-sandbox-2023-06-10-00-01-19'

    local_datetime_from_snapshot_id = (datetime.strptime(snapshot_id[-19:], "%Y-%m-%d-%H-%M-%S") + timedelta(hours=8)).strftime('%Y%m%dT%H%M%S')
    restore_cluster_id = f'{cluster_id}-snapshot-{local_datetime_from_snapshot_id}'

    sys.exit(0)

    # 基于已有集群快照创建新的集群
    # restore_from_cluster_snapshot()

    # sys.exit(0)

    # 删除集群
    # client.delete_cluster(
    #     ClusterIdentifier=restore_cluster_id,
    #     SkipFinalClusterSnapshot=True
    # )

    # sys.exit(0)

    # tables = [
    # ]
    #
    # for table in tables:
    #     restore_table_from_cluster_snapshot(
    #         src_table_name=f'{dbname}.{table}',
    #         dst_table_name=f'{dbname}.temp.{table.split(".")[1]}_{local_datetime_from_snapshot_id}',
    #     )
