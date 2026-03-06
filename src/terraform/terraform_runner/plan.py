from python_terraform import Terraform
from config import TerraformConfig

def terraform_plan():
    print("base dir: ", TerraformConfig.base_dir)
    print("variables location: ", TerraformConfig.directory_path)

    tf = Terraform(working_dir=TerraformConfig.directory_path)
    print("Working on Terraform Plan")
    return_code, stdout, stderr = tf.plan(
        var_file=TerraformConfig.variables,
        out=TerraformConfig.tfplan_outfile
    )

    print(stdout)
    return return_code, stdout, stderr
