- [1. aws:zzz:](#1-awszzz)
  - [1.1. commands](#11-commands)
    - [1.1.1. <font color=red>spwd</font>](#111-font-colorredspwdfont)
    - [1.1.2. <font color=red>sdb</font>](#112-font-colorredsdbfont)
    - [1.1.3. <font color=red>sls</font>](#113-font-colorredslsfont)
    - [1.1.4. <font color=red>scd</font>](#114-font-colorredscdfont)
    - [1.1.5. <font color=red>sul</font>](#115-font-colorredsulfont)
    - [1.1.6. <font color=red>sdl</font>](#116-font-colorredsdlfont)
    - [1.1.7. <font color=red>smv</font>](#117-font-colorredsmvfont)
    - [1.1.8. <font color=red>srm</font>](#118-font-colorredsrmfont)

# 1. aws:zzz:

My aws s3 command line interface, just as an aid to myself.

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



### 1.1.1. <font color=red>spwd</font>

```diff
+ print working directory
```



### 1.1.2. <font color=red>sdb</font>

```diff
+ set -vx & set +vx option for command
```



### 1.1.3. <font color=red>scd</font>

```diff
+ Usage:
+     scd [-h | [S3Uri]]
```

### 1.1.4. <font color=red>sls</font>

```diff
+ Usage:
+     sls [-h] [-r] [S3Uri]
```



### 1.1.5. <font color=red>sul</font>

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



### 1.1.6. <font color=red>sdl</font>

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



### 1.1.7. <font color=red>srm</font>

```diff
+ Usage:
+     srm [-h] [-r] [-d] [-i <wildcard>] <S3Uri>
+ 
+     -h Print this message, then exit
+ 
+     -r Command is performed on all files or objects under the specified directory or prefix.
+     -d Displays the operations that would be performed using the specified command without actually running them.
+     -i Don’t exclude files or objects in the command that match the specified pattern.
+        See https://docs.aws.amazon.com/cli/latest/reference/s3/rm.html
```



### 1.1.8. <font color=red>smv</font>

```diff
+ NAME
+     smv
+ 
+ SYNOPSIS
+     smv [-h] [-r] [-d] [-q] [-n] [-i <wildcard>] <S3SrcUri> [S3SrcUri]
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

