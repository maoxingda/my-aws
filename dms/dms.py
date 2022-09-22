import sys

import boto3
# from util.format import print

if __name__ == '__main__':
    dms_client = boto3.client('dms')

    de_paginator = dms_client.get_paginator('describe_endpoints')
    for endpoints in de_paginator.paginate():
        for endpoint in endpoints['Endpoints']:
            print(endpoint['EndpointIdentifier'])

    drt_paginator = dms_client.get_paginator('describe_replication_tasks')
    for tasks in drt_paginator.paginate():
        for task in tasks['ReplicationTasks']:
            dts_paginator = dms_client.get_paginator('describe_table_statistics')
            for stats in dts_paginator.paginate(ReplicationTaskArn=task['ReplicationTaskArn']):
                for stat in stats['TableStatistics']:
                    if stat['Deletes'] > 0:
                        print(stat['SchemaName'], stat['TableName'], stat['Deletes'])

    dri_paginator = dms_client.get_paginator('describe_replication_instances')
    for instances in dri_paginator.paginate():
        for instance in instances['ReplicationInstances']:
            print(instance['ReplicationInstanceIdentifier'])

