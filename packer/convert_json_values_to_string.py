import json
import argparse, sys

parser=argparse.ArgumentParser()

parser.add_argument('--file', help='JSON File to convert',type=str,required=True)
args=parser.parse_args()


with open(args.file,mode="r") as f:
    print(f"Loading file: - {args.file}")
    data = json.load(f)
    print(f"Original data:\n{data}")

print("Converting file...")
for key,value in data.items():
    data[key]=str(value)
print(f"Converted data:\n{data}")

with open(args.file, mode="w") as f:
    print(f"Overwrite file: - {args.file}")
    json.dump(data,f)