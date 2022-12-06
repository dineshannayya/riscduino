from typing import List
import os

def get_pdk_lefs_paths(pdk_path: str) -> List[str]:
    lef_paths = []
    for root, dirs, files in os.walk(pdk_path):
        for file in files:
            filename, file_extension = os.path.splitext(f"{file}")
            if file_extension == ".lef":
                lef_paths.append(f"{root}/{file}")
    return lef_paths


def get_macros(lef_file: str) -> List[str]:
    macros = []
    with open(lef_file) as f:
        for line in f.readlines():
            if "MACRO" in line:
                macro_name = line.split()[1]
                macros.append(macro_name)
    return macros
