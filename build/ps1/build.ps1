$changelogFile = "changelogs.md"
$changelogContent = Get-Content -Path $changelogFile -Raw
$versionHeader = "## $version"
$nextVersionHeader = "## "
$changelog = $changelogContent -split $versionHeader, 2 | Select-Object -Last 1
$changelog = $changelog -split $nextVersionHeader, 2 | Select-Object -First 1