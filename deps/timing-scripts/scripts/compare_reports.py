#!/usr/bin/env python3
import click

from report import Report


@click.command(
    help="""
               attempts to compare two sta reports 
               """
)
@click.option("--first", "-f", required=True, type=str)
@click.option("--first-label", default="first", type=str)
@click.option("--second-label", default="second", type=str)
@click.option("--second", "-s", required=True, type=str)
@click.option("--output", "-o", required=True, type=str)
def main(first, second, output, first_label, second_label):
    first_report = Report(first)
    second_report = Report(second)

    print(f"{first_label} {len(first_report.paths)}")
    print(f"{second_label} {len(second_report.paths)}")
    f_output = open(output, "w+")
    f_first_diff = open(f"{first}.diff", "w+")
    f_second_diff = open(f"{second}.diff", "w+")
    header = (
        f"start,end,group,type,{first_label},{second_label},"
        f"required_first,required_second,first-second,percent"
    )
    f_output.write(f"{header}\n")

    matches_count = 0
    b = 0
    c = 0

    for first_path in first_report.paths:
        if first_path in second_report.paths:
            matches = [
                element for element in second_report.paths if first_path == element
            ]
            if len(matches) == 1:
                matches_count += 1
                second_path = matches[0]
                delta = first_path.slack - second_path.slack
                percent = delta / first_path.slack * 100.0
                path_summary = (
                    f"{first_path.start_point},{first_path.end_point},"
                    f"{first_path.path_group},"
                    f"{first_path.path_type},"
                    f"{first_path.slack:.4f},"
                    f"{second_path.slack:.4f},"
                    f"{first_path.required_time:.4f},"
                    f"{second_path.required_time:.4f},"
                    f"{delta:.4f},{percent:.2f}%"
                )
                f_output.write(f"{path_summary}\n")

                f_first_diff.write(f"{first_path.start_point}\n")
                f_first_diff.write(f"{first_path.end_point}\n")
                f_first_diff.write(f"{first_path.path}\n")
                f_second_diff.write(f"------------\n")

                f_second_diff.write(f"{second_path.start_point}\n")
                f_second_diff.write(f"{second_path.end_point}\n")
                f_second_diff.write(f"{second_path.path}\n")
                f_second_diff.write(f"------------\n")
            elif len(matches) > 1:
                b += 1
            # print(
            # f"{path.start_point},{path.end_point},{path.path_group},{path.path_type},{path.slack}"
            # )
        else:
            c += 1

    f_output.close()
    f_first_diff.close()
    f_second_diff.close()
    print("matches:", matches_count)
    print("non unique matches:", b)
    print("unmatched:", c)
    print("done")


if __name__ == "__main__":
    main()
