from imports import *

class TerraformConfig:
    base_dir = Path(__file__).resolve().parent
    directory = "terraform"
    directory_path = os.path.relpath(directory, base_dir)
    variables = "terraform.tfvar"
    tfplan_outfile = "tfplan"
    PLAN_ERROR = 1
    
# python3 -m venv venv
# source venv/bin/activate

def main():
    print("base dir: ", TerraformConfig.base_dir)
    print("variables location: ", TerraformConfig.directory_path)
    tf = Terraform(working_dir=TerraformConfig.directory_path)
    return_code, stdout, stderr = tf.plan(var_file=TerraformConfig.variables, out=TerraformConfig.tfplan_outfile)

    if return_code == TerraformConfig.PLAN_ERROR:
        print("PLAN ERROR:", stderr)

    else:
        print(stdout)
        return_code, stdout, stderr = tf.apply(TerraformConfig.tfplan_outfile)
        print("return code: ", return_code)
        print("stdout: ", stdout)
        print("stderr: ", stderr)




if __name__ == "__main__":
    main()