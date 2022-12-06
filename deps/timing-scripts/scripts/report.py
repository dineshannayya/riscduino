from timing_path import TimingPath


class Report:
    def __init__(self, report_file):
        self.report_file = report_file
        self.paths = []
        self.input_output_paths = []
        self.input_flipflop_paths = []
        self.flipflop_flipflop_paths = []
        self.flipflop_output_paths = []
        self.build_db()
        self.classify_paths()

    def classify_paths(self):
        for path in self.paths:
            path_category = path.category
            if path_category == "input-output":
                self.input_output_paths.append(path)
            elif path_category == "input-flipflop":
                self.input_flipflop_paths.append(path)
            elif path_category == "flipflop-flipflop":
                self.flipflop_flipflop_paths.append(path)
            elif path_category == "flipflop-output":
                self.flipflop_output_paths.append(path)

    def build_db(self):
        file = open(self.report_file)
        start_point = end_point = path_group = path_values = ""

        line = file.readline()
        while line != "":
            line = line.strip()
            if "Startpoint" in line:
                x = file.tell()
                start_point = " ".join(line.split(" ")[1:])
                line2 = file.readline()
                if "Endpoint" not in line2:
                    start_point += line2
                else:
                    file.seek(x)
            elif "Endpoint" in line:
                x = file.tell()
                end_point = " ".join(line.split(" ")[1:])
                line2 = file.readline()
                if "Path Group" not in line2:
                    end_point += line2
                else:
                    file.seek(x)
            elif "Path Group" in line:
                path_group = line.split(" ")[2]
            elif "Path Type" in line:
                path_type = line.split(" ")[2]

                path_line = file.readline()
                while path_line != "":
                    if "Startpoint" in path_line:
                        path_object = TimingPath(
                            start_point=start_point.rstrip(),
                            end_point=end_point.rstrip(),
                            path_group=path_group.rstrip(),
                            path_type=path_type,
                            path=path_values,
                        )
                        self.paths.append(path_object)

                        path_line = path_line.strip()
                        start_point = " ".join(path_line.split(" ")[1:])
                        x = file.tell()
                        line2 = file.readline()
                        if "Endpoint" not in line2:
                            start_point += line2
                        else:
                            file.seek(x)

                        path_values = ""
                        break
                    else:
                        path_values += path_line
                    path_line = file.readline()
            line = file.readline()

        file.close()
