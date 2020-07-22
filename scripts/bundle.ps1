# clear dir
Write-Debug "Cleaning build directory";

Remove-Item -Recurse build -Force | Out-Null;

# Setup directories
Write-Debug "Creating directories";

New-Item "build" -Type Directory  | Out-Null;
New-Item "build\server" -Type Directory  | Out-Null;
New-Item "build\overlay" -Type Directory  | Out-Null;
New-Item "build\extension" -Type Directory  | Out-Null;

# Add the server code to the build dir
Write-Debug "Adding server code";

Copy-Item "server\src\*" "build\server" | Out-Null;

# Add deno to the build dir
Write-Debug "Adding deno executable";

$denoCmd = Get-Command "deno";
Copy-Item $denoCmd.Source "build\$( $denoCmd.Name )" | Out-Null;

# Build the client
Write-Debug "Bundling overlay";

Set-Location client | Out-Null;
npm i --silent > $null;
npm run build > $null;
Set-Location .. | Out-Null;

Write-Debug "Adding overlay";
Copy-Item "client\public\*" "build\overlay" | Out-Null;

# Build the extension
Write-Debug "Bundling extension";

Set-Location extension | Out-Null;
npm i --silent > $null;
npm run build > $null;
Set-Location .. | Out-Null;

Write-Debug "Adding extension";
Copy-Item "extension\dist\build\*" "build\extension" | Out-Null;

# Copy the env-vars
Write-Debug "Adding env vars";

Copy-Item ".env.example" "build\.env" | Out-Null;

Copy-Item "README.md" "build\README.md" | Out-Null;

# Copy scripts
Write-Debug "Adding scripts";

Copy-Item "scripts\final\*" "build" | Out-Null;

Write-Output "Copied";

Write-Output "Compressing";

$buildName = "build-$(git rev-parse --abbrev-ref HEAD)-$(git rev-parse --short HEAD)";

# Compress
Compress-Archive "build\*" "build\$buildName.zip";

Write-Output "Ceaning up";
# Remove everything else
Get-ChildItem "build" | Where-Object {-not $_.Name.Equals("$buildName.zip")} | Remove-Item -Recurse | Out-Null;