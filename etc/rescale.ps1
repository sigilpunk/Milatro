# $path = "C:\Users\matcha\AppData\Roaming\Balatro\Mods\Milatro\assets\1x\Jokers.png"
param (
    [Parameter(Mandatory)]
    [String]$Path,

    [Parameter(Mandatory)]
    [ValidateSet(2, 0.5)]
    [Float]$Scale
)
add-type -AssemblyName System.Drawing
$Image = New-Object System.Drawing.Bitmap $Path
if($Scale -eq 2){
    $ffmpegScale = "$($($Image.Width)*2):$($($Image.Height)*2)"
} else {
    $ffmpegScale = "$([math]::Round($($Image.Width)/2)):$([math]::Round($($Image.Height)/2))"
}
$Destination = [String]($Path | Get-Item | Select-Object -Exp Directory | Get-Item | Select-Object -Exp Parent)
if($Scale -eq 2){
    $Destination += "\2x\"
} else {
    $Destination += "\1x\"
}
$Destination += [String]((Get-Item $Path).Basename) + [String]((Get-Item $Path).Extension)
Write-Output $Destination
ffmpeg -i $Path -vf scale=$ffmpegScale $Destination
$Image.Dispose()