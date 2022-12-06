from pyverilog.vparser.parser import parse

class VerilogParser():
    def __init__(self, verilog_netlist):
        self.verilog_netlist = [verilog_netlist]
        ast, _ = parse(self.verilog_netlist)
        top_definition = None
        self.instances = {}

        for definition in ast.description.definitions:
            def_type = type(definition).__name__
            if def_type == "ModuleDef":
                top_definition = definition

        # Loop over each node under the top module definition
        for item in top_definition.items:
            item_type = type(item).__name__
            if item_type == "InstanceList":  # Module instances
                instance = item.instances[0]
                self.instances[instance.name] = instance.module
