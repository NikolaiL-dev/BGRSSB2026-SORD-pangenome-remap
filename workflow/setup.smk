from pathlib import Path

ROOT = Path(workflow.snakefile).parent.parent.resolve()
ENVS = str(ROOT.joinpath("envs")).rstrip('/')
REFERENCE = str(ROOT.joinpath("reference")).rstrip('/')

configfile: ROOT.joinpath("config", "setup.yaml")

rule all:
    input: 
        ENVS + "/aws.sif",
        ENVS + "/vg.sif",
        ENVS + "/version.yaml",
        REFERENCE + f"/{config["resources"]["chr15.vg"].split('/')[-1]}"

rule get_hprc_chr15:
    input: ENVS + "/aws.sif"
    params: config["resources"]["chr15.vg"]
    container: ENVS + "/aws.sif"
    output: REFERENCE + '/' + Path(config['resources']['chr15.vg']).name

    shell:
        """
        aws s3 cp {params} {output} --checksum-mode ENABLED --no-sign-requestz
        """

rule build_container_images:
    output:
        aws_sif = ENVS + "/aws.sif",
        vg_sif = ENVS + "/vg.sif",
        version = ENVS + "/version.yaml"

    params:
        aws_hub = config["containers"]["awscli"]['dockerhub'],
        aws_digest = config["containers"]["awscli"]['digest'],
        aws_version = config["containers"]["awscli"]['version'],
        vg_hub = config["containers"]["vg"]['dockerhub'],
        vg_digest = config["containers"]["vg"]['digest'],
        vg_version = config["containers"]["vg"]['version']

    shell:
        """
        singularity pull {output.aws_sif} {params.aws_hub}{params.aws_digest}
        echo "aws : {params.aws_version}" >> {output.version}
        singularity pull {output.vg_sif} {params.vg_hub}{params.vg_digest}
        echo "vg : {params.vg_version}" >> {output.version}
        """