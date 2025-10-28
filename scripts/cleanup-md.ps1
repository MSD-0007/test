$files = Get-ChildItem -Path . -Filter *.md -Recurse
foreach ($f in $files) {
    if ($f.Name -ne 'README.md') {
        Write-Host "Removing: $($f.FullName)"
        Remove-Item -Force $f.FullName
    }
}
