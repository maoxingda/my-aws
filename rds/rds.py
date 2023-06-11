import sys
from datetime import datetime, timedelta
from pprint import pprint

import boto3

from util.corp_wechat import send_message


def find_db_instance_by_addr(*, server_address):
    """
    查找数据库实例通过数据库地址
    :param server_address: 数据库地址
    :return: None
    """
    di_paginator = client.get_paginator('describe_db_instances')

    for db_instances in di_paginator.paginate():
        for instance in db_instances['DBInstances']:
            if 'Endpoint' in instance and server_address in instance['Endpoint']['Address']:
                print(instance['DBInstanceIdentifier'])


def find_snapshot():
    suffix = (datetime.utcnow() - timedelta(hours=16)).strftime('%Y-%m-%d-18-10')
    paginator = client.get_paginator('describe_db_snapshots')
    for page in paginator.paginate(DBInstanceIdentifier=db_id, DBSnapshotIdentifier=f'rds:{db_id}-{suffix}'):
        for snapshot in page['DBSnapshots']:
            print(snapshot['DBSnapshotIdentifier'])
            return snapshot['DBSnapshotIdentifier']


if __name__ == '__main__':
    client = boto3.client('rds')
    db_id = 'sandbox-common-bi-postgres'

    # 查找数据库快照
    snapshot_id = find_snapshot()
    sys.exit(0)

    local_datetime_from_snapshot_id = (datetime.strptime(snapshot_id[-16:], "%Y-%m-%d-%H-%M") + timedelta(hours=8)).strftime('%Y%m%dT%H%M%S')
    restore_db_id = f'{db_id}-snapshot-{local_datetime_from_snapshot_id}'

    response = client.describe_db_instances(DBInstanceIdentifier=db_id)

    # 从数据库快照创建新的数据库实例
    # client.restore_db_instance_from_db_snapshot(
    #     DBInstanceIdentifier=restore_db_id,
    #     DBSnapshotIdentifier=snapshot_id,
    #     DBSubnetGroupName=response['DBInstances'][0]['DBSubnetGroup']['DBSubnetGroupName'],
    #     PubliclyAccessible=False,
    #     VpcSecurityGroupIds=[
    #         vsgi['VpcSecurityGroupId'] for vsgi in response['DBInstances'][0]['VpcSecurityGroups']
    #     ],
    #     DBParameterGroupName=response['DBInstances'][0]['DBParameterGroups'][0]['DBParameterGroupName']
    # )
    # client.get_waiter('db_instance_available').wait(DBInstanceIdentifier=restore_db_id)
    # send_message(f'从快照（{snapshot_id}）创建数据库实例成功：https://cn-northwest-1.console.amazonaws.cn'
    #              f'/rds/home?region=cn-northwest-1#database:id={restore_db_id.lower()};is-cluster=false')

    # 删除数据库实例
    # client.delete_db_instance(
    #     DBInstanceIdentifier=restore_db_id,
    #     SkipFinalSnapshot=True
    # )
