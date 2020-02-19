# TODO
# Add support for pycn comparison
# Ensure cn parsers actually succeed
# Compile cpp files with gcc to make sure they can be

import os
import subprocess

from pathlib import Path

CNCBIN = '../bin/cn'
PYCNBIN = 'pycn'

ignore_chars = ' \t;\n'

t = Path('tests')
reference_dir = t / 'reference'
cnc_outdir = t / 'cnc'
pycn_outdir = t / 'pycn'

def compare_files(f, g):
    a = f.read(1)
    b = g.read(1)

    while True:
        if (not a and b in ignore_chars) or (not b and a in ignore_chars):
            return 0
        elif a in ignore_chars:
            a = f.read(1)
        elif b in ignore_chars:
            b = g.read(1)
        elif a == b:
            a = f.read(1)
            b = g.read(1)
        else:
            return 1

def compare_to_reference(fname, fscores, n):
    with open(reference_dir / fname, 'r') as reference:
        with open(cnc_outdir / fname, 'r') as f:
            fscores['cnc'][n] = compare_files(reference, f)
        #with open(pycn_outdir / fname, 'r') as f:
        #    fscores['pycn'][n] += compare_files(reference, f)



if __name__ == '__main__':
    # Index files in test_scores dir
    test_scores = {}
    for f in reversed(sorted(t.iterdir())):
        if f.is_file() and f.suffix == '.cn':
            test_scores[f] = {'cnc': [0,0,0], 'pycn': [-1,-1,-1]}

    if not cnc_outdir.exists():
        cnc_outdir.mkdir()
    if not pycn_outdir.exists():
        pycn_outdir.mkdir()

    # Calculate initial spacing for prettiness
    s = max([len(n.name) for n in test_scores]) + 4
    results = ' ' * s + 'cnc  pycn\n'

    compiler_errors = b''
    for tf in test_scores.keys():
        results += f'{tf.name}:' + ' ' * (s - len(tf.name) - 1)

        cpp = tf.with_suffix('.cpp').name
        hpp = tf.with_suffix('.hpp').name

        # Parse .cn file
        # TODO Ensure these didn't fail

        # cnc
        # TODO cn util does not currently support giving an output dir
        # For now, move the file into proper dir
        subprocess.call(f'{CNCBIN} {str(tf)}', shell=True)
        os.replace(str(t / hpp), str(cnc_outdir / hpp))
        os.replace(str(t / cpp), str(cnc_outdir / cpp))

        try:
            subprocess.check_output(f'g++ -fsyntax-only {cnc_outdir / cpp}',
                                    stderr=subprocess.STDOUT,
                                    shell=True)
        except subprocess.CalledProcessError as e:
            compiler_errors += e.output
            test_scores[tf]['cnc'][0] = 1

        # pycn
        #subprocess.call(f'python {PYCNBIN} {str(tf)}', shell=True)

        compare_to_reference(hpp, test_scores[tf], 1)
        compare_to_reference(cpp, test_scores[tf], 2)


        for score in test_scores[tf]['cnc']:
            results += str(score)
        results += '  '
        for score in test_scores[tf]['pycn']:
            results += str(score)
        results += '\n'

    print(results)
    print(compiler_errors.decode())
