- [1. aws:zzz:](#1-awszzz)
  - [1.1. commands](#11-commands)
    - [1.1.1. spwd](#111-spwd)
    - [1.1.2. sdb](#112-sdb)
    - [1.1.3. scd](#113-scd)
    - [1.1.4. sls](#114-sls)
    - [1.1.5. sul](#115-sul)
    - [1.1.6. sdl](#116-sdl)
    - [1.1.7. srm](#117-srm)
    - [1.1.8. smv](#118-smv)

# 1. aws:zzz:

**My aws s3 command line interface, just as an aid to myself.**



## 1.1. commands

The command name prefix character `s` stands for aws service s3.

```diff
+ Usage:
+   command -h
+
+ Example:
+   scd -h
+     Usage:
+       scd [-h | [S3Uri]]
+
+   sls -h
+     Usage:
+       sls [-h | [S3Uri]]
```



### 1.1.1. spwd

```diff
+ print working directory
```



### 1.1.2. sdb

```diff
+ set -vx & set +vx option for command
```



### 1.1.3. scd

```diff
+ Usage:
+     scd [-h | [S3Uri]]
```

### 1.1.4. sls

```diff
+ Usage:
+     sls [-h] [-r] [S3Uri]
```



### 1.1.5. sul

```diff
+ NAME
+     sul
+ 
+ SYNOPSIS
+     sul [-h] [-r] [-d] [-q] [-n] [-i <wildcard>] <LocalPath> [S3Uri]
+ 
+ DESCRIPTION
+     Copies a local file to S3 object.
+ 
+ OPTIONS
+     -h Print this message, then exit.
+ 
+     -r Command is performed on all files or objects under the specified directory or prefix.
+     -d Displays the operations that would be performed using the specified command without actually running them.
+     -q Does not display the operations performed from the specified command.
+     -n File transfer progress is not displayed.
```



### 1.1.6. sdl

```diff
+ NAME
+     sdl
+ 
+ SYNOPSIS
+     sdl [-h] [-r] [-d] [-q] [-n] [-i <wildcard>] <S3Uri> [LocalPath]
+ 
+ DESCRIPTION
+     Copies S3 object to a local file.
+ 
+ OPTIONS
+     -h Print this message, then exit
+ 
+     -r Command is performed on all files or objects under the specified directory or prefix.
+     -d Displays the operations that would be performed using the specified command without actually running them.
+     -q Does not display the operations performed from the specified command.
+     -n File transfer progress is not displayed.
```



### 1.1.7. srm

```diff
+ NAME
+     srm
+ 
+ SYNOPSIS
+     srm [-h] [-r] [-d] [-i <wildcard>] <S3Uri>
+ 
+ DESCRIPTION
+     Deletes an S3 object.
+ 
+ OPTIONS
+     -h Print this message, then exit
+ 
+     -r Command is performed on all files or objects under the specified directory or prefix.
+     -d Displays the operations that would be performed using the specified command without actually running them.
+     -i Don’t exclude files or objects in the command that match the specified pattern.
+        See https://docs.aws.amazon.com/cli/latest/reference/s3/rm.html
```



### 1.1.8. smv

```diff
+ NAME
+     smv
+ 
+ SYNOPSIS
+     smv [-h] [-r] [-d] [-q] [-n] [-i <wildcard>] <S3SrcUri> [S3DstUri]
+ 
+ DESCRIPTION
+     Copies S3 object to another location in S3.
+ 
+ OPTIONS
+     -h Print this message, then exit
+ 
+     -r Command is performed on all files or objects under the specified directory or prefix.
+     -d Displays the operations that would be performed using the specified command without actually running them.
+     -q Does not display the operations performed from the specified command.
+     -n File transfer progress is not displayed.
```

