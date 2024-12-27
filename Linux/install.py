from variables import *

function_info = {
    # "wifi": ("wifi/wifi.sh", True),
    # "create_users": ("create_users/create_users.sh", False),
    "system": ("system/system.sh", True),
    # "softwares": ("softwares/softwares.sh", True),
    # "bootloader": ("bootloader/bootloader.sh", True),
    # "themes": ("themes/themes.sh", True),
    # "icons": ("icons/icons.sh", True),
    # "cursors": ("cursors/cursors.sh", True),
    # "fonts": ("fonts/fonts.sh", True),
    # "gdms": ("gdms/gdms.sh", True),
    # "custom_users": ("custom_users/custom_users.sh", True),
    # "clean_data": ("clean_data/clean_data.sh", True),
}

def main():
    if check_sudo_privilege():
        sudo_users()
    else:
        normal_users()
    if os.path.exists(logs_folder_path):
        shutil.rmtree(logs_folder_path)

    delete_completed_functions()


main()
