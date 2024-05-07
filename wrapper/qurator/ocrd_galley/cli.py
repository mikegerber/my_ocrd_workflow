import os
import subprocess
import sys
import colorama
from pathlib import Path
from termcolor import colored

from .processor_images import processor_images


LOG_LEVEL = os.environ.get("LOG_LEVEL", "INFO")

# xdg-user-dirs is only available under Python 3.10+ etc. pp. → it is simpler
# to just roll it on our own.
XDG_CONFIG_HOME = os.environ.get("XDG_CONFIG_HOME", Path.home() / ".config")
XDG_DATA_HOME = os.environ.get("XDG_DATA_HOME", Path.home() / ".local" / "share")
XDG_CACHE_HOME = os.environ.get("XDG_CACHE_HOME", Path.home() / ".cache")

# ocrd_tesserocr
TESSDATA_PREFIX = XDG_DATA_HOME / "ocrd-resources" / "ocrd-tesserocr-recognize"

def main():
    colorama.init()

    argv = sys.argv.copy()
    argv[0] = os.path.basename(argv[0])


    # If we're running ocrd resmgr download we need to run the correct subimage.
    if argv[:3] == ["ocrd", "resmgr", "download"] or \
       argv[:3] == ["ocrd", "resmgr", "list-available"]:
        # Default to the base image
        processor_image = processor_images[argv[0]]
        # But look for a match of the executable
        for x in argv[3:]:
            if x in processor_images:
                processor_image = processor_images[x]
                break
    else:
        processor_image = processor_images[argv[0]]

    docker_image = processor_image

    if docker_image != "ocrd/all:maximum":
        print(colored(f"Using {docker_image}", 'red'))
    docker_run(argv, docker_image)


def docker_run(argv, docker_image):
    docker_run_options = []
    docker_run_options.extend(["--rm", "-t"])
    docker_run_options.extend(["--mount", "type=bind,src=%s,target=/data" % os.getcwd()])
    docker_run_options.extend(["--mount", "type=tmpfs,target=/tmp"])
    docker_run_options.extend(["--user", "%s:%s" % (os.getuid(), os.getgid())])
    docker_run_options.extend(["-e", "LOG_LEVEL=%s" % LOG_LEVEL])
    docker_run_options.extend(["-e", "_OCRD_COMPLETE"])

    # home directory
    docker_run_options.extend(["-e", "HOME=%s" % Path.home()])

    # .config
    docker_run_options.extend(["-e", "XDG_CONFIG_HOME=%s" % XDG_CONFIG_HOME])
    docker_run_options.extend(["--mount", "type=bind,src=%s,target=%s" %
        (XDG_CONFIG_HOME, XDG_CONFIG_HOME)])
    # .local/share
    docker_run_options.extend(["-e", "XDG_DATA_HOME=%s" % XDG_DATA_HOME])
    docker_run_options.extend(["--mount", "type=bind,src=%s,target=%s" %
        (XDG_DATA_HOME, XDG_DATA_HOME)])
    # .cache
    docker_run_options.extend(["-e", "XDG_CACHE_HOME=%s" % XDG_CACHE_HOME])
    docker_run_options.extend(["--mount", "type=bind,src=%s,target=%s" %
        (XDG_CACHE_HOME, XDG_CACHE_HOME)])
    # .huggingface
    os.makedirs(Path.home() / ".huggingface", exist_ok=True)
    docker_run_options.extend(["--mount", "type=bind,src=%s,target=%s" %
        (Path.home() / ".huggingface", Path("/root") / ".huggingface")])

    # ocrd_tesserocr
    docker_run_options.extend(["-e", "TESSDATA_PREFIX=%s" % TESSDATA_PREFIX])

    # JAVA_TOOL_OPTIONS is used for Java proxy settings
    if os.environ.get("JAVA_TOOL_OPTIONS"):
        docker_run_options.extend(["-e", "JAVA_TOOL_OPTIONS"])

    # The containers currently need to run privileged to allow it to read from e.g.
    # /home on SELinux secured systems such as Fedora. We might want to use udica
    # instead in the future.
    docker_run_options.extend(["--privileged=true"])

    docker_run_options.extend([docker_image])
    docker_run_options.extend(argv)

    docker_run_command = ["docker", "run"] + docker_run_options
    c = subprocess.run(docker_run_command)
    sys.exit(c.returncode)


if __name__ == "__main__":
    main()
