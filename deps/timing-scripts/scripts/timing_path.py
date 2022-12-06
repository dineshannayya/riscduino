import textwrap
import re


class TimingPath:
    def __init__(self, start_point, end_point, path_group, path_type, path):
        self.start_point = start_point
        self.end_point = end_point
        self.path_group = path_group
        self.path_type = path_type
        self.path = path
        self.category = ""
        self.slack = None
        self.edges = ""
        self.required_time = None
        self.arrival_time = None
        self.find_category()
        self.simplify_points()
        self.find_slack()
        self.find_required()
        self.find_arrival()
        self.id = self.start_point + self.end_point + self.path_group + self.path_type

    def find_required(self):
        for line in self.path.split("\n"):
            if "required time" in line:
                self.required_time = float(re.findall(
                    r"[+-]? *(?:\d+(?:\.\d*)?|\.\d+)(?:[eE][+-]?\d+)?", line
                )[0].strip())
                break

    def find_arrival(self):
        for line in self.path:
            if "arrival time" in line:
                self.arrival_time = float(re.findall(
                    r"[+-]? *(?:\d+(?:\.\d*)?|\.\d+)(?:[eE][+-]?\d+)?", line
                )[0].strip())
                break

    def find_edges(self):
        split_path = self.path.split("\n")
        edge = "f"
        for line in split_path:
            if "^" in line or " r" in line:
                edge = "r"
                self.edges = self.edges + edge
            elif "v" in line or " f" in line:
                edge = "f"
                self.edges = self.edges + edge
            elif "data arrival time" in line:
                break

    def simplify_points(self):
        if len(self.start_point.split()) > 1:
            self.start_point = self.start_point.split()[0]
        if len(self.end_point.split()) > 1:
            self.end_point = self.end_point.split()[0]

    @classmethod
    def get_header(cls):
        start_point = "start_point"
        end_point = "end_point"
        group = "group"
        type = "type"
        slack = "slack"
        return f"{start_point},{end_point},{group},{type},{slack}\n"

    def find_slack(self):
        slack = ""
        for line in self.path.splitlines():
            if "slack" in line:
                slack = textwrap.dedent(line)
                break
        self.slack = re.findall(
            r"[+-]? *(?:\d+(?:\.\d*)?|\.\d+)(?:[eE][+-]?\d+)?", slack
        )[0].strip()
        self.slack = float(self.slack)

    def summarize(self):
        slack_value = self.slack
        group = self.path_group
        type = self.path_type
        start_point = self.start_point
        end_point = self.end_point
        return f"{start_point},{end_point},{group},{type},{slack_value:.4f}\n"

    def find_category(self):
        start = ""
        end = ""
        if "input" in self.start_point:
            start = "input"
        else:
            start = "flipflop"
        if "output" in self.end_point:
            end = "output"
        else:
            end = "flipflop"

        self.category = f"{start}-{end}"

    def __eq__(self, other):
        return self.id == other.id

    def __str__(self):
        return f"""
Startpoint: {self.start_point}
Endpoint: {self.end_point}
Path group: {self.path_group}
Path type: {self.path_type}
Path:
{self.path}
"""
