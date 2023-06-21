#!/usr/bin/env python3

"""Benchmark executor for SPECFEM3D

Usage:
   ./this_script -h

"""


import sys
import argparse
from cartesian import cartesian as ca


def main():
    parser = argparse.ArgumentParser(
        description='SPECFEM3D benchmark problems executor')

    subparsers = parser.add_subparsers(help='Benchmark')

    cart_parse = subparsers.add_parser('cartesian')
    cart_parse = ca.create_parser(cart_parse)
    cart_parse.set_defaults(func=ca.run)

    args = parser.parse_args()
    if len(sys.argv) <= 1:
        parser.print_help()
        sys.exit(1)

    args.func(args)


if __name__ == '__main__':
    main()
