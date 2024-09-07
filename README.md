# Docker Images

I was inspired by **cdrx/pyinstaller-linux** - I like the idea of using a docker
container based on CentOS 7 for building python programs using Pyinstaller. Only
problem with cdrx (and the fork by Barracuda, fydeinc/pyinstaller) is that
they're using openssl version 1.0.2, which won't work for my use case. I need a
newer version of openssl so that when I `import urllib3` as a part of
`import requests` the program doesn't crash.

So I built my own mess of a container based on that but with openssl 1.1.1. The
dockerfile for that is in pyinstaller/.

## Usage

I'm using the entrypoint from Barracuda (with a few tweaks). So you can run:

```bash
docker run -v "$(pwd):/src/" -e "PLATFORM=linux" -e "SHELL_CMDS=pip install -e
/src" kkatfish/pyinstaller:latest "my_script.py" -n "myprogram"
```

This will build your PyInstaller project into `dist/linux`. A .spec file will
automatically be generated if one doesn't already exist. The resulting program
will be named by `-n "myprogram"`

For use in a CI/CD workflow, try this:

```yaml
- name: Compile program with kkatfish/pyinstaller
  uses: addnab/docker-run-action@v3
  with:
    image: kkatfish/pyinstaller:1.0.0
    options: --volumes-from=${{ env.JOB_CONTAINER_NAME }}
    run: |
      export PLATFORMS=linux
      export SRCDIR=/workspace/<gh user>/<gh repo>
      export SHELL_CMDS="<your commands here>"
      /entrypoint.sh "script.py" -n myscript
```

## License

MIT
