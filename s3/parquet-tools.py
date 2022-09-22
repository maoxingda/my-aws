import glob

import pandas as pd

pd.set_option('display.max_columns', None)

if __name__ == '__main__':
    # bucket = 'bi-data-lake'
    # prefix = 'realtime-cdc/fan/fan/librabill/2022/07/29/04/20220729-043430807.parquet'
    # df = wr.s3.read_parquet(f's3://{bucket}/{prefix}', dataset=False)
    # print(df[df['id'] == 354741874])

    for file in glob.glob("/tmp/parquet/dine_in/*.parquet"):
        # print(file)
        df = pd.read_parquet(file)
        df = df[df['order_no'] == 82476010394648622]
        if not df.empty:
            print(file)
            break
