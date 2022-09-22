import boto3
import botocore

if __name__ == '__main__':
    glue = boto3.client('glue')
    try:
        table = glue.get_table(DatabaseName='emr', Name='fan_corp_order_user')
        print(table['Table']['Name'])
    except botocore.exceptions.ClientError as error:
        if error.response['Error']['Code'] == 'EntityNotFoundException':
            print(error)
        else:
            raise error
