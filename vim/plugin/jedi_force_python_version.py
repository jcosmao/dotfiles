#!/usr/bin/env python

import json
import subprocess
import vim


def jedi_force_python_version():
    try:
        debug = int(vim.eval("g:jedi_debug"))
    except Exception:
        debug = None

    try:
        # get python2 sys.path (wether we are in pyton2 or 3)
        output = subprocess.check_output(
            'python2 -c "import sys; import json; print(json.dumps(sys.path))"',
            stderr=subprocess.STDOUT,
            shell=True,
            universal_newlines=True,
        )
        py2_sys_path = json.loads(output)
        py2_sys_path.remove('')
        current_file_path = vim.eval("expand('%:p:h')")

        for python_path in py2_sys_path:
            if python_path in current_file_path:
                # we are in a python2 dir
                vim.command("let g:jedi#force_py_version = 2")
                if debug == 1:
                    print("JEDI version forced to python2 - {} in {}".format(
                          python_path, current_file_path))
                return
    except Exception:
        pass

    # Default behavior
    if debug == 1:
        print("JEDI version forced to 'auto'")
    vim.command("let g:jedi#force_py_version = 'auto'")
