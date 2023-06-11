"""
日常常用小工具
"""
import re
import sys
from pprint import pprint

import boto3


def find_task_by_table(*, table_name):
    """
    查找同步某个表的任务
    :param table_name: 表名称
    :return: None
    """
    find_tasks = set()
    drt_paginator = dms_client.get_paginator('describe_replication_tasks')
    for tasks in drt_paginator.paginate():
        for task in tasks['ReplicationTasks']:
            dts_paginator = dms_client.get_paginator('describe_table_statistics')
            for stats in dts_paginator.paginate(ReplicationTaskArn=task['ReplicationTaskArn']):
                for stat in stats['TableStatistics']:
                    if table_name in stat['TableName']:
                        find_tasks.add((task['ReplicationTaskIdentifier'],
                                        f"https://cn-northwest-1.console.amazonaws.cn/dms/v2/home?region=cn-northwest-1#taskDetails/{task['ReplicationTaskIdentifier']}"))
    if find_tasks:
        task_id_max_length = max([len(task_id) for task_id, _ in find_tasks])
        for task_id, task_url in sorted(find_tasks):
            print(task_id.ljust(task_id_max_length), task_url)


def find_endpoint_by_addr(*, server_address):
    """
    找到端点通过数据库地址
    :param server_address: 数据库地址
    :return: None
    """
    de_paginator = dms_client.get_paginator('describe_endpoints')
    for endpoints in de_paginator.paginate():
        for endpoint in endpoints['Endpoints']:
            if 'ServerName' in endpoint and server_address in endpoint['ServerName']:
                print(endpoint['DatabaseName'], endpoint['EndpointArn'])


def find_tasks_by_source_endpoint(*, endpoint_arn):
    """
    查找源端点为endpoint_arn的任务
    :param endpoint_arn: 源端点ID
    :return: None
    """
    drt_paginator = dms_client.get_paginator('describe_replication_tasks')
    for tasks in drt_paginator.paginate():
        for task in tasks['ReplicationTasks']:
            if endpoint_arn in task['SourceEndpointArn']:
                print(task['ReplicationTaskIdentifier'],
                      f"https://cn-northwest-1.console.amazonaws.cn/dms/v2/home?region=cn-northwest-1#taskDetails/{task['ReplicationTaskIdentifier']}")


if __name__ == '__main__':
    dms_client = boto3.client('dms')
