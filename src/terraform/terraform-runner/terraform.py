from python_terraform import *
from pathlib import Path
import os

class TerraformConfig:
    base_dir = Path(__file__).resolve().parent
    directory = "terraform"
    directory_path = os.path.relpath(directory, base_dir)
    variables = "terraform.tfvars"
    tfplan_outfile = "tfplan"
    PLAN_ERROR = 1

def main():
    print("base dir: ", TerraformConfig.base_dir)
    print("variables location: ", TerraformConfig.directory_path)
    tf = Terraform(working_dir=TerraformConfig.directory_path)
    print("Working on Terraform Plan")
    return_code, stdout, stderr = tf.plan(var_file=TerraformConfig.variables, out=TerraformConfig.tfplan_outfile)

    if return_code == TerraformConfig.PLAN_ERROR:
        print("[ERROR] Terraform Plan:", stderr)

    else:
        print(stdout)
        return_code, stdout, stderr = tf.apply(TerraformConfig.tfplan_outfile, parallelism=1)
        print("Working on Terraform Apply")
        print("return code: ", return_code)
        print("stdout: ", stdout)
        print("stderr: ", stderr)
    return 0

if __name__ == "__main__":
    main()
    print("Done with Terraform Apply")