from python_terraform import Terraform
from .config import TerraformConfig

def run_plan():
    print("base dir: ", TerraformConfig.base_dir)
    print("variables location: ", TerraformConfig.directory_path)

    tf = Terraform(working_dir=TerraformConfig.directory_path)
    print("Working on Terraform Plan")
    return_code, stdout, stderr = tf.plan(
        var_file=TerraformConfig.variables,
        out=TerraformConfig.tfplan_outfile
    )

    if return_code == TerraformConfig.PLAN_ERROR:
        print("[ERROR] Terraform Plan:", stderr)
        return 1

    print(stdout)
    return_code, stdout, stderr = tf.apply(
        TerraformConfig.tfplan_outfile, parallelism=1
    )
    print("Working on Terraform Apply")
    print("return code: ", return_code)
    print("stdout: ", stdout)
    print("stderr: ", stderr)
    return 0