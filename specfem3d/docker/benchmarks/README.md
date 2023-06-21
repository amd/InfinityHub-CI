# Synopsis

Convenience functions for running benchmark examples with two GPUs.

# Requirements

- python 3

# Usage

View help menu

```bash
python3 main.py -h
```

Example

```bash
python3 main.py cartesian -h

python3 main.py cartesian -c 0 -g 2 -s 288x256 -o /tmp/out --mpi-args='--report-bindings'
```
