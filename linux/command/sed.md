# How to use `sed` linux

1. Add a new line at line i th in a file:

```bash
sed -i 'i\Content' filename
```
Example
```bash
$ cat test.txt
line1
line2
line3
line4
line5
```