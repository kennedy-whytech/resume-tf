import argparse
import subprocess
import re

def parse_args():
    parser = argparse.ArgumentParser(description='Update Terraform deployment image version.')
    parser.add_argument('-i', '--image', required=True, help='Image to use in deployment')
    return parser.parse_args()

def update_tfvars(image):
    tfvars_file = 'terraform.tfvars' 
    
    with open(tfvars_file, 'r') as file:
        lines = file.readlines()

    with open(tfvars_file, 'w') as file:
        for line in lines:
            if 'image' in line:
                # Replace the version after the image base name
                line = f'image = "{image}"\n'
            file.write(line)

def run_terraform_command(command):
    result = subprocess.run(["terraform", command], capture_output=True, text=True)
    print(result.stdout)
    if result.stderr:
        print(result.stderr)
    return result.returncode == 0

def main():
    args = parse_args()

    update_tfvars(args.image)

    print("Running 'terraform plan'...")
    if not run_terraform_command("plan"):
        print("Terraform plan failed.")
        return

    confirm = input("Do you want to apply these changes? (yes/no): ")
    if confirm.lower() == 'yes':
        print("Running 'terraform apply'...")
        if not run_terraform_command("apply"):
            print("Terraform apply failed.")
        else:
            print("Terraform apply succeeded.")
    else:
        print("Operation canceled.")

if __name__ == "__main__":
    main()
