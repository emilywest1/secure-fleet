from python_terraform import Terraform
from config import TerraformConfig

def terraform_apply():
    tf = Terraform(working_dir=TerraformConfig.directory_path)
    return_code, stdout, stderr = tf.apply(
        TerraformConfig.tfplan_outfile, parallelism=1
    )
    print("Working on Terraform Apply")
    print(stdout)
    return return_code, stdout, stderr