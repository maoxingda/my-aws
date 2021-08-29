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
+     scd [-h | [S3Uri]]
+
+   sls -h
+     Usage:
+     sls [-h | [S3Uri]]
```



Usage:

> command -h 

> e.g. scd -h or sls -h etc.

### 1.1.1. <font color=red>spwd</font>

> print working directory

### 1.1.2. <font color=red>sdb</font>

> set -vx & set +vx option for command

### 1.1.3. <font color=red>sls</font>

> implementation for `aws s3 ls`

### 1.1.4. <font color=red>scd</font>

> auxiliary command, emulate for system command cd

### 1.1.5. <font color=red>sul</font>

> implementation for `aws s3 cp <LocalPath> <S3Uri>`

### 1.1.6. <font color=red>sdl</font>

> implementation for `aws s3 cp <S3Uri> <LocalPath>`

### 1.1.7. <font color=red>smv</font>

> implementation for `aws s3 mv <S3Uri> [S3Uri]`

### 1.1.8. <font color=red>srm</font>

> implementation for `aws s3 rm <S3Uri>`