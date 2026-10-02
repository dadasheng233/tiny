param(
    [Parameter(Position = 0)]
    [ValidateSet("build", "check", "run", "clean", "shell")]
    [string]$Action = "build"
)

$image = "tinyos-toolchain"
$workspace = (Get-Location).Path

if ($Action -eq "clean") {
    if (Test-Path (Join-Path $workspace "build")) {
        Remove-Item -Recurse -Force (Join-Path $workspace "build")
    }
    exit $LASTEXITCODE
}

if (-not (docker image inspect $image 2>$null)) {
    docker build -t $image .
    if ($LASTEXITCODE -ne 0) { exit $LASTEXITCODE }
}

if ($Action -eq "shell") {
    docker run --rm -it --entrypoint bash -v "${workspace}:/workspace" $image
} elseif ($Action -eq "build") {
    docker run --rm -v "${workspace}:/workspace" $image
} else {
    docker run --rm -it -v "${workspace}:/workspace" $image $Action
}

exit $LASTEXITCODE