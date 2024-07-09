import os
import subprocess
import threading
import time
import shutil
import sys


global exit_flag
exit_flag = False
current_dir = os.path.dirname(os.path.realpath(__file__))
folder_path = os.path.join(os.environ["HOME"], "Drive")
logs_folder_path = os.path.join(folder_path, "logs")
if not os.path.exists(logs_folder_path):
    os.makedirs(logs_folder_path)
completed_functions_file = os.path.join(folder_path, "completed_functions.txt")


function_info = {
    "wifi": ("wifi/wifi.sh", True),
    # "create_users": ("create_users/create_users.sh", False),
    "system": ("system/system.sh", True),
    "softwares": ("softwares/softwares.sh", True),
    "bootloader": ("bootloader/bootloader.sh", True),
    "themes": ("themes/themes.sh", True),
    "icons": ("icons/icons.sh", True),
    "cursors": ("cursors/cursors.sh", True),
    "fonts": ("fonts/fonts.sh", True),
    "gdms": ("gdms/gdms.sh", True),
    "custom_users": ("custom_users/custom_users.sh", True),
    "clean_data": ("clean_data/clean_data.sh", True),
}


def create_function(func_name, func_info, contains_exit):
    code = f"""
def {func_name}(returncode):
    path = os.path.join(current_dir, "{func_info}")
    result = subprocess.run(["bash", path])
    if {contains_exit}:
        global exit_flag
        exit_flag = True
    returncode[0] = result.returncode
"""
    exec(code, globals())


def run(func_name, notification):
    character = [
        "\033[1m\033[31m⣾\033[0m",
        "\033[1m\033[32m⣷\033[0m",
        "\033[1m\033[33m⣯\033[0m",
        "\033[1m\033[34m⣟\033[0m",
        "\033[1m\033[35m⡿\033[0m",
        "\033[1m\033[36m⢿\033[0m",
        "\033[1m\033[37m⣻\033[0m",
        "\033[1m\033[38m⣽\033[0m",
    ]
    returncode = [None]
    count_thread = threading.Thread(target=globals()[func_name], args=(returncode,))
    count_thread.start()
    while not exit_flag:
        for i in character:
            print(f"\r\033[33m{notification}\033[0m{i} ", end="")
            time.sleep(0.1)
    count_thread.join()
    if returncode[0] == 0:
        print(f"\r\033[32m{notification}Done\033[0m")
    else:
        print(
            f"\r\033[31m{notification}Error, please see in {logs_folder_path}/{func_name}.log and {current_dir}/{func_name}/{func_name}.sh\033[0m"
        )
    return returncode[0]


def write_completed_function(func_name):
    with open(completed_functions_file, "a") as f:
        f.write(func_name + "\n")


def delete_completed_functions():
    if os.path.exists(completed_functions_file):
        os.remove(completed_functions_file)


def load_completed_functions():
    completed_functions = []
    if os.path.exists(completed_functions_file):
        with open(completed_functions_file, "r") as f:
            completed_functions = f.read().splitlines()
    return completed_functions


def sudo_users():
    global exit_flag
    completed_functions = load_completed_functions()
    for func_name, (func_info, contains_exit) in function_info.items():
        print()
        if func_name in completed_functions:
            print(f"{func_name}: Already completed. Skipping...")
            print()
            continue
        create_function(func_name, func_info, contains_exit)
        if contains_exit:
            exit_code = run(func_name, notification=f"{func_name}: ")
            exit_flag = False
            if exit_code != 0:
                sys.exit(exit_code)
        else:
            returncode = [None]
            globals()[func_name](returncode)
            if returncode[0] == 0:
                print(f"\r\033[32m{func_name}: Done\033[0m")
            else:
                print(
                    f"\r\033[31m{func_name}: Error, please see in {logs_folder_path}/{func_name}.log and {current_dir}/{func_name}/{func_name}.sh\033[0m"
                )
                sys.exit(returncode[0])
        write_completed_function(func_name)
    delete_completed_functions()


def normal_users():
    global exit_flag
    create_function("custom_users", "custom_users/custom_users.sh", True)
    exit_code = run("custom_users", notification=f"custom_users: ")
    exit_flag = False
    if exit_code != 0:
        sys.exit(exit_code)


def check_sudo_privilege():
    try:
        subprocess.check_output("sudo -v", shell=True, stderr=subprocess.STDOUT)
        return True
    except subprocess.CalledProcessError:
        return False


def main():
    if check_sudo_privilege():
        sudo_users()
    else:
        normal_users()
    if os.path.exists(logs_folder_path):
        shutil.rmtree(logs_folder_path)

    delete_completed_functions()


main()
