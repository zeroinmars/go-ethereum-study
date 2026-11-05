# Run the official Linux Lighthouse binary through the existing Ubuntu WSL.
& wsl.exe -d Ubuntu-22.04 --cd $PSScriptRoot --exec ./.local/lighthouse/lighthouse @args
exit $LASTEXITCODE
