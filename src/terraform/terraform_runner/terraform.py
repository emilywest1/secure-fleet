import subprocess
import json
import sys
import os

sys.path.append(os.path.dirname(os.path.abspath(__file__)))

from config import TerraformConfig
from plan import terraform_plan
from apply import terraform_apply

def main():
    plan_return_code, plan_stdout, plan_stderr = terraform_plan()
    if plan_return_code == TerraformConfig.PLAN_ERROR:
        print("[ERROR] Terraform Plan:", plan_stderr)
        return 1
    apply_return_code, apply_stdout, apply_stderr = terraform_apply()
    if apply_return_code == TerraformConfig.APPLY_ERROR:
        print("[ERROR] Terraform Plan:", plan_stderr)
        return 1
    print("[SUCCESS]")
    return 0


def get_terraform_outputs():
    result = subprocess.run(
        ["terraform", "output", "-json"],
        cwd=TerraformConfig.directory_path,
        capture_output=True,
        text=True
    )

    data = json.loads(result.stdout)
    vm_ids = data["vm_names"]["value"]
    ips = data["nodes_ips"]["value"]

    vms = {}
    for name, vm_id in vm_ids.items():
        vms[name] = {
            "vm_id": vm_id,
            "ip": ips["control"] if name == "control" else ips["nodes"].get(name)
        }

    return vms


if __name__ == "__main__":
    main()
    print(get_terraform_outputs())