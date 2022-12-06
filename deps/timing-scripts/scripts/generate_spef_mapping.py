from pathlib import Path
from verilog_parser import VerilogParser
from pdk_helpers import get_macros, get_pdk_lefs_paths
import click
import logging


@click.command(
    help="""parses a verilog gatelevel netlist and creates a
               spef mapping file for non pdk macros. the file is used
               along with the other scripts in the repo for proper parasitics annotation 
               during sta"""
)
@click.option(
    "--input",
    "-i",
    required=True,
    type=click.Path(exists=True, dir_okay=False),
    help="input verilog netlist",
)
@click.option(
    "--project-root",
    required=True,
    type=click.Path(exists=True, file_okay=False),
    help="path of the project that will be used in the output spef mapping file and finding verilog modules",
)
@click.option(
    "--output", "-o", required=True, type=str, help="spef mapping tcl output file"
)
@click.option(
    "--pdk-path", required=True, type=click.Path(exists=True, file_okay=False)
)
@click.option(
    "--macro-parent",
    required=False,
    type=str,
    default="",
    help="optional name of the parent of the macro",
)
@click.option("--debug", is_flag=True)
def main(input, project_root, output, pdk_path, macro_parent, debug=False):
    """
    Parse a verilog netlist
    """
    output_path = Path(output)
    output_path.parents[0].mkdir(parents=True, exist_ok=True)
    logging.basicConfig(format="%(asctime)s | %(module)s | %(levelname)s | %(message)s")
    logger = logging.getLogger()
    if debug:
        logger.setLevel(logging.DEBUG)
    else:
        logger.setLevel(logging.INFO)

    logger.info(f"using project_root {project_root}")

    pdk_macros = []
    logger.info("getting pdk macros ..")
    lef_paths = get_pdk_lefs_paths(pdk_path)
    for lef in lef_paths:
        pdk_macros = pdk_macros + get_macros(lef)
    logger.debug(f"pdk has {len(pdk_macros)} macros")

    with open(output_path, "w") as f:
        for mapping in run(input, project_root, pdk_macros, logger, macro_parent):
            logging.debug(mapping)
            f.write(mapping)

    logger.info(f"wrote to {output_path}")


def run(input, project_root, pdk_macros, logger, macro_parent=""):
    logger.info(f"parsing netlist {input} ..")
    parsed = VerilogParser(input)
    logger.info("comparing macros against pdk macros ..")
    postfix = ".$::env(RCX_CORNER).spef"

    mappings = []
    non_pdk_instance = []
    for instance in parsed.instances:
        macro = parsed.instances[instance]
        if macro not in pdk_macros:
            logging.debug(f"{macro} not found in pdk_macros")
            non_pdk_instance.append(instance)

    logging.debug(f"# of non pdk instances {len(non_pdk_instance)}")
    # recursion will break if above is zero
    for instance in non_pdk_instance:
        macro = parsed.instances[instance]
        mapping_key = instance
        hier_separator = "/"
        if macro_parent != "":
            mapping_key = f"{macro_parent}{hier_separator}{instance}"

        existing_netlist = list(
            (Path(project_root) / "verilog" / "gl").rglob(f"{macro}.v")
        )
        if len(existing_netlist) == 1:
            logging.info(f"found netlist {str(existing_netlist[0])} for macro {macro}")
            mappings += run(
                input=str(existing_netlist[0]),
                project_root=project_root,
                pdk_macros=pdk_macros,
                logger=logger,
                macro_parent=mapping_key,
            )

        spef_dir = Path(project_root) / "signoff" / "not-found"
        for macro_spef_file in (Path(project_root) / "signoff").rglob(f"{macro}*.spef"):
            spef_dir = macro_spef_file.parent
            logging.debug(f"found {macro_spef_file} for {macro}")
        spef_rel_dir = spef_dir.relative_to(project_root)
        macro_spef = f"$::env(PROJECT_ROOT)/{spef_rel_dir}/{macro}{postfix}"
        mappings.append(f'set spef_mapping({mapping_key}) "{macro_spef}"\n')

    return mappings


# sys.path.insert(0, os.path.dirname(os.path.dirname(os.path.abspath(__file__))))
if __name__ == "__main__":
    main()
