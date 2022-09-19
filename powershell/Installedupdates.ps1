Get-HotFix |

Where {

    $_.InstalledOn -gt "07/01/2019" -AND $_.InstalledOn -lt "09/01/2019" } |

    sort InstalledOn | Out-File $HOME\desktop\installedupdates.txt