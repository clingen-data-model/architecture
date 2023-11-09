# Underlying command we're replicating:
# SEQREPO_ROOT_DIR=/Users/kferrite/dev/biocommons.seqrepo/seqrepo/2021-01-29
# GENE_NORM_DB_URL='http://localhost:8000'
# UTA_DB_URL="postgresql://uta_admin:uta_pw@localhost:5432/uta/uta_20210129"
# bash -c
# 'python -c "import cool_seq_tool" && uvicorn variation.main:app --workers 10 --port 8002 --host 0.0.0.0'

# Example command for this script:
# SEQREPO_ROOT_DIR=~/dev/biocommons.seqrepo/seqrepo/2021-01-29 GENE_NORM_DB_URL='http://localhost:8000' UTA_DB_URL="postgresql://uta_admin:uta_pw@localhost:5432/uta/uta_20210129" python start_servers.py 8010,8011,8012,8013,8014,8015,8016,8017,8018,8019 nginx-varnorm-generated.conf


import sys
import os
import time
import subprocess
import signal


processes = []


def start_on_port(port, host="0.0.0.0"):
    print(f"Starting uvicorn on {host}:{port}")
    p = subprocess.Popen(["uvicorn", "variation.main:app",
                          "--workers", "1",
                          "--port", str(port),
                          "--host", host],
                         env=os.environ.copy())
    processes.append({
        "process": p,
        "port": port,
        "host": host
    })
    return {"host": host, "port": port}


def generate_nginx_conf(template_filename: str,
                        start_params: dict,
                        server_tmpl="{{server_list}}") -> str:
    """
    Replaces the template string in the template filename with
    newline delimited nginx server lines.
    """
    server_lines = [f'server {sp["host"]}:{sp["port"]};'
                    for sp in start_params]
    print(f"server_lines: {server_lines}")
    with open(template_filename, encoding="UTF-8") as f:
        contents = f.read()
        padded_lines = [str((" " * 8) + s) for s in server_lines]
        return contents.replace(server_tmpl,
                                str("\n".join(padded_lines)))


def write_nginx_conf(template_filename: str,
                     output_filename: str,
                     start_params: dict) -> str:
    with open(output_filename, "w", encoding="UTF-8") as fout:
        fout.write(generate_nginx_conf(template_filename, start_params))


def main(argv):
    """
    ./start_servers.py 1000,1001,1002 output-nginx-filename.conf
    """
    global processes
    ports_csv = argv[1]
    ports = ports_csv.split(",")
    print(f"ports: {ports}")

    start_params = [{"port": p, "host": "127.0.0.1"} for p in ports]
    nginx_params = [{"port": p, "host": "127.0.0.1"} for p in ports]
    nginx_filename = argv[2]
    write_nginx_conf("varnorm-nginx-template.conf",
                     nginx_filename,
                     nginx_params)
    print(f"Wrote nginx conf: {nginx_filename}")

    for sp in start_params:
        print(f"sp: {sp}")
        start_on_port(**sp)

    last_printed_success_time = time.time()
    printed_this_time = False

    while len([p for p in processes if p["process"].returncode is None]) > 0:
        need_to_restart = []
        for p in processes:
            proc = p["process"]
            host = p["host"]
            port = p["port"]
            returncode = proc.poll()
            if returncode is None:
                # Still running
                # print still running status only after 5 min
                if time.time() - last_printed_success_time >= 60*5:
                    printed_this_time = True
                    print(f"Process {proc.pid} on {host}:{port} still running")
            else:
                print(f"Process {proc.pid} on {host}:{port} has terminated "
                      f"with status code {returncode}")
                # Remove P, and start again. start_on_port appends it back
                need_to_restart.append(p)
        for p in need_to_restart:
            host = p["host"]
            port = p["port"]
            print(f"Restarting dead worker on {host}:{port}")
            processes.remove(p)
            start_on_port(port, host)
        if printed_this_time:
            last_printed_success_time = time.time()
            printed_this_time = False
        time.sleep(5)


def sigint_handler(sig, frame):
    print("SIGINT handler")
    not_stopped = [p for p in processes if p["process"].returncode is None]
    while len(not_stopped) > 0:
        print("Waiting for ({}/{}) processes: {}".format(
            len(not_stopped), len(processes),
            str([p["process"].pid for p in not_stopped])))
        for p in not_stopped:
            try:
                p["process"].wait(timeout=1)
            except subprocess.TimeoutExpired:
                print(f"Process {p['process'].pid} not yet finished")
            if p["process"].returncode:
                print(f"Process on {p['host']}:{p['port']} terminated")
        not_stopped = [p for p in processes if p["process"].returncode is None]
        time.sleep(5)
        print()


signal.signal(signal.SIGINT, sigint_handler)


if __name__ == "__main__":
    main(sys.argv)
