import argparse
import subprocess
import os
import requests
import re

def parse_args():
    parser = argparse.ArgumentParser(description='Update Terraform deployment image version and create a PR.')
    parser.add_argument('-i', '--image', required=True, help='Image to use in deployment')
    return parser.parse_args()

def update_tfvars(image):
    tfvars_file = 'terraform.tfvars'
    with open(tfvars_file, 'r') as file:
        lines = file.readlines()
    with open(tfvars_file, 'w') as file:
        for line in lines:
            if 'image' in line:
                line = f'image = "{image}"\n'
            file.write(line)

def run_terraform_command(command):
    result = subprocess.run(["terraform", command], capture_output=True, text=True)
    return result.stdout if result.returncode == 0 else None

def extract_plan_summary(plan_output):
    clean_output = re.sub(r'\x1b\[.*?m', '', plan_output)
    lines = clean_output.split('\n')
    summary_lines = [line for line in lines if 'Plan:' in line]
    return ' '.join(summary_lines)

def git_operations(branch_name):
    if not subprocess.run(["git", "branch", "--list", branch_name], capture_output=True, text=True).stdout.strip():
        subprocess.run(["git", "checkout", "-b", branch_name], check=True)
    # limit devlopers what to update- it could be more than just terraform.tfvars in the future
    subprocess.run(["git", "add", "terraform.tfvars"], check=True)

def git_commit_and_push(branch_name, image, plan_summary):
    commit_message = f"Update image to {image}. Terraform Plan: {plan_summary}"
    try:
        subprocess.run(["git", "commit", "-m", commit_message], check=True)
        subprocess.run(["git", "push", "--set-upstream", "origin", branch_name], check=True)
        print("Changes pushed to GitHub.")
    except subprocess.CalledProcessError as e:
        print(f"Failed to push changes to GitHub: {e}")

def create_pull_request(branch_name, token):
    url = "https://api.github.com/repos/{owner}/{repo}/pulls".format(owner="kennedy-whytech", repo="resume-tf")
    headers = {
        "Authorization": f"token {token}",
        "Content-Type": "application/json"
    }
    data = {
        "title": f"Updated image version",
        "head": branch_name,
        "base": "main",
        "body": "This PR updates the Docker image version in terraform.tfvars."
    }
    response = requests.post(url, headers=headers, json=data)
    if response.status_code == 201:
        print(f"Pull request created: {response.json()['html_url']}")
    else:
        print(f"Failed to create pull request: {response.content}")

def main():
    args = parse_args()
    update_tfvars(args.image)

    print("Running 'terraform plan'...")
    plan_output = run_terraform_command("plan")
    print(plan_output)
    if plan_output:
        plan_summary = extract_plan_summary(plan_output)
        confirm = input("Do you want to create a PR with these changes? (yes/no): ")
        if confirm.lower() == 'yes':
            branch_name = f"staging"
            git_operations(branch_name)
            git_commit_and_push(branch_name, args.image, plan_summary)
            create_pull_request(branch_name, os.getenv('GITHUB_TOKEN'))
        else:
            print("Operation canceled.")
    else:
        print("Terraform plan failed.")

if __name__ == "__main__":
    main()
