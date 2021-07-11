#### aws:zzz:

my aws cli

just as an aid to myself

#### functions
the function name prefix character `s` stands for aws service s3

usage:
​	function -h 

​	e.g. sls -h

##### <font color=red>spwd</font>

print working directory

##### <font color=red>sdb</font>

set -vx & set +vx  option for function

##### <font color=red>sls</font>

implementation for `aws s3 ls [-h] [-r]`

##### <font color=red>scd</font>

auxiliary function, emulate for system command cd

##### <font color=red>sup</font>

implementation for `aws s3 cp [-h] [-r] [-i wildcard] <locaPath> <s3Uri>`

##### <font color=red>sdo</font>

implementation for `aws s3 cp [-h] [-r] [-i wildcard] <s3Uri> <locaPath>`

##### <font color=red>smv</font>

implementation for `aws s3 mv [-h] [-r] [-i wildcard] <s3Uri> <s3Uri>`

##### <font color=red>srm</font>

implementation for `aws s3 rm [-h] [-r] [-i wildcard] <s3Uri>`