from __future__ import absolute_import
from __future__ import print_function
from pathlib import Path
from verilog_parser import VerilogParser
from pdk_helpers import get_pdk_lefs_paths, get_macros
import click
import logging
import os
import sys


@click.command(
    help="""parses a verilog gatelevel netlist and
               prints the non scl instance names
               """
)
@click.option(
    "--input",
    "-i",
    required=True,
    type=click.Path(exists=True, dir_okay=False),
    help="input verilog netlist",
)
@click.option(
    "--pdk-path", required=True, type=click.Path(exists=True, file_okay=False)
)
@click.option(
    "--output",
    "-o",
    required=True,
    type=str,
    help="output file in the format each line <instance_name> <instance_type>",
)
@click.option(
    "--project-root",
    required=True,
    type=click.Path(exists=True, file_okay=False),
    help="path of the project that will be used in the finding verilog modules",
)
@click.option(
    "--macro-parent",
    required=False,
    type=str,
    default="",
    help="optional name of the parent of the macro",
)
@click.option("--debug", is_flag=True)
def main(input, output, pdk_path, project_root, macro_parent, debug=False):
    """
    Parse a verilog netlist
    """
    logging.basicConfig(format="%(asctime)s | %(module)s | %(levelname)s | %(message)s")
    logger = logging.getLogger()
    if debug:
        logger.setLevel(logging.DEBUG)
    else:
        logger.setLevel(logging.INFO)

    output_path = Path(output)
    output_path.parents[0].mkdir(parents=True, exist_ok=True)

    pdk_macros = []
    logger.info("getting pdk macros..")
    lef_paths = get_pdk_lefs_paths(pdk_path)
    for lef in lef_paths:
        pdk_macros = pdk_macros + get_macros(lef)
    logger.debug(pdk_macros)


    with open(output_path, "w") as f:
        for macro in run(input, project_root, pdk_macros, logger, macro_parent):
            f.write(macro)

def run(input, project_root, pdk_macros, logger, macro_parent=""):
    logger.info(f"parsing netlist {input} ..")
    parsed = VerilogParser(input)
    logger.info("comparing macros against pdk macros ..")

    macros = []
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
            macros += run(
                input=str(existing_netlist[0]),
                project_root=project_root,
                pdk_macros=pdk_macros,
                logger=logger,
                macro_parent=mapping_key,
            )

        macros.append(f'{instance} {macro}\n')

    return macros


sys.path.insert(0, os.path.dirname(os.path.dirname(os.path.abspath(__file__))))
if __name__ == "__main__":
    main()
