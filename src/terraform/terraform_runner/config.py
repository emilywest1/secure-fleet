from pathlib import Path

class TerraformConfig:
    base_dir = Path.cwd().parent # place terraform config files (variables, tfvars, and main.tf in terraform directory.
    directory_path = base_dir
    variables = "terraform.tfvars"
    tfplan_outfile = "tfplan"
    PLAN_ERROR = 1
    APPLY_ERROR = 2